/*
 * motor_pos_sf_common.h
 *
 * Real-Time Workshop code generation for Simulink model "motor_pos_sf.mdl".
 *
 * Model Version                        : 1.0
 * Real-Time Workshop file version      : 4.1 $Date: 2001/05/16 13:59:43 $
 * Real-Time Workshop file generated on : Thu Aug 16 10:44:10 2001
 * TLC version                          : 4.1 (May 19 2001)
 * C source code generated on           : Thu Aug 16 10:44:10 2001
 *
 * Relevant TLC Options:
 *   InlineParameters      = 1
 *   RollThreshold         = 5
 *   CodeFormat            = S-Function
 *
 * Simulink model settings:
 *   Solver     : VariableStep
 *   StartTime  : 0.0 s
 *   StopTime   : 10.0 s
 *   Variable step solver used
 */

#ifndef _RTW_COMMON_HEADER_FILE_motor_pos_sf_
#define _RTW_COMMON_HEADER_FILE_motor_pos_sf_

#define S_FUNCTION_NAME                 motor_pos_sf
#define S_FUNCTION_LEVEL                2
#define RTW_GENERATED_S_FUNCTION

#if !defined(RTW_SFUNCTION_DEFINES)
#define RTW_SFUNCTION_DEFINES
typedef struct {
  void *blockIO;
  void *defaultParam;
  void *dataStoreMem;
} LocalS;

#define ssSetLocalBlockIO(S,io) ((LocalS *)ssGetUserData(S))->blockIO = ((void *)(io))
#define ssGetLocalBlockIO(S) ((LocalS *)ssGetUserData(S))->blockIO

#define ssSetLocalDefaultParam(S,paramVector) ((LocalS *)ssGetUserData(S))->defaultParam = (paramVector)
#define ssGetLocalDefaultParam(S) ((LocalS *)ssGetUserData(S))->defaultParam

#define ssSetLocalDataStoreMem(S,dsMem) ((LocalS *)ssGetUserData(S))->dataStoreMem = (dsMem)
#define ssGetLocalDataStoreMem(S) ((LocalS *)ssGetUserData(S))->dataStoreMem

#endif

#ifndef TRUE
# define TRUE (1)
#endif
#ifndef FALSE
# define FALSE (0)
#endif

#define fcn_call_T                      real_T
#define pointer_T                       void*
#define action_T                        real_T

#define rt_VALIDATE_MEMORY(S, ptr) if(!(ptr)) {\
    ssSetErrorStatus((S), RT_MEMORY_ALLOCATION_ERROR);\
    return(S);\
  }

#if !defined(_WIN32)
#define rt_FREE(ptr) if((ptr) != NULL) {\
    free((ptr));\
    (ptr) = NULL;\
  }
#else
/* Visual and other windows compilers delcare free without const! */
#define rt_FREE(ptr) if((ptr) != NULL) {\
    free((void *)(ptr));\
    (ptr) = NULL;\
  }
#endif

#define assert(exp)

#include "simstruc.h"
#include "rtlibsrc.h"
#include "motor_pos_sf_export.h"
#include <stdlib.h>
#include <math.h>

/*
 * Block I/O Structure 
 *
 * Note: Individual field names are derived from the signal name when
 * present, otherwise, field names are derived from the source block name
 * with an optional port number appened to the block name if the block has
 * multiple output ports. The comment to the right of structure field
 * contains the signal source block name.
 *
 */

typedef struct motor_pos_BlockIO_tag {
  real_T Integrator;                    /* <S1>/Integrator */
  real_T Backlash;                      /* <S1>/Backlash */
  real_T Electrical;                    /* <S1>/Electrical */
  real_T Mechanical;                    /* <S1>/Mechanical */
  real_T Motor_Gain;                    /* <S1>/Motor Gain */
  real_T Sum3;                          /* <S1>/Sum3 */
} motor_pos_BlockIO;

/*
 * Default Parameters Structure 
 *
 * Note: The parameters structure is for block parameters which have an
 * auto storage class designation and cannot be inlined based on their
 * usage in the generated code.  Individual field names are comprised of
 * the block and parameter name.
 *
 */

typedef struct motor_pos_Parameters_tag {
  real_T Integrator_IC;                 /* Expression: 0
                                         * External Mode Tunable: no
                                         * Referenced by block:
                                         * <S1>/Integrator
                                         */
} motor_pos_Parameters;

/*
 * Continuous States Structure
 *
 * Note: Individual field names are derived from the block name.
 *
 */

typedef struct motor_pos_ContinuousStates_tag {
  real_T Integrator_CSTATE;
  real_T Electrical_CSTATE;
  real_T Mechanical_CSTATE;
} motor_pos_ContinuousStates;

/*
 * State Derivatives Structure
 *
 * Note: Individual field names are derived from the block name.
 *
 */
typedef struct motor_pos_StateDerivatives_tag {
  real_T Integrator_CSTATE;
  real_T Electrical_CSTATE;
  real_T Mechanical_CSTATE;
} motor_pos_StateDerivatives;

/*
 * Nonsampled Zero-Crossings Structure
 *
 * Note: Individual field names are derived from the block name.
 *
 */

typedef struct motor_pos_NonsampledZCs_tag {
  real_T Backlash_NSZC[2];
  real_T Input_Voltage_Saturation_NSZC[2];
  real_T Current_Saturation_NSZC[2];
} motor_pos_NonsampledZCs;

/*
 * External Inputs Structure
 *
 * Note: Individual field names are derived from the block name.
 *
 */

typedef struct motor_pos_ExternalUPtrs_tag {
  real_T *E_in;
} motor_pos_ExternalUPtrs;

/*
 * External Outputs Structure
 *
 * Note: Individual field names are derived from the outport block names
 *
 */

typedef struct motor_pos_ExternalOutputs_tag {
  real_T *Position_out;
} motor_pos_ExternalOutputs;

/* non-finites */
extern real_T rtMinusInf;

#endif                                  /* _RTW_COMMON_HEADER_FILE_motor_pos_sf_ */

/* [EOF] motor_pos_sf_common.h */
