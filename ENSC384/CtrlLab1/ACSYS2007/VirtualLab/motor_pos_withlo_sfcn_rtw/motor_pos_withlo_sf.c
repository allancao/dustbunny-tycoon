/*
 * motor_pos_withlo_sf.c
 *
 * Real-Time Workshop code generation for Simulink model "motor_pos_withlo_sf.mdl".
 *
 * Model Version                        : 1.0
 * Real-Time Workshop file version      : 4.1 $Date: 2001/05/16 13:59:43 $
 * Real-Time Workshop file generated on : Thu Aug 16 10:48:49 2001
 * TLC version                          : 4.1 (May 19 2001)
 * C source code generated on           : Thu Aug 16 10:48:49 2001
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

#include <math.h>
#include <string.h>
#include "motor_pos_withlo_sf.h"
#include "motor_pos_withlo_sf_export.h"

#if defined(MATLAB_MEX_FILE)

real_T rtInf;
real_T rtMinusInf;
real_T rtNaN;
#endif

#if defined(RT_MALLOC) || defined(MATLAB_MEX_FILE)
extern void *motor_pos_withlo_malloc(SimStruct *S);
#endif

#if defined (MATLAB_MEX_FILE)
extern void * utMalloc(size_t);
extern void utFree(void *);
#endif

/* Start of Functions in model "motor_pos_withlo_sf" */
/* Start the model */
#define MDL_START
static void mdlStart(SimStruct *S)
{
  /* instance underlying S-Function data */
#if defined(RT_MALLOC) || defined(MATLAB_MEX_FILE)
# if defined(MATLAB_MEX_FILE)

  /* non-finites */
  rtInf = mxGetInf();
  rtMinusInf = -rtInf;
  rtNaN = mxGetNaN();

  /* Check for invalid switching between solver types */
  if (!ssIsVariableStepSolver(S)) {
    ssSetErrorStatus(S,"This Real-Time Workshop generated "
     "S-function cannot be used in a simulation with a solver type of "
     "fixed-step since this S-function was created from a model with "
     "solver type of variable-step and it has continuous time blocks. See "
     "the Solver page of the simulation parameters dialog.");
    return;
  }

# endif

  motor_pos_withlo_malloc(S);
  if( ssGetErrorStatus(S) != NULL ) {
    return;
  }
#endif

  {
    /* simstruct variables */
    motor_pos_withlo_BlockIO *motor_pos_withlo_B = (motor_pos_withlo_BlockIO *)
      ssGetLocalBlockIO(S);
    motor_pos_withlo_Parameters *motor_pos_withlo_P =
      (motor_pos_withlo_Parameters *) ssGetLocalDefaultParam(S);

    /* Integrator Block: <S1>/Integrator */
    (void)memcpy(&motor_pos_withlo_B->Integrator,
     &motor_pos_withlo_P->Integrator_IC, 1 * sizeof(real_T));

    /* Backlash Block: <S1>/Backlash */
    ((real_T*) ssGetDWork(S,0))[0] = rtMinusInf;
    ((real_T*) ssGetDWork(S,0))[2] = rtMinusInf;

    ((real_T*) ssGetDWork(S,0))[1] = 0.0;
    ((real_T*) ssGetDWork(S,0))[3] = 0.0;
  }
}

/* Initialize the model */
#define MDL_INITIALIZE_CONDITIONS
static void mdlInitializeConditions(SimStruct *S)
{
  /* simstruct variables */
  motor_pos_withlo_ContinuousStates *motor_pos_withlo_X =
    (motor_pos_withlo_ContinuousStates*) ssGetContStates(S);

  /* Integrator Block: <S1>/Integrator */
  motor_pos_withlo_X->Integrator_CSTATE = 0.0;

  /* TransferFcn Block: <S1>/Electrical */
  motor_pos_withlo_X->Electrical_CSTATE = 0.0;

  /* TransferFcn Block: <S1>/Mechanical */
  motor_pos_withlo_X->Mechanical_CSTATE = 0.0;
}

