/*
 * DC_sf.h
 *
 * Real-Time Workshop code generation for Simulink model "DC_sf.mdl".
 *
 * Model Version                        : 1.122
 * Real-Time Workshop file version      : 5.0 $Date: 2002/05/30 19:21:33 $
 * Real-Time Workshop file generated on : Wed Jul 30 14:06:53 2003
 * TLC version                          : 5.0 (Jun 18 2002)
 * C source code generated on           : Wed Jul 30 14:06:54 2003
 */

#ifndef _RTW_HEADER_DC_sf_h_
# define _RTW_HEADER_DC_sf_h_

#ifndef _DC_sf_COMMON_INCLUDES_
# define _DC_sf_COMMON_INCLUDES_
#include <math.h>
#include <stdlib.h>

#define S_FUNCTION_NAME                 DC_sf
#define S_FUNCTION_LEVEL                2
#define RTW_GENERATED_S_FUNCTION

#include "simstruc.h"
#include "rtlibsrc.h"

#if !defined(RTW_SFUNCTION_DEFINES)
#define RTW_SFUNCTION_DEFINES
typedef struct {
  void *blockIO;
  void *defaultParam;
  void *nonContDerivSig;
} LocalS;

#define ssSetLocalBlockIO(S, io) ((LocalS *)ssGetUserData(S))->blockIO = ((void *)(io))
#define ssGetLocalBlockIO(S) ((LocalS *)ssGetUserData(S))->blockIO

#define ssSetLocalDefaultParam(S, paramVector) ((LocalS *)ssGetUserData(S))->defaultParam = (paramVector)
#define ssGetLocalDefaultParam(S) ((LocalS *)ssGetUserData(S))->defaultParam

#define ssSetLocalNonContDerivSig(S, pSig) ((LocalS *)ssGetUserData(S))->nonContDerivSig = (pSig)
#define ssGetLocalNonContDerivSig(S) ((LocalS *)ssGetUserData(S))->nonContDerivSig
#endif

#endif                                  /* _DC_sf_COMMON_INCLUDES_ */

#include "DC_sf_types.h"

/* Intrinsic types */
#ifndef POINTER_T
# define POINTER_T
typedef void * pointer_T;
#endif

/* Block signals (auto storage) */
typedef struct _DC_BlockIO {
  real_T Velocity;                      /* '<S1>/Transfer Fcn1' */
  real_T Transfer_Fcn2;                 /* '<S1>/Transfer Fcn2' */
  real_T Random_Number;                 /* '<S1>/Random Number' */
  real_T Sum;                           /* '<S1>/Sum' */
  real_T Sum1;                          /* '<S1>/Sum1' */
  real_T Sum2;                          /* '<S1>/Sum2' */
} DC_BlockIO;

/* Continuous states (auto storage) */
typedef struct _DC_ContinuousStates {
  real_T Transfer_Fcn1_CSTATE[2];       /* '<S1>/Transfer Fcn1' */
  real_T Transfer_Fcn2_CSTATE;          /* '<S1>/Transfer Fcn2' */
  real_T Integrator_CSTATE;             /* '<S1>/Integrator' */
} DC_ContinuousStates;

/* State derivatives (auto storage) */
typedef struct _DC_StateDerivatives {
  real_T Transfer_Fcn1_CSTATE[2];       /* '<S1>/Transfer Fcn1' */
  real_T Transfer_Fcn2_CSTATE;          /* '<S1>/Transfer Fcn2' */
  real_T Integrator_CSTATE;             /* '<S1>/Integrator' */
} DC_StateDerivatives;

/* State disabled  */
typedef struct _DC_StateDisabled {
  boolean_T Transfer_Fcn1_CSTATE[2];    /* '<S1>/Transfer Fcn1' */
  boolean_T Transfer_Fcn2_CSTATE;       /* '<S1>/Transfer Fcn2' */
  boolean_T Integrator_CSTATE;          /* '<S1>/Integrator' */
} DC_StateDisabled;

/* Zero-crossing (trigger) state */
typedef struct _DC_NonsampledZCs {
  real_T Current_Saturation_NSZC[2];    /* '<S1>/Current Saturation' */
  real_T Input_Voltage_Saturation_NSZC[2]; /* '<S1>/Input Voltage Saturation' */
} DC_NonsampledZCs;

/* External inputs (root inport signals with auto storage) */
typedef struct _DC_ExternalUPtrs_tag {
  real_T *Torque;                       /* '<Root>/Torque' */
  real_T *In2;                          /* '<Root>/In2' */
} DC_ExternalUPtrs;

/* External outputs (root outports fed by signals with auto storage) */
typedef struct _DC_ExternalOutputs_tag {
  real_T *Position;                     /* '<Root>/Position' */
  real_T *Velocity;                     /* '<Root>/Velocity' */
} DC_ExternalOutputs;

/* External data declarations for dependent source files */

/* non-finites */
extern real_T rtInf;
extern real_T rtNaN;

/* 
 * The generated code includes comments that allow you to trace directly 
 * back to the appropriate location in the model.  The basic format
 * is <system>/block_name, where system is the system number (uniquely
 * assigned by Simulink) and block_name is the name of the block.
 *
 * Use the MATLAB hilite_system command to trace the generated code back
 * to the model.  For example,
 *
 * hilite_system('<S3>')    - opens system 3
 * hilite_system('<S3>/Kp') - opens and selects block Kp which resides in S3
 *
 * Here is the system hierarchy for this model
 *
 * '<Root>' : DC_sf
 * '<S1>'   : DC_sf/DC Motor
 */

#endif                                  /* _RTW_HEADER_DC_sf_h_ */
