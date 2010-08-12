/*
 * motor_spd_sf.c
 *
 * Real-Time Workshop code generation for Simulink model "motor_spd_sf.mdl".
 *
 * Model Version                        : 1.0
 * Real-Time Workshop file version      : 4.1 $Date: 2001/05/16 13:59:43 $
 * Real-Time Workshop file generated on : Tue Aug 21 10:23:50 2001
 * TLC version                          : 4.1 (May 19 2001)
 * C source code generated on           : Tue Aug 21 10:23:50 2001
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
#include "motor_spd_sf.h"
#include "motor_spd_sf_export.h"

#if defined(MATLAB_MEX_FILE)

real_T rtInf;
real_T rtMinusInf;
real_T rtNaN;
#endif

#if defined(RT_MALLOC) || defined(MATLAB_MEX_FILE)
extern void *motor_spd_malloc(SimStruct *S);
#endif

#if defined (MATLAB_MEX_FILE)
extern void * utMalloc(size_t);
extern void utFree(void *);
#endif

/* Start of Functions in model "motor_spd_sf" */
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

  motor_spd_malloc(S);
  if( ssGetErrorStatus(S) != NULL ) {
    return;
  }
#endif

  {

    /* RandomNumber Block: <S1>/Random Number */
    {
      uint_T *RandSeed = (uint_T *) &((int_T*) ssGetDWork(S, 2))[0];
      int_T r, t;
      *RandSeed = 0U;
      r = *RandSeed >> 16;
      t = *RandSeed & BIT16;
      *RandSeed = ((*RandSeed - (r << 16) - t) << 16) + t + r;
      if (*RandSeed < 1) {
        *RandSeed = SEED0;
      }
      if (*RandSeed > MAXSEED) {
        *RandSeed = MAXSEED;
      }

      ((real_T*) ssGetDWork(S,0))[0] =
        rt_NormalRand(RandSeed++) * 8.6602540378443865E-002 + 0.1;
    }

    /* RandomNumber Block: <S1>/Random Number1 */
    {
      uint_T *RandSeed = (uint_T *) &((int_T*) ssGetDWork(S, 3))[0];
      int_T r, t;
      *RandSeed = 0U;
      r = *RandSeed >> 16;
      t = *RandSeed & BIT16;
      *RandSeed = ((*RandSeed - (r << 16) - t) << 16) + t + r;
      if (*RandSeed < 1) {
        *RandSeed = SEED0;
      }
      if (*RandSeed > MAXSEED) {
        *RandSeed = MAXSEED;
      }

      ((real_T*) ssGetDWork(S,1))[0] =
        rt_NormalRand(RandSeed++) * 7.0710678118654753E-003 + 0.0;
    }
  }
}

/* Initialize the model */
#define MDL_INITIALIZE_CONDITIONS
static void mdlInitializeConditions(SimStruct *S)
{
  /* simstruct variables */
  motor_spd_ContinuousStates *motor_spd_X = (motor_spd_ContinuousStates*)
    ssGetContStates(S);

  /* TransferFcn Block: <S1>/Mechanical */
  motor_spd_X->Mechanical_CSTATE = 0.0;

  /* TransferFcn Block: <S1>/Electrical */
  motor_spd_X->Electrical_CSTATE = 0.0;
}

/* Compute block outputs */
static void mdlOutputs(SimStruct *S, int_T tid)
{
  /* simstruct variables */
  motor_spd_BlockIO *motor_spd_B = (motor_spd_BlockIO *) ssGetLocalBlockIO(S);
  motor_spd_ContinuousStates *motor_spd_X = (motor_spd_ContinuousStates*)
    ssGetContStates(S);

  /* local block i/o variables */
  real_T rtb_Mechanical;
  real_T rtb_Start;
  real_T rtb_End;
  real_T rtb_Input_Voltage_Saturation;
  real_T rtb_Current_Saturation;

  if (ssIsContinuousTask(S, tid)) {     /* Sample time: [0.0, 0.0] */
    /* TransferFcn Block: <S1>/Mechanical */
    rtb_Mechanical = 5.2631578947368416E+002*motor_spd_X->Mechanical_CSTATE;

    /* Step: '<S1>/Start' */
    if (ssIsMajorTimeStep(S)) {
      if (ssGetTaskTime(S,tid) >= 0.002) {
        ((int_T*) ssGetDWork(S, 4))[0] = 1;
      } else {
        ((int_T*) ssGetDWork(S, 4))[0] = 0;
      }
    }
    /* Output value */
    rtb_Start = (((int_T*) ssGetDWork(S, 4))[0] == 1) ? 1.0 : 0.0;

    /* Step: '<S1>/End' */
    if (ssIsMajorTimeStep(S)) {
      if (ssGetTaskTime(S,tid) >= 0.005) {
        ((int_T*) ssGetDWork(S, 5))[0] = 1;
      } else {
        ((int_T*) ssGetDWork(S, 5))[0] = 0;
      }
    }
    /* Output value */
    rtb_End = (((int_T*) ssGetDWork(S, 5))[0] == 1) ? (-1.0) : 0.0;
  }

  if (ssIsSampleHit(S, 1, tid)) {       /* Sample time: [0.00075, 0.0] */
    /* RandomNumber: '<S1>/Random Number' */
    motor_spd_B->Random_Number = ((real_T*) ssGetDWork(S,0))[0];
  }

  if (ssIsSampleHit(S, 2, tid)) {       /* Sample time: [0.002, 0.0] */
    /* RandomNumber: '<S1>/Random Number1' */
    motor_spd_B->Random_Number1 = ((real_T*) ssGetDWork(S,1))[0];
  }

  if (ssIsContinuousTask(S, tid)) {     /* Sample time: [0.0, 0.0] */
    /* Outport: '<Root>/Speed out' incorporates:
     *   Sum: '<S1>/Sum1'
     *   Sum: '<S1>/Sum5'
     *   Product: '<S1>/Product'
     *   Sum: '<S1>/Sum2'
     */
    ((real_T *)ssGetOutputPortSignal(S,0))[0] = ((rtb_Mechanical + ((rtb_Start +
      rtb_End) * motor_spd_B->Random_Number)) + motor_spd_B->Random_Number1);

    /* Saturate: '<S1>/Input Voltage Saturation' incorporates:
     *   Inport: '<Root>/E in'
     *
     * Regarding '<S1>/Input Voltage Saturation':
     *   Lower limit: (-10.0)
     *   Upper limit: 10.0
     */
    if (ssIsMajorTimeStep(S)) {
      if (*(((const real_T**)ssGetInputPortSignalPtrs(S, 0))[0]) >= 10.0) {
        ((int_T*) ssGetDWork(S, 6))[0] = 1;
      } else if (*(((const real_T**)ssGetInputPortSignalPtrs(S, 0))[0]) <=
       (-10.0)) {
        ((int_T*) ssGetDWork(S, 6))[0] = -1;
      } else {
        ((int_T*) ssGetDWork(S, 6))[0] = 0;
      }
    }
    /* Output value */
    if (((int_T*) ssGetDWork(S, 6))[0] == 1) {
      rtb_Input_Voltage_Saturation = 10.0;
    } else if (((int_T*) ssGetDWork(S, 6))[0] == -1) {
      rtb_Input_Voltage_Saturation = (-10.0);
    } else {
      rtb_Input_Voltage_Saturation = *(((const
        real_T**)ssGetInputPortSignalPtrs(S, 0))[0]);
    }

    /* TransferFcn Block: <S1>/Electrical */
    motor_spd_B->Electrical =
      1.7857142857142858E+003*motor_spd_X->Electrical_CSTATE;

    /* Saturate: '<S1>/Current Saturation'
     *
     * Regarding '<S1>/Current Saturation':
     *   Lower limit: (-4.0)
     *   Upper limit: 4.0
     */
    if (ssIsMajorTimeStep(S)) {
      if (motor_spd_B->Electrical >= 4.0) {
        ((int_T*) ssGetDWork(S, 7))[0] = 1;
      } else if (motor_spd_B->Electrical <= (-4.0)) {
        ((int_T*) ssGetDWork(S, 7))[0] = -1;
      } else {
        ((int_T*) ssGetDWork(S, 7))[0] = 0;
      }
    }
    /* Output value */
    if (((int_T*) ssGetDWork(S, 7))[0] == 1) {
      rtb_Current_Saturation = 4.0;
    } else if (((int_T*) ssGetDWork(S, 7))[0] == -1) {
      rtb_Current_Saturation = (-4.0);
    } else {
      rtb_Current_Saturation = motor_spd_B->Electrical;
    }

    /* Gain: '<S1>/Motor Gain'
     *
     * Regarding '<S1>/Motor Gain':
     *   Gain value: 0.1
     */
    motor_spd_B->Motor_Gain = rtb_Current_Saturation * 0.1;

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
    motor_spd_B->Sum3 = (2.0 * rtb_Input_Voltage_Saturation)
      - (0.1 * rtb_Mechanical);
  }
}

/* Perform model update */
#define MDL_UPDATE
static void mdlUpdate(SimStruct *S, int_T tid)
{
  if (ssIsSampleHit(S, 1, tid)) {       /* Sample time: [0.00075, 0.0] */
    /* RandomNumber Block: <S1>/Random Number */
    ((real_T*) ssGetDWork(S,0))[0] = rt_NormalRand((uint_T *)&((int_T*)
      ssGetDWork(S, 2))[0])*8.6602540378443865E-002+0.1;
  }

  if (ssIsSampleHit(S, 2, tid)) {       /* Sample time: [0.002, 0.0] */
    /* RandomNumber Block: <S1>/Random Number1 */
    ((real_T*) ssGetDWork(S,1))[0] = rt_NormalRand((uint_T *)&((int_T*)
      ssGetDWork(S, 3))[0])*7.0710678118654753E-003+0.0;
  }
}

/* Compute model derivatives */
#define MDL_DERIVATIVES
static void mdlDerivatives(SimStruct *S)
{
  /* simstruct variables */
  motor_spd_BlockIO *motor_spd_B = (motor_spd_BlockIO *) ssGetLocalBlockIO(S);
  motor_spd_ContinuousStates *motor_spd_X = (motor_spd_ContinuousStates*)
    ssGetContStates(S);

  /* TransferFcn Block: <S1>/Mechanical */
  {
    real_T *dx = ssGetdX(S)+0;

    dx[0] = motor_spd_B->Motor_Gain;
    dx[0] += (-4.1684210526315785E-001)*motor_spd_X->Mechanical_CSTATE;
  }

  /* TransferFcn Block: <S1>/Electrical */
  {
    real_T *dx = ssGetdX(S)+1;

    dx[0] = motor_spd_B->Sum3;
    dx[0] += (-2.4107142857142862E+003)*motor_spd_X->Electrical_CSTATE;
  }
}

/* Compute model zero crossings */
#define MDL_ZERO_CROSSINGS
static void mdlZeroCrossings(SimStruct *S)
{
  /* simstruct variables */
  motor_spd_BlockIO *motor_spd_B = (motor_spd_BlockIO *) ssGetLocalBlockIO(S);
  motor_spd_NonsampledZCs *motor_spd_NonsampledZC = (motor_spd_NonsampledZCs *)
    ssGetNonsampledZCs(S);

  /* Step Block: <S1>/Start */
  motor_spd_NonsampledZC->Start_NSZC = ssGetT(S) - 0.002;

  /* Step Block: <S1>/End */
  motor_spd_NonsampledZC->End_NSZC = ssGetT(S) - 0.005;

  /* Saturate Block: <S1>/Input Voltage Saturation */
  /* Do zero crossings for the upper limit */
  motor_spd_NonsampledZC->Input_Voltage_Saturation_NSZC[0] = *(((const
    real_T**)ssGetInputPortSignalPtrs(S, 0))[0]) -
    10.0;
  /* Do zero crossings for the lower limit */
  motor_spd_NonsampledZC->Input_Voltage_Saturation_NSZC[1] = *(((const
    real_T**)ssGetInputPortSignalPtrs(S, 0))[0]) -
    (-10.0);

  /* Saturate Block: <S1>/Current Saturation */
  /* Do zero crossings for the upper limit */
  motor_spd_NonsampledZC->Current_Saturation_NSZC[0] = motor_spd_B->Electrical -

    4.0;
  /* Do zero crossings for the lower limit */
  motor_spd_NonsampledZC->Current_Saturation_NSZC[1] = motor_spd_B->Electrical -

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

/* End of Functions in model "motor_spd_sf" */

#include "motor_spd_sf_reg.h"

/* [EOF] motor_spd_sf.c */
