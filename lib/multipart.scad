
module part_wrapper() {
  children();
}
module part(name,process="",offset=[0,0,0],ignore=false) {
  offset_actual=($part==undef || $part==$partname) ? offset : [0,0,0];
  if ($part==undef || $part==name || $part==$partname) {
    if ($bake_discover && $partname==undef) echo(str("bake-part:",name,";process:",process,ignore ? ";ignore:true":""));
    translate(offset_actual)
    part_wrapper($partname=name)
    children();
  }
}

module reference() {
  if ($part==undef) children();
}