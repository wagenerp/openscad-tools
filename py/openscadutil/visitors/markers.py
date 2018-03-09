from collections import namedtuple
import numpy

class MarkerVisitor:
  marker_t=namedtuple("marker_t","args kwargs transform absTransform parent")

  def __init__(s):

    s.markers=list()

    s._curTransform=[
      [1,0,0,0],
      [0,1,0,0],
      [0,0,1,0],
      [0,0,0,1]
    ]
    s._transform_stack=[]
    s._marker_stack=[]

  def multmatrix_pre(s,m):
    s._transform_stack.append(s._curTransform)
    s._curTransform=numpy.dot(s._curTransform,m)
  
  def multmatrix_post(s,m):
    s._curTransform=s._transform_stack.pop()
    
  def marker_pre(s,*args,**kwargs):
    transform=s._curTransform
    parent=None

    if len(s._marker_stack)>0:
      parent=s._marker_stack[-1]
      transform=numpy.dot(numpy.linalg.inv(s.markers[parent].absTransform),transform)


    s._marker_stack.append(len(s.markers))
    s.markers.append(MarkerVisitor.marker_t(
      args,kwargs,transform,s._curTransform,parent))

  def marker_post(s,*args,**kwargs):
    s._marker_stack.pop()