/* Compute block outputs */
static void mdlOutputs(SimStruct *S, int_T tid)
{
  /* simstruct variables */
  motor_pos_withlo_BlockIO *motor_pos_withlo_B = (motor_pos_withlo_BlockIO *)
    ssGetLocalBlockIO(S);
  motor_pos_withlo_ContinuousStates *motor_pos_withlo_X =
    (motor_pos_withlo_ContinuousStates*) ssGetContStates(S);

  /* local block i/o variables */
  real_T rtb_Input_Voltage_Saturation;
  real_T rtb_Current_Saturation;

  /* Integrator: '<S1>/Integrator' */
  motor_pos_withlo_B->Integrator = motor_pos_withlo_X->Integrator_CSTATE;

  /* Backlash: '<S1>/Backlash' */
  {
    enum modes {MODE_NEG_ENGAGED = -1, MODE_DISENGAGED = 0,
        MODE_POS_ENGAGED = 1};
    real_T t = ssGetT(S);
    real_T timeStampA = ((real_T*) ssGetDWork(S,0))[0];
    real_T timeStampB = ((real_T*) ssGetDWork(S,0))[2];
    real_T halfDeadBand;
    real_T *lastY;

    halfDeadBand = (1.7444444444444447E-003)/2.0;
    if (timeStampA < timeStampB) {
      if (timeStampB < t) {
        lastY = &((real_T*) ssGetDWork(S,0))[3];
      } else {
        /* timeStampB == t, so use lastYatTimeA */
        lastY = &((real_T*) ssGetDWork(S,0))[1];
      }
    } else {
      /* timeStampB <= timeStampA */
      if (timeStampA < t) {
        lastY = &((real_T*) ssGetDWork(S,0))[1];
      } else {
        /* timeStampA == t, so use lastYatTimeB */
        lastY = &((real_T*) ssGetDWork(S,0))[3];
      }
    }

    if (ssIsMajorTimeStep(S)) {
      int_T newMode;
      real_T lb = *lastY - halfDeadBand;
      real_T ub = *lastY + halfDeadBand;

      /* find the new engagement mode */
      if ( motor_pos_withlo_B->Integrator <= lb ) {
        newMode = MODE_NEG_ENGAGED;
      } else if ( motor_pos_withlo_B->Integrator < ub ) {
        newMode = MODE_DISENGAGED;
      } else {
        newMode = MODE_POS_ENGAGED;
      }

      /* Update the mode vector, and reset solver if mode change */
      if (newMode != ((int_T*) ssGetDWork(S, 1))[0]) {
        ssSetSolverNeedsReset(S);
        ((int_T*) ssGetDWork(S, 1))[0] = newMode;
      }
    }

    /* compute the output */
    switch (((int_T*) ssGetDWork(S, 1))[0]) {
     case MODE_NEG_ENGAGED:
      motor_pos_withlo_B->Backlash = motor_pos_withlo_B->Integrator +
        halfDeadBand;
      break;
     case MODE_DISENGAGED:
      motor_pos_withlo_B->Backlash = *lastY;
      break;
     case MODE_POS_ENGAGED:
      motor_pos_withlo_B->Backlash = motor_pos_withlo_B->Integrator -
        halfDeadBand;
      break;
    }
    lastY++;
  }

  /* Outport: '<Root>/Position out' */
  ((real_T *)ssGetOutputPortSignal(S,0))[0] = motor_pos_withlo_B->Backlash;

  /* Saturate: '<S1>/Input Voltage Saturation' incorporates:
   *   Inport: '<Root>/E in'
   *
   * Regarding '<S1>/Input Voltage Saturation':
   *   Lower limit: (-10.0)
   *   Upper limit: 10.0
   */
  if (ssIsMajorTimeStep(S)) {
    if (*(((const real_T**)ssGetInputPortSignalPtrs(S, 0))[0]) >= 10.0) {
      ((int_T*) ssGetDWork(S, 2))[0] = 1;
    } else if (*(((const real_T**)ssGetInputPortSignalPtrs(S, 0))[0]) <=
     (-10.0)) {
      ((int_T*) ssGetDWork(S, 2))[0] = -1;
    } else {
      ((int_T*) ssGetDWork(S, 2))[0] = 0;
    }
  }
  /* Output value */
  if (((int_T*) ssGetDWork(S, 2))[0] == 1) {
    rtb_Input_Voltage_Saturation = 10.0;
  } else if (((int_T*) ssGetDWork(S, 2))[0] == -1) {
    rtb_Input_Voltage_Saturation = (-10.0);
  } else {
    rtb_Input_Voltage_Saturation = *(((const
      real_T**)ssGetInputPortSignalPtrs(S, 0))[0]);
  }

  /* TransferFcn Block: <S1>/Electrical */
  motor_pos_withlo_B->Electrical =
    1.7857142857142858E+003*motor_pos_withlo_X->Electrical_CSTATE;
  /* Saturate: '<S1>/Current Saturation'
   *
   * Regarding '<S1>/Current Saturation':
   *   Lower limit: (-4.0)
   *   Upper limit: 4.0
   */
  if (ssIsMajorTimeStep(S)) {
    if (motor_pos_withlo_B->Electrical >= 4.0) {
      ((int_T*) ssGetDWork(S, 3))[0] = 1;
    } else if (motor_pos_withlo_B->Electrical <= (-4.0)) {
      ((int_T*) ssGetDWork(S, 3))[0] = -1;
    } else {
      ((int_T*) ssGetDWork(S, 3))[0] = 0;
    }
  }
  /* Output value */
  if (((int_T*) ssGetDWork(S, 3))[0] == 1) {
    rtb_Current_Saturation = 4.0;
  } else if (((int_T*) ssGetDWork(S, 3))[0] == -1) {
    rtb_Current_Saturation = (-4.0);
  } else {
    rtb_Current_Saturation = motor_pos_withlo_B->Electrical;
  }

  /* TransferFcn Block: <S1>/Mechanical */
  motor_pos_withlo_B->Mechanical =
    8.5251491901108267E+001*motor_pos_withlo_X->Mechanical_CSTATE;
  /* Gain: '<S1>/Motor Gain'
   *
   * Regarding '<S1>/Motor Gain':
   *   Gain value: 0.1
   */
  motor_pos_withlo_B->Motor_Gain = rtb_Current_Saturation * 0.1;

  /* Sum: '<S1>/Sum3' incorporates:
   *   Gain: '<S1>/Amplifier Gain'
   *   Gain: '<S1>/Motor feedback'
   *
   * Regarding '<S1>/Amplifier Gain':
   *   Gain value: 2.0
   *
   * Regarding '<S1>/Motor feedback':
   *   Gain value: 0.1
   */
  motor_pos_withlo_B->Sum3 = (2.0 * rtb_Input_Voltage_Saturation)
    - (0.1 * motor_pos_withlo_B->Mechanical);
}

/* Perform model update */
#define MDL_UPDATE
static void mdlUpdate(SimStruct *S, int_T tid)
{
  /* simstruct variables */
  motor_pos_withlo_BlockIO *motor_pos_withlo_B = (motor_pos_withlo_BlockIO *)
    ssGetLocalBlockIO(S);

  /* Backlash Block: <S1>/Backlash */
  {
    real_T t = ssGetT(S);
    real_T *timeStampA = &((real_T*) ssGetDWork(S,0))[0];
    real_T *timeStampB = &((real_T*) ssGetDWork(S,0))[2];
    if (*timeStampA < *timeStampB) {
      *timeStampA = t;
      ((real_T*) ssGetDWork(S,0))[1] = motor_pos_withlo_B->Backlash;
    } else {
      *timeStampB = t;
      ((real_T*) ssGetDWork(S,0))[3] = motor_pos_withlo_B->Backlash;
    }
  }
}

/* Compute model derivatives */
#define MDL_DERIVATIVES
static void mdlDerivatives(SimStruct *S)
{
  /* simstruct variables */
  motor_pos_withlo_BlockIO *motor_pos_withlo_B = (motor_pos_withlo_BlockIO *)
    ssGetLocalBlockIO(S);
  motor_pos_withlo_ContinuousStates *motor_pos_withlo_X =
    (motor_pos_withlo_ContinuousStates*) ssGetContStates(S);

  /* Integrator Block: <S1>/Integrator */
  {
    real_T *dx = ssGetdX(S);

    dx[0] = motor_pos_withlo_B->Mechanical;
  }

  /* TransferFcn Block: <S1>/Electrical */
  {
    real_T *dx = ssGetdX(S)+1;

    dx[0] = motor_pos_withlo_B->Sum3;
    dx[0] += (-2.4107142857142862E+003)*motor_pos_withlo_X->Electrical_CSTATE;
  }

  /* TransferFcn Block: <S1>/Mechanical */
  {
    real_T *dx = ssGetdX(S)+2;

    dx[0] = motor_pos_withlo_B->Motor_Gain;
    dx[0] += (-2.9070758738277919E-001)*motor_pos_withlo_X->Mechanical_CSTATE;
  }
}

/* Compute model zero crossings */
#define MDL_ZERO_CROSSINGS
static void mdlZeroCrossings(SimStruct *S)
{
  /* simstruct variables */
  motor_pos_withlo_BlockIO *motor_pos_withlo_B = (motor_pos_withlo_BlockIO *)
    ssGetLocalBlockIO(S);
  motor_pos_withlo_NonsampledZCs *motor_pos_withlo_NonsampledZC =
    (motor_pos_withlo_NonsampledZCs *) ssGetNonsampledZCs(S);

  /* Backlash Block: <S1>/Backlash */
  {
    real_T t = ssGetT(S);
    real_T timeStampA = ((real_T*) ssGetDWork(S,0))[0];
    real_T timeStampB = ((real_T*) ssGetDWork(S,0))[2];
    real_T halfDeadBand;
    real_T *lastY;

    halfDeadBand = (1.7444444444444447E-003)/2.0;
    if (timeStampA < timeStampB) {
      if (timeStampB < t) {
        lastY = &((real_T*) ssGetDWork(S,0))[3];
      } else {
        /* timeStampB == t, so use lastYatTimeA */
        lastY = &((real_T*) ssGetDWork(S,0))[1];
      }
    } else {
      /* timeStampB <= timeStampA */
      if (timeStampA < t) {
        lastY = &((real_T*) ssGetDWork(S,0))[1];
      } else {
        /* timeStampA == t, so use lastYatTimeB */
        lastY = &((real_T*) ssGetDWork(S,0))[3];
      }
    }

    motor_pos_withlo_NonsampledZC->Backlash_NSZC[0] =
      motor_pos_withlo_B->Integrator - lastY[0] - halfDeadBand;
    motor_pos_withlo_NonsampledZC->Backlash_NSZC[1] =
      motor_pos_withlo_B->Integrator - lastY[0] + halfDeadBand;
  }

  /* Saturate Block: <S1>/Input Voltage Saturation */
  /* Do zero crossings for the upper limit */
  motor_pos_withlo_NonsampledZC->Input_Voltage_Saturation_NSZC[0] = *(((const
    real_T**)ssGetInputPortSignalPtrs(S, 0))[0]) -
    10.0;
  /* Do zero crossings for the lower limit */
  motor_pos_withlo_NonsampledZC->Input_Voltage_Saturation_NSZC[1] = *(((const
    real_T**)ssGetInputPortSignalPtrs(S, 0))[0]) -
    (-10.0);

  /* Saturate Block: <S1>/Current Saturation */
  /* Do zero crossings for the upper limit */
  motor_pos_withlo_NonsampledZC->Current_Saturation_NSZC[0] =
    motor_pos_withlo_B->Electrical -
    4.0;
  /* Do zero crossings for the lower limit */
  motor_pos_withlo_NonsampledZC->Current_Saturation_NSZC[1] =
    motor_pos_withlo_B->Electrical -
    (-4.0);
}

/* Terminate function */
static void mdlTerminate(SimStruct *S)
{
  if(S != NULL) {

#if defined(RT_MALLOC) || defined(MATLAB_MEX_FILE)

    if (ssGetUserData(S) != NULL ) {
      rt_FREE(ssGetLocalBlockIO(S));
    }
    rt_FREE(ssGetUserData(S));
#endif
  }
}

#define MDL_CHECK_PARAMETERS
#if defined(MDL_CHECK_PARAMETERS) && defined(MATLAB_MEX_FILE)
static void mdlCheckParameters(SimStruct *S)
{
}
#endif                                  /* MDL_CHECK_PARAMETERS */

/* End of Functions in model "motor_pos_withlo_sf" */

#include "motor_pos_withlo_sf_reg.h"

/* [EOF] motor_pos_withlo_sf.c */
