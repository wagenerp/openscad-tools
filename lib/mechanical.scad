
include <transform.scad>;


module m3_shaft(
  height,nutcase=false,top=false,bottom=false,nutchute=false,
  ez=[0,0,1],ex=[1,0,0]) {

  nutcase_height=(nutchute==false) ? 3.2 : 3.8;

  transform_ezex(ez=ez,ex=ex) {
    cylinder(d=3.8,h=height,$fs=0.1,$fa=1);
    if (nutcase!=false)
      translate([0,0,nutcase]) hull() {
        cylinder(d=6.6,h=nutcase_height,$fa=60);
        if (nutchute!=false) {
          translate([nutchute,0,0]) 
            cylinder(d=6.6,h=nutcase_height,$fa=60);
        }
      }
    if (top) {
      translate([0,0,height])
        cylinder(d=6.4,h=3.2);
    }
    if (bottom) {
      translate([0,0,0])
        cylinder(d=6.4,h=3.2);
    }
  }
}


module m25_shaft(
  height,nutcase=false,top=false,bottom=false,nutchute=false,
  ez=[0,0,1],ex=[1,0,0]) {

  nutcase_height=(nutchute==false) ? 2.2 : 2.4;

  transform_ezex(ez=ez,ex=ex) {
    cylinder(d=3.8,h=height,$fs=0.1,$fa=1);
    if (nutcase!=false)
      translate([0,0,nutcase]) hull() {
        cylinder(d=5.9,h=nutcase_height,$fa=60);
        if (nutchute!=false) {
          translate([nutchute,0,0]) 
            cylinder(d=5.9,h=nutcase_height,$fa=60);
        }
      }
    if (top) {
      translate([0,0,height])
        cylinder(d=5.6,h=3.2);
    }
    if (bottom) {
      translate([0,0,0])
        cylinder(d=5.6,h=3.2);
    }
  }
}
