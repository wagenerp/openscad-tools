#ifndef TYPES_H
#define TYPES_H
#include <stdint.h>
#include <alpha2/math.h>
#include <vector>
#include <algorithm>

typedef float coord_t;
typedef alp::Vector3<coord_t> vertex_t;
typedef alp::Vector2<coord_t> vertex2_t;

struct triangle_t {
  size_t vertices[3];
  vertex_t normal;

  size_t operator[](size_t idx) const {
    return vertices[idx];
  }
  size_t &operator[](size_t idx) {
    return vertices[idx];
  }
};

class Face {
  protected:
    vertex_t _base;
    vertex_t _normal;
    std::vector<triangle_t> _triangles;
  
  public:

    Face(const vertex_t &base, const vertex_t &normal);
    void addTriangle(const triangle_t &tri);

    const vertex_t &base() const { return _base; }
    const vertex_t &normal() const { return _normal; }
    const std::vector<triangle_t> &triangles() const { return _triangles; }
};

class Mesh {
  protected:
    std::vector<vertex_t> _vertices;
    std::vector<triangle_t> _triangles;

  public:

    const std::vector<vertex_t>   &vertices()  { return _vertices; }
    const std::vector<triangle_t> &triangles() { return _triangles; }

    void addTriangle(
      const vertex_t &v0,
      const vertex_t &v1,
      const vertex_t &v2,
      const vertex_t &normal
    );

    void mergeVertices(coord_t threshold=0);

    std::vector<Face*> *buildFaceList(std::vector<Face*> *vec=NULL,coord_t threshold=0);

    template<class Compare>
    void sortFaces(Compare comp) {
      std::sort(_triangles.begin(),_triangles.end(),comp);
    }
};




#endif