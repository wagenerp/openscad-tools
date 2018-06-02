
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

module transform_arb(p=undef,ex=undef,ey=undef,ez=undef,angs=undef) {
  hx=ex!=undef;
  hy=ey!=undef;
  hz=ez!=undef;
  translate(p==undef ? [0,0,0] : p)
  if (angs==undef) {
    if (false) { }
    else if ( hx&& hy && hz) transform_ezex(ex,ez) children();
    else if (!hx&& hy && hz) transform_ezex(cross(ey,ez),ez) children();
    else if ( hx&&!hy && hz) transform_ezex(ex,ez) children();
    else if ( hx&& hy &&!hz) transform_ezex(ex,cross(ex,ey)) children();
    else if (hx) transform_arb(ex=ex,ey=cross([0,0,1],ex)) children();
    else if (hy) transform_arb(ey=ey,ex=cross(ey,[0,0,1])) children();
    else if (hz && (abs(dot(hz,[0,0,1]))==norm(ez))) children();
    else if (hz) transform_arb(ez=ez,ex=cross(ez,[0,0,1])) children();
    else children();
  } else {
    assert(!(hx||hy||hz),"ambiguous transform");
    rotate(angs) children();
  }
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