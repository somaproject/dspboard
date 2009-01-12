# 

h_sources = dspcontrol.h eventcodec.h const.h
cc_sources = dspcontrol.cc eventcodec.cc
library_includedir=$(includedir)/$(GENERIC_LIBRARY_NAME)-$(GENERIC_API_VERSION)/$(GENERIC_LIBRARY_NAME)
library_include_HEADERS = $(h_sources)

library_CXXFLAGS =  $(SOMADEPS_CFLAGS)

lib_LTLIBRARIES= libsomadspio-1.0.la
libsomadspio_1_0_la_SOURCES= $(h_sources) $(cc_sources)
libsomadspio_1_0_la_CXXFLAGS= $(SOMADEPS_CFLAGS)
libsomadspio_1_0_la_LDFLAGS= -version-info $(GENERIC_LIBRARY_VERSION) -release $(GENERIC_RELEASE)
