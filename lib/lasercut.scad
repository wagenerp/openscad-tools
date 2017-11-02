include <types.scad>;

module engrave(depth=0.1) {
  if ($bake_discover) echo(str("bake-engrave:",depth));
  if ($laser_part==undef) {
    difference() {
      children(0);
      children([1:$children-1]);
    }
    color([0.7*(1-depth),0.4+0.6*depth,1.0,1.0]) children([1:$children-1]);
  } else if (
    $laser_part=="engrave" && 
    ($engrave_depth==undef || abs($engrave_depth-depth)<1e-5)) {
    children([1:$children-1]);
  } else {
    children(0);
  }
}
module cut() {
  if ($bake_discover) echo(str("bake-cut"));
  if ($laser_part==undef) {
    difference() {
      children(0);
      children([1:$children-1]);
    }
    color([1,0,0,0.5]) children([1:$children-1]);
  } else if ($laser_part=="cut") {
    difference() {
      children(0);
      children([1:$children-1]);
    }
  } else {
    children(0);
  }

}
module mark(depth=0.1) {
  if ($bake_discover) echo(str("bake-mark:",depth));
  if ($laser_part==undef) {
    difference() {
      children(0);
      children([1:$children-1]);
    }
    color([0.7*(1-depth),0.4+0.6*depth,1.0,1.0]) children([1:$children-1]);
  } else if (
    $laser_part=="mark" && 
    ($mark_depth==undef || abs($mark_depth-depth)<1e-5)) {
    children([1:$children-1]);
  } else {
    children(0);
  }
}