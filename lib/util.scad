
function bezier4(f,p0,p1,p2,p3) = 
  pow(1-f,3)*p0 + 
  3*pow(1-f,2)*f*p1 +
  3*(1-f)*f*f*p2 +
  f*f*f*p3;

module mirrordup(v) {
  children();
  mirror(v=v) children();
}
