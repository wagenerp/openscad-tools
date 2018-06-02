include <transform.scad>
include <math.scad>;
include <preprocess.scad>

$mt=4;
$bw=0.2; // beam width / cut loss

$plate_finger_length=8;
$plate_finger_overlap=0.2;
$plate_finger_lip=4;
$plate_finger_grip=0.1;
$plate_slit_grip=0.1;

function pt_find_plate(k,l,i=0) =
  (i>=len(l) || l==undef) ? (
    undef
  ) : (
    (l[i][1]==k) ? i : pt_find_plate(k,l,i+1)
  );

function pt_sort_line(l) = 
  ( l[0][0]<l[1][0] ) ? ( l ) : (
    ( l[0][0]==l[1][0] && l[0][1]<l[1][1] ) ? ( l ) : (
      ( l[0][1]==l[1][1] && l[0][2]<l[1][2] ) ? ( l ) : (
        [l[1],l[0]])));

function pt_reproject_line(l,m) =
  [ 
    subvec2(m * [l[0][0],l[0][1],0,1]),
    subvec2(m * [l[1][0],l[1][1],0,1]) 
  ];

function pt_test_cut1(p,w,h,t=0.2) =
  ( p[0]<t || p[1]<t || p[0]>w-t || p[1]>h-t ) ? 1 : 0;

function pt_test_cut2(a,b) = 
  [ a && b, a || b, a, b];

function pt_test_cut(l,w,h,t=0.2) =
  pt_test_cut2(pt_test_cut1(l[0],w,h,t),pt_test_cut1(l[1],w,h,t));


function pt_test_edge1(l,c,o,t, e) =
  (abs(l[0][c]-o)<t && abs(l[1][c]-o)<t) ? [c,o] : e;

function pt_test_edge(l,w,h,t=0.2) = 
  pt_test_edge1(l,0,0,t,
    pt_test_edge1(l,0,w,t,
      pt_test_edge1(l,1,0,t,
        pt_test_edge1(l,1,h,t,undef))));

function pt_slit_parity(a,b,c,d,p) =
  (a && !b) ? 0 :
  (!a && b) ? 1 : 
  p;
/*
  (a && !b && (c==d)) ? 0 : // cut into 1 but not 2
  (!a && b && (c==d)) ? 1 : // ^
  ((a==b) && c && !d) ? 1 : // cut into 2 but not 1
  ((a==b) && !c && d) ? 0 : // ^
  ((a==b) && (c==d)) ? p : // cut both (partially or complete)
    a+b+c+d==4) ? p : 
    */

module plate_joint_fingers(l,v,p,protrude=0) {
  oh=$plate_finger_overlap/2;
  gh=$plate_finger_grip/2;
  lh=norm(l[1]-l[0])/2;
  u=(l[1]-l[0])/norm(l[1]-l[0]);
  

  protrude1=protrude*(
    (abs(v[0])>abs(v[1])) ? v[0]/abs(v[0]) : v[1]/abs(v[1]));
  
  y1=gh + min(0,protrude1);
  y2=$mt-gh + max(0,protrude1);

  M=[
    [
      [u[0],v[0],0,l[0][0]],
      [u[1],v[1],0,l[0][1]],
      [0,0,1,0],
      [0,0,0,1]
    ],
    [
      [-u[0],v[0],0,l[1][0]],
      [-u[1],v[1],0,l[1][1]],
      [0,0,1,0],
      [0,0,0,1]
    ]
  ];
  
  module finger(x,w) {
    for(m=M) multmatrix(m)
      polygon(points=[
        [x+oh,y1],[x+w-oh,y1],[x+w-oh,y2],[x+oh,y2]
      ]);
  }
  if (p>0) {
    for(x=[$plate_finger_lip:$plate_finger_length*2:lh])
      finger(x,$plate_finger_length);
  } else {
    finger(0,$plate_finger_lip);
    for(x=[$plate_finger_lip+$plate_finger_length:$plate_finger_length*2:lh])
      finger(x,$plate_finger_length);

  }


}

module plate_joint_slit(l,v,protrude1=false,protrude2=false) {
  gh=$plate_slit_grip/2;
  w=norm(l[1]-l[0]);
  u=(l[1]-l[0])/w;
  x1=protrude1?-$mt*2 : gh;
  x2=protrude2?w+$mt*2 : w-gh;
  multmatrix([
      [u[0],v[0],0,l[0][0]],
      [u[1],v[1],0,l[0][1]],
      [0,0,1,0],
      [0,0,0,1]
    ])
    polygon(points=[
      [x1,gh],[x1,$mt-gh],[x2,$mt-gh],[x2,gh]
    ]);
}

function pt_plate_position(i) = 
  (i==0) ? [0,0] : pt_plate_position(i-1)+[1+$plates[i-1][3][0],0];

module plate(
  ident="",s=[100,100],
  p=undef,ez=undef,ex=undef,ey=undef,a=undef,
  xyz=undef,yzx=undef,xzy=undef,
  transform=undef,
  dupe=false, parade=false) {
  m=transform==undef ? m4_transform_arb(p,ex,ey,ez,a,xyz,yzx,xzy) : transform;
  m_inv=m4_inverse(m);


  my_data=[0,ident,m,s];

  if (!dupe) pp("store",["$plates[]",my_data]);

  i1=pt_find_plate(ident,$plates);

  module mytransform() {
    if (parade) translate(pt_plate_position(i1)) children();
    else multmatrix(m) children();
  }

  mytransform()
    part(ident,root=true,process="visicut",ignore=dupe,extrude=$mt) {
      cut() {
      difference() {
        intersection() {
          square(s);
          if ($children>0) children(0);
          if ($children>2)
            projection() {
              intersection() {
                multmatrix(m_inv) children(2);
                linear_extrude(height=$mt) square(s);
              }
            }
        }
        if (i1!=undef) {
          m1=m;
          s1=s;
          for(i2=[0:1:len($plates)-1]) if (i1!=i2) {
            p2=$plates[i2];
            m2=p2[2];
            s2=p2[3];

            w1=subvec3(m1*[0,0,1,0]);
            w2=subvec3(m2*[0,0,1,0]);
            p=(subvec3(m1*[0,0,0,1]) + (subvec3((m2-m1)*[0,0,0,1])*w2)*w2);
            u=cross(w1,w2)/norm(cross(w1,w2));


            l1=pt_sort_line(
              clip2d_line_rect(
                pt_reproject_line(
                  clip2d_line_rect(
                    [proj_point(p+u*-10000,m2),proj_point(p+u*10000,m2)],
                    s2[0],s2[1]
                  )
                  ,m4_inverse(m1)*m2
                ),
                s1[0],s1[1]));
            l2=pt_reproject_line(l1,m4_inverse(m2)*m1);

            e1=pt_test_edge(l1,s1[0],s1[1],t=$bw+$mt);
            e2=pt_test_edge(l2,s2[0],s2[1],t=$bw+$mt);

            c1=pt_test_cut(l1,s1[0],s1[1],t=$bw);
            c2=pt_test_cut(l2,s2[0],s2[1],t=$bw);

            v=subvec2(m4_inverse(m1)*m2*[0,0,1,0]);
            // todo: scale joint width by angle if incidence
            if (l1==undef) {
              // no intersection
            } else if (e1!=undef || e2!=undef) {
              // at least one intersection occurs at the edge -> finger joint
              if (e1!=undef)
                plate_joint_fingers(l1,v,i1<i2?1:-1,protrude=e1[1]>0 ? +1 : -1);
              else
                plate_joint_fingers(l1,v,i1<i2?1:-1);
            } else if (c1[0] && !c2[1]) {
              // we are cut through completely by a part of the other plate
            } else if (c2[0] && !c1[1]) {
              // we cut the other plate in half but don't reach an edge
              plate_joint_slit(l1,v);
            } else {
              // at least for one partner, we cut in from an edge.
              // cut a slit halfway across the line on both partners.
              parity=(c1[2]&&!c1[3]) ? 0 : (!c1[2]&&c1[3]) ? 1 : (i1<i2) ? 0 : 1;
              pc=(l1[0]+l1[1])/2;
              l1h=parity ? [pc,l1[1]] : [l1[0],pc];
              plate_joint_slit(l1h,
                v, ((parity==0) && c1[2]), (parity==1&&c1[3]));
              
            }
          }
        }
        if ($children>1) children(1);
        if ($children>3)
          projection() {
            intersection() {
              multmatrix(m_inv) children(3);
              linear_extrude(height=$mt) square(s);
            }
          }
      }
      translate([100000,0]) square(1);
      }
    }
  
}
module gplate(
  ident="",s=[100,100],
  p=undef,ez=undef,ex=undef,ey=undef,a=undef,
  xyz=undef,yzx=undef,xzy=undef,
  transform=undef,
  dupe=false, parade=false) {
  plate(ident,s,p,ez,ex,ey,a,xyz,yzx,xzy,transform,dupe,parade) {
    intersection() {
      if ($children>0) children(0);
    }
    union() {
      if ($children>1) children(1);
    }
    intersection() {
      g_intersect();
      if ($children>2) children(2);
    }
    union() {
      g_difference();
      if ($children>3) children(3);
    }
  }
}