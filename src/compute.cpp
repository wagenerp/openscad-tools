#include "compute.h"
#include <math.h>

bool collide_face_face(
  const vertex_t &a0,
  const vertex_t &a1,
  const vertex_t &a2,
  const vertex_t &b0,
  const vertex_t &b1,
  const vertex_t &b2,
  vertex_t &p0,
  vertex_t &p1) {

  // compute normal of a
  vertex_t an=(a2-a0) % (a1-a0);
  an.normalize();
  // translate b to relative coordinates wrt a0 to form triangle c
  vertex_t c0=b0-a0;
  vertex_t c1=b1-a0;
  vertex_t c2=b2-a0;

  #define SIGN(x) ((x>0)?0b10 : ((x<0) ? 0b00 : 0b01))
  #define PROJ(a,b,c,n) __extension__ \
    ({ \
      float d=(b-a)*n; \
      if (d!=0) d=( (c-a)*n ) / d; \
      if ((d<0)||(d>1)) return false;  \
      (d==0) ? a : (a + (b-a)*d); \
      /*(d==0)?a : ((a) - (b-a) * (n*(a-c)) / d); */ \
    })
  #define PROJ2(i0,i1) PROJ(b##i0,b##i1,a0,an)

  // compute relationship of b's vertices to the plane of a
  int rel=(SIGN(an*c0))|((SIGN(an*c1))<<2)|((SIGN(an*c2))<<4);

  // compute the intersection line of triangle b in plane of a  
  switch(rel) {
    // faces are separate or identical
    case 0b00'00'00: case 0b01'01'01: case 0b10'10'10:
      return false;

    // single-point collision
    case 0b00'00'01: case 0b10'10'01: p0=p1=b0; break;
    case 0b00'01'00: case 0b10'01'10: p0=p1=b1; break;
    case 0b01'00'00: case 0b01'10'10: p0=p1=b2; break;

    // two-point collision of on-face vertices
    case 0b00'01'01: case 0b10'01'01: p0=b0; p1=b1; break;
    case 0b01'00'01: case 0b01'10'01: p0=b0; p1=b2; break;
    case 0b01'01'00: case 0b01'01'10: p0=b1; p1=b2; break;

    // two-point collision of two edges
    case 0b00'00'10: case 0b10'10'00: p0=PROJ2(0,1); p1=PROJ2(0,2); break;
    case 0b00'10'00: case 0b10'00'10: p0=PROJ2(1,2); p1=PROJ2(1,0); break;
    case 0b10'00'00: case 0b00'10'10: p0=PROJ2(2,0); p1=PROJ2(2,1); break;

    // point-and-edge collision
    case 0b10'01'00: case 0b00'01'10: p0=b1; p1=PROJ2(2,0); printf("A %g %g %g  %g %g %g |   %3g %3g %3g  %3g %3g %3g  %3g %3g %3g |   %3g %3g %3g  %3g %3g %3g  %3g %3g %3g\n",p0.x,p0.y,p0.z,p1.x,p1.y,p1.z,a0.x,a0.y,a0.z,a1.x,a1.y,a1.z,a2.x,a2.y,a2.z,b0.x,b0.y,b0.z,b1.x,b1.y,b1.z,b2.x,b2.y,b2.z); break;
    case 0b01'00'10: case 0b01'10'00: p0=b2; p1=PROJ2(0,1); printf("B %g %g %g  %g %g %g |   %3g %3g %3g  %3g %3g %3g  %3g %3g %3g |   %3g %3g %3g  %3g %3g %3g  %3g %3g %3g\n",p0.x,p0.y,p0.z,p1.x,p1.y,p1.z,a0.x,a0.y,a0.z,a1.x,a1.y,a1.z,a2.x,a2.y,a2.z,b0.x,b0.y,b0.z,b1.x,b1.y,b1.z,b2.x,b2.y,b2.z); break;
    case 0b10'00'01: case 0b00'10'01: p0=b0; p1=PROJ2(1,2); printf("C %g %g %g  %g %g %g |   %3g %3g %3g  %3g %3g %3g  %3g %3g %3g |   %3g %3g %3g  %3g %3g %3g  %3g %3g %3g\n",p0.x,p0.y,p0.z,p1.x,p1.y,p1.z,a0.x,a0.y,a0.z,a1.x,a1.y,a1.z,a2.x,a2.y,a2.z,b0.x,b0.y,b0.z,b1.x,b1.y,b1.z,b2.x,b2.y,b2.z); break;

  }

  {
    // compute relationship of a's vertices to the plane of b 
    vertex_t c0=a0-b0;
    vertex_t c1=a1-b0;
    vertex_t c2=a2-b0;
    vertex_t bn=((a2-a0) % (a1-a0)).normal();
    int rel=(SIGN(bn*c0))|((SIGN(bn*c1))<<2)|((SIGN(bn*c2))<<4);

    // compute the intersection line of triangle b in plane of a  
    switch(rel) {
      // faces are separate or identical
      case 0b00'00'00: case 0b01'01'01: case 0b10'10'10:
        return false;
    }


  }

  // now clip the projected line to the triangle of a.
  // compute tangents of a's edges and determine what's 'inside' (parity q)
  vertex_t t0=(a1-a0)%an; t0.normalize(); 
  vertex_t t1=(a2-a1)%an; t1.normalize();
  vertex_t t2=(a0-a2)%an; t2.normalize();
  int q0=SIGN(t0*(a2-a0));
  int q1=SIGN(t1*(a0-a1));
  int q2=SIGN(t2*(a1-a2));

  if (SIGN(t0*(p0-a0))!=q0) p0=PROJ(p0,p1,a0,t0);
  if (SIGN(t1*(p0-a1))!=q1) p0=PROJ(p0,p1,a1,t1);
  if (SIGN(t2*(p0-a2))!=q2) p0=PROJ(p0,p1,a2,t2);

  if (SIGN(t0*(p1-a0))!=q0) p1=PROJ(p1,p0,a0,t0);
  if (SIGN(t1*(p1-a1))!=q1) p1=PROJ(p1,p0,a1,t1);
  if (SIGN(t2*(p1-a2))!=q2) p1=PROJ(p1,p0,a2,t2);
  
  return (p1-p0).sqr()>1e-6;

  #undef PROJ
  #undef PROJ2
  #undef SIGN

}

bool collide_face_face_ex(
  const std::vector<vertex_t> &vex,
  size_t a0,
  size_t a1,
  size_t a2,
  size_t b0,
  size_t b1,
  size_t b2,
  vertex_t &p0,
  vertex_t &p1) {

  int n=0;
  #define ADDPOINT(idx) { \
    if (n==2) return false; \
    else if (n==1) p1=vex[idx]; \
    else p0=vex[idx]; \
    n++; \
  }
  if (a0==b0) { ADDPOINT(a0) }
  if (a0==b1) { ADDPOINT(a0) }
  if (a0==b2) { ADDPOINT(a0) }
  if (a1==b0) { ADDPOINT(a1) }
  if (a1==b1) { ADDPOINT(a1) }
  if (a1==b2) { ADDPOINT(a1) }
  if (a2==b0) { ADDPOINT(a2) }
  if (a2==b1) { ADDPOINT(a2) }
  if (a2==b2) { ADDPOINT(a2) }

  if (n==2) return true;

  return collide_face_face(
    vex[a0],vex[a1],vex[a2],vex[b0],vex[b1],vex[b2],p0,p1);

}