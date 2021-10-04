# gt.m4 - Macros to locate and utilise Giella infra scripts -*- Autoconf -*-
# serial 1 (gtsvn-1)
# 
# Copyright © 2011 Divvun/Samediggi/UiT <bugs@divvun.no>.
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; version 3 of the License.
#
# This program is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.
#
# As a special exception to the GNU General Public License, if you
# distribute this file as part of a program that contains a
# configuration script generated by Autoconf, you may include it under
# the same distribution terms that you use for the rest of that program.

# the prefixes giella_*, _giella_* are reserved here for Giella variables and
# macros.
#
# Obsolete:
# the prefixes gt_*, _gt_* are reserved here for Giella variables and
# macros. It is the same as gettext and probably others, but I expect no
# collisions really.


AC_DEFUN([gt_PROG_SCRIPTS_PATHS],
         [
# Define whether you want to be a maintainer:
AC_ARG_VAR([GTMAINTAINER], [define if you are maintaining the infra to get additional complaining about infra integrity])
AM_CONDITIONAL([WANT_MAINTAIN], [test x"$GTMAINTAINER" != x])

################################
### Giella-core dir:
################
AC_ARG_WITH([giella-core],
            [AS_HELP_STRING([--with-giella-core=DIRECTORY],
                               [set giella-core to DIRECTORY @<:@default=PATH@:>@])],
            [with_giella_core=$withval],
            [with_giella_core=false])

_giella_core_not_found_message="
GIELLA_CORE could not be set:

Could not set GIELLA_CORE and thus not find required scripts in:
       \$GIELLA_CORE/scripts 
       \$GTHOME/giella-core/scripts 
       $PATH 

       Please do the following: 
       1. svn co https://gtsvn.uit.no/langtech/trunk/giella-core
       2. then either:
         a: cd giella-core && ./autogen.sh && ./configure && make install

          or:
         b: add the following to your ~/.bash_profile or ~/.profile:

       export \$GIELLA_CORE=/path/to/giella-core/checkout/dir

       (replace the path with the real path from 1. above)

          or:
         c: run configure as follows

       ./configure --with-giella-core=/path/to/giella-core/checkout/dir

       (replace the path with the real path from 1. above)
"

AC_MSG_CHECKING([whether we can set GIELLA_CORE])

# --with-giella-core overrides everything:
AS_IF([test "x$with_giella_core" != "xfalse" -a \
          -d "$with_giella_core/scripts" ], [
    GIELLA_CORE=$with_giella_core
    ],[
    # GIELLA_CORE is the env. variable for this dir:
    AS_IF([test "x$GIELLA_CORE" != "x" -a \
              -d "$GIELLA_CORE/scripts"], [], [
        # GIELLA_HOME is the new GTHOME:
        AS_IF([test "x$GIELLA_HOME" != "x" -a \
                  -d "$GIELLA_HOME/giella-core/scripts"], [
            GIELLA_CORE=$GIELLA_HOME/giella-core
        ], [
            # GTHOME for backwards compatibility - it is deprecated:
            AS_IF([test "x$GTHOME" != "x" -a \
                      -d "$GTHOME/giella-core/scripts"], [
                GIELLA_CORE=$GTHOME/giella-core
            ], [
                # GTCORE for backwards compatibility - it is deprecated:
                AS_IF([test "x$GTCORE" != "x" -a \
                          -d "$GTCORE/scripts"], [
                    GIELLA_CORE=$GTCORE
                ], [
                    # Try the gt-core.sh script. NB! It is deprecated:
                    AS_IF([test "x$GTCORESH" != xfalse -a \
                           -d "$(${GTCORESH})/scripts"], [
                        GIELLA_CORE=$(${GTCORESH})
                    ], [
                       # If nothing else works, try pkg-config:
                       AS_IF([pkg-config --exists giella-core], [
                           GIELLA_CORE=$(pkg-config --variable=dir giella-core)
                       ], [
                       AC_MSG_ERROR([${_giella_core_not_found_message}])
                       ])
                   ])
                ])
            ])
        ])
    ])
])
AC_MSG_RESULT([$GIELLA_CORE])

# GTCORE env. variable is required by the infrastructure to find scripts:
AC_ARG_VAR([GIELLA_CORE], [directory for the Giella infra core scripts and other required resources])

GTCORE=${GIELLA_CORE}
AC_ARG_VAR([GTCORE], [GTCORE = GIELLA_CORE, retained for backwards compatibility while being cleaned out])

##### Check the version of the giella-core, and stop with error message if too old:
# This is the error message:
giella_core_too_old_message="

The giella-core is too old, we require at least $_giella_core_min_version.

*** ==> PLEASE ENTER THE FOLLOWING COMMANDS: <== ***

cd $GTCORE
svn up
./autogen.sh # required only the first time
./configure  # required only the first time
make
sudo make install # optional, only needed if installed
                  # earlier or installed on a server.
"

# Identify the version of giella-core:
AC_PATH_PROG([GIELLA_CORE_VERSION], [gt-version.sh], [no],
    [$GTCORE/scripts$PATH_SEPARATOR$GTHOME/giella-core/scripts$PATH_SEPARATOR$PATH])
AC_MSG_CHECKING([the version of the Giella Core])
AS_IF([test "x${GIELLA_CORE_VERSION}" != xno],
        [_giella_core_version=$( ${GIELLA_CORE_VERSION} )],
        [AC_MSG_ERROR([gt-version.sh could not be found, installation is incomplete!])
    ])
AC_MSG_RESULT([$_giella_core_version])

AC_MSG_CHECKING([whether the Giella Core version is at least $_giella_core_min_version])
# Compare it to the required version, and error out if too old:
AX_COMPARE_VERSION([$_giella_core_version], [ge], [$_giella_core_min_version],
                   [giella_core_version_ok=yes], [giella_core_version_ok=no])
AS_IF([test "x${giella_core_version_ok}" != xno], [AC_MSG_RESULT([$giella_core_version_ok])],
[AC_MSG_ERROR([$giella_core_too_old_message])])

################################
### Giella-templates dir:
################
# 1. check --with-giella-templates option
# 2. check env GIELLA_TEMPLATES, then GIELLA_HOME, then GTHOME
# 3. error if not found

# Error message when $GIELLA_TEMPLATES is/are not found:
_giella_templates_not_found_message="
GIELLA_TEMPLATES could not be set:

Could not set GIELLA_TEMPLATES. Please do the following: 

       1. svn co https://gtsvn.uit.no/langtech/trunk/giella-templates
       2. then either:
         a: add the following to your ~/.bash_profile or ~/.profile:

       export \$GIELLA_TEMPLATES=/path/to/giella-templates/checkout/dir

       (replace the path with the real path from 1. above)

          or:
         b: run configure as follows

       ./configure --with-giella-templates=/path/to/giella-templates/checkout/dir

       (replace the path with the real path from 1. above)
"

# GIELLA_TEMPLATES is required for building draft keyboard layout based on cldr
# data:
AC_ARG_WITH([giella-templates],
            [AS_HELP_STRING([--with-giella-templates=DIRECTORY],
                            [search giella-templates data in DIRECTORY @<:@default=PATH@:>@])],
            [with_giella_templates=$withval],
            [with_giella_templates=false])

AC_MSG_CHECKING([whether we can set GIELLA_TEMPLATES])
# --with-giella-templates overrides everything:
AS_IF([test "x$with_giella_templates" != "xfalse" -a \
          -d "$with_giella_templates/langs-templates" ], [
    GIELLA_TEMPLATES=$with_giella_templates
    ],[
    # GIELLA_TEMPLATES is the env. variable for this dir:
    AS_IF([test "x$GIELLA_TEMPLATES" != "x" -a \
              -d "$GIELLA_TEMPLATES/langs-templates"], [], [
        # GIELLA_HOME is the new GTHOME:
        AS_IF([test "x$GIELLA_HOME" != "x" -a \
                  -d "$GIELLA_HOME/giella-templates/langs-templates"], [
            GIELLA_TEMPLATES=$GIELLA_HOME/giella-templates
        ], [
            # GTHOME for backwards compatibility - it is deprecated:
            AS_IF([test "x$GTHOME" != "x" -a \
                      -d "$GTHOME/giella-templates/langs-templates"], [
                GIELLA_TEMPLATES=$GTHOME/giella-templates
            ], [AC_MSG_ERROR([${_giella_templates_not_found_message}])])
        ])
    ])
])
AC_MSG_RESULT([$GIELLA_TEMPLATES])

# GIELLA_TEMPLATES is required if you do infrastructure maintenance (otherwise it is ignored):
AC_ARG_VAR([GIELLA_TEMPLATES], [directory for keyboard templates and template data])

################ Python requirements: ################
AM_PATH_PYTHON([3.5],, [:])

]) # gt_PROG_SCRIPTS_PATHS

AC_DEFUN([gt_PRINT_FOOTER],
[
cat<<EOF
-- Building $PACKAGE_STRING:

For more ./configure options, run ./configure --help

To build installation packages for the keyboards, do:
    make
EOF
]) # gt_PRINT_FOOTER
# vim: set ft=config: 
