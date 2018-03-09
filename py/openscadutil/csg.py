import sys
from collections import namedtuple

arglist_t=namedtuple("arglist_t","args kwargs")
modhead_t=namedtuple("modhead_t","ident args kwargs")
modinst_t=namedtuple("modinst_t","ident args kwargs children")


tokens = (
  "LPAREN",
  "RPAREN",
  "LSQUARE",
  "RSQUARE",
  "LCURLY",
  "RCURLY",
  "SEMICOLON",
  "COMMA",
  "EQUALS",
  "IDENT",
  "NUMBER",
  "STRING",
  "TRUE",
  "FALSE"
)
# Tokens

t_LPAREN = r"\("
t_RPAREN = r"\)"
t_LSQUARE = r"\["
t_RSQUARE = r"\]"
t_LCURLY = r"\{"
t_RCURLY = r"\}"
t_SEMICOLON = ";"
t_COMMA = ","
t_EQUALS = "="
t_TRUE = "true"
t_FALSE = "false"

RESERVED = {
  "true": "TRUE",
  "false": "FALSE",
}

def t_IDENT(t):
  r"[a-zA-Z_][a-zA-Z0-9_]*"
  t.type=RESERVED.get(t.value,"IDENT")
  return t

def t_NUMBER(t):
  r"[0-9]+(\.[0-9]+)?"
  try:
    t.value = int(t.value)
  except ValueError:
    t.value = float(t.value)
  return t

def t_STRING(t):
  r"\"([^\"]*(\\\")?)*\""
  t.value=t.value.encode().decode("unicode_escape")
  return t

t_ignore = ' \t'


def t_newline(t):
  r'\n+'
  t.lexer.lineno += t.value.count("\n")


def t_error(t):
  raise RuntimeError("unexpected symbol encountered in csg file: '%s'"%t.value[0])
  t.lexer.skip(1)

import ply.lex as lex
lex.lex()

def p_statements(p):
  '''statements : 
                | statements statement'''
  if len(p)==1:
    p[0]=list()
  else:
    p[0]=p[1]+[p[2]]

def p_statement_empty(p):
  '''statement : LCURLY statements RCURLY '''
  p[0]=p[2]

def p_instantiation(p):
  '''statement : module_head SEMICOLON
              | module_head LCURLY statements RCURLY'''
  if len(p)==3:
    children=list()
  else:
    children=p[3]
  p[0]=modinst_t(p[1].ident,p[1].args,p[1].kwargs,children)

def p_module_header(p):
  '''module_head : IDENT LPAREN arglist RPAREN
                | IDENT LPAREN RPAREN'''
  if len(p)==5:
    p[0]=modhead_t(p[1],p[3][0],p[3][1])
  else:
    p[0]=modhead_t(p[1],list(),dict())

def p_arglist(p):
  '''arglist : arg
            | arg COMMA arglist'''
  if len(p)==2:
    args=list()
    kwargs=dict()
  else:
    args,kwargs=p[3]
  if p[1][1] is None:
    args.append(p[1][0])
  else:
    kwargs[p[1][1]]=p[1][0]
  p[0]=arglist_t(args,kwargs)


def p_arg(p):
  '''arg : IDENT EQUALS literal 
        | literal'''
  if len(p)==2:
    p[0]=(p[1],None)
  else:
    p[0]=(p[3],p[1])

def p_literallist(p):
  '''literallist : literal
                | literal COMMA literallist'''
  if len(p)==2:
    p[0]=[p[1]]
  else:
    p[0]=[p[1]]+p[3]

def p_literal(p):
  '''literal : NUMBER
            | STRING
            | list'''
  p[0]=p[1]

def p_true(p):
  '''literal : TRUE'''
  p[0]=True
def p_false(p):
  '''literal : FALSE'''
  p[0]=False

def p_list(p):
  '''list : LSQUARE literallist RSQUARE
          | LSQUARE RSQUARE'''
  if len(p)==4:
    p[0]=p[2]
  elif len(p)==3: 
    p[0]=list()


def p_error(p):
    if p:
        print("Syntax error in line %s at '%s'" % (p.lexer.lineno,p.value))
    else:
        print("Syntax error at EOF")

import ply.yacc as yacc
yacc.yacc()


parse=yacc.parse

def traverse(statements,visitor):
  for modinst in statements:
    if hasattr(visitor,"%s_pre"%modinst.ident):
      getattr(visitor,"%s_pre"%modinst.ident)(*modinst.args,**modinst.kwargs)
    traverse(modinst.children,visitor)
    if hasattr(visitor,"%s_post"%modinst.ident):
      getattr(visitor,"%s_post"%modinst.ident)(*modinst.args,**modinst.kwargs)
