#include "format-stl.h"
#include <alpha2/util.h>
#include <stdio.h>

#define keepel(x) (x)
#define swapel(x) (((x>>24)&0xff) | ((x>>8)&0xff00) | ((x<<8)&0xff0000) | ((x<<24)&0xff000000))

#if __BYTE_ORDER__==__ORDER_LITTLE_ENDIAN__
#define stohl keepel
#else
#define stohl swapel
#endif

int identify_binary_stl(const char *buf, size_t cb) {
  if (cb<84) return MeshFormat::CANNOT_LOAD;
  uint32_t n_triangles=stohl(*(uint32_t*)(buf+80));

  if (cb<84+n_triangles*50) return MeshFormat::CANNOT_LOAD;
  if (cb>84+n_triangles*50) return MeshFormat::MAYBE_CAN_LOAD;

  return MeshFormat::CAN_LOAD;
}

Mesh *load_binary_stl(const char *buf, size_t cb) {

  if (cb<84) return NULL;

  uint32_t n_triangles=stohl(*(uint32_t*)(buf+80));

  if (cb<84+n_triangles*50) return NULL;

  buf+=84;

  alp::Vector3f vectors[4];

  Mesh *res=new Mesh();

  for(uint32_t i_triangle=0;i_triangle<n_triangles;i_triangle++) {
    memcpy(vectors,buf,sizeof(vectors));
    res->addTriangle(vectors[1],vectors[2],vectors[3],vectors[0]);
  }

  res->mergeVertices();

  return res;


}


int identify_ascii_stl(const char *buf, size_t cb) {
  alp::LineScanner ln;
  alp::substring cmd;
  ln.assign(buf,cb);
  if (!ln.getLnFirstString(&cmd)) return MeshFormat::CANNOT_LOAD;
  if (!(cmd=="solid")) return MeshFormat::CANNOT_LOAD;
  return MeshFormat::CAN_LOAD;
}

Mesh *load_ascii_stl(const char *buf, size_t cb) {
  alp::LineScanner ln;
  alp::substring cmd;
  ln.assign(buf,cb);
  if (!ln.getLnFirstString(&cmd)) return NULL;
  if (!(cmd=="solid")) return NULL;

  Mesh *res=new Mesh();

  vertex_t vertices[3];
  vertex_t normal;


  while(ln.getLnFirstString(&cmd)) {
    if (cmd=="endsolid") break;
    else if (cmd=="facet") {
      if (
      ln.getLnString(&cmd) && (cmd=="normal") &&
      ln.getFloat(&normal.x,1) && 
      ln.getFloat(&normal.y,1) && 
      ln.getFloat(&normal.z,1) &&
      ln.getLnFirstString(&cmd) && (cmd=="outer") && 
      ln.getLnString(&cmd) && (cmd=="loop") &&
      ln.getLnFirstString(&cmd) && (cmd=="vertex") && 
      ln.getFloat(&vertices[0].x,1) && 
      ln.getFloat(&vertices[0].y,1) && 
      ln.getFloat(&vertices[0].z,1) &&
      ln.getLnFirstString(&cmd) && (cmd=="vertex") && 
      ln.getFloat(&vertices[1].x,1) && 
      ln.getFloat(&vertices[1].y,1) && 
      ln.getFloat(&vertices[1].z,1) &&
      ln.getLnFirstString(&cmd) && (cmd=="vertex") && 
      ln.getFloat(&vertices[2].x,1) && 
      ln.getFloat(&vertices[2].y,1) && 
      ln.getFloat(&vertices[2].z,1) &&
      ln.getLnFirstString(&cmd) && (cmd=="endloop") &&
      ln.getLnFirstString(&cmd) && (cmd=="endfacet")
      ) {
        res->addTriangle(vertices[0],vertices[1],vertices[2],normal);
      } else {
        delete res;
        return NULL;
      }
    } else {
      delete res;
      return NULL;
    }
  }

  return res;


}

MeshFormat format_ascii_stl("stl (ascii)",load_ascii_stl,identify_ascii_stl);
MeshFormat format_binary_stl("stl (binary)",load_binary_stl,identify_binary_stl);