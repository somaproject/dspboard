## Makefile.am -- Process this file with automake to produce Makefile.in
ACLOCAL_AMFLAGS = -I m4

SUBDIRS = src 

AM_CXXFLAGS = $(BOOST_CPPFLAGS) $(FAKESRC_CFLAGS) -pthread 
AM_LDFLAGS = $(BOOST_LDFLAGS) $(FAKESRC_LIBS) $(BOOST_THREAD_LIB)


pkgconfigdir = $(libdir)/pkgconfig
pkgconfig_DATA = somadspio-1.0.pc
