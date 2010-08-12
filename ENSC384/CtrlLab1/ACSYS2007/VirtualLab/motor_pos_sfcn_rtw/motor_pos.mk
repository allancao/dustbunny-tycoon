# Copyright 1994-2001 The MathWorks, Inc.
#
# File    : rtwsfcn_vc.tmf   $Revision: 1.32 $
#
# Abstract:
#       Real-Time Workshop template makefile for building a WindowsNT-based,
#       RTW generated S-Function of Simulink model using generated C code
#       and the
#          Microsoft Visual C/C++ compiler versions 5.0, 6.0.
#
#       Note that this template is automatically customized by the Real-Time
#       Workshop build procedure to create "<model>.mk"
#
#       The following defines can be used to modify the behavior of the
#       build:
#
#         OPT_OPTS       - Optimization option. Specify OPT_OPTS=-g to
#                          create a mex file for debugging.
#         MEX_OPTS       - User specific mex options.
#         USER_SRCS      - Additional user sources, such as files needed by
#                          S-functions.
#         USER_INCLUDES  - Additional include paths
#                          (i.e. USER_INCLUDES="-Iwhere-ever -Iwhere-ever2")
#
#       This template makefile is designed to be used with a system target
#       file that contains 'rtwgensettings.BuildDirSuffix' see rtwsfcn.tlc

#------------------------ Macros read by make_rtw -----------------------------
#
# The following macros are read by the Real-Time Workshop build procedure:
#
#  MAKECMD         - This is the command used to invoke the make utility
#  HOST            - What platform this template makefile is targeted for
#                    (i.e. PC or UNIX)
#  BUILD           - Invoke make from the Real-Time Workshop build procedure
#                    (yes/no)?
#  SYS_TARGET_FILE - Name of system target file.

MAKECMD         = nmake
HOST            = PC
BUILD           = yes
SYS_TARGET_FILE = rtwsfcn.tlc

#---------------------- Tokens expanded by make_rtw ---------------------------
#
# The following tokens, when wrapped with "|>" and "|<" are expanded by the
# Real-Time Workshop build procedure.
#
#  MODEL_NAME      - Name of the Simulink block diagram
#  MODEL_MODULES   - Any additional generated source modules
#  MAKEFILE_NAME   - Name of makefile created from template makefile <model>.mk
#  MATLAB_ROOT     - Path to were MATLAB is installed.
#  MATLAB_BIN      - Path to MATLAB executable.
#  S_FUNCTIONS     - List of S-functions.
#  S_FUNCTIONS_LIB - List of S-functions libraries to link.
#  SOLVER          - Solver source file name
#  NUMST           - Number of sample times
#  TID01EQ         - yes (1) or no (0): Are sampling rates of continuous task
#                    (tid=0) and 1st discrete task equal.
#  NCSTATES        - Number of continuous states
#  BUILDARGS       - Options passed in at the command line.
#  CREATEMODEL     - 1 will cause a untitled model to be opened with the
#                    generated s-function block inside it.
#  USERMODULES     - passed along for later code generations of models that
#                    contain this RTW S-Function. (Used by RTW S-Function block.)
#  USEPARAMVALUES  - 1 will cause the generated S-function block to have values
#                    instead of variable names.

MODEL           = motor_pos
MODULES         = 
MAKEFILE        = motor_pos.mk
MATLAB_ROOT     = C:\MATLAB6P1
MATLAB_BIN      = C:\MATLAB6P1\bin\win32
S_FUNCTIONS     = 
S_FUNCTIONS_LIB = 
SOLVER          = ode45.c
NUMST           = 1
TID01EQ         = 
NCSTATES        = 3
MEM_ALLOC       = RT_STATIC
BUILDARGS       = 
CREATEMODEL     = 1
USERMODULES     =  
USEPARAMVALUES  = 0

#--------------------------- Tool Specifications ------------------------------

!include $(MATLAB_ROOT)\rtw\c\tools\vctools.mak

MEX    = $(MATLAB_BIN)\mex
CC     = $(MATLAB_BIN)\mex -c
LIBCMD = lib
PERL   = $(MATLAB_ROOT)\sys\perl\win32\bin\perl

