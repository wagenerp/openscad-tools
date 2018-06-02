include <all.scad>;
include <hddcase.scad.pp>;


$mt=4;
$bw=0.2; // beam width / cut loss

$plate_finger_length=8;
$plate_finger_overlap=0.2;
$plate_finger_lip=4;
$plate_finger_grip=0.1;
$plate_slit_grip=0.1;

clearance=0.2;

hdd_width=101.6;
hdd_length=147;
hdd_height=26;

height=80;

lid_fore=20;
lid_aft=20;
module hdd() {
  screw_z=6.5;
  screw_y=[28.5,42+28.5,57.5+42+28.5];
  screw_diam=3.3;
  screw_protrusion=20;
  cube([hdd_width,hdd_length,hdd_height]);
  for(y=screw_y)
    translate([-screw_protrusion,y,screw_z]) 
      rotate([0,90,0]) cylinder(d=screw_diam,h=hdd_width+screw_protrusion*2,$fn=32);

}

module fan() {
  translate([0,-1,0]) {
    rotate([-90,0,0]) cylinder(d=50,h=2,$fn=128);
    for(sx=[-1,1]) for(sy=[-1,1]) translate([sx,0,sy]*21) rotate([-90,0,0]) cylinder(d=3.4,h=2,$fn=32);
  }
}

module g_difference() {
  for(i=[0,1])
    translate([0,0,((height-hdd_height*2))/3*(i+1)+hdd_height*i])
      hdd();
  translate([25,hdd_length+1,25])
    fan();
  translate([hdd_width-25,hdd_length+1,height-25])
    fan();
}

module g_intersect() {

}


module mod_plates(parade=false) {
  gplate(
    ident="x0",
    yzx=[-lid_fore,-$mt,-$mt-clearance],
    s=[hdd_length+lid_fore+lid_aft,2*$mt+height],
    dupe=parade,parade=parade);
  gplate(
    ident="x1",
    yzx=[-lid_fore,-$mt,hdd_width+clearance],
    s=[hdd_length+lid_fore+lid_aft,2*$mt+height],
    dupe=parade,parade=parade);

  gplate(
    ident="z0",
    xyz=[-clearance-$mt,-$mt-clearance,-$mt],
    s=[clearance*2+hdd_width+$mt*2,hdd_length+$mt*2],
    dupe=parade,parade=parade);
  gplate(
    ident="z1",
    xyz=[-clearance-$mt,-$mt-clearance,height],
    s=[clearance*2+hdd_width+$mt*2,hdd_length+$mt*2],
    dupe=parade,parade=parade);

  gplate(
    ident="y0",
    xzy=[0,-$mt,-clearance-$mt],
    s=[hdd_width,height+$mt*2],
    dupe=parade,parade=parade);
  gplate(
    ident="y1",
    xzy=[-$mt-clearance,-$mt,hdd_length+clearance],
    s=[hdd_width+clearance*2+$mt*2,height+$mt*2],
    dupe=parade,parade=parade);
}


part(ignore=true) {
  color([1,0,0,0.4]) g_difference();
}

mod_plates();
