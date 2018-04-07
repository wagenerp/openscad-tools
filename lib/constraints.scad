
module constraint_system_wrapper(transform,$constraint_system_name="") {
  assert(parent_module()=="constraint_system");
  marker("constraint_system",name=$constraint_system_name,transform=transform)
    children();
}

module constraint_system(name) {
  name_actual=($constraint_system_name==undef) 
    ? name 
    : str($constraint_system_name,"/",name);

  transform=
    ($constraint_system_transforms==undef)
    ? undef
    : lookups(name_actual,$constraint_system_transforms);
  
  transform_actual=
    (transform==undef)
    ? [[1,0,0,0],[0,1,0,0],[0,0,1,0],[0,0,0,1]]
    : transform;
  
  multmatrix(transform_actual)
    constraint_system_wrapper($constraint_system_name=name_actual,transform=transform_actual) children();
}

module constraint_point(name,offset=[0,0,0]) {
  name_actual=($constraint_system_name==undef) 
    ? name
    : str($constraint_system_name,":",name);
  
  translate(offset) {
    marker("point",system=$constraint_system_name,name=name);
    if (($constraint_reference==undef) || $constraint_reference)
    %reference() scale($vpd*0.002) {
      color("red") cube([20,1,1],true);
      color("green") cube([1,20,1],true);
      color("blue") cube([1,1,20],true);
    }
  }
}

module constraint_line(name,p1,p2) {
  marker("line",system=$constraint_system_name,name=name,a=p1,b=p2);
}

module constraint_object(name) {
  name_actual=str($constraint_system_name,".",name);

  transform=
    ($constraint_system_transforms==undef)
    ? undef
    : lookups(name_actual,$constraint_system_transforms);
  
  transform_actual=
    (transform==undef)
    ? [[1,0,0,0],[0,1,0,0],[0,0,1,0],[0,0,0,1]]
    : transform;

  multmatrix(transform_actual)
    marker("object",system=$constraint_system_name,name=name)
      children();
  
  assert(parent_module()=="constraint_system_wrapper");
}

module constrain_coincident(p1,p2) {
  marker("constrain",system=$constraint_system_name,type="POINTS_COINCIDENT",p1=p1,p2=p2);
}
module constrain_distance(p1,p2,val) {
  marker("constrain",system=$constraint_system_name,type="PT_PT_DISTANCE",p1=p1,p2=p2,val=val);
}
module constrain_on_line(p1,l1) {
  marker("constrain",system=$constraint_system_name,type="PT_ON_LINE",p1=p1,l1=l1);
}
module constrain_equal_length(l1,l2) {
  marker("constrain",system=$constraint_system_name,type="EQUAL_LENGTH_LINES",l1=l1,l2=l2);
}
module constrain_length_ratio(l1,l2,val) {
  marker("constrain",system=$constraint_system_name,type="LENGTH_RATIO",l1=l1,l2=l2,val=val);
}
module constrain_equal_angle(l1,l2) {
  marker("constrain",system=$constraint_system_name,type="EQUAL_ANGLE",l1=l1,l2=l2);
}
module constrain_at_midpoint(l1,p1) {
  marker("constrain",system=$constraint_system_name,type="AT_MIDPOINT",l1=l1,p1=p1);
}
module constrain_angle(l1,l2,val) {
  marker("constrain",system=$constraint_system_name,type="ANGLE",l1=l1,l2=l2,val=val);
}
module constrain_parallel(l1,l2) {
  marker("constrain",system=$constraint_system_name,type="PARALLEL",l1=l1,l2=l2);
}
module constrain_perpendicular(l1,l2) {
  marker("constrain",system=$constraint_system_name,type="PERPENDICULAR",l1=l1,l2=l2);
}
