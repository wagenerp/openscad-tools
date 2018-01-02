#ifndef COMPUTE_HPP
#define COMPUTE_HPP
#include "types.h"

bool collide_face_face(
  const vertex_t &a0,
  const vertex_t &a1,
  const vertex_t &a2,
  const vertex_t &b0,
  const vertex_t &b1,
  const vertex_t &b2,
  vertex_t &p0,
  vertex_t &p1);

bool collide_face_face_ex(
  const std::vector<vertex_t> &vex,
  size_t a0,
  size_t a1,
  size_t a2,
  size_t b0,
  size_t b1,
  size_t b2,
  vertex_t &p0,
  vertex_t &p1);

#endif