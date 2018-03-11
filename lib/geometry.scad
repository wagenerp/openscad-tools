
module cccube(v) {
  translate(-0.5*[v[0],v[1],0])
    cube(v);
}

module rcccube(v,r) {
  translate(-0.5*[v[0],v[1],0]+[r,r,0]) 
    minkowski() {
      cylinder(r=r,h=v[2]/2);
      cube([v[0]-r*2,v[1]-r*2,v[2]/2]);
    }
    
}

module rcube(v,r) {
  translate([r,r,0]) 
    minkowski() {
      cylinder(r=r,h=v[2]/2);
      cube([v[0]-r*2,v[1]-r*2,v[2]/2]);
    }
    
}

module ccsquare(v) {
  translate(-0.5*[v[0],v[1],0])
    square(v);
}

module rccsquare(v,r) {
  translate(-0.5*[v[0],v[1],0]+[r,r,0]) 
    minkowski() {
      circle(r=r,h=v[2]);
      square([v[0]-r*2,v[1]-r*2]);
    }
    
}


module rsquare(v,r) {
  hull() {
    for (x=[r,v[0]-r]) for (y=[r,v[1]-r]) 
      translate([x,y]) circle(r=r);
  }
}


module spool_extrude_part(da,dz) {
  hull() {
    children();
    translate([0,0,dz]) rotate([0,0,da])
      children();
  }
}

module spool_extrude(twist,height,steps=500) {
  da=twist/steps;
  dz=height/steps;
  for(i=[0:1:steps]) {
    translate([0,0,dz*i]) rotate([0,0,da*i])
      spool_extrude_part(da,dz) children();
  }
}

module rngon(n,d=undef,r=undef,rc=2) {
  r_outer=(d==undef) ? r : d/2;
  r_ring=r_outer-rc/cos(180/n);

  hull() {
    for(i=[0:1:n-1]) rotate([0,0,360/n*i]) translate([r_ring,0,0])
      circle(r=rc);
  }
}

module rncylinder(n,d=undef,r=undef,rc=2,h=1) {
  linear_extrude(height=h) rngon(n,d,r,rc);
}