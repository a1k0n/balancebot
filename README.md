# balancebot
Small DC-motor based balancing robot.

![IMG_20190731_091730](https://user-images.githubusercontent.com/46170/62229378-61ce5080-b374-11e9-9bae-903f8e7f7537.jpg)

Parts:
 - 130-size DC motor
 - Digispark
 - Digispark motor shield
 - Adaboost LiPo battery charger
 - LiPo battery
 - MPU-9250 accelerometer/gyro/compass (compass not used, MPU-6050 would also work)
 - 3D printed frame, wheels+axle+spur gear, pinion gear
 
This is all stuff I had on hand; if I were to design it around parts which can be bought new, I would do
it differently. There are better/cheaper microcontroller boards w/ integrated charging, ARM CPU, more IO for example.

It does not have any sort of wheel encoder, which means it doesn't know where its own CG is, or how far from the
center position it has travelled. It tries to guess this by summing up all motor outputs over time, and adds this
as a small bias to the desired upright angle which causes it to gently roll back and forth which doubles as a "demo".
The CG bias is just hardcoded; if I move the battery it'll have to be adjusted manually.

There are still issues with the I2C bus glitching from the motor's activity which causes the Arduino Wire
library to get stuck in an infinite loop. I would use SPI instead of I2C for the MPU-9250 except the motor
shield is using the MOSI pin.
