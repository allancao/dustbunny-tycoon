/*
 * Real-Time Workshop code generation for Simulink model "DC_sf.mdl".
 *
 * Model Version                        : 1.122
 * Real-Time Workshop file version      : 5.0 $Date: 2002/05/30 19:21:33 $
 * Real-Time Workshop file generated on : Wed Jul 30 14:06:53 2003
 * TLC version                          : 5.0 (Jun 18 2002)
 * C source code generated on           : Wed Jul 30 14:06:54 2003
 */

#include <math.h>
#include <string.h>
#include "DC_sf.h"
#include "DC_sf_private.h"
#include "simstruc.h"

#if defined(RT_MALLOC) || defined(MATLAB_MEX_FILE)
extern void *DC_malloc(SimStruct *S);
#endif

#if defined (MATLAB_MEX_FILE)
extern void * utMalloc(size_t);
extern void utFree(void *);
#endif

#if defined(MATLAB_MEX_FILE)

real_T rtInf;
real_T rtNaN;
#endif

/* Initial conditions for root system: '<Root>' */
#define MDL_INITIALIZE_CONDITIONS
static void mdlInitializeConditions(SimStruct *S)
{
  /* simstruct variables */
  DC_ContinuousStates *DC_X = (DC_ContinuousStates*) ssGetContStates(S);

  /* TransferFcn Block: <S1>/Transfer Fcn1 */
  DC_X->Transfer_Fcn1_CSTATE[0] = 0.0;
  DC_X->Transfer_Fcn1_CSTATE[1] = 0.0;

  /* TransferFcn Block: <S1>/Transfer Fcn2 */
  DC_X->Transfer_Fcn2_CSTATE = 0.0;

  /* Integrator Block: <S1>/Integrator */
  DC_X->Integrator_CSTATE = 0.0;
}

/* Start for root system: '<Root>' */
#define MDL_START
static void mdlStart(SimStruct *S)
{

  /* instance underlying S-Function data */
#if defined(RT_MALLOC) || defined(MATLAB_MEX_FILE)
# if defined(MATLAB_MEX_FILE)

  /* non-finites */
  rtInf = mxGetInf();
  rtNaN = mxGetNaN();

  /* Check for invalid switching between solver types */
  if (!ssIsVariableStepSolver(S)) {
    ssSetErrorStatus(S, "This Real-Time Workshop generated "
     "S-function cannot be used in a simulation with "
     "a solver type of fixed-step "
     "because this S-function was created from a model with "
     "solver type of variable-step solver and it has continuous time blocks. "
     "See the Solver page of the simulation parameters dialog.");

    return;
  }

# endif

  DC_malloc(S);
  if( ssGetErrorStatus(S) != NULL ) {
    return;
  }
#endif

  {

    /* TransportDelay Block: <S1>/Transport Delay2 */
    {
      real_T *pBuffer = &((real_T*) ssGetDWork(S, 0))[0];

      ((int_T*) ssGetDWork(S, 3))[0] = 0;
      ((int_T*) ssGetDWork(S, 3))[1] = 0;
      ((int_T*) ssGetDWork(S, 3))[2] = 0;
      ((int_T*) ssGetDWork(S, 3))[3] = 4096;
      pBuffer[0] = 0.0;
      pBuffer[4096] = ssGetT(S);
      ((pointer_T*) ssGetDWork(S, 2))[0] = (void *) &pBuffer[0];
      ((pointer_T*) ssGetDWork(S, 2))[1] = (void *) &pBuffer[4096];
    }

    /* RandomNumber Block: <S1>/Random Number */
    {
      uint_T *RandSeed = (uint_T *) &((int_T*) ssGetDWork(S, 4))[0];
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

      ((real_T*) ssGetDWork(S, 1))[0] =
        rt_NormalRand(RandSeed++) * 3.1622776601683794E-003 + 0.0;
    }
  }
}

