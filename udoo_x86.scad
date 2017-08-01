hs_offset = 3;    //it sits on top of the socket
hs_height = 25;  //set to 25 or more to fit the heat sink
ssd_depth = 0;   //set to 10 or more to fit a drive in the bottom
fan_depth = 10;  //set to 10 or 20 for case fans, width/height is echo'd

//this is the height of the case not including the tray and lid 
base = 10 + hs_offset + hs_height + ssd_depth;

//theres a bug in this when the dimensions are unbalanced
module rounded_rect(dimensions) {
  hull() {
    translate([dimensions[1],0,0]) cylinder(h=dimensions[2], d=dimensions[1], $fn=100);
    translate([dimensions[0] - dimensions[1],0,0]) cylinder(h=dimensions[2], d=dimensions[1], $fn=100);
  }
}

module udoo_board() {
  //the board  
  color([0,.5,.1,1]) import("./udoo_x86.stl", convexity=10);
  //the heatsink needs at least 25mm
  if(hs_height >= 25)
    translate([25.5,34,hs_offset]) color([.6,.1,.1,.5]) cube([29,29,25]);
  //an ssd needs at least 10mm
  if(ssd_depth >= 10)
    translate([10,7.5,-10 - ssd_depth]) color([.6,.1,.1,.5]) cube([101,70,10]);
  //push pull fans
  fan_size = floor((base) / 5.0) * 5;
  if(fan_depth > 0) {
    echo(str("Case fans dimensions: <b>", fan_size, "mmX", fan_size, "mmX", fan_depth, "mm</b>"));
    translate([-4 - fan_depth,42.5-(fan_size/2),-10 - ssd_depth]) color([.6,.1,.1,.5]) cube([fan_depth,fan_size,fan_size]);
    translate([134 - fan_depth,42.5-(fan_size/2),-10 - ssd_depth]) color([.6,.1,.1,.5]) cube([fan_depth,fan_size,fan_size]);
  }
};

module case_tray() {
  translate([0, 0, -13 - ssd_depth]) {
    union() {
      //bottom
      color([0,.25,1,.5]) translate([-4 - fan_depth,0,0]) cube([134 + 2*fan_depth,85,3]);
      //standoffs
      color([1,1,1,.5]) translate([0,0,3]) {
        translate([-1 - fan_depth,0,0]) cube([11 + fan_depth,7,10 + ssd_depth]);
        translate([-1- fan_depth,78,0]) cube([11 + fan_depth,7,10 + ssd_depth]);
        translate([116,0,0]) cube([11 + fan_depth,8,10 + ssd_depth]);
        translate([116,77,0]) cube([11 + fan_depth,8,10 + ssd_depth]);
      }
    }
  }
}

module case_lid() {
  translate([0, 0, hs_offset + hs_height]) {
    difference(){
      union() {
        //top
        color([0,.25,1,.5]) translate([-4 - fan_depth,0,0]) cube([134+ 2*fan_depth,85,3]);
        //mounts
        color([1,1,1,.5]) translate([0,0,-10]) {
          translate([-1 - fan_depth,0,0]) cube([11 + fan_depth,7,10]);
          translate([-1 - fan_depth,78,0]) cube([11 + fan_depth,7,10]);
          translate([116,0,0]) cube([11 + fan_depth,8,10]);
          translate([116,77,0]) cube([11 + fan_depth,8,10]);
        }
      }
      //cutout for hsf
      color([0,.25,1,.5]) translate([28,33.5,-1]) cube([30,30,0]);
    }
  }
}

module case_sides() {
  translate([0, 0, -10 - ssd_depth]) {
    difference() {
      //the sides
      color([1,1,.25,.5]) union() {
        translate([-4 - fan_depth,0,0]) cube([3,85,base]);
        translate([127 + fan_depth,0,0]) cube([3,85,base]);
      };
      //ventilation holes
      color([1,1,.25,.5]) {
        for (i =[0:6]) {
          translate([-5-fan_depth,18.5 + i * 8,base - 2]) rotate([0,90,0]) rounded_rect([base-4,3,5]);
          translate([126+fan_depth,18.5 + i * 8,base - 2]) rotate([0,90,0]) rounded_rect([base-4,3,5]);
        }
      };
    }
  }
}

module case_panels() {
  translate([0, 0, -13 - ssd_depth]) {
    difference() {
      //thin sides
      color([1,.25,1,.5]) {
        translate([-4-fan_depth,-1,0]) cube([134+fan_depth*2,1,6 + base]);
        translate([-4-fan_depth,85,0]) cube([134+fan_depth*2,1,6 + base]);
      }
      //cut outs
      color([1,.25,1,.5]) {
        //sdcard
        translate([101,84,11 + ssd_depth]) cube([14,3,2]);
        //audio in/out jack
        translate([83.75,84,14.5 + ssd_depth]) cube([7,3,5]);
        //usb 3.0 ports
        translate([66.75,84,15 + ssd_depth]) cube([14.75,3,7.25]);
        translate([49,84,15 + ssd_depth]) cube([14.75,3,7.25]);
        //power button
        translate([17.5,84,14.5 + ssd_depth]) cube([4,3,1.75]);
        //ir receiver
        translate([9.5,84,14.5 + ssd_depth]) cube([7,3,3.25]);
        //dc in
        translate([11.75,-2,14.5 + ssd_depth]) cube([9.5,3,11.25]);
        //usb 3.0 port
        translate([24.25,-2,15 + ssd_depth]) cube([14.75,3,7.25]);
        //ethernet port
        translate([41.5,-2,15 + ssd_depth]) cube([16.5,3,14]);
        //hdmi
        translate([62,-2,15 + ssd_depth]) cube([15.25,3,6]);
        //mini dp+ ports
        translate([82.75,-2,17.5 + ssd_depth]) cube([9,3,6]);
        translate([96.75,-2,17.5 + ssd_depth]) cube([9,3,6]);
      }
    }
  }
}

translate([-60,-42.5,0]) udoo_board();
translate([-63,-42.5,0]) case_tray();
translate([-63,-42.5,0]) case_lid();
translate([-63,-42.5,0]) case_sides();
translate([-63,-42.5,0]) case_panels();
