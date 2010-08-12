/*
 * motor_pos_withlo_mid.h
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

#include "tmwtypes.h"
#include "simstruc.h"
#include "motor_pos_withlo_sf.h"
#include "motor_pos_withlo_sf_prm.h"

static const char_T *RT_MEMORY_ALLOCATION_ERROR =
  "memory allocation error in RTW generated S-Function";

#if defined(MATLAB_MEX_FILE) || defined(RT_MALLOC)
static int_T RegNumInputPorts(SimStruct *S, int_T nInputPorts) {
  _ssSetNumInputPorts(S,nInputPorts);
  return TRUE;
}

static int_T RegNumOutputPorts(SimStruct *S, int_T nOutputPorts) {
  _ssSetNumOutputPorts(S,nOutputPorts);
  return TRUE;
}
#endif

/* instance data for model: motor_pos_withlo */
void *motor_pos_withlo_malloc(SimStruct *rts)
{
  /* Local SimStruct for RTW generated S-Function */
  LocalS *lS = (LocalS *) malloc(sizeof(LocalS));

  rt_VALIDATE_MEMORY(rts, lS);
  (void)memset((char *) lS, 0, sizeof(LocalS));
  ssSetUserData(rts, lS);

  /* block I/O */
  {
    void *b = malloc(sizeof(motor_pos_withlo_BlockIO));
    rt_VALIDATE_MEMORY(rts, b);

    ssSetLocalBlockIO(rts, b);

    {
      int_T i;

      for (i = 0; i < 6; i++) {
        ((real_T*) b)[i] = 0.0;
      }
    }
  }

  /* model parameters */
  ssSetLocalDefaultParam(rts, (real_T *) &motor_pos_withlo_DefaultParameters);

  /* model checksums */
  ssSetChecksum0(rts, 2275017285U);
  ssSetChecksum1(rts, 3749255188U);
  ssSetChecksum2(rts, 2468337266U);
  ssSetChecksum3(rts, 2853432745U);

  return NULL;
}

/* [EOF] motor_pos_withlo_sf_mid.h */