/* Outputs for root system: '<Root>' */
static void mdlOutputs(SimStruct *S, int_T tid)
{
  /* simstruct variables */
  DC_BlockIO *DC_B = (DC_BlockIO *) ssGetLocalBlockIO(S);
  DC_ContinuousStates *DC_X = (DC_ContinuousStates*) ssGetContStates(S);

  /* local block i/o variables */
  real_T rtb_Current_Saturation;
  real_T rtb_Input_Voltage_Saturation;
  real_T rtb_temp11;

  if (ssIsContinuousTask(S, tid)) {     /* Sample time: [0.0, 0.0] */

    /* TransportDelay Block: <S1>/Transport Delay2 */
    {

      real_T **uBuffer = (real_T**)&((pointer_T*) ssGetDWork(S, 2))[0];
      real_T **tBuffer = (real_T**)&((pointer_T*) ssGetDWork(S, 2))[1];
      real_T simTime = ssGetT(S);
      real_T tMinusDelay = simTime - 0.001;

      rtb_temp11 = rt_TDelayInterpolate(
        tMinusDelay,
        *tBuffer,
        *uBuffer,
        ((int_T*) ssGetDWork(S, 3))[3],
        &((int_T*) ssGetDWork(S, 3))[2],
        ((int_T*) ssGetDWork(S, 3))[0],
        ((int_T*) ssGetDWork(S, 3))[1],
        0,
        (boolean_T) (ssIsMinorTimeStep(S) && (ssGetTimeOfLastOutput(S) ==
        ssGetT(S))));
    }

    /* Outport: '<Root>/Position' */
    ((real_T *)ssGetOutputPortSignal(S, 0))[0] = rtb_temp11;

    /* TransferFcn Block: <S1>/Transfer Fcn1 */
    DC_B->Velocity = 2.4998812556403573E+002*DC_X->Transfer_Fcn1_CSTATE[0] +
      0.0*DC_X->Transfer_Fcn1_CSTATE[1];

    /* Outport: '<Root>/Velocity' */
    ((real_T *)ssGetOutputPortSignal(S, 1))[0] = DC_B->Velocity;

    /* TransferFcn Block: <S1>/Transfer Fcn2 */
    DC_B->Transfer_Fcn2 = 1.7857142857142858E+003*DC_X->Transfer_Fcn2_CSTATE;

    /* Saturate: '<S1>/Current Saturation'
     *
     * Regarding '<S1>/Current Saturation':
     *   Lower limit: (-4.0)
     *   Upper limit: 4.0
     */
    if (ssIsMajorTimeStep(S)) {
      if (DC_B->Transfer_Fcn2 >= 4.0) {
        ((int_T*) ssGetDWork(S, 5))[0] = 1;
      } else if (DC_B->Transfer_Fcn2 <= (-4.0)) {
        ((int_T*) ssGetDWork(S, 5))[0] = -1;
      } else {
        ((int_T*) ssGetDWork(S, 5))[0] = 0;
      }
    }
    /* Output value */
    if (((int_T*) ssGetDWork(S, 5))[0] == 1) {
      rtb_Current_Saturation = 4.0;
    } else if (((int_T*) ssGetDWork(S, 5))[0] == -1) {
      rtb_Current_Saturation = (-4.0);
    } else {
      rtb_Current_Saturation = DC_B->Transfer_Fcn2;
    }

    /* Saturate: '<S1>/Input Voltage Saturation' incorporates:
     *   Inport: '<Root>/In2'
     *
     * Regarding '<S1>/Input Voltage Saturation':
     *   Lower limit: (-10.0)
     *   Upper limit: 10.0
     */
    if (ssIsMajorTimeStep(S)) {
      if (*(((const real_T**)ssGetInputPortSignalPtrs(S, 1))[0]) >= 10.0) {
        ((int_T*) ssGetDWork(S, 6))[0] = 1;
      } else if (*(((const real_T**)ssGetInputPortSignalPtrs(S, 1))[0]) <=
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
        real_T**)ssGetInputPortSignalPtrs(S, 1))[0]);
    }

    /* Integrator: '<S1>/Integrator' */
    rtb_temp11 = DC_X->Integrator_CSTATE;
  }

  if (ssIsSampleHit(S, 1, tid)) {       /* Sample time: [0.01, 0.0] */

    /* RandomNumber: '<S1>/Random Number' */
    DC_B->Random_Number = ((real_T*) ssGetDWork(S, 1))[0];
  }

  if (ssIsContinuousTask(S, tid)) {     /* Sample time: [0.0, 0.0] */

    /* Sum: '<S1>/Sum' */
    DC_B->Sum = rtb_temp11 + DC_B->Random_Number;

    /* Sum: '<S1>/Sum1' incorporates:
     *   Inport: '<Root>/Torque'
     *   Gain: '<S1>/Current -> Torque'
     *
     * Regarding '<S1>/Current -> Torque':
     *   Gain value: 0.1
     */
    DC_B->Sum1 = - *(((const real_T**)ssGetInputPortSignalPtrs(S, 0))[0])
      + (rtb_Current_Saturation * 0.1);

    /* Sum: '<S1>/Sum2' incorporates:
     *   Gain: '<S1>/Current -> Torque1'
     *   Gain: '<S1>/Back EMF'
     *
     * Regarding '<S1>/Current -> Torque1':
     *   Gain value: 2.0
     *
     * Regarding '<S1>/Back EMF':
     *   Gain value: 0.1
     */
    DC_B->Sum2 = (rtb_Input_Voltage_Saturation * 2.0) - (DC_B->Velocity * 0.1);
  }
}

