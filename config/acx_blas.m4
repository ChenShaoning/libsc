dnl This is a modified version of the Teuchos config dir from Trilinos
dnl with the following license.
dnl
dnl ***********************************************************************
dnl
dnl                    Teuchos: Common Tools Package
dnl                 Copyright (2004) Sandia Corporation
dnl
dnl Under terms of Contract DE-AC04-94AL85000, there is a non-exclusive
dnl license for use of this work by or on behalf of the U.S. Government.
dnl
dnl This library is free software; you can redistribute it and/or modify
dnl it under the terms of the GNU Lesser General Public License as
dnl published by the Free Software Foundation; either version 2.1 of the
dnl License, or (at your option) any later version.
dnl
dnl This library is distributed in the hope that it will be useful, but
dnl WITHOUT ANY WARRANTY; without even the implied warranty of
dnl MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
dnl Lesser General Public License for more details.
dnl
dnl You should have received a copy of the GNU Lesser General Public
dnl License along with this library; if not, write to the Free Software
dnl Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307
dnl USA
dnl Questions? Contact Michael A. Heroux (maherou@sandia.gov)
dnl
dnl ***********************************************************************
dnl
dnl @synopsis ACX_BLAS([ACTION-IF-FOUND[, ACTION-IF-NOT-FOUND]])
dnl
dnl This macro looks for a library that implements the BLAS
dnl linear-algebra interface (see http://www.netlib.org/blas/).
dnl On success, it sets the BLAS_LIBS output variable to
dnl hold the requisite library linkages.
dnl
dnl To link with BLAS, you should link with:
dnl
dnl 	$BLAS_LIBS $LIBS $FLIBS
dnl
dnl in that order.  FLIBS is the output variable of the
dnl AC_F77_LIBRARY_LDFLAGS macro (called if necessary by ACX_BLAS),
dnl and is sometimes necessary in order to link with F77 libraries.
dnl Users will also need to use AC_F77_DUMMY_MAIN (see the autoconf
dnl manual), for the same reason.
dnl
dnl Many libraries are searched for, from ATLAS to CXML to ESSL.
dnl The user may also use --with-blas=<lib> in order to use some
dnl specific BLAS library <lib>.  In order to link successfully,
dnl however, be aware that you will probably need to use the same
dnl Fortran compiler (which can be set via the F77 env. var.) as
dnl was used to compile the BLAS library.
dnl
dnl ACTION-IF-FOUND is a list of shell commands to run if a BLAS
dnl library is found, and ACTION-IF-NOT-FOUND is a list of commands
dnl to run it if it is not found.  If ACTION-IF-FOUND is not specified,
dnl the default action will define HAVE_BLAS.
dnl
dnl This macro requires autoconf 2.50 or later.
dnl
dnl @version $Id: acx_blas.m4,v 1.3 2006/04/21 02:29:27 jmwille Exp $
dnl @author Steven G. Johnson <stevenj@alum.mit.edu>
dnl
dnl Edited by Jim Willenbring on 5-14-2004 to check for dgemm instead of
dnl sgemm.
dnl Edited by Jim Willenbring on 4-17-2006 to stop looking for BLAS if
dnl a specific BLAS library specified by a user cannot be used.

AC_DEFUN([ACX_BLAS], [
AC_PREREQ(2.50)
AC_REQUIRE([AC_F77_LIBRARY_LDFLAGS])
acx_blas_ok=no

AC_ARG_WITH(blas,
	[AC_HELP_STRING([--with-blas=<lib>], [use BLAS library <lib>])])
case $with_blas in
	yes | "") ;;
	no) acx_blas_ok=disable ;;
	-* | */* | *.a | *.so | *.so.* | *.o) BLAS_LIBS="$with_blas" ;;
	*) BLAS_LIBS="-l$with_blas" ;;
esac

# Get fortran linker names of BLAS functions to check for.
AC_F77_FUNC(sgemm)
AC_F77_FUNC(dgemm)

acx_blas_save_LIBS="$LIBS"
LIBS="$LIBS $FLIBS"

# First, check BLAS_LIBS environment variable
if test $acx_blas_ok = no; then
if test "x$BLAS_LIBS" != x; then
	save_LIBS="$LIBS"; LIBS="$BLAS_LIBS $LIBS"
	AC_MSG_CHECKING([for $dgemm in $BLAS_LIBS])
	AC_TRY_LINK_FUNC($dgemm, [acx_blas_ok=yes], [user_spec_blas_failed=yes])
	AC_MSG_RESULT($acx_blas_ok)
	LIBS="$save_LIBS"
fi
fi

# If the user specified a blas library that could not be used we will
# halt the search process rather than risk finding a blas library that
# the user did not specify.

if test "x$user_spec_blas_failed" != xyes; then

# BLAS linked to by default?  (happens on some supercomputers)
if test $acx_blas_ok = no; then
	save_LIBS="$LIBS"; LIBS="$LIBS"
	AC_CHECK_FUNC($dgemm, [acx_blas_ok=yes])
	LIBS="$save_LIBS"
fi

# BLAS in ATLAS library? (http://math-atlas.sourceforge.net/)
if test $acx_blas_ok = no; then
	AC_CHECK_LIB(atlas, ATL_xerbla,
		[AC_CHECK_LIB(f77blas, $dgemm,
		[AC_CHECK_LIB(cblas, cblas_dgemm,
			[acx_blas_ok=yes
			 BLAS_LIBS="-lcblas -lf77blas -latlas"],
			[], [-lf77blas -latlas])],
			[], [-latlas])])
fi

# BLAS in PhiPACK libraries? (requires generic BLAS lib, too)
if test $acx_blas_ok = no; then
	AC_CHECK_LIB(blas, $dgemm,
		[AC_CHECK_LIB(dgemm, $dgemm,
		[AC_CHECK_LIB(sgemm, $sgemm,
			[acx_blas_ok=yes; BLAS_LIBS="-lsgemm -ldgemm -lblas"],
			[], [-lblas])],
			[], [-lblas])])
fi

# BLAS in Intel MKL library?
if test $acx_blas_ok = no; then
	AC_CHECK_LIB(mkl, $dgemm, [acx_blas_ok=yes;BLAS_LIBS="-lmkl"])
fi

# BLAS in Apple vecLib library?
if test $acx_blas_ok = no; then
	save_LIBS="$LIBS"; LIBS="-framework vecLib $LIBS"
	AC_CHECK_FUNC($dgemm, [acx_blas_ok=yes;BLAS_LIBS="-framework vecLib"])
	LIBS="$save_LIBS"
fi

# BLAS in Alpha CXML library?
if test $acx_blas_ok = no; then
	AC_CHECK_LIB(cxml, $dgemm, [acx_blas_ok=yes;BLAS_LIBS="-lcxml"])
fi

# BLAS in Alpha DXML library? (now called CXML, see above)
if test $acx_blas_ok = no; then
	AC_CHECK_LIB(dxml, $dgemm, [acx_blas_ok=yes;BLAS_LIBS="-ldxml"])
fi

# BLAS in Sun Performance library?
if test $acx_blas_ok = no; then
	if test "x$GCC" != xyes; then # only works with Sun CC
		AC_CHECK_LIB(sunmath, acosp,
			[AC_CHECK_LIB(sunperf, $dgemm,
        			[BLAS_LIBS="-xlic_lib=sunperf -lsunmath"
                                 acx_blas_ok=yes],[],[-lsunmath])])
	fi
fi

# BLAS in SCSL library?  (SGI/Cray Scientific Library)
if test $acx_blas_ok = no; then
	AC_CHECK_LIB(scs, $dgemm, [acx_blas_ok=yes; BLAS_LIBS="-lscs"])
fi

# BLAS in SGIMATH library?
if test $acx_blas_ok = no; then
	AC_CHECK_LIB(complib.sgimath, $dgemm,
		     [acx_blas_ok=yes; BLAS_LIBS="-lcomplib.sgimath"])
fi

# BLAS in IBM ESSL library? (requires generic BLAS lib, too)
if test $acx_blas_ok = no; then
	AC_CHECK_LIB(blas, $dgemm,
		[AC_CHECK_LIB(essl, $dgemm,
			[acx_blas_ok=yes; BLAS_LIBS="-lessl -lblas"],
			[], [-lblas $FLIBS])])
fi

# Generic Mac OS X library?
if test $acx_blas_ok = no; then
	save_LIBS="$LIBS"; LIBS="-framework Accelerate $LIBS"
	AC_CHECK_FUNC($dgemm, [acx_blas_ok=yes])
	BLAS_LIBS="-framework Accelerate"
	LIBS="$save_LIBS"
fi

# Generic BLAS library?
if test $acx_blas_ok = no; then
	AC_CHECK_LIB(blas, $dgemm, [acx_blas_ok=yes; BLAS_LIBS="-lblas"])
fi

AC_SUBST(BLAS_LIBS)

fi # If the user specified library wasn't found, we skipped the remaining
   # checks.

LIBS="$acx_blas_save_LIBS"

# Finally, execute ACTION-IF-FOUND/ACTION-IF-NOT-FOUND:
if test x"$acx_blas_ok" = xyes; then
        ifelse([$1],,AC_DEFINE(HAVE_BLAS,1,[Define if you have a BLAS library.]),[$1])
        :
else
        acx_blas_ok=no
        $2
fi

])dnl ACX_BLAS