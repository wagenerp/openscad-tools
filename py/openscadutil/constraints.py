import slvs
from .types import marker_t
from collections import namedtuple
from .visitors.markers import MarkerVisitor
import numpy
import random

object_t=namedtuple("object_t","name transform points")
point_t=namedtuple("point_t","name object pos entity")
normal_t=namedtuple("normal_t","name direction entity")
line_t=namedtuple("line_t","name a b entity")
constraint_t=namedtuple("constraint_t","type args entity")

constraint_lut={
  "POINTS_COINCIDENT" : slvs.SLVS_C_POINTS_COINCIDENT,
  "PT_PT_DISTANCE" : slvs.SLVS_C_PT_PT_DISTANCE,
  "PT_PLANE_DISTANCE" : slvs.SLVS_C_PT_PLANE_DISTANCE,
  "PT_LINE_DISTANCE" : slvs.SLVS_C_PT_LINE_DISTANCE,
  "PT_FACE_DISTANCE" : slvs.SLVS_C_PT_FACE_DISTANCE,
  "PT_IN_PLANE" : slvs.SLVS_C_PT_IN_PLANE,
  "PT_ON_LINE" : slvs.SLVS_C_PT_ON_LINE,
  "PT_ON_FACE" : slvs.SLVS_C_PT_ON_FACE,
  "EQUAL_LENGTH_LINES" : slvs.SLVS_C_EQUAL_LENGTH_LINES,
  "LENGTH_RATIO" : slvs.SLVS_C_LENGTH_RATIO,
  "EQ_LEN_PT_LINE_D" : slvs.SLVS_C_EQ_LEN_PT_LINE_D,
  "EQ_PT_LN_DISTANCES" : slvs.SLVS_C_EQ_PT_LN_DISTANCES,
  "EQUAL_ANGLE" : slvs.SLVS_C_EQUAL_ANGLE,
  "EQUAL_LINE_ARC_LEN" : slvs.SLVS_C_EQUAL_LINE_ARC_LEN,
  "SYMMETRIC" : slvs.SLVS_C_SYMMETRIC,
  "SYMMETRIC_HORIZ" : slvs.SLVS_C_SYMMETRIC_HORIZ,
  "SYMMETRIC_VERT" : slvs.SLVS_C_SYMMETRIC_VERT,
  "SYMMETRIC_LINE" : slvs.SLVS_C_SYMMETRIC_LINE,
  "AT_MIDPOINT" : slvs.SLVS_C_AT_MIDPOINT,
  "HORIZONTAL" : slvs.SLVS_C_HORIZONTAL,
  "VERTICAL" : slvs.SLVS_C_VERTICAL,
  "DIAMETER" : slvs.SLVS_C_DIAMETER,
  "PT_ON_CIRCLE" : slvs.SLVS_C_PT_ON_CIRCLE,
  "SAME_ORIENTATION" : slvs.SLVS_C_SAME_ORIENTATION,
  "ANGLE" : slvs.SLVS_C_ANGLE,
  "PARALLEL" : slvs.SLVS_C_PARALLEL,
  "PERPENDICULAR" : slvs.SLVS_C_PERPENDICULAR,
  "ARC_LINE_TANGENT" : slvs.SLVS_C_ARC_LINE_TANGENT,
  "CUBIC_LINE_TANGENT" : slvs.SLVS_C_CUBIC_LINE_TANGENT,
  "EQUAL_RADIUS" : slvs.SLVS_C_EQUAL_RADIUS,
  "PROJ_PT_DISTANCE" : slvs.SLVS_C_PROJ_PT_DISTANCE,
  "WHERE_DRAGGED" : slvs.SLVS_C_WHERE_DRAGGED,
  "CURVE_CURVE_TANGENT" : slvs.SLVS_C_CURVE_CURVE_TANGENT,
  "LENGTH_DIFFERENCE" : slvs.SLVS_C_LENGTH_DIFFERENCE,
}

