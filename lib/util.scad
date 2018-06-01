include <multipart.scad>;

function bezier4(f,p0,p1,p2,p3) = 
  pow(1-f,3)*p0 + 
  3*pow(1-f,2)*f*p1 +
  3*(1-f)*f*f*p2 +
  f*f*f*p3;

module mirrordup(v) {
  children();
  mirror(v=v) children();
}

module ifhull(cond) {
  if(cond) hull() children();
  else children();
}

module triad(s=1,v=1,a=1,l=10) {
  module arrow() {
    mirrordup(v=[0,0,1]) cylinder(d1=0,d2=1,h=l,$fn=16);
    translate([0,0,l]) cylinder(d1=1,d2=0,h=2,$fn=16);
  }


  part(ignore=true)
  scale(s) {
    color([v,0,0,a]) rotate([0,90,0]) arrow();
    color([0,v,0,a]) rotate([-90,0,0]) arrow();
    color([0,0,v,a]) arrow();
  }
}

function subvec3(v) = [v[0],v[1],v[2]];
function subvec2(v) = [v[0],v[1]];