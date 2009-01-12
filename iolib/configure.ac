#
# This is partly based on
# http://www.openismus.com/documents/linux/building_libraries/building_libraries.shtml
# and 
# Prelude . 
AC_INIT([somadspio], [1.0], [soma-bugs@mit.edu])
AC_CONFIG_SRCDIR([src/dspcontrol.cc])


AM_CONFIG_HEADER(config.h)

dnl -----------------------------------------------
dnl Package name and version number (user defined)
dnl -----------------------------------------------

GENERIC_LIBRARY_NAME=somadspio

#release versioning
GENERIC_MAJOR_VERSION=0
GENERIC_MINOR_VERSION=3
GENERIC_MICRO_VERSION=0

#API version (often = GENERIC_MAJOR_VERSION.GENERIC_MINOR_VERSION)
GENERIC_API_VERSION=1.0
AC_SUBST(GENERIC_API_VERSION)

#shared library versioning
GENERIC_LIBRARY_VERSION=1:2:0
#                       | | |
#                +------+ | +---+
#                |        |     |
#             current:revision:age
#                |        |     |
#                |        |     +- increment if interfaces have been added
#                |        |        set to zero if interfaces have been removed
#                                  or changed
#                |        +- increment if source code has changed
#                |           set to zero if current is incremented
#                +- increment if interfaces have been added, removed or changed


dnl --------------------------------
dnl Package name and version number
dnl --------------------------------

AC_SUBST(GENERIC_LIBRARY_VERSION)

PACKAGE=$GENERIC_LIBRARY_NAME
AC_SUBST(GENERIC_LIBRARY_NAME)

GENERIC_VERSION=$GENERIC_MAJOR_VERSION.$GENERIC_MINOR_VERSION.$GENERIC_MICRO_VERSION
GENERIC_RELEASE=$GENERIC_MAJOR_VERSION.$GENERIC_MINOR_VERSION
AC_SUBST(GENERIC_RELEASE)
AC_SUBST(GENERIC_VERSION)

VERSION=$GENERIC_VERSION

AM_INIT_AUTOMAKE([foreign])
AC_CONFIG_MACRO_DIR([m4]) # not strictly needed yet, but let's be future-proof


# -----------------------------------------------
# Checks for programs.
# -----------------------------------------------

AC_PROG_CC
AC_PROG_CXX
AC_PROG_LIBTOOL

# Boost!!! 
BOOST_REQUIRE([1.34.1])
BOOST_THREADS
BOOST_TEST
BOOST_PROGRAM_OPTIONS
BOOST_FORMAT

# sigc++ for fakenetworksrc
PKG_CHECK_MODULES(SOMADEPS, sigc++-2.0 >= 2.0 somanetwork-1.0 >= 1.0)
AC_SUBST(SOMADEPS_CFLAGS)
AC_SUBST(SOMADEPS_LIBS)


AM_PROG_LIBTOOL
AM_SANITY_CHECK

AC_LANG_CPLUSPLUS


dnl -----------------------------------------------
dnl Generates Makefile's, configuration files and scripts
dnl -----------------------------------------------

AC_CONFIG_FILES([Makefile src/Makefile tests/Makefile somadspio-1.0.pc] )

AC_OUTPUT

