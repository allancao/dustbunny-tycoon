/*
 * motor_pos_sf_reg.h
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
 *
 * SOURCES: motor_pos_sf.c 
 */

#include "motor_pos_sf_prm.h"
#if defined(RT_MALLOC) || defined(MATLAB_MEX_FILE)
# include "motor_pos_mid.h"
#endif

/* Function to initialize sizes */
static void mdlInitializeSizes(SimStruct *S)
{
  ssSetNumSampleTimes(S, 1);            /* Number of sample times */
  ssSetNumContStates(S, 3);             /* Number of continuous states */
  ssSetNumNonsampledZCs(S, 6);          /* Number of nonsampled ZCs */

  /* Number of output ports */
  if (!ssSetNumOutputPorts(S, 1)) return;

  /* outport number: 0 */
  if(!ssSetOutputPortVectorDimension(S, 0, 1)) return;
  ssSetOutputPortSampleTime(S, 0, 0.0);
  ssSetOutputPortOffsetTime(S, 0, 0.0);
  ssSetOutputPortOptimOpts(S, 0, SS_REUSABLE_AND_LOCAL);

  /* Number of input ports */
  if (!ssSetNumInputPorts(S, 1)) return;

  /* inport number: 0 */
  {
    if(!ssSetInputPortVectorDimension(S, 0, 1)) return;
    ssSetInputPortDirectFeedThrough(S, 0, 1);
    ssSetInputPortSampleTime(S, 0, 0.0);
    ssSetInputPortOffsetTime(S, 0, 0.0);
    ssSetInputPortOverWritable(S, 0, 0);
    ssSetInputPortOptimOpts(S, 0, SS_NOT_REUSABLE_AND_GLOBAL);
  }

  ssSetRTWGeneratedSFcn(S, 1);          /* RTW generated S-function */

  /* DWork */
  if ( !ssSetNumDWork(S, 4)) {
    return;
  }

  /* <S1>/Backlash: RWORK */
  ssSetDWorkName(S, 0, "DWORK0");
  ssSetDWorkWidth(S, 0, 4);

  /* <S1>/Backlash: MODE */
  ssSetDWorkName(S, 1, "DWORK1");
  ssSetDWorkWidth(S, 1, 1);
  ssSetDWorkDataType(S, 1, SS_INTEGER);

  /* <S1>/Input Voltage Saturation: MODE */
  ssSetDWorkName(S, 2, "DWORK2");
  ssSetDWorkWidth(S, 2, 1);
  ssSetDWorkDataType(S, 2, SS_INTEGER);

  /* <S1>/Current Saturation: MODE */
  ssSetDWorkName(S, 3, "DWORK3");
  ssSetDWorkWidth(S, 3, 1);
  ssSetDWorkDataType(S, 3, SS_INTEGER);

  /* Tunable Parameters */
  ssSetNumSFcnParams(S, 0);             /* Number of expected parameters */
#if defined(MATLAB_MEX_FILE)
  if (ssGetNumSFcnParams(S) == ssGetSFcnParamsCount(S)) {
#if defined(MDL_CHECK_PARAMETERS)
    mdlCheckParameters(S);
#endif                                  /* MDL_CHECK_PARAMETERS */
    if (ssGetErrorStatus(S) != NULL) {
      return;
    }
  } else {
    return;                             /* Parameter mismatch will be reported by Simulink */
  }
#endif                                  /* MATLAB_MEX_FILE */

  /* Options */
  ssSetOptions(S, (SS_OPTION_RUNTIME_EXCEPTION_FREE_CODE |
    SS_OPTION_PORT_SAMPLE_TIMES_ASSIGNED ));
}

/* Function to initialize sample times */
static void mdlInitializeSampleTimes(SimStruct *S)
{
  /* task periods */
  ssSetSampleTime(S, 0, 0.0);

  /* task offsets */
  ssSetOffsetTime(S, 0, 0.0);
}

#if defined(MATLAB_MEX_FILE)

# include "simulink.c"

#else

# undef S_FUNCTION_NAME
# define S_FUNCTION_NAME motor_pos_sf
# include "cg_sfun.h"

#endif                                  /* defined(MATLAB_MEX_FILE) */

/* [EOF] motor_pos_sf_reg.h */
