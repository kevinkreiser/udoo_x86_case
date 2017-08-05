hs_height = 25;  //set to 25 or more to fit the stock heat sink, dont go less than 13
hs_offset = 3;    //it sits on top of the socket
ssd_depth = 10;   //set to 10 or more to fit a drive in the bottom
fan_depth = 10;  //set to 10 or 20 for case fans, width/height is echo'd
standoff = 9;    //the height of the standoffs, you need at least 9
show_mounts = true;
flatten = false;

//this is the height of the case not including the tray and lid 
base = standoff + hs_offset + hs_height + ssd_depth;

echo(str("Case dimensions: <b>", 134+ 2*fan_depth,"mmX91mmX",base + 6,"mm"));

module fcylinder(h,d,fn) {
  if(flatten)
    circle(d=d, $fn=fn);
  else
    cylinder(h=h, d=d, $fn=fn);   
}

module fcube(dimensions) {
  if(flatten)
    square([dimensions[0], dimensions[1]]);
  else
    cube(dimensions);
}

//theres a bug in this when the dimensions are unbalanced
module rounded_rect(dimensions) {
  hull() {
    translate([dimensions[1],0,0]) fcylinder(h=dimensions[2], d=dimensions[1], fn=100);
    translate([dimensions[0] - dimensions[1],0,0]) fcylinder(h=dimensions[2], d=dimensions[1], fn=100);
  }
}

module udoo_board() {
  //the board  
  color([0,.5,.1,1]) import("./udoo_x86.stl", convexity=10);
  //the heatsink needs at least 25mm
  if(hs_height >= 25) translate([25.5,34,hs_offset]) color([.6,.1,.1,.5]) cube([29,29,25]);
  //an ssd needs at least 10mm
  if(ssd_depth >= 10) translate([10,7.5,-10 - ssd_depth]) color([.6,.1,.1,.5]) cube([101,70,10]);
  //push pull fans
  fan_size = floor((base) / 5.0) * 5;
  if(fan_depth > 0) {
    echo(str("Case fans dimensions: <b>", fan_size, "mmX", fan_size, "mmX", fan_depth, "mm</b>"));
    translate([-4 - fan_depth,42.5-(fan_size/2),-standoff - ssd_depth]) color([.6,.1,.1,.5]) cube([fan_depth,fan_size,fan_size]);
    translate([134 - fan_depth,42.5-(fan_size/2),-standoff - ssd_depth]) color([.6,.1,.1,.5]) cube([fan_depth,fan_size,fan_size]);
  }
}

module case_tray() {
  translate([0, 0, -standoff - 3 - ssd_depth]) {
    union() {
      //bottom
      color([0,.25,1,.5]) translate([-4 - fan_depth,0,0]) fcube([134 + 2*fan_depth,85,3]);
      //standoffs
      if(show_mounts) color([1,1,1,.5]) translate([0,0,3]) {
        translate([-1 - fan_depth,0,0]) cube([11 + fan_depth,7,standoff + ssd_depth]);
        translate([-1- fan_depth,78,0]) cube([11 + fan_depth,7,standoff + ssd_depth]);
        translate([116,0,0]) cube([11 + fan_depth,8,standoff + ssd_depth]);
        translate([116,77,0]) cube([11 + fan_depth,8,standoff + ssd_depth]);
      }
    }
  }
}

module case_lid() {
  translate([0, 0, hs_offset + hs_height]) {
    difference(){
      union() {
        //top
        color([0,.25,1,.5]) translate([-4 - fan_depth,0,0]) fcube([134+ 2*fan_depth,85,3]);
        //mounts
        if(show_mounts) color([1,1,1,.5]) translate([0,0,-8]) {
          translate([-1 - fan_depth,0,0]) fcube([5 + fan_depth,7,8]);
          translate([-1 - fan_depth,78,0]) fcube([5 + fan_depth,7,8]);
          translate([122,0,0]) fcube([5 + fan_depth,8,8]);
          translate([122,77,0]) fcube([5 + fan_depth,8,8]);
        }
      }
      //cutout for hsf
      color([0,.25,1,.5]) {
        for (i =[0:6]) {
          translate([18,i * 7 + 25,flatten?0:-1]) rounded_rect([45,3,5]);
        }
        if(hs_height < 25) {
          for (i =[0:8]) {
            translate([2,i * 7 + 18,flatten?0:-1]) rounded_rect([38,3,5]);
          }
        }
      }
    }
  }
}

module case_sides() {
  color([1,1,.25,.5]) {
    translate([-1 - fan_depth,0,-standoff-ssd_depth]) rotate([0,flatten?0:-90,0]) difference() {
      fcube([base,85,3]);
      for (i =[0:9]) translate([2,11 + i * 7,flatten?0:-1]) rounded_rect([base-4,3,5]);
    }
    translate([130 + fan_depth,0,-standoff-ssd_depth]) rotate([0,flatten?0:-90,0]) difference() {
      fcube([base,85,3]);
      for (i =[0:9]) translate([2,11 + i * 7,flatten?0:-1]) rounded_rect([base-4,3,5]);
    }
  }
}

module case_panels() {
  color([1,.25,1,.5]) {
    translate([-4-fan_depth,88,-standoff-ssd_depth-3]) rotate([flatten?0:90,0,0]) difference() {
      fcube([134+fan_depth*2,6 + base,3]);
      translate([14,-1,0]) union() {
        //sdcard
        translate([101,11 + ssd_depth,flatten?0:-1]) fcube([14,2,5]);
        //audio in/out jack
        translate([83.75,14.5 + ssd_depth,flatten?0:-1]) fcube([7,5,5]);
        //usb 3.0 ports
        translate([66.75,15 + ssd_depth,flatten?0:-1]) fcube([14.75,7.25,5]);
        translate([49,15 + ssd_depth,flatten?0:-1]) fcube([14.75,7.25,5]);
        //power button
        translate([17.5,14.5 + ssd_depth,flatten?0:-1]) fcube([4,1.75,5]);
        //ir receiver
        translate([9.5,14.5 + ssd_depth,flatten?0:-1]) fcube([7,3.25,5]);
      }
    }
    translate([-4-fan_depth,0,-standoff-ssd_depth-3]) rotate([flatten?0:90,0,0]) difference() {
      fcube([134+fan_depth*2,6 + base,3]);
      translate([14,-1,0]) union() {
        //dc in
        translate([11.75,14.5 + ssd_depth,flatten?0:-1]) fcube([9.5,11.25,5]);
        //usb 3.0 port
        translate([24.25,15 + ssd_depth,flatten?0:-1]) fcube([14.75,7.25,5]);
        //ethernet port
        translate([41.5,15 + ssd_depth,flatten?0:-1]) fcube([16.5,14,5]);
        //hdmi
        translate([62,15 + ssd_depth,flatten?0:-1]) fcube([15.25,6,5]);
        //mini dp+ ports
        translate([82.75,17.5 + ssd_depth,flatten?0:-1]) fcube([9,6,5]);
        translate([96.75,17.5 + ssd_depth,flatten?0:-1]) fcube([9,6,5]);
      }
    }
  }
}

translate([-63,-42.5,0]) {
  translate([3,0,0]) udoo_board();
  case_tray();
  case_lid();
  case_sides();
  case_panels();
}
