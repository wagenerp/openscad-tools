import sys

class InfoProcessor:

  ident="store"

  def __init__(s):
    s._three_dimensional=False
    s._projection_count=0
  
  @property
  def three_dimensional(s): return s._three_dimensional

  def projection_pre(s,**kwargs):
    s._projection_count+=1
  def projection_post(s,**kwargs):
    s._projection_count-=1
  
  def linear_extrude_pre(s,**kwargs):
    if s._projection_count==0:
      s._three_dimensional=True
  def cube_pre(s,**kwargs):
    if s._projection_count==0:
      s._three_dimensional=True
  def cylinder_pre(s,**kwargs):
    if s._projection_count==0:
      s._three_dimensional=True
  def sphere_pre(s,**kwargs):
    if s._projection_count==0:
      s._three_dimensional=True
  def polyhedron_pre(s,**kwargs):
    if s._projection_count==0:
      s._three_dimensional=True
  def import_pre(s,**kwargs):
    if s._projection_count==0:
      s._three_dimensional=True
  
  def compute(s):
    pass

  def output(s,f):
    pass