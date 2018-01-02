#include "types.h"
#include <map>
#include <set>

Face::Face(const vertex_t &base, const vertex_t &normal) :
  _base(base),
  _normal(normal) {

}

void Face::addTriangle(const triangle_t &tri) {
  _triangles.push_back(tri);
}


void Mesh::addTriangle(
      const vertex_t &v0,
      const vertex_t &v1,
      const vertex_t &v2,
      const vertex_t &normal) {
  _vertices.push_back(v0);
  _vertices.push_back(v1);
  _vertices.push_back(v2);
  _triangles.push_back(triangle_t{_vertices.size()-3,_vertices.size()-2,_vertices.size()-1,normal});
}

void Mesh::mergeVertices(coord_t threshold) {
  std::vector<size_t> index_map;
  std::map<size_t,size_t> replacements;
  std::vector<vertex_t> new_vertices;
  std::set<size_t> erasures;

  // obtain a sorted index map of vertices
  // (sorting along any axis will do)
  index_map.resize(_vertices.size());
  for(size_t i=0;i<_vertices.size();i++) index_map[i]=i;
  std::sort(
    index_map.begin(),index_map.end(),
    [this](const size_t &a, const size_t &b) { 
      return _vertices[a].x<_vertices[b].x;
    });
  
  // square the threshold to avoid using sqrt()
  coord_t threshold_sqr=threshold*threshold;
  
  // merge vertices by building a replacement table mapping
  // old indices to new indices (without accounting for deletion of duplicates)
  {
    for(auto it0=index_map.begin();it0!=index_map.end();) {
      if (replacements.count(*it0)!=0) { it0++; continue; }
      new_vertices.push_back(_vertices[*it0]);
      replacements[*it0]=new_vertices.size()-1;
      
      auto it1=it0;
      auto itn=it0;
      it1++;
      itn++;
      vertex_t v0=_vertices[*it0];
      while((it1!=index_map.end())&&(_vertices[*it1].x-v0.x<=threshold)) {
        if ((v0-_vertices[*it1]).sqr()<=threshold_sqr) {
          replacements[*it1]=new_vertices.size()-1;
          if (itn==it1) itn++;
        }
        it1++;
      }
      it0=itn;
    }
  }

  // re-encode faces and replace vertices
  _vertices=new_vertices;
  for(auto it=_triangles.begin();it!=_triangles.end();it++) {
    it->vertices[0]=replacements[it->vertices[0]];
    it->vertices[1]=replacements[it->vertices[1]];
    it->vertices[2]=replacements[it->vertices[2]];
  }
}

std::vector<Face*> *Mesh::buildFaceList(std::vector<Face*> *vec, coord_t threshold) {
  if (vec==NULL) vec=new std::vector<Face*>();
  std::set<size_t> completed_set;

  std::vector<vertex_t> normals;
  normals.resize(_triangles.size());
  for(size_t i=0;i<_triangles.size();i++) {
    normals[i]=(
      (_vertices[_triangles[i].vertices[1]]-_vertices[_triangles[i].vertices[0]])
      %
      (_vertices[_triangles[i].vertices[2]]-_vertices[_triangles[i].vertices[0]])
    ).normal();
  }

  for(size_t i=0;i<_triangles.size();i++) {
    if (completed_set.count(i)>0) continue;
    vertex_t base=_vertices[_triangles[i].vertices[0]];
    Face *face=new Face(base,normals[i]);
    vec->push_back(face);
    face->addTriangle(_triangles[i]);
    coord_t d=base*normals[i];
    for(size_t j=i+1;j<_triangles.size();j++) {
      if ((normals[j]-normals[i]).sqr()>threshold) continue;
      //if ((normals[j]!=normals[i])&&(normals[j]!=-normals[i])) continue;
      if (fabs(_vertices[_triangles[j].vertices[0]]*normals[i]-d)>threshold) continue;
      face->addTriangle(_triangles[j]);
      if (j==i+1) i=j;
      else completed_set.insert(j);
    }
    
  }


  return vec;
}

