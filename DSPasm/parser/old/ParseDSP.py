#!/usr/bin/env python
#
# Important prefixs to know:
# fd - function dictionary, contains all relevant function information
#      example:
#
#    {'name':'function_name',
#     'comments':'comments...comments',
#     'inputs' :['r1','r0'],
#     'outputs':['r0','r1'],
#     'modifies':['r2'],
#     'body':'function_name: r2 = r1 + r0\n.....'}
#
# tf - total function, a string that contains the entirety of the function
#      information - body, header - in the string
#
# example:
#
# '''/*----- header info ----------*/ body body body'''
#
#

def extract_variables(str):
    """
    Input: DSP assembly variable string
    Output: List of used variables

    Takes a string from which variables should be extracted.
    Whitespace at the beginning of a line is ignored.  Variables
    should be a comma-seperated list of registers or memory
    locations.  Comments are delimited by the lack of a comma.
    Calling extract_variables on:

    r0, r1, r2 are here
    r3, r4 = lalala
    r5,r6,r7
    r8 , r9 , r10 : three variables

    should return:

    ['r0','r1','r2',.....,'r8','r9','r10']
    """

    svars = []                           #variables to return

    sl = str.split('\n')                 #split the string into lines
    sl = map( lambda x: x.lstrip(), sl )  #remove front whitespace chars
    for i in sl:
        #find the comment delimiter index,
        #then extract variables from the front part of the string
        #
        #commenter delimiter index is found by splitting the string
        #by commas, removing whitespace from string ends,
        #and find the first item in the list that contains whitespace
        if i == '':
            continue
        tmp = i.split(',')
        tmp = map( lambda x: x.strip(), tmp)
        tmp = map( lambda x: x.replace('=',' '), tmp)
        tmp = map( lambda x: x.replace('=',' '), tmp)
        index = len(tmp)
        for j in range(len(tmp)):
            if tmp[j].count(' '):
                index = j
                tmp[j] = (tmp[j].split())[0]
                break
        tmp = tmp[:(index + 1)]
        
        #double check that no variables are named : or =
        #could happen if the string """a,b, : stuff"""
        #is passed
        if (':' in tmp) or ('=' in tmp):
            raise """Syntax problem with line:\n%s""" % i
        svars.extend(tmp)
    return svars

def tfFromFile(file_str):
    """
    Input: A DSP assembly file
    Outpt: A list of string, which are function headers and bodies

    This function ignores header information at the top of the file.

    Example:
    extract_function_list('
    UH
    /*---
    FH1
    ---*/
    FB1
    /*---
    FH2
    ---*/
    FB2
    /*---
    FH3
    ---*/
    FB3
    '
    returns a list of total function strings (minus a few newline's):
    ['--- FH1 ---*/ FB1','---FH2---*/FB2','---FH3---*/FB3']
    """
    return (file_str.split('/*-'))[1:]

def asFrombd(bd_str):
    """
    Input: A body string from a function dictionary
    Output: A list of assembly statements w/o comments or labels

    Example

    asFrombd('
    test:
    r2 = r1 + r0;  //don't want me
    foo:
    bar:
    r0 = r2 - r0; r1 = r2 - r0;

    '

    should return
    ['r0 = r1 + r2;','r2 = r0 - r1;','r1 = r2 - r0;']

    """
    #First, split up the body, remove all comments
    tmp = bd_str.split('\n')
    for i in range(len(tmp)):
        if tmp[i].count('\\'):
            tmp[i] = (tmp[i].split('\\'))[0]
    #strip and remove null strings ( '' )
    tmp = map( lambda x: x.strip(), tmp )
    tmp = filter( lambda x: x != '', tmp )
    
    #next, remove all strings that end with a : (aka labels)
    tmp = filter( lambda x: not x.endswith(':'), tmp)

    #now, change statements that have commas or ; to multiple lines
    tmp2 = []
    for i in range(len(tmp)):
        tmp2.extend( tmp[i].split(';'))
    tmp = tmp2
    del tmp2

    #filter the body statments
    return asFromuas(tmp)


def asFromuas(asLst):
    """
    Take a list of assembly statements and filters out the ones
    we don't want.
    """
    reg_list = map( lambda x: 'r%s' % x, range(32))
    reg_list.extend( map( lambda x: 'i%s' % x, range(32) ) )
    return filter( lambda x: overlap(x, reg_list) , asLst )

def overlap(str, lst):
    """
    Return whether str contains any elements of lst
    overlap('abc',['a','e','m']) -> True
    overlap('abc',['e','m']) -> False
    """
    flag = False
    for i in lst:
        if str.count(i):
            print i
            flag = True
            break

    return flag

def fdFromtf(tf_str):
    """
    Input: A 'total function' string, consisting of complete contents (
    header and body) in one string.
    Output: A dictionary containing the information in a parsed manner.

    Example:
    fdFromtf('
    /*--------------------------------------------------
    function_name:
    comments comments comments
    badgers badgers badgers
    comments comments comments
    comments comments comments

    inputs:
    r1,r0
    outputs:
    r0,r1
    modifies:
    r2 : lalalala
    ----------------------------------------*/
    function_name:
    r2 = r1 + r0
    r1 = r2 - r1
    r0 = r2 - r1
    ')

    returns
    {'name':'function_name',
     'comments':'comments...comments',
     'inputs' :['r1','r0'],
     'outputs':['r0','r1'],
     'modifies':['r2'],
     'body':'function_name: r2 = r1 + r0\n.....'}

    Note that this function checks to make sure the body begins with
    function_name: but does not strip this statement.

    """
    if tf_str.count('-*/') > 1:
        raise "Function/body parse error","Function header/body contains "+\
              "more than one -*/ but only one /*-"
    if tf_str.count('-*/') == 0:
        raise "Function/body parse error","Function header/body does not "+\
              "contain the split character -*/"
    tmp = tf_str.split('-*/')
    fd = extract_header_info(tmp[0])
    fd['body'] = tmp[1]

    #check that the body has function_name: as the first statement
    if not tmp[1].lstrip().startswith(fd['name']+':'):
        raise "Body parse error","Body does not begin with the function " + \
              "name.\nExpected: %s\nFound:%s\n" % \
              (fd['name']+':',(tmp[1].lstrip().split('\n'))[0])

    return fd

def extract_header_info(header_str):
    """
    Input: DSP header string
    Output: {'name':func_name,
             'comments':comments
             'inputs':[list,of,inputs]
             'outputs':[list,of,outputs]
             'modifies':[list,of,modifies]}

    Takes a header string and returns a dict containing the function name,
    the comment string, the input variable string, the output variable
    string and the modifies variable string.

    The header string has the following structure:

    /*--------------------------------------------------
    function_name:
    comments comments comments
    badgers badgers badgers
    comments comments comments
    comments comments comments

    inputs:
    r1,r0
    outputs:
    r0,r1
    modifies:
    r1 : lalalala
    ----------------------------------------*/

    The /*-[-] at the start and [-]-*/ at the end of the argument are optional
    """
    #begin by making sure inputs:, outputs:, modifies: exist once
    if header_str.count('inputs:') != 1:
        raise "Header exception","inputs: not in header string or "+\
                                                     "occurs repeatedly"
    if header_str.count('outputs:') != 1:
        raise "Header exception","outputs: not in header string or "+\
                                                     "occurs repeatedly"
    if header_str.count('modifies:') != 1:
        raise "Header exception","modifies: not in header string or "+\
                                                     "occurs repeatedly"

    #split array into two parts based on 'modifies:' location
    #extract variable information of second part

    tmp = header_str.split('modifies:')
    usMod = tmp[1]

    tmp = tmp[0].split('outputs:')
    usOut = tmp[1]

    tmp = tmp[0].split('inputs:')
    usIn = tmp[1]

    tmp = tmp[0].split(':',1)
    usFuncName = tmp[0]
    usComment = tmp[1]

    #first, remove -*/ from the modifies/function name string
    usMod = usMod.replace(r'/',' ')
    usMod = usMod.replace(r'*',' ')
    usMod = usMod.replace(r'-',' ')
    usFuncName = usFuncName.replace(r'/',' ')
    usFuncName = usFuncName.replace(r'*',' ')
    usFuncName = usFuncName.replace(r'-',' ')

    #now, remove white space from usFuncName and raise an error if unable
    #to parse
    usFuncName = usFuncName.strip()
    if len(usFuncName.split()) > 1:
        raise "Header Exception","Unable to parse function name from "+\
                           "header:\n\n%s\n\n" % header_str
    else:
        sFuncName = usFuncName
        sMod = extract_variables(usMod)
        sOut = extract_variables(usOut)
        sIn  = extract_variables(usIn)
        sComment = usComment.strip()

    return {'name':sFuncName,
            'comments':sComment,
            'inputs':sIn,
            'outputs':sOut,
            'modifies':sMod}

def cfd_list_extra(cfd):
    """
    Input: A complete function dictionary (w/ set, queried variables)
    Output: A tuple containing:
            ( list of variables to be added to inputs,
              list of variables to be added to modifies,
              list of variables which are in inputs but not queried,
              list of variables which are in outputs but not set,
              list of variables which are in modifies but not set)

    The contents of the two lists are undefined if the function succeeds.

    Queried variables can be in inputs, outputs or modifies.
    Set variables may only be in modifies or outputs.

    example:
    cfd_list_used(
    {'name':'function_name',
     'comments':'comments\ncomments\ncomments',
     'inputs':['r0','r1','r2'],
     'outputs':['r0'],
     'modifies':['r3','r4'],
     'body':'r3 = r1 + r4\nr4 = r0 + r3\nr0 = r4\n'
     'calls':[]
     'set':['r0','r3','r4'],
     'queried':['r1','r2','r0','r3','r4']
     }
     )
    returns
    ([], [], [], [], [])

    cfd_list_used(
    {'name':'function_name',
     'comments':'comments\ncomments\ncomments',
     'inputs':['r0','r1','r2'],
     'outputs':['r0'],
     'modifies':['r3','r4'],
     'body':'r3 = r1 + r4\nr4 = r0 + r3\nr0 = r4\n'
     'calls':[]
     'set':['r0','r3','r4'],
     'queried':['r1','r2','r0','r3','r4','r5']
     }
     )    
     returns
     (['r5'],[],[],[],[])

    """
    add_in = []
    add_mod = []
    extra_in = []
    extra_out = []
    extra_mod = []
    allowed_qur = []
    allowed_set = []
    inp = cfd['inputs']
    out = cfd['outputs']
    mod = cfd['modifies']
    set = cfd['set']
    qur = cfd['queried']

    allowed_qur = list(inp)
    allowed_qur.extend(out)
    allowed_qur.extend(mod)

    allowed_set = list(out)
    allowed_set.extend(mod)

    for i in inp:
        if not (i in qur):
            extra_in.append(i)

    for i in out:
        if not (i in set):
            extra_out.append(i)

    for i in mod:
        if not (i in set):
            extra_mod.append(i)

    for i in set:
        if not (i in allowed_set):
            add_mod.append(i)

    for i in qur:
        if not ((i in allowed_qur) or (i in set)):
            add_in.append(i)

    return (add_in, add_mod, extra_in, extra_out, extra_mod)
