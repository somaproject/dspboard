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

f_header_main  := whitespace,func_name_h!,func_h_body!,func_variables!

func_name_h    := func_name,(':' / ';')
func_name      := var_name
func_h_body    := -(input_pair_h)*
func_variables := input_pair,output_pair,modifies_pair,whitespace

input_pair     := input_pair_h,input_pair_b
input_pair_h   := 'inputs',(':'/';')
input_pair_b   := -(output_pair_h)*

output_pair    := output_pair_h,output_pair_b
output_pair_h  := 'outputs',(':' / ';')
output_pair_b  := -(modifies_pair_h)*

modifies_pair  := modifies_pair_h,modifies_pair_b
modifies_pair_h:= 'modifies',(':'/';')
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

#takes an input/output/modifies pair body
varsDeclaration = r'''
statements     := statement*
statement      := ( (var_list, var_comment?) /
                     comment                 /
                     whitespace),
                     newline?

var_list       := var_name,(whitespace?,',',whitespace?,var_name)*
var_name       := [a-zA-Z], [a-zA-Z0-9_]*
var_comment    := tonewline

comment        := ('//',tonewline) / ('/*',-'*/'*,'*/')
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

dm_pm_func     := dmORpm,'(',w,(qreg,w,',',w,qreg)/(constant,((w,',',w,qreg)/(w,'+',w,integer))?),w,')'
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

def treeWalkerReturn(key,parse_lst):
    """Return the two indices associated with a key in a tree
    in the list [start,end]

    False is returned if the key isn't in the parse list
    """
    for i in parse_lst:
        if i[0] == key:
            return [i[1],i[2]]
        else:
            start_end = treeWalkerReturn(key,i[3])
            if start_end:
                return start_end
            else:
                continue
    return False

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

def varCheck(str):
    """Check that str is a valid register name

    True if a valid name, else false
    """
    j = str.upper()
    prefix = ['R','F','SF','I','M','L','B','USTAT']
    flag = True
    flag = flag and reduce( lambda a,b: a or j.startswith(b),
                            prefix,
                            False)
    return flag
    
parser = Parser( declaration, "file" )
headerVarsParser = Parser( varsDeclaration, "statements" )
bodyParser = Parser(  bodyDeclaration,  "f_body" )
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

    # do some basic tests on the inputs/outputs/modifies strings
    # to make sure they don't have stupid values
    treeWalker('input_pair_b',lambda a: assertNoEndComment(text[a[1]:a[2]]),
               parseTree[1])
    treeWalker('output_pair_b',lambda a: assertNoEndComment(text[a[1]:a[2]]),
               parseTree[1])
    treeWalker('modifies_pair_b',lambda a: assertNoInputs(text[a[1]:a[2]]),
               parseTree[1])


    #f_pairs contains the sub_trees for all the function pairs
    f_pairs = []
    treeWalker('f_pair',
               lambda a: f_pairs.append(a),
               parseTree[1])

#    def print_foo(x):
#        print x

#    def print_qreg(x,i):
#        if i.strip() != '':
#            print 'statement:\n',i[x[1]:x[2]]
#            treeWalker('sreg',
#                       lambda a: print_foo('\nsreg:\n'+i[a[1]:a[2]]),
#                       x[3])
#            treeWalker('qreg',
#                       lambda a: print_foo('\nqreg:\n'+i[a[1]:a[2]]),
#                       x[3])
#            print '\n\n'

    fd_lst = []
    
    for i in f_pairs:
        fd = dict({})

        # extract out the various important parts
        # of the function information
        # start_end contains the start and end indices of said parts
        #print i[3]

        start_end = treeWalkerReturn('f_body',i[3])
        f_body = text[start_end[0]:start_end[1]].upper().strip()
        
        start_end = treeWalkerReturn('func_name',i[3])
        f_name = text[start_end[0]:start_end[1]]

        start_end = treeWalkerReturn('input_pair_b',i[3])
        ipb = text[start_end[0]:start_end[1]]

        start_end = treeWalkerReturn('output_pair_b',i[3])
        opb = text[start_end[0]:start_end[1]]

        start_end = treeWalkerReturn('modifies_pair_b',i[3])
        mpb = text[start_end[0]:start_end[1]]

        fd['name'] = f_name
        fd['body_txt'] = f_body
        fd['input_txt'] = ipb
        fd['output_txt'] = opb
        fd['modifies_txt'] = mpb

        fd_lst.append(dict(fd))

    # fd_lst should now be a list of all the different
    # function dictionaries

    for i in fd_lst:

        #query, set, input, output, modifies register lists
        qreg = []
        sreg = []
        ireg = []
        oreg = []
        mreg = []

        #setup body, header trees
        #walk them to find appropriate register lists
        bodyParseTree = bodyParser.parse(i['body_txt'])
        iParseTree = headerVarsParser.parse(i['input_txt'])
        oParseTree = headerVarsParser.parse(i['output_txt'])
        mParseTree = headerVarsParser.parse(i['modifies_txt'])

        #check that the body was totally parsed
        #else spit out some information
        next_chars = len(i['body_txt']) - bodyParseTree[2]
        next_chars = min(100,next_chars)
        #        if True:
        if next_chars > 0:
            print 'Problem parsing body:\n'
            print "body string length: %s" % len(i['body_txt'])
            print "body parsed to: %s"     % bodyParseTree[2]
            print "next few chars:\n"
            pprint.pprint(i['body_txt'][bodyParseTree[2]:
                                         bodyParseTree[2]+next_chars])
            print '-----------------------------------------------------------'


        print
        print
        print 'f_name',i['name']

        #keep going, attempting to find q/s/i/o/mreg
        treeWalker('qreg',
                   lambda a: qreg.append(i['body_txt'][a[1]:a[2]]),
                   bodyParseTree[1])

        print 'qreg',qreg

        treeWalker('sreg',
                   lambda a: sreg.append(i['body_txt'][a[1]:a[2]]),
                   bodyParseTree[1])

        print 'sreg',sreg

        treeWalker('var_name',
                   lambda a: ireg.append(i['input_txt'][a[1]:a[2]]),
                   iParseTree[1])

        treeWalker('var_name',
                   lambda a: oreg.append(i['output_txt'][a[1]:a[2]]),
                   oParseTree[1])

        treeWalker('var_name',
                   lambda a: mreg.append(i['modifies_txt'][a[1]:a[2]]),
                   mParseTree[1])

        #check all the variables in ireg, oreg, mreg to make sure
        #they're all registers
        for j in ireg:
            if not varCheck(j):
                print ('In func %s, input register list has ' % i['name'])+\
                      'a non-standard register name: %s' % j

        for j in oreg:
            if not varCheck(j):
                print ('In func %s, output register list has ' % i['name'])+\
                      'a non-standard register name: %s' % j

        for j in mreg:
            if not varCheck(j):
                print ('In func %s, modifies register list has ' % i['name'])+\
                      'a non-standard register name: %s' % j

        print 'ireg',ireg
        print 'oreg',oreg
        print 'mreg',mreg
        print
        print


        for j in ireg:
            j = j.upper()
            prefix = ['R','F','SF','I','M','L','B','USTAT']
            noflag = True
            noflag = noflag and reduce( lambda a,b: a or j.startswith(b),
                                        prefix,
                                        False)
            if not noflag:
                print ('In func %s, input register list has ' % i['name'])+\
                      'a non-standard register name: %s' % j


        i['qreg'] = qreg
        i['sreg'] = sreg
        i['ireg'] = ireg
        i['oreg'] = oreg
        i['mreg'] = mreg
            
    if parseTree[2] != len(text):
        next_chars = len(text) - parseTree[2]
        next_chars = min(100,next_chars)
        print "didn't parse beyond %s character: next few chars\n\n%s"%\
              (parseTree[2],text[parseTree[2]:parseTree[2]+next_chars])

    
