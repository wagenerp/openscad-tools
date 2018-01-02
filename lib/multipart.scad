
module part_wrapper() {
  children();
}
module part(name,process="",offset=[0,0,0],matrix=[[1,0,0,0], [0,1,0,0], [0,0,1,0], [0,0,0,1]],ignore=false,extrude=undef) {
  offset_actual=($part==undef || $part==$partname) ? offset : [0,0,0];
  matrix_actual=($part==undef || $part==$partname) ? matrix : [[1,0,0,0], [0,1,0,0], [0,0,1,0], [0,0,0,1]];
  explode_actual=($part==undef || $part==$partname) ? $part_explode : 0;
  if ($part==undef || $part==name || $part==$partname) {
    if ($bake_discover && $partname==undef) echo(str("bake-part:",name,";process:",process,ignore ? ";ignore:true":""));
    multmatrix(matrix_actual)
    translate([0,0,explode_actual])
    translate(offset_actual)
    if ((extrude==undef)|| ($part==name) ) {
      part_wrapper($partname=name)
      children();
    } else {
      translate([0,0,-max(0,-extrude)])
      linear_extrude(height=abs(extrude))
      part_wrapper($partname=name)
      children();
    }
  }
}

module reference() {
  if ($part==undef) children();
}