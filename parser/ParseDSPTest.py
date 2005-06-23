import ParseDSP

def test_variable_extraction():
    #
    #extract variables cases
    #
    ev = ParseDSP.extract_variables("""
    r0, r1, r2 are here
    r3, r4 = lalala
    r5,r6,r7
    r8 , r9 , r10 : three variables
    r11=stuff
        """)
    if ev != ['r0','r1','r2','r3','r4','r5','r6','r7','r8','r9','r10','r11']:
        raise "\n\nTest case failed - variable extract case"

    ev = ParseDSP.extract_variables("""

        """)

    if ev != []:
        raise "\n\nTest case failed - variable extract case"

def test_header_extraction():
    #
    #header inputs: outputs: modifies: test case
    #
    flag = True
    try:
        ParseDSP.extract_header_info("func_name: comments inputs: outputs:")
    except:
        flag = False

    try:
        ParseDSP.extract_header_info("func_name: comments inputs: modifies:")
    except:
        flag = False

    try:
        ParseDSP.extract_header_info("func_name: comments outputs: modifies:")
    except:
        flag = False

    if flag:
        raise '''Improper Parse''','"modifies:", "inputs:", or "outputs:"'+\
              ' not in header\n\n'

    test_header = """
    /*--------
    test_func:
    comments one
    two
    three

    inputs:
    r1,r0
    r3
    outputs:
    r0
    modifies:
    r1 : lalala
    ---------*/
    """

    header = ParseDSP.extract_header_info(test_header)

    if header['name'] != 'test_func':
        raise "Improper Parse","Expected test_func for function name, "+\
              "but %s was returned from \n%s\n\n"%(header['name'],test_header)
    if header['comments'].replace(' ','') != 'commentsone\ntwo\nthree':
        raise "Improper Parse","Expected a different comment\n"+\
                               "Returned:%s\nExpected:%s"%\
                               (header['comments'],'comments one\ntwo\nthree')
    if header['inputs'] != ['r1','r0','r3']:
        raise "Improper Parse","Expected different inputs variables:"+\
              "Returned:%s\nExpected:%s"%(header['inputs'],['r1','r0','r3'])

    if header['outputs'] != ['r0']:
        raise "Improper Parse","Expected different outputs variables:"+\
              "Returned:%s\nExpected:%s"%(header['outputs'],['r0'])

    test_header = """
    /*--------

    comments one
    two
    three

    inputs:
    r1,r0
    outputs:
    r0
    modifies:
    r1 : lalala
    ---------*/
    """

    flag = True
    try:
        header = ParseDSP.extract_header_info(test_header)        
    except:
        flag = False

    if flag:
        raise "Improper Parse","Expected error for lack of function name"+\
              ", but no error returned"

    test_header = """
    /*--------
    func_name:

    comments one
    two
    three

    inputs:
    r1,r0
    outputs:
    r0

    r1 : lalala
    ---------*/
    """

    flag = True
    try:
        header = ParseDSP.extract_header_info(test_header)        
    except:
        flag = False

    if flag:
        raise "Improper Parse","Expected error for lack of modifies:"+\
              ", but no error returned"

def test_fdFromtf():
    tfTest = r'''
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
    '''

    fd = ParseDSP.fdFromtf(tfTest)

    if fd['name'] != 'function_name':
        raise "fd from tf error","Incorrect function name returned\n" + \
              "Expected: %s \n Found: %s \n String: %s" % \
              ('function_name',fd['name'],tfTest)

    if fd['inputs'] != ['r1','r0']:
        raise "fd from tf error","Incorrect inputs returned\n" + \
              "Expected: %s \n Found: %s \n String: %s" % \
              (['r1','r0'],fd['inputs'],tfTest)

    tfTest = r'''
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

    func_name:
    r2 = r1 + r0
    r1 = r2 - r1
    r0 = r2 - r1
    '''

    flag = True
    try:
        fdTest = ParseDSP.fdFromtf(tfTest)
    except:
        flag = False

    if flag:
        raise "Parse Error","Expected incorrect function name, no error " + \
              "returned."

def test_cfd_list_extra():
    test_dict = {
        'name':'function_name',
        'comments':'comments\ncomments\ncomments',
        'inputs':['r0','r1','r2'],
        'outputs':['r0'],
        'modifies':['r3','r4'],
        'body':'r3 = r1 + r4\nr4 = r0 + r3\nr0 = r4\n',
        'calls':[],
        'set':['r0','r3','r4'],
        'queried':['r1','r2','r0','r3','r4']
    }

    result = ParseDSP.cfd_list_extra(test_dict)

    if result != ([],[],[],[],[]):
        raise "Parse Test Error","expected cfs_list_extra to return with " + \
                                 "five empty lists"

    test_dict = {
        'name':'function_name',
        'comments':'comments\ncomments\ncomments',
        'inputs':['r0','r1','r2','r10'],
        'outputs':['r0'],
        'modifies':['r3','r4'],
        'body':'r3 = r1 + r4\nr4 = r0 + r3\nr0 = r4\n',
        'calls':[],
        'set':['r0','r3','r4'],
        'queried':['r1','r2','r0','r3','r4','r5']
    }

    list_tuple = ParseDSP.cfd_list_extra(test_dict)

    if list_tuple[0] != ['r5']:
        raise "Parse Test Error"
    if list_tuple[2] != ['r10']:
        raise "Parse Test Error"


def test():
    test_variable_extraction()
    test_header_extraction()
    test_fdFromtf()
    test_cfd_list_extra()
    print "\n\nAll tests okay.\n\n"
    return True
