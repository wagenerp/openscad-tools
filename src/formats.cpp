#include "formats.h"
#include <unordered_set>

std::vector<MeshFormat*> __formats;

MeshFormat::MeshFormat(
  const std::string &ident, mesh_load_f loader, mesh_identify_f identifier) :
  _ident(ident),
  _loader(loader),
  _identifier(identifier) {
  __formats.push_back(this);
}

Mesh *MeshFormat::Load(const char *fn) {
  FILE *f=NULL;
  size_t cb;
  size_t cb_read;
  void *buf=NULL;
  Mesh *res=NULL;

  std::unordered_set<MeshFormat*> loaders;

  f=fopen(fn,"r");
  if (!f) {
    perror("fopen");
    goto finish;
  }
  fseek(f,0,SEEK_END);
  cb=ftello64(f);
  fseek(f,0,SEEK_SET);

  buf=malloc(cb);
  if (buf==NULL) {
    perror("malloc");
    fclose(f);
    return NULL;
  }

  cb_read=fread(buf,1,cb,f);
  if (cb_read!=cb) {
    perror("fread");
    goto finish;
  }
  fclose(f);


  for(auto it=__formats.begin();it!=__formats.end();it++) {
    if ((*it)->identifier()((char*)buf,cb)) loaders.insert(*it);
  }

  if (loaders.size()<1) {
    fprintf(stderr,"error: no loader found for given file\n");
    goto finish;
  }
  if (loaders.size()>1) {
    fprintf(stderr,"error: multiple (%lu) loaders found for given file\n",loaders.size());
    goto finish;
  }

  res=(*loaders.begin())->loader()((char*)buf,cb);

  finish:
    if (f!=NULL) fclose(f);
    if (buf!=NULL) free(buf);
    return res;
  


}
const std::vector<MeshFormat*>  &MeshFormat::formats() { return __formats; }