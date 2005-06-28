#!/usr/bin/env python

from simpleparse.parser import Parser
import pprint
import sys

#   ?  0 or 1
#   +  1 or more
#   *  0 or more

declaration = r'''# note use of raw string when embedding in python code...
file           := header,body

header         := whitespace,include*
include        := include_symb,tonewline,newlines
include_symb   := '.'/"#"

body           := flotsam, f_pairs        # f_pair is a function pair

flotsam        := -(func_h_start)*

######################## start header stuff #############################

func_h_start   := '/*-'
func_h_end     := '-'*,'*/'

f_pairs        := f_pair*
f_pair         := f_header,f_body
f_header       := func_h_start!,'-'*,newline*,f_header_main!,func_h_end!
f_body         := -(func_h_start)*

f_header_main  := whitespace,func_name!,func_h_body!,func_variables!

func_name      := var_name,':'
func_h_body    := -(input_pair_h)*
func_variables := input_pair,output_pair,modifies_pair,whitespace

input_pair     := input_pair_h,input_pair_b
input_pair_h   := 'inputs:'
input_pair_b   := -(output_pair_h)*

output_pair    := output_pair_h,output_pair_b
output_pair_h  := 'outputs:'
output_pair_b  := -(modifies_pair_h)*

modifies_pair  := modifies_pair_h,modifies_pair_b
modifies_pair_h:= 'modifies:'
modifies_pair_b:= -(func_h_end)*

comment        := ('//',tonewline,newline*) / ('/*',-'-'*,'*/')

######################### end header / start body stuff ###################



########################## end body stuff #################################
whitespace     := (newline / white)*
white          := ' ' / '\t' / '\v'
var_name       := [a-zA-Z], [a-zA-Z0-9_]*
tonewline      := -(newline)*
newline        := '\n'/'\r'
newlines       := newline+
'''

tmp = '''
body           :=  statement*
statement      :=  (ts,';',comment,'\n')/equality/nullline
nullline       :=  ts,'\n'
comment        :=  -'\n'*
equality       :=  ts, identifier,ts,'=',ts,identified,ts,'\n'
identifier     :=  [a-zA-Z], [a-zA-Z0-9_]*
identified     :=  ('"',string,'"')/number/identifier
ts             :=  [ \t]*
char           :=  -[\134"]+
number         :=  [0-9eE+.-]+
string         :=  (char/escapedchar)*
escapedchar    :=  '\134"' / '\134\134"'
'''

parser = Parser( declaration, "file" )
if __name__ =="__main__":


    if(len(sys.argv) < 2):
        raise 'Usage Error', '\n\nusage: %s file\n\n' % sys.argv[0]

    f = open(sys.argv[1])
    text = f.read()
    f.close()

    parseTree = parser.parse( text )
    #parse tree is of the form:
    # (start_index,[sub_tree,sub_tree,sub_tree,...],end_index)
    # sub_tree = (obj_name,start,[sub_tree,...],end)
    pprint.pprint( parseTree )

    if parseTree[2] != len(text):
        next_chars = len(text) - parseTree[2]
        next_chars = min(100,next_chars)
        print "didn't parse beyond %s character: next few chars\n\n%s"%(parseTree[2], text[parseTree[2]:parseTree[2]+next_chars])