/* Update for root system: '<Root>' */
#define MDL_UPDATE
static void mdlUpdate(SimStruct *S, int_T tid)
{

  /* simstruct variables */
  DC_BlockIO *DC_B = (DC_BlockIO *) ssGetLocalBlockIO(S);

  if (ssIsContinuousTask(S, tid)) {     /* Sample time: [0.0, 0.0] */

    /* TransportDelay Block: <S1>/Transport Delay2 */
    {
      real_T **uBuffer = (real_T**)&((pointer_T*) ssGetDWork(S, 2))[0];
      real_T **tBuffer = (real_T**)&((pointer_T*) ssGetDWork(S, 2))[1];
      real_T simTime = ssGetT(S);

      ((int_T*) ssGetDWork(S, 3))[1] = ((((int_T*) ssGetDWork(S, 3))[1] <
        (((int_T*) ssGetDWork(S, 3))[3]-1)) ? (((int_T*) ssGetDWork(S, 3))[1]+1)
        : 0);

      if (((int_T*) ssGetDWork(S, 3))[1] == ((int_T*) ssGetDWork(S, 3))[0]) {
        ((int_T*) ssGetDWork(S, 3))[0] = ((((int_T*) ssGetDWork(S, 3))[0] <
          (((int_T*) ssGetDWork(S, 3))[3]-1)) ? (((int_T*) ssGetDWork(S,
          3))[0]+1) : 0);
      }

      (*tBuffer)[((int_T*) ssGetDWork(S, 3))[1]] = simTime;
      (*uBuffer)[((int_T*) ssGetDWork(S, 3))[1]] = DC_B->Sum;
    }
  }

  if (ssIsSampleHit(S, 1, tid)) {       /* Sample time: [0.01, 0.0] */

    /* RandomNumber Block: <S1>/Random Number */
    ((real_T*) ssGetDWork(S, 1))[0] = rt_NormalRand((uint_T *)&((int_T*)
      ssGetDWork(S, 4))[0])*3.1622776601683794E-003+0.0;
  }
}

/* Derivatives for root system: '<Root>' */
#define MDL_DERIVATIVES
static void mdlDerivatives(SimStruct *S)
{
  /* simstruct variables */
  DC_BlockIO *DC_B = (DC_BlockIO *) ssGetLocalBlockIO(S);
  DC_ContinuousStates *DC_X = (DC_ContinuousStates*) ssGetContStates(S);
  DC_StateDerivatives *DC_Xdot = (DC_StateDerivatives*) ssGetdX(S);

  /* TransferFcn Block: <S1>/Transfer Fcn1 */
  {

    DC_Xdot->Transfer_Fcn1_CSTATE[0] = DC_B->Sum1;
    DC_Xdot->Transfer_Fcn1_CSTATE[0] +=
      (-2.8933625652781492E-001)*DC_X->Transfer_Fcn1_CSTATE[0] +
      (-2.1733967636537269E-001)*DC_X->Transfer_Fcn1_CSTATE[1];
    DC_Xdot->Transfer_Fcn1_CSTATE[1] = DC_X->Transfer_Fcn1_CSTATE[0];
  }

  /* TransferFcn Block: <S1>/Transfer Fcn2 */
  {

    DC_Xdot->Transfer_Fcn2_CSTATE = DC_B->Sum2;
    DC_Xdot->Transfer_Fcn2_CSTATE +=
      (-2.4107142857142862E+003)*DC_X->Transfer_Fcn2_CSTATE;
  }

  /* Integrator Block: <S1>/Integrator */
  {

    DC_Xdot->Integrator_CSTATE = DC_B->Velocity;
  }
}

/* ZeroCrossings for root system: '<Root>' */
#define MDL_ZERO_CROSSINGS
static void mdlZeroCrossings(SimStruct *S)
{
  /* simstruct variables */
  DC_BlockIO *DC_B = (DC_BlockIO *) ssGetLocalBlockIO(S);
  DC_NonsampledZCs *DC_NonsampledZC = (DC_NonsampledZCs *) ssGetNonsampledZCs(S);

  /* Saturate Block: '<S1>/Current Saturation' */
  /* Do zero crossings for the upper limit */
  DC_NonsampledZC->Current_Saturation_NSZC[0] = DC_B->Transfer_Fcn2 -
    4.0;
  /* Do zero crossings for the lower limit */
  DC_NonsampledZC->Current_Saturation_NSZC[1] = DC_B->Transfer_Fcn2 -
    (-4.0);

  /* Saturate Block: '<S1>/Input Voltage Saturation' */
  /* Do zero crossings for the upper limit */
  DC_NonsampledZC->Input_Voltage_Saturation_NSZC[0] = *(((const
    real_T**)ssGetInputPortSignalPtrs(S, 1))[0]) -
    10.0;
  /* Do zero crossings for the lower limit */
  DC_NonsampledZC->Input_Voltage_Saturation_NSZC[1] = *(((const
    real_T**)ssGetInputPortSignalPtrs(S, 1))[0]) -
    (-10.0);
}

/* Terminate for root system: '<Root>' */
static void mdlTerminate(SimStruct *S)
{
  if(S != NULL) {

#if defined(RT_MALLOC) || defined(MATLAB_MEX_FILE)

    if ( ssGetUserData(S) != NULL ) {
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

#if defined(RT_MALLOC) || defined(MATLAB_MEX_FILE)
# include "DC_mid.h"
#endif

/* Function to initialize sizes */
static void mdlInitializeSizes(SimStruct *S)
{
  ssSetNumSampleTimes(S, 2);            /* Number of sample times */
  ssSetNumContStates(S, 4);             /* Number of continuous states */
  ssSetNumNonsampledZCs(S, 4);          /* Number of nonsampled ZCs */

  /* Number of output ports */
  if (!ssSetNumOutputPorts(S, 2)) return;

  /* outport number: 0 */
  if(!ssSetOutputPortVectorDimension(S, 0, 1)) return;
  ssSetOutputPortSampleTime(S, 0, 0.0);
  ssSetOutputPortOffsetTime(S, 0, 0.0);
  ssSetOutputPortOptimOpts(S, 0, SS_REUSABLE_AND_LOCAL);

  /* outport number: 1 */
  if(!ssSetOutputPortVectorDimension(S, 1, 1)) return;
  ssSetOutputPortSampleTime(S, 1, 0.0);
  ssSetOutputPortOffsetTime(S, 1, 0.0);
  ssSetOutputPortOptimOpts(S, 1, SS_REUSABLE_AND_LOCAL);

  /* Number of input ports */
  if (!ssSetNumInputPorts(S, 2)) return;

  /* inport number: 0 */
  {
    if(!ssSetInputPortVectorDimension(S, 0, 1)) return;
    ssSetInputPortDirectFeedThrough(S, 0, 1);
    ssSetInputPortSampleTime(S, 0, 0.0);
    ssSetInputPortOffsetTime(S, 0, 0.0);
    ssSetInputPortOverWritable(S, 0, 0);
    ssSetInputPortOptimOpts(S, 0, SS_NOT_REUSABLE_AND_GLOBAL);
  }

  /* inport number: 1 */
  {
    if(!ssSetInputPortVectorDimension(S, 1, 1)) return;
    ssSetInputPortDirectFeedThrough(S, 1, 1);
    ssSetInputPortSampleTime(S, 1, 0.0);
    ssSetInputPortOffsetTime(S, 1, 0.0);
    ssSetInputPortOverWritable(S, 1, 0);
    ssSetInputPortOptimOpts(S, 1, SS_NOT_REUSABLE_AND_GLOBAL);
  }

  ssSetRTWGeneratedSFcn(S, 1);          /* RTW generated S-function */

  /* DWork */
  if ( !ssSetNumDWork(S, 7)) {
    return;
  }

  /* <S1>/Transport Delay2: RWORK */
  ssSetDWorkName(S, 0, "DWORK0");
  ssSetDWorkWidth(S, 0, 8192);

  /* <S1>/Random Number: RWORK */
  ssSetDWorkName(S, 1, "DWORK1");
  ssSetDWorkWidth(S, 1, 1);

  /* <S1>/Transport Delay2: PWORK */
  ssSetDWorkName(S, 2, "DWORK2");
  ssSetDWorkWidth(S, 2, 2);

  ssSetDWorkDataType(S, 2, SS_POINTER);

  /* <S1>/Transport Delay2: IWORK */
  ssSetDWorkName(S, 3, "DWORK3");
  ssSetDWorkWidth(S, 3, 4);

  ssSetDWorkDataType(S, 3, SS_INTEGER);

  /* <S1>/Random Number: IWORK */
  ssSetDWorkName(S, 4, "DWORK4");
  ssSetDWorkWidth(S, 4, 1);

  ssSetDWorkDataType(S, 4, SS_INTEGER);

  /* <S1>/Current Saturation: MODE */
  ssSetDWorkName(S, 5, "DWORK5");
  ssSetDWorkWidth(S, 5, 1);

  ssSetDWorkDataType(S, 5, SS_INTEGER);

  /* <S1>/Input Voltage Saturation: MODE */
  ssSetDWorkName(S, 6, "DWORK6");
  ssSetDWorkWidth(S, 6, 1);

  ssSetDWorkDataType(S, 6, SS_INTEGER);

  /* Tunable Parameters */
  ssSetNumSFcnParams(S, 0);
  /* Number of expected parameters */
#if defined(MATLAB_MEX_FILE)
  if (ssGetNumSFcnParams(S) == ssGetSFcnParamsCount(S)) {
#if defined(MDL_CHECK_PARAMETERS)
    mdlCheckParameters(S);
#endif                                  /* MDL_CHECK_PARAMETERS */
    if( ssGetErrorStatus(S) != NULL ) {
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
  ssSetSampleTime(S, 1, 0.01);

  /* task offsets */
  ssSetOffsetTime(S, 0, 0.0);
  ssSetOffsetTime(S, 1, 0.0);
}

#if defined(MATLAB_MEX_FILE)

# include "simulink.c"

#else

# undef S_FUNCTION_NAME
# define S_FUNCTION_NAME DC_sf
# include "cg_sfun.h"

#endif                                  /* defined(MATLAB_MEX_FILE) */

