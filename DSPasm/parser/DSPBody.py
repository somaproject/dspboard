#!/usr/local/bin/python

from mx.TextTools import *

head_pos = 0

def jump_count(taglist,txt,l,r,subtag):
    global head_pos
    if head_pos is None:
        head_pos = r
    elif head_pos == r:
        raise "InfiniteLoopError", \
              txt[l-20:l]+'{'+txt[l]+'}'+txt[l+1:r+15]
    else:
        head_pos = r

labels = []

label_parser = (labels, AppendToTag+Table,
                (#check for non-white-space
                 (None,AllIn,alphanumeric+'._'),
                 (None,Is,':'),
                 (None,IsIn, white+newline),
                 (None,Skip, -1)
                 ))

statements = []

statement_parser = (statements, AppendToTag+Table,)

includes = []

include_parser = \
      (includes, AppendToTag+Table,
       (#check for #
        (None,IsIn,'''.#'''),
        (None,AllNotIn,newline),
        (None,AllIn,newline),
        (None, Skip, -1)
        ))

comments = []

comment_parser = \
      (comments, AppendToTag+Table,
       (#check for //
        (None,Word,'''//'''),
        (None,AllNotIn,newline),
        (None,AllIn,newline),
        (None, Skip, -1)
        ))

statements = []

statement_parser = \
       (statements, AppendToTag+Table,
        (#check for alphanumeric, run until hit a , or ;
         #need to recurse to do paren matching :>
         (None,IsIn,a2z+A2Z),
         (None,AllNotIn,';,('),
         (None,IsIn,';,',+1,+10),
         (None,AllNotIn,')',-10,-2)))

#(tagobj, command+flags, command_argument, [,jump_no_match] [,jump_match=+1])
tag_table = (
             include_parser+(+1,0),
             comment_parser+(+1,-1),
             label_parser+(+1,-2),
             statement_parser+(+1,-3),
             (None,AllIn,white+newline,+1,-4),
             (None,IsNotIn,white+newline,+1), # uninteresting
             (jump_count, Skip+CallTag, 0),      # Check for infinite loop
             (None,EOF,Here,-7)) # EOF

set = []

eq_set = (set,AppendToTag+Table,
                 (
    (None,AllNotIn,';=\n'),
    (None,Is,'='),
    (None,Skip,-1)), +2, +1)

qur=[]

eq_qur = (qur,AppendToTag+Table,
          (
    (None,Is,'='),
    (None,AllNotIn,',;'+newline),
    (None,AllIn,',;'+newline)),+1,-3)

 #for parsing statements
statement_table = ((None,Word,'''rts''',+1,0),
                   (None,Table,((None,Word,'''if'''),
                                (None,AllIn,white),
                                (None,AllIn,alpha+'_.'),
                                (None,AllIn,white))
                                            ,+1,-1),
                   eq_set,
                   eq_qur,
                   (None,IsNotIn,'',-4),
                   (None,EOF,Here,-5),
                   )


if __name__ == '__main__':
    
    import sys

    # read in a file
    f = open(sys.argv[1])
    text = f.read()

    t = TextTools._timer()

    t.start()
    # don't need a taglist, so pass None
    result, taglist, nextindex = tag(text,tag_table,0,len(text))

    statement_body = reduce(lambda x,y:x+'\n'+text[y[1]:y[2]],statements,'')
    
    st_result, st_taglist, st_nextindex = tag(statement_body,
        statement_table,0,len(text))
    t = t.stop()

    print taglist

#    for i in taglist:
#        print i,' ', text[i[1]:i[2]]

#    print 'labels'
#    for n,l,r,d in labels:
#        print ' ',text[l:r]
#    print
#    print 'comments'
#    for n,l,r,d in comments:
#        print ' ',text[l:r]
#    print
#    print 'includes'
#    for n,l,r,d in includes:
#        print ' ',text[l:r]
#    print
#    print 'statements'
#    for n,l,r,d in statements:
#        print ' ',text[l:r]
#    print

#    print statement_body

    print 'set'
    for i in set:
        print ' ',statement_body[i[1]:i[2]]
    print
