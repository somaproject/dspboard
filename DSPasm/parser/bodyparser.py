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
statement      := ( (var_list, var_comment?) /
                     whitespace              /
                     comment),
                     newline?

var_list       := var_name,(whitespace?,',',whitespace?,var_name)*
var_name       := [a-zA-Z], [a-zA-Z0-9_]*
var_comment    := tonewline

comment        := ('//',tonewline,newline*) / ('/*',-'*/'*,'*/')
whitespace     := (newline / white)*
white          := ' ' / '\t' / '\v'
tonewline      := -(newline)*
newline        := '\n'/'\r'
newlines       := newline+
'''

bodyDeclaration = r'''
f_body         := f_name_line,statements

f_name_line    := w,label,(comment / (white*, newline*))
f_name         := label
statements     := statement*
statement      := w,(  comment /
                       (asm_statement,(',',w,asm_statement)*,';') /
                       (extern_statement,';')  /
                       label /
                       newline), w,comment?,(w,newline*)?

label          := var_name,w,':'

extern_statement:= '.EXTERN',w,var_name,w

asm_statement  := (func_call    /
                   if_statement /
                   branch_statement /
                   dm_pm_statement  /
                   misc_statement   /
                   alu_op),w

misc_statement := bit_statement /
                  mod_statement /
                  clear_statement /
                  'NOP' /
                  'IDLE' /
                  cjump_statement
bit_statement  := 'BIT',w,bit_keyword,w,(sreg/var_name),w,constant
mod_statement  := ('MODIFY'/'BITREV'),'(',w,sreg,w,constant,w,')'
clear_statement:= pushORpop,w,var_name,w,pushORpop,w,var_name,w,pushORpop,w,var_name,w,'FLUSH',w,'CACHE'
cjump_statement:= 'RFRAME'

pushORpop      := 'PUSH' / 'POP'
bit_keyword    := 'SET' / 'CLR' / 'TGL' / 'TST' / 'XOR'

dm_pm_statement:= (dm_pm_func,w,'=',w,qreg)/(sreg,w,'=',w,dm_pm_func)/(dm_pm_func,w,'=',w,constant)

dm_pm_func     := dmORpm,'(',w,(constant,((w,',',w,qreg)/(w,'+',w,integer))?)/(qreg,w,',',w,qreg),w,')'
dmORpm         := 'DM'/'PM'

branch_statement := ('JUMP',w,var_name) / 'RTS'

if_statement   := 'IF',w,if_clause,w,asm_statement
#                 if foo assembly_statemenlento

if_clause      := 'EQ' / 'NE' / 'GT' / 'LT' / 'GE' / 'LE' / 'AC' / ('NOT',w,'AC') / 'AV' / ('NOT',w,'AV') / 'MV' / ('NOT',w,'MV') / 'MS' / ('NOT',w,'MS') / 'SV' / ('NOT',w,'SV') / 'SZ' / ('NOT',w,'SZ') / 'TF' / ('NOT',w,'TF')


func_call      := 'CALL',white+,func_name

func_name      := var_name

alu_op         :=  ((prefunccode)/(inopcode)/(avgcode)/(constantcode))


constantcode   := sreg,w,'=',w,constant
#                 r0 = CONSTANT

prefunccode    := (sreg,w,'=',w)?,prefuncname,w,'(',w,(qreg,w,(',',w,qreg,w)?)/ (constant,w),')'
#                 [r0 =] PREFUNC( {r1[,r2]}|{CONSTANT} )


inopcode      := sreg,w,'=',w,qur,(w,inopname,w,qur)*

avgcode        := sreg,w,'=',w,'(',w,qreg,w,'+',w,qreg,w,')',w,'/',w,'2'
#                 r0 = (r1+r2)/2

