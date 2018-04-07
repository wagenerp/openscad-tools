
module guide_dist(p1,p2) {
  p1_actual=($constraint_system_name==undef) 
    ? p1
    : str($constraint_system_name,":",p1);
  p2_actual=($constraint_system_name==undef) 
    ? p2
    : str($constraint_system_name,":",p2);
  name=str("guide-",p1_actual,"-",p2_actual);
  name_actual=($constraint_system_name==undef) 
    ? name
    : str($constraint_system_name,":",name);
  constraint_point(name);

  echo(p1_actual,lookups(p1_actual,$point_inv_transforms));
  echo(name_actual,lookups(name_actual,$point_inv_transforms));
  p1_m=lookups(p1_actual,$point_transforms)-lookups(name_actual,$point_transforms);
  p2_m=lookups(p2_actual,$point_transforms)-lookups(name_actual,$point_transforms);
  p1_p=[p1_m[0][3],p1_m[1][3],p1_m[2][3]];
  p2_p=[p2_m[0][3],p2_m[1][3],p2_m[2][3]];
  %reference() {
    color([1,1,1,1]*10) {
      hull() {
        for(p=[p1_p,p2_p])
          translate(p)
            cube($vpd*0.0005);
      }
      translate((p1_p+p2_p)/2) 
        transform_ez(p2_p-p1_p) 
          rotate([90,0,-90]) {
        scale($vpd*0.001) text(str(" ",norm(p2_p-p1_p)));
      }
    }
  }

}
