import sys

def csgrepr(v):
  if type(v)==list:
    return("[%s]"%",".join(csgrepr(w) for w in v))
  elif type(v)==str:
    return("\"%s\""%v)
  else: return "%s"%v

class StorageProcessor:

  ident="store"

  def __init__(s):
    s._scalars=dict()
    s._vectors=dict()
  
  def directive(s,args,raw):
    if type(args)!=list or len(args)!=2: 
      sys.stderr.write("Warning: Invalid storage directive: pair expected\n")
      return
    k,v=args
    if type(k)!=str:
      sys.stderr.write("Warning: Invalid storage directive: string key expected\n")
      return
    if k.endswith("[]"):
      k=k[:-2]
      if not k in s._vectors: s._vectors[k]=list()
      s._vectors[k].append(v)
    else:
      if k in s._scalars:
        sys.stderr.write("Warning: storage variable %s redefined\n"%k)
      s._scalars[k]

  def compute(s):
    pass

  def output(s,f):

    for k,v in s._scalars.items():
      f.write("%s=%s;\n"%(k,csgrepr(v)))
    for k,v in s._vectors.items():
      f.write("%s=%s;\n"%(k,csgrepr(v)))