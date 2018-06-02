
module part_wrapper(root) {
  if (root) !children();
  else children();
}
module part(
  name,
  process="",
  offset=[0,0,0],
  matrix=[[1,0,0,0], [0,1,0,0], [0,0,1,0], [0,0,0,1]],
  ignore=false,
  extrude=undef,
  root=false) {

  offset_actual=($part==undef || $part==$partname) ? offset : [0,0,0];
  matrix_actual=($part==undef || $part==$partname) ? matrix : [[1,0,0,0], [0,1,0,0], [0,0,1,0], [0,0,0,1]];
  root_actual=root && $part==name;
  explode_actual=($part==undef || $part==$partname) ? $part_explode : 0;
  if ($hidden_parts!=undef && len(search([name],$hidden_parts)[0])==undef) {
  } else if ($part==undef || (!ignore && ($part==name || $part==$partname))) {
    if ($bake_discover && $partname==undef) echo(str("bake-part:",name,";process:",process,ignore ? ";ignore:true":""));
    multmatrix(matrix_actual)
    translate([0,0,explode_actual])
    translate(offset_actual)
    if ((extrude==undef)|| ($part==name) ) {
      part_wrapper($partname=name,root=root_actual)
      children();
    } else {
      translate([0,0,-max(0,-extrude)])
      linear_extrude(height=abs(extrude))
      part_wrapper($partname=name,root=root_actual)
      children();
    }
  }
}

module reference() {
  if ($part==undef) children();
}