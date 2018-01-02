#include "formats.h"
#include "types.h"
#include "compute.h"
#include "format-stl.h"
#include <unordered_map>

struct face_cut_t {
  vertex2_t vertices[4];
};



int main(int argn, char **argv) {

  if (argn<2) return 1;
  MeshFormat fmt1("stl ascii",load_ascii_stl,identify_ascii_stl);

  coord_t finger_length=12;
  coord_t finger_clearance=-1;
  coord_t material_thickness=3.8;
  coord_t finger_lip=0.1;
  coord_t merge_threshold=1e-5;
  
  printf("formats: %lu\n",MeshFormat::formats().size());
  Mesh *m=MeshFormat::Load(argv[1]);
  if (m==NULL) return 1;

  printf("vertices (pre-merge): %lu, ",m->vertices().size());
  m->mergeVertices(merge_threshold);
  std::vector<Face*> *faces=m->buildFaceList(NULL,merge_threshold);
  printf("vertices: %lu, triangles: %lu, faces: %lu\n",m->vertices().size(),m->triangles().size(),faces->size());


  std::unordered_map<Face*,std::vector<face_cut_t>> cuts;
  std::unordered_map<Face*,std::vector<face_cut_t>> expansions;
  FILE *fout=fopen("/tmp/cube.scad","w");

  #define MKBASE(face,ex,ey,ez) { \
    ez=(*face)->normal().normal(); \
    ex=vertex_t{1,0,0}%ez; \
    { \
      coord_t l=ex.length(); \
      if (l==0) { \
        ex=vertex_t{0,1,0}; \
        ey=vertex_t{0,0,1}; \
      } else { \
        ex/=l; \
        ey=ez%ex; \
      } \
    } \
  }

  { // compute cutout polygons for local coordinate spaces
    auto vex=m->vertices();
    vertex_t p0,p1;
    vertex_t o1,ex1,ey1,ez1, o2,ex2,ey2,ez2;

    for(auto face1=faces->begin();face1!=faces->end();face1++) {
      auto tris1=(*face1)->triangles();
      o1=vex[tris1[0].vertices[0]];
      MKBASE(face1,ex1,ey1,ez1)

      for(auto face2=face1+1;face2!=faces->end();face2++) {
        auto tris2=(*face2)->triangles();
        vertex_t o2=vex[tris2[0].vertices[0]];
        MKBASE(face2,ex2,ey2,ez2)
        float face_angle=(ez1*ez2);
        float cut_depth=face_angle*face_angle;
        if (cut_depth>1) continue;
        //float cut_depth=sqrt(1-(ez1*ez2)*(ez1*ez2))*material_thickness;
        cut_depth=sqrt(1-cut_depth*cut_depth);
        //printf("%f ",cut_depth);
        cut_depth*=material_thickness;
        //printf("%f\n",cut_depth);

        for(auto tri1=tris1.begin();tri1!=tris1.end();tri1++) {
          for(auto tri2=tris2.begin();tri2!=tris2.end();tri2++) {
            if (!collide_face_face_ex(
              vex,
              tri1->vertices[0],
              tri1->vertices[1],
              tri1->vertices[2],
              tri2->vertices[0],
              tri2->vertices[1],
              tri2->vertices[2],
              p0,p1)) continue;
              
            // compute normal and length of the collision
            vertex_t n=(p1-p0);
            coord_t distance=n.length();
            n/=distance;
            // determine if the colliding faces form a concavity
            bool concave=
              (
                ( 
                  vex[tri2->vertices[0]]+
                  vex[tri2->vertices[1]]+
                  vex[tri2->vertices[2]])
                *(1.0/3.0)
                -vex[tri1->vertices[0]])
              *tri1->normal>0;

            // normalize the normal, i.e. have all parallel lines face the
            // same direction. this is needed to ensure the same parity for
            // multi-triangle cuts!

            if (n.x+n.y+n.z<=0) n=-n;

            // compute position of each endpoint on us as an infinite ray..
            coord_t dist0=p0*n;
            coord_t dist1=p1*n;
            // .. and use the lower one as starting point to cut finger joints
            if (dist0>dist1) {
              { vertex_t tmp=p1; p1=p0; p0=tmp; }
              { coord_t tmp=dist1; dist1=dist0; dist0=tmp; }
            }

            // compute initial parity and inset into finger joint stream.
            int parity=((int)(dist0/finger_length)) % 2;
            dist0=fmod(dist0,finger_length);

            // compute local coordinate systems for both faces
            vertex2_t u[2]={ {ex1*n,ey1*n}, {ex2*n,ey2*n} };
            vertex2_t v[2]={ 
              vertex2_t(-ex1*tri2->normal,-ey1*tri2->normal).normal(), 
              vertex2_t(-ex2*tri1->normal,-ey2*tri1->normal).normal()
            };
            vertex2_t a[2]={ {ex1*(p0-o1),ey1*(p0-o1)}, {ex2*(p0-o2),ey2*(p0-o2)} };
            /*
            printf("%3g %3g %3g  %3g %3g %3g  %3g %3g %3g",p0.x,p0.y,p0.z,p1.x,p1.y,p1.z,n.x,n.y,n.z);

            printf(" | %6.2f %6.2f, %6.2f %6.2f, %6.2f %6.2f",u[0].x,u[0].y,v[0].x,v[0].y,a[0].x,a[0].y);

            printf(" | %6.2f %6.2f %6.2f, %6.2f %6.2f %6.2f,  %6.2f %6.2f %6.2f",ex1.x,ex1.y,ex1.z,ey1.x,ey1.y,ey1.z,ez1.x,ez1.y,ez1.z);


            printf("\n");
            //*/
            // if we this connection is concave, we must extend both faces
            if (concave) {
              for(int p=0;p<2;p++) {
                expansions[(p==0)?(*face1):(*face2)].push_back(face_cut_t{{
                  a[p]+u[p]*0+v[p]*0,
                  a[p]+u[p]*distance+v[p]*0,
                  a[p]+u[p]*distance+v[p]*cut_depth,
                  a[p]+u[p]*0+v[p]*cut_depth
                }});
              }
            }
            // create finger joint cutouts
            for(coord_t pos=-dist0;pos<distance;pos+=finger_length) {
              
              coord_t u0=pos;
              coord_t u1=pos+finger_length;

              if (u0<0) u0=0;
              if (u1>distance) u1=distance;
              u0+=finger_clearance*0.5;
              u1-=finger_clearance*0.5;

              Face *face=parity ? *face2 : *face1;
              cuts[face].push_back(face_cut_t{{
                a[parity]+u[parity]*u0-v[parity]*finger_lip,
                a[parity]+u[parity]*u0+v[parity]*cut_depth,
                a[parity]+u[parity]*u1+v[parity]*cut_depth,
                a[parity]+u[parity]*u1-v[parity]*finger_lip}}),
              dist0=0;

              parity=!parity;
            }
          }
        }


      }
    }

  }

  { // generate openscad output
    auto vex=m->vertices();

    fprintf(fout,
      "include <all.scad>;\n"
    );
    vertex_t o,ex,ey,ez;
    for(auto face=faces->begin();face!=faces->end();face++) {
      auto tris=(*face)->triangles();
      o=vex[tris[0].vertices[0]];
      MKBASE(face,ex,ey,ez)
      
      fprintf(fout,
        "part(\"face-%li\",process=\"visicut\","
          "matrix=[[%f,%f,%f,%f], [%f,%f,%f,%f], [%f,%f,%f,%f], [0,0,0,1] ],"
          "extrude=%f) {\n"
        "  difference() {\n"
        "    union() {\n",
          face-faces->begin(),
          ex.x,ey.x,ez.x,o.x,
          ex.y,ey.y,ez.y,o.y,
          ex.z,ey.z,ez.z,o.z,
          -material_thickness
          );
      
      for(auto tri=tris.begin();tri!=tris.end();tri++) {
        fprintf(fout,
          "      polygon(points=[[%f,%f],[%f,%f],[%f,%f]]);\n",
          ex*(vex[tri->vertices[0]]-o),ey*(vex[tri->vertices[0]]-o),
          ex*(vex[tri->vertices[1]]-o),ey*(vex[tri->vertices[1]]-o),
          ex*(vex[tri->vertices[2]]-o),ey*(vex[tri->vertices[2]]-o));
      }

      for(auto quad=expansions[*face].begin();quad!=expansions[*face].end();quad++) {
        fprintf(fout,
          "    polygon(points=[[%f,%f],[%f,%f],[%f,%f],[%f,%f]]);\n",
          quad->vertices[0].x,quad->vertices[0].y,
          quad->vertices[1].x,quad->vertices[1].y,
          quad->vertices[2].x,quad->vertices[2].y,
          quad->vertices[3].x,quad->vertices[3].y);
      }

      fprintf(fout,"    }\n");

      for(auto quad=cuts[*face].begin();quad!=cuts[*face].end();quad++) {
        fprintf(fout,
          "    polygon(points=[[%f,%f],[%f,%f],[%f,%f],[%f,%f]]);\n",
          quad->vertices[0].x,quad->vertices[0].y,
          quad->vertices[1].x,quad->vertices[1].y,
          quad->vertices[2].x,quad->vertices[2].y,
          quad->vertices[3].x,quad->vertices[3].y);
      }

      fprintf(fout,"  }\n}\n");
    }
    fflush(fout);
  }

  return 0;
}