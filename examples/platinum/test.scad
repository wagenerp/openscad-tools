include <all.scad>;
include <test.scad.pp>;
$mt=4;
$bw=0.2; // beam width / cut loss

$plate_finger_length=8;
$plate_finger_overlap=0.2;
$plate_finger_lip=4;
$plate_finger_grip=0.1;
$plate_slit_grip=0.1;

module g_intersect() {
}

module g_difference() {
  translate([-1,-5,-1])
  cube([20,2,20]);
  translate([30,-1,30]) cube([10,102,10]);
}


if(0) {
gplate(o=-4, ez=[0,-1,0],ex=[1,0,0]) {
  union() { // intersection 2d
  circle(d=90);
  }
  union() { // difference 2d
    translate([20,0]) square([200,10]);
  }
  union() { // intersection 3d
  }
  union() { // difference 3d
  }
}


for(y=[20,40,60,80])
  gplate([100,100],p=[0,y,0],ez=[0,-1,0],ex=[1,0,0]);

color([1,0,0,0.4])
g_difference();
color([0,0,1,0.4])
g_intersect();
}

plates=[
  [m4_identity(),[100,100],[0,1,0,0.4]],
  [m4_transform_arb(p=[0,0,100-$mt]),[100,100],[0,1,0,0.4]],
  [m4_transform_arb(ex=[1,0,0],ez=[0,-1,0],p=[10,20,0]),[80,100],[0,0,1,0.4]],
  [m4_transform_arb(ex=[1,0,0],ez=[0,-1,0],p=[10,50,0]),[80,100],[0,0,1,0.4]],
  [m4_transform_arb(ex=[0,1,1],ez=[1,0,0],p=[60,10,-30]),[100,100],[1,0,0,0.4]]
];

module plates(parade=false) {

for(i1=[0:1:len(plates)-1]) {
  p1=plates[i1];
  m1=p1[0];
  s1=p1[1];
  color(p1[2])
    gplate(transform=p1[0],s=p1[1],ident=str("plate",i1),parade=parade,dupe=parade);
}
}



plates();