#------------------------------ Include/Lib Path ------------------------------
MATLAB_INCLUDES =                    $(MATLAB_ROOT)\simulink\include
MATLAB_INCLUDES = $(MATLAB_INCLUDES);$(MATLAB_ROOT)\extern\include
MATLAB_INCLUDES = $(MATLAB_INCLUDES);$(MATLAB_ROOT)\rtw\c\src
MATLAB_INCLUDES = $(MATLAB_INCLUDES);$(MATLAB_ROOT)\rtw\c\libsrc

# Additional file include paths


INCLUDE = ..;$(MATLAB_INCLUDES);$(VC_INCLUDE)

#------------------------ C and MEX optimization options ----------------------

DEFAULT_OPT_OPTS = -O

MEX_OPTS = 
OPT_OPTS = $(DEFAULT_OPT_OPTS)

MEX_OPT_OPTS = $(OPT_OPTS)    # passed to 'mex -c'

!if "$(MEX_OPTS)" == "-g"
MEX_OPT_OPTS =
!endif

#-------------------------------- Mex Options  --------------------------------

MEX_OPT_FILE =
!if "$(VISUAL_VER)" == "5.0"
MEX_OPT_FILE = -f $(MATLAB_BIN)\mexopts\msvc50opts.bat
!endif
!if "$(VISUAL_VER)" == "6.0"
MEX_OPT_FILE = -f $(MATLAB_BIN)\mexopts\msvc60opts.bat
!endif

MEX_FLAGS = $(MEX_OPTS) $(MEX_OPT_OPTS) $(MEX_OPT_FILE)

#----------------------------- Source Files -----------------------------------
USER_SRCS =

OBJS = $(MODEL)_sf.obj $(MODULES:.c=.obj) $(USER_SRCS:.c=.obj)

!if "$(MEX_OPT_OPTS)" == "$(DEFAULT_OPT_OPTS)"
RTWLIB = $(MATLAB_ROOT)\rtw\c\lib\win32\rtwlib_rtwsfcn_vc.lib
!else
RTWLIB = rtwlib.lib
!endif

LIBSRC = $(MATLAB_ROOT)\rtw\c\libsrc
CUSTLIB = 

LIBUT = $(MATLAB_ROOT)\rtw\c\lib\win32\libut_vc.lib
MAT_LIBS = $(LIBUT)
LIBS = $(S_FUNCTIONS_LIB) $(MAT_LIBS)

CMD_FILE = $(MODEL).lnk
GEN_LNK_SCRIPT = $(MATLAB_ROOT)\rtw\c\tools\mkvc_lnk.pl

#--------------------------------- Rules --------------------------------------

..\$(MODEL)_sf.dll : set_environment_variables $(OBJS) $(RTWLIB) $(MAT_LIBS) $(CUSTLIB)
	@echo ### Linking ...
	$(PERL) $(GEN_LNK_SCRIPT) $(CMD_FILE) $(OBJS)
	$(MEX) $(MEX_FLAGS) @$(CMD_FILE) $(RTWLIB) $(LIBS) $(CUSTLIB) -outdir .. 
	@echo ### Created dll $(MODEL)_sf.dll

# Look in simulink/src helper files

{$(MATLAB_ROOT)\simulink\src}.c.obj :
	@echo ### Compiling $<
	$(CC) $(MEX_FLAGS) $<

# Additional sources



# Put these rules last, otherwise nmake will check toolboxes first

{..}.c.obj :
	@echo ### Compiling $<
	$(CC) $(MEX_FLAGS) $(USER_INCLUDES) $<

.c.obj :
	@echo ### Compiling $<
	@if exist $*.pdb del $*.pdb
	@if exist ..\$(MODEL)_sf.pdb del ..\$(MODEL)_sf.pdb
	$(CC) $(MEX_FLAGS) $(USER_INCLUDES) $<

set_environment_variables:
	@set INCLUDE=$(INCLUDE)
	@set LIB=$(LIB)
	@set MATLAB=$(MATLAB_ROOT)

rtwlib.lib: rtw_proj.tmw $(MAKEFILE)
	@echo ### Creating rtwlib.lib
	@SET RTW_CC=$(CC)
	@SET RTW_CFLAGS= $(MEX_FLAGS)
	@SET RTW_LIBCMD=$(LIBCMD) /nologo /out:$@
	$(PERL) $(LIBSRC)\mklib.pl $(LIBSRC) $@



#----------------------------- Dependencies -----------------------------------

$(OBJS) : $(MAKEFILE) rtw_proj.tmw

