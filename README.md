# balancebot
Small DC-motor based balancing robot.

![picture of bot standing upright](https://user-images.githubusercontent.com/46170/62229378-61ce5080-b374-11e9-9bae-903f8e7f7537.jpg)

[![BalanceBot video](http://img.youtube.com/vi/YxdkzbH74xc/0.jpg)](http://www.youtube.com/watch?v=YxdkzbH74xc "BalanceBot in motion")

Parts:
 - 130-size DC motor (w/ capacitors soldered between wires and case -- this prevents catastrophic amounts of noise on the power supply rail!)
 - Digispark
 - Digispark motor shield
 - Adaboost LiPo battery charger
 - LiPo battery
 - MPU-9250 accelerometer/gyro/compass (compass not used, MPU-6050 would also work)
 - 3D printed frame, wheels+axle+spur gear, pinion gear
 - rubber bands for tires
 - M2.5 screws for the PCBs and servo tape to hold on the battery / power switch

![3d parts](https://user-images.githubusercontent.com/46170/62230263-51b77080-b376-11e9-8613-e106cb508b14.jpg)

This is all stuff I had on hand; if I were to design it around parts which can be bought new, I would do
it differently. There are better/cheaper microcontroller boards w/ integrated charging, ARM CPU, more IO for example.

It does not have any sort of wheel encoder, which means it doesn't know where its own CG is, or how far from the
center position it has travelled. It tries to guess this by summing up all motor outputs over time, and adds this
as a small bias to the desired upright angle which causes it to gently roll back and forth which doubles as a "demo".
The CG bias is just hardcoded; if I move the battery it'll have to be adjusted manually.

There are still issues with the I2C bus glitching from the motor's activity which causes the Arduino Wire
library to get stuck in an infinite loop. I would use SPI instead of I2C for the MPU-9250 except the motor
shield is using the MOSI pin.