preopname      := '-' / 'ABS' / 'PASS' / 'NOT' / 'CLIP' / 'RND' / 'SCALB' /'MANT' / 'LOGB' / 'FIX' / 'TRUNC' / 'FLOAT' / 'RECIPS' / 'RSQRTS' / 'FEXT' / 'LSHIFT' / 'FDEP' / 'LSHIFT' / 'ASHIFT' / 'BCLR' / 'BSET'
prefuncname    := 'COMP'/'COMPU'/'MIN'/'MAX'/'DM'
inopname       := '+' / '-' / 'COPYSIGN' / '|' / 'OR'

sreg           := reg

qur            := qreg / oped_reg / constant
qreg           := reg


constant       := number / var_name

oped_reg       := preopname,w,qreg,w,
                  ('BY',w,(qreg / (number,(':',number)?)))?
reg            := reg_type,reg_number
reg_type       := 'R' / 'F' / 'SF' / 'I' / 'M' / 'L' / 'B' / 'USTAT'
reg_number     := integer

integer        := [0-9]+
number         := bin_number / hex_number / ('-'?,integer,('.',integer)?)
hex_number     := '0X',[0-9A-F]+
bin_number     := '0B',('0' / '1')*

var_name       := [A-Z], [a-zA-Z0-9_.]*
comment        := ('//',tonewline,newline*) / ('/*',-'*/'*,'*/')
w              := white*
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


def extractVars(bodyStr):
    """Returns a list of the listed variables in the
    body statement
    
    Inputs:
    inputBodyStr - text betwixt foo: and bar:
    Outputs:
    a list of input variables listed
    """
    bodyTree = varsParser.parse(bodyStr)
    vars = []
    treeWalker('var_name',
               lambda a: vars.append(bodyStr[a[1]:a[2]]),
               bodyTree[1])
    return vars    
    
parser = Parser( declaration, "file" )
varsParser = Parser( varsDeclaration, "statements" )
bodyParser = Parser(  bodyDeclaration,  "f_body" )
if __name__ =="__main__":

    bodies = []

    if(len(sys.argv) < 2):
        raise 'Usage Error', '\n\nusage: %s file\n\n' % sys.argv[0]

    f = open(sys.argv[1])
    text = f.read()
    f.close()

    parseTree = parser.parse( text )
    #parse tree is of the form:
    # (start_index,[sub_tree,sub_tree,sub_tree,...],end_index)
    # sub_tree = (obj_name,start,end,[sub_tree,...])

    # do some basic tests on the inputs/outputs/modifies strings
    # to make sure they don't have stupid values
    treeWalker('input_pair_b',lambda a: assertNoEndComment(text[a[1]:a[2]]),
               parseTree[1])
    treeWalker('output_pair_b',lambda a: assertNoEndComment(text[a[1]:a[2]]),
               parseTree[1])
    treeWalker('modifies_pair_b',lambda a: assertNoInputs(text[a[1]:a[2]]),
               parseTree[1])

    treeWalker('f_body',lambda a: bodies.append(text[a[1]:a[2]]),
               parseTree[1])

    test = map( lambda x: x.upper().strip(), bodies)
    
    for i in test:
        bodyParseTree = bodyParser.parse(i)
        next_chars = len(i) - bodyParseTree[2]
        next_chars = min(100,next_chars)
#        if True:
        if next_chars > 0:
#            pprint.pprint(i)
            print '\n'
#            pprint.pprint(bodyParseTree)
            print '\n\n'
            print "string length: %s" % len(i)
            print "parsed to: %s"     % bodyParseTree[2]
            print "next few chars:\n"

            pprint.pprint(i[bodyParseTree[2]:
                            bodyParseTree[2]+next_chars])
            print '-------------------------------------------------------------'


    if parseTree[2] != len(text):
        next_chars = len(text) - parseTree[2]
        next_chars = min(100,next_chars)
        print "didn't parse beyond %s character: next few chars\n\n%s"%\
              (parseTree[2],text[parseTree[2]:parseTree[2]+next_chars])

    
