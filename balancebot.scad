$fs = 0.1;

use <pd-gears.scad>;

// explode assembly apart for 3d printing preparation
apart = 20;

pitch = 2;
n1 = 11;
n2 = 80;


motor_axle_spacing = pitch_radius(pitch, n1) + pitch_radius(pitch, n2) + 0.25;

module wheel() {
  union() {
    difference() {
      cylinder(h=5, d=60, $fn=100);
      translate([0, 0, -0.1]) cylinder(h=5.2, d=45, $fn=100);
    }
    cylinder(h=10, d=10);
    for (i = [0:5]) {
      rotate([0, 0, i*360/5]) translate([0, -2, 0]) cube([25, 4, 3]);
    }
  }
}

buildthick = 2;
buildplane_ang = acos((7.5 + buildthick - 5.5) / motor_axle_spacing);

module motormount() {
  wall = 1.2;  // 3x nozzle
  translate([0, 0, 10])
    difference() {
      cylinder(h=19, d=20+2*wall);
      translate([0, 0, -0.1]) cylinder(h=19.2, d=20);
      translate([-11, -7.5-8, -0.1]) cube([22, 10, 19.2]);
      translate([-11, 7.5, -0.1]) cube([22, 10, 19.2]);
    }
  translate([-2.5, 7.5-3, 10-wall]) cube([5, 4, wall]);
  translate([-8, 7.5, 10]) cube([16, buildthick, 25]);
  translate([-2.5, 7.5-3, 35]) cube([5, 4, wall]);
}

module pcbmounts(tail) {
  offset = 3+buildthick;
  d = 5;
  screw_drill = 2.5;

  %translate([0, -36/2, offset]) cube([23, 36, 1]);
  %translate([25, -26/2, offset]) cube([15.5, 26, 1]);
  %translate([44, -19/2, 0]) cube([17, 19, 1]);
  %translate([44, -12.3/2, 0]) cube([27, 12.3, 1]);
  %translate([44, -18/2, 0]) cube([2.54, 15.77, 9]);

  mountpts = [
    [2.5, -36/2+2.5],
    [23-2.5, -36/2+2.5],
    [25+2.5, 20.25/2],
    [25+2.5, -20.25/2],
  ];
  difference() {
    union() {
      linear_extrude(buildthick) hull() {
        for (m = mountpts) {
          translate(m) circle(d=d);
        }
        translate(tail) circle(d=20);
        translate([44+2.54/2, -19/2, 0]) circle(d=5);
        translate([44+2.54/2, 19/2, 0]) circle(d=5);
      }
      for (m = mountpts) {
        translate(m) cylinder(d=d, h=offset);
      }
      linear_extrude(8) hull() {
        translate([44+2.54/2, -19/2, 0]) circle(d=5);
        translate([44+2.54/2, 19/2, 0]) circle(d=5);
      }
    }
    for (m = mountpts) {
      translate([m[0], m[1], -0.1]) cylinder(d=screw_drill, h=offset*2);
    }
    linear_extrude(9) hull() {
      translate([44+2.54/2, -19/2, 0-0.1]) circle(d=3);
      translate([44+2.54/2, 19/2, 0-0.1]) circle(d=3);
    }
    scale([0.8, 0.7, 1.5]) translate([0,0,-0.1]) linear_extrude(buildthick) hull() {
      for (m = mountpts) {
        translate(m) circle(d=d);
      }
      translate(tail) circle(d=20);
    }
    translate([26, 0, 0]) scale([0.7, 0.5, 1.5]) translate([0,0,-0.1]) linear_extrude(buildthick) hull() {
      translate([2.5, 20.25/2]) circle(d=d);
      translate([2.5, -20.25/2]) circle(d=d);
      translate([44+2.54/2-25, -19/2, 0]) circle(d=5);
      translate([44+2.54/2-25, 19/2, 0]) circle(d=5);
    }
  }
}

union() {
  translate([apart, 0, 5.5]) {
    rotate([0, 0, buildplane_ang]) {
      motormount();
    }
    rotate([0, 0, 180/n1]) gear(pitch, n1, 5, 2.2, twist=0);
  }
  translate([apart, 0, 0]) rotate([0, 0, buildplane_ang-90]) rotate([-90, 0, 0]) rotate([0, 90, 0]) {
    translate([20, -55/2, -7.5-buildthick]) pcbmounts([-15, 0, 0]);
  }

  translate([0, motor_axle_spacing + apart, 5]) {
    gear(pitch, n2, 4, 45, twist=0, $fn=100);
    translate([0, 0, -5]) difference() {
      wheel();
      difference() {
        cylinder(h=10.1, d=5.1);
        translate([-2.5, 1, 0]) cube([5, 5, 5]);
      }
    }
  }

  translate([0, motor_axle_spacing + apart, 55 + apart]) rotate([0, 180, 0]) {
    wheel();
    difference() {
      cylinder(h=55, d=5.0);
      translate([-2.5, 1, 50]) cube([5, 5, 5]);
    }
  }


  // beam connecting motor to axle, wheel hubs
  r=2.5;
  y0 = 7.5 + buildthick - r;
  difference() {
    union() {
      hull() {
        translate([apart, 0, 0]) rotate([0, 0, buildplane_ang]) {
          translate([0, y0, 55/2 - 8]) sphere(r=r);
          translate([motor_axle_spacing, y0, 10.5+2.5]) sphere(r=r);
        }
      }
      hull() {
        translate([apart, 0, 0]) rotate([0, 0, buildplane_ang]) {
          translate([0, y0, 55/2 + 1]) sphere(r=r);
          translate([motor_axle_spacing, y0, 55-10.5-2.5]) sphere(r=r);
        }
      }
      translate([apart, motor_axle_spacing, 10.3]) cylinder(h=5, d=11);
      translate([apart, motor_axle_spacing, 55-10.3-5]) cylinder(h=5, d=11);
    }
    translate([apart, 0, 0]) cylinder(h=100, d=20+2*1.2-0.1);
    translate([apart, motor_axle_spacing, 0]) cylinder(h=100, d=5.3);
  }
}

*pcbmounts([-15,0,0]);