class ConstraintSystem:
  def __init__(s,absTransform,name,transform):
    s._sys=slvs.System()

    s._absTransform=absTransform
    s._name=name
    s._transform=transform
    s._objects=dict()
    s._points=dict()
    s._normals=dict()
    s._lines=dict()
    s._constraints=list()
    s._solution_points=dict()
    s._solution_matrices=dict()

  @property
  def absTransform(s): return s._absTransform
  
  @property
  def name(s): return s._name

  @property
  def transform(s): return s._transform

  def addObject(s,transform,name):
    if len(s._objects)>0:
      # a little random offset so that solving becomes easier
      transform=transform+[
        [0,0,0,random.random()],
        [0,0,0,random.random()],
        [0,0,0,random.random()],
        [0,0,0,0],
      ]
    s._objects[name]=object_t(name,transform,list())
    return s._objects[name]

  def addPoint(s,transform,object,name):
    baseTransform=s._absTransform
    if object is not None:
      if not object in s._objects:
        raise SyntaxError("non-existing object %s in system %s"%(object,s._name))
      baseTransform=s._objects[object].transform
    
    local_pos=numpy.dot(
      numpy.linalg.inv(baseTransform),
      numpy.dot(transform,[0,0,0,1])
    )
    p=point_t(name,object,local_pos,s._sys.point(*local_pos[:3]))
    s._points[name]=p
    if object is not None:
      s._objects[object].points.append(p)

  def addNormal(s,transform,object,dir):
    baseTransform=s._absTransform
    if object is not None:
      if not object in s._objects:
        raise SyntaxError("non-existing object %s in system %s"%(object,s._name))
      baseTransform=s._objects[object].transform

    local_dir=numpy.dot(
      numpy.linalg.inv(baseTransform),
      numpy.dot(transform,dir+[0])
    )
    # todo: add normal to solvespace system and remember its entity
    s._normals[name]=normal_t(name,local_dir,None)

  def addLine(s,a,b,name):

    if not a in s._points:
      raise SyntaxError("non-existing point %s in system %s"%(a,s._name))
    if not b in s._points:
      raise SyntaxError("non-existing point %s in system %s"%(b,s._name))
    
    s._lines[name]=line_t(
      name,a,b,
      s._sys.lineSegment(s._points[a].entity,s._points[b].entity))

  def addConstraint(s,type,**kwargs):
    if not type in constraint_lut:
      raise SyntaxError("unknown constraint type: %s"%type)
    type=constraint_lut[type]
    argd=dict()
    for arg,ns,key in [
      ("val",None,"valA"), 
      ("p1",s._points,"ptA"), ("p2",s._points,"ptB"), 
      ("l1",s._lines,"entityA"), ("l2",s._lines,"entityB") ]:
      if not arg in kwargs:
        pass
      elif ns is not None and kwargs[arg] not in ns:
        raise SyntaxError("non-existing entity %s in system %s"%(kwargs[arg],s._name))
      elif key in argd:
        raise SyntaxError("argument %s respecified"%key)
      elif ns is None:
        argd[key]=kwargs[arg]
      else:
        argd[key]=ns[kwargs[arg]].entity
    
    s._constraints.append(constraint_t(type,kwargs,s._sys.constrain(type,**argd)))
  
  def dump(s):
    print("system %s:"%s._name)
    for id in ["objects","lines","points","normals","constraints","solution_points","solution_matrices"]:
      print("  %s:"%id)
      c=getattr(s,"_%s"%id)
      if type(c)==dict: c=c.items()
      for v in c:
        print("    %s"%(v,))
  
  def compute(s):
    for obj in s._objects.values():
      for i1,p1 in enumerate(obj.points[:-1]):
        for i2,p2 in enumerate(obj.points[i1+1:i1+4]):
          d=numpy.linalg.norm(p1.pos[:3]-p2.pos[:3])
          s._sys.constrain(slvs.SLVS_C_PT_PT_DISTANCE,ptA=p1.entity,ptB=p2.entity,valA=d)

    s._sys.build()
    s._sys.solve()

    for k,v in s._points.items():
      s._solution_points[k]=s._sys.getCoords(v.entity)
    
    for obj in s._objects.values():
      if len(obj.points)<1: # no constraints
        continue

      if len(obj.points)==1: # translation only
        delta=s._sys.getCoords(obj.points[0].entity)-obj.points[0].pos[:3]
        m=[
          [1,0,0,delta[0]],
          [0,1,0,delta[1]],
          [0,0,1,delta[2]],
          [0,0,0,1]
        ]
      else: # complex transformation -> perform square error minimization

        A=[]
        b=[]

        for point in obj.points:
          p=point.pos
          q=s._sys.getCoords(point.entity)
          A.append([p[0],p[1],p[2],1, 0,0,0,0, 0,0,0,0]); b.append(q[0])
          A.append([0,0,0,0, p[0],p[1],p[2],1, 0,0,0,0]); b.append(q[1])
          A.append([0,0,0,0, 0,0,0,0, p[0],p[1],p[2],1]); b.append(q[2])

        x,_,_,_=numpy.linalg.lstsq(A,b)
        m=[
          [x[0],x[1],x[2],x[3]],
          [x[4],x[5],x[6],x[7]],
          [x[8],x[9],x[10],x[11]],
          [0,0,0,1]]
      s._solution_matrices[obj.name]=m


class ConstraintProcessor(MarkerVisitor):

  ident="constraints"

  def __init__(s):
    MarkerVisitor.__init__(s)
    s._systems=dict()
    s._current_object=None

  def marker_constraint_system_pre(s,name,*args,**kwargs):
    s._systems[name]=ConstraintSystem(s._curTransform,name,*args,*kwargs)
  
  def marker_object_pre(s,system,*args,**kwargs):
    if not system in s._systems:
      raise SyntaxError("non-existing marker system '%s'"%system)
    obj=s._systems[system].addObject(s._curTransform,*args,**kwargs)
    s._current_object=obj.name

  def marker_object_post(s,*args,**kwargs):
    s._current_object=None
  

  def marker_point_pre(s,system,*args,**kwargs):
    if not system in s._systems:
      raise SyntaxError("non-existing marker system '%s'"%system)
    s._systems[system].addPoint(s._curTransform,s._current_object,*args,**kwargs)

  def marker_normal_pre(s,system,*args,**kwargs):
    if not system in s._systems:
      raise SyntaxError("non-existing marker system '%s'"%system)
    s._systems[system].addNormal(s._curTransform,s._current_object,*args,**kwargs)

  def marker_line_pre(s,system,*args,**kwargs):
    if not system in s._systems:
      raise SyntaxError("non-existing marker system '%s'"%system)
    s._systems[system].addLine(*args,**kwargs)
  
  def marker_constrain_pre(s,system,*args,**kwargs):
    if not system in s._systems:
      raise SyntaxError("non-existing marker system '%s'"%system)
    s._systems[system].addConstraint(*args,**kwargs)

  def compute(s):
    for s in s._systems.values():
      s.compute()
    
  def output(s,f):
    f.write("$constraint_system_transforms=[\n")

    for csys in s._systems.values():
      for k,m in csys._solution_matrices.items():
        ms=",\n     ".join("[%s]"%",".join("%s"%v for v in row) for row in m)
        f.write(
          f"  [\n"
          f"    \"{csys.name}.{k}\",\n"
          f"    [{ms}]\n"
          f"  ],\n"
        )
    f.write("];\n")

