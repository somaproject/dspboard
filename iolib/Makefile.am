## Makefile.am -- Process this file with automake to produce Makefile.in
ACLOCAL_AMFLAGS = -I m4

SUBDIRS = src tests

AM_CXXFLAGS = $(BOOST_CPPFLAGS)  $(BOOST_THREAD_CPPFLAGS) $(FAKESRC_CFLAGS) -pthread 
AM_LDFLAGS = $(BOOST_LDFLAGS)  $(BOOST_THREAD_LDFLAGS) $(FAKESRC_LIBS) $(BOOST_THREAD_LIB)

LIBS =  $(BOOST_THREAD_LDFLAGS) 
pkgconfigdir = $(libdir)/pkgconfig
pkgconfig_DATA = somadspio-1.0.pc
