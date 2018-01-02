#ifndef FORMATS_H
#define FORMATS_H
#include "types.h"
#include <string>
#include <vector>


typedef Mesh*(*mesh_load_f)(const char *buf, size_t cb);
typedef int(*mesh_identify_f)(const char *buf, size_t cb);
class MeshFormat {
  public:
    enum {
      CANNOT_LOAD = 0,
      CAN_LOAD = 1,
      MAYBE_CAN_LOAD = 2,
    };
  protected:
    std::string _ident;
    mesh_load_f _loader;
    mesh_identify_f _identifier;
  
  public:
    MeshFormat(
      const std::string &ident, mesh_load_f loader, mesh_identify_f identifier);
    const std::string &ident() const { return _ident; }
    const mesh_load_f &loader() const { return _loader; }
    const mesh_identify_f &identifier() const { return _identifier; }

    static Mesh *Load(const char *fn);

    static const std::vector<MeshFormat*> &formats();
};

#endif