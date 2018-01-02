#ifndef FORMAT_STL_H
#define FORMAT_STL_H

#include <stdint.h>
#include "types.h"
#include "formats.h"

int identify_binary_stl(const char *buf, size_t cb);
Mesh *load_binary_stl(const char *buf, size_t cb);

int identify_ascii_stl(const char *buf, size_t cb);
Mesh *load_ascii_stl(const char *buf, size_t cb);


#endif