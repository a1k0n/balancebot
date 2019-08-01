#include <Wire.h>

static const int MotorDir = 5;
static const int MotorSpeed = 1;

uint8_t i2caddr = 0x68;

const uint8_t PROGMEM mpu9250conf[] = {
  107, 0,
  107, 1,
  108, 0,
  55, 0x32,  // bypass_en for magnetometer
  25, 0x00,  // samplerate divisor = 0
  26, 0x00,  // dlpf_cfg = 0
  27, 0x10,  // gyro_conf: gyro_fs_sel = 1000dps
  28, 0x00,  // +-2g full scale
  29, 0x05,  // accel dlpf = 0 (218Hz BW)
};

void setup() {
  // put your setup code here, to run once:
  pinMode(MotorDir, OUTPUT);   
  pinMode(MotorSpeed, OUTPUT);
  Wire.begin();

  // hold MPU-9150 in reset for 10ms
  Wire.beginTransmission(i2caddr);
  Wire.write(107);
  Wire.write(0x80);
  Wire.endTransmission();
  delay(10);

  for (uint8_t i = 0; i < sizeof(mpu9250conf); i += 2) {
    Wire.beginTransmission(i2caddr);
    Wire.write(pgm_read_byte(mpu9250conf+i));
    Wire.write(pgm_read_byte(mpu9250conf+i+1));
    Wire.endTransmission();
  }
  
  //DigiUSB.begin();
  //DigiUSB.println(F("starting up!"));
}

int16_t readreg16(uint8_t addr) {
  Wire.beginTransmission(i2caddr);
  Wire.write(addr);
  if (Wire.endTransmission(false) != 0) {
    return 0;
  }
  if (Wire.requestFrom(i2caddr, 2) != 0) {
    // reset the bus?
    Wire.begin();
    return 0;
  }
  int16_t res;
  res = Wire.read() << 8;
  if (!Wire.available()) return 0;
  res += Wire.read();
  while (Wire.available()) {
    Wire.read();
  }
  return res;
}

int16_t readgy() {
  return readreg16(0x45);
}

int16_t readaz() {
  return readreg16(0x3f);
}

void loop() {
  // use complementary filter to compute angle
  int32_t angle = 0;
  int32_t xsum = 0;
  int32_t u = 0, dxsum = 0;
  uint16_t n_ = 0;
  for (;;) {
    unsigned long t0 = millis();
    int16_t az = readaz();  // +- full scale of 2g; 16384 = 1g
    int16_t gy = readgy();  // 1000dps full scale; 32768 = 1000 deg/s = ~17.45 rad/s

    // az = 1g * sin(theta) = 16384 * sin(theta)
    // gy = dtheta/dt * 1877.4681030846816
    // dt = 0.01s (100Hz main loop)
    
    angle += gy;  // angle = 187746.81030846816 * theta (rad)
    angle -= angle >> 4;  // leaky integrator (high pass filtered, tau=0.15s)
    angle -= az >> 1;  // ~ 2048*theta (radians), low-pass filtered az (ideally, 2933*theta)

    // don't attempt to drive if we're already tipped over
    if (angle > -74000 && angle < 74000) {
      int32_t anglecg = 9000 - (xsum<<2) + (dxsum << 4);
      u = ((angle - anglecg) >> 5) + (gy >> 5);
      if (u > 255) u = 255;
      if (u < -255) u = -255;

      dxsum = u - (xsum >> 7);
      xsum += dxsum;
      
      uint16_t sp = (u < 0 ? -u : u);
      digitalWrite(MotorDir, u<0 ? 0 : 1);
      analogWrite(MotorSpeed, sp);
    } else {
      analogWrite(MotorSpeed, 0);
      xsum = 0;
    }

    // program loop 100Hz
    while (millis() - t0 < 10) {
      //DigiUSB.refresh();
    }
  }
}
