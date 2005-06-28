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

varsDeclaration = r'''
statements     := statement*
statement      := ( whitespace /
                    comment    /
                    (var_list, var_comment?) ),
                    newline?


var_list       := var_name,(whitespace?,',',whitespace?,var_name)*
var_name       := -(white / '//' / '/*' )+
var_comment    := tonewline

comment        := ('//',tonewline,newline*) / ('/*',-'-'*,'*/')
whitespace     := (newline / white)*
white          := ' ' / '\t' / '\v'
tonewline      := -(newline)*
newline        := '\n'/'\r'
newlines       := newline+
'''

def treeWalker(key,function,parse_lst):
    """Walk a parse list until the tuple with tuple[0] == key,
    recurse first, then call function(tuple)
    """
    for i in parse_lst:
        treeWalker(key,function,i[3])
        if i[0] == key:
            function(i)

def assertNoEndComment(a):
    if '-*/' in a:
        raise "Parse End Comment Error","No end comment should be in "+\
              "\n\n%s\n\nCheck for a typo in outputs: or modifies:" % a

def assertNoInputs(a):
    if 'inputs' in a:
        raise "Parse Inputs Error","No inputs: should be in "+\
              "\n\n%s\n\nCheck for a typo in outputs: or modifies:" % a


parser = Parser( declaration, "file" )
varsParser = Parser( varsDeclaration, "statements" )
if __name__ =="__main__":


    if(len(sys.argv) < 2):
        raise 'Usage Error', '\n\nusage: %s file\n\n' % sys.argv[0]

    f = open(sys.argv[1])
    text = f.read()
    f.close()

    parseTree = parser.parse( text )
    #parse tree is of the form:
    # (start_index,[sub_tree,sub_tree,sub_tree,...],end_index)
    # sub_tree = (obj_name,start,end,[sub_tree,...])
    pprint.pprint( parseTree )

    # do some basic tests on the inputs/outputs/modifies strings
    # to make sure they don't have stupid values
    treeWalker('input_pair_b',lambda a: assertNoEndComment(text[a[1]:a[2]]),
               parseTree[1])
    treeWalker('output_pair_b',lambda a: assertNoEndComment(text[a[1]:a[2]]),
               parseTree[1])
    treeWalker('modifies_pair_b',lambda a: assertNoInputs(text[a[1]:a[2]]),
               parseTree[1])

    treeWalker('input_pair_b',lambda a: pprint.pprint(text[a[1]:a[2]]),
               parseTree[1])

    pprint.pprint(varsParser.parse(' \r\n\r r10 r11 \n\n '))

#    treeWalker('input_pair_b',lambda a: pprint.pprint(varsParser.parse(text[a[1]:a[2]])),
#               parseTree[1])

    if parseTree[2] != len(text):
        next_chars = len(text) - parseTree[2]
        next_chars = min(100,next_chars)
        print "didn't parse beyond %s character: next few chars\n\n%s"%\
              (parseTree[2],text[parseTree[2]:parseTree[2]+next_chars])