import slvs
from .types import marker_t
from collections import namedtuple
from .visitors.markers import MarkerVisitor
import numpy

point_t=namedtuple("point_t","transform invTransform")

class GuidesProcessor(MarkerVisitor):

  ident="guides"

  def __init__(s):
    MarkerVisitor.__init__(s)
    s._points=dict()


  def marker_point_pre(s,*args,name,system=None,**kwargs):
    if system is not None:
      name="%s:%s"%(system,name)
    s._points[name]=point_t(s._curTransform,numpy.linalg.inv(s._curTransform))

  def compute(s):
    pass

  def output(s,f):
    for key,ident in ( (0,"point_transforms"), (1,"point_inv_transforms")):
      f.write(f"${ident}=[\n")

      for k,v in s._points.items():
        ms=",\n     ".join("[%s]"%",".join("%s"%v for v in row) for row in v[key])
        f.write(
          f"  [\n"
          f"    \"{k}\",\n"
          f"    [{ms}]\n"
          f"  ],\n"
          )
      f.write("];\n")
