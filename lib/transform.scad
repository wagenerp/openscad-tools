
module transform_ez(ez) {
  w0=ez/norm(ez);
  v=cross([0,0,1],w0);
  u=cross(v,w0);
  v0=v/norm(v);
  u0=u/norm(u);
  m= 
    ((ez[0]==0)&&(ez[1]==0)) ?
    (
      (ez[2]>0) ? 
      [
        [1,0,0,0],
        [0,1,0,0],
        [0,0,1,0],
        [0,0,0,1]
      ] : [
        [1,0,0,0],
        [0,1,0,0],
        [0,0,-1,0],
        [0,0,0,1]
      ]
    ) : [
        [u0[0],v0[0],w0[0],0],
        [u0[1],v0[1],w0[1],0],
        [u0[2],v0[2],w0[2],0],
        [u0[3],v0[3],w0[3],1]
    ];
  multmatrix(m) children();
}

module transform_ezex(ex,ez) {
  u0=ex/norm(ex);
  v=cross(ez,ex);
  v0=v/norm(v);
  w0=cross(u0,v0);

  multmatrix([
    [u0[0],v0[0],w0[0],0],
    [u0[1],v0[1],w0[1],0],
    [u0[2],v0[2],w0[2],0],
    [u0[3],v0[3],w0[3],1]
  ]) children();
}

module chain_translate(offsets,index,f=1) {
  if (index==0) 
    translate(offsets[0]*f) 
      children();
  else 
    chain_translate(offsets,index-1,f) 
      translate(offsets[index]*f) 
        children();
}