/*
 * motor_spd_mid.h
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

#include "tmwtypes.h"
#include "simstruc.h"
#include "motor_spd_sf.h"
#include "motor_spd_sf_prm.h"

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

/* instance data for model: motor_spd */
void *motor_spd_malloc(SimStruct *rts)
{
  /* Local SimStruct for RTW generated S-Function */
  LocalS *lS = (LocalS *) malloc(sizeof(LocalS));

  rt_VALIDATE_MEMORY(rts, lS);
  (void)memset((char *) lS, 0, sizeof(LocalS));
  ssSetUserData(rts, lS);

  /* block I/O */
  {
    void *b = malloc(sizeof(motor_spd_BlockIO));
    rt_VALIDATE_MEMORY(rts, b);

    ssSetLocalBlockIO(rts, b);

    {
      int_T i;

      for (i = 0; i < 5; i++) {
        ((real_T*) b)[i] = 0.0;
      }
    }
  }

  /* model checksums */
  ssSetChecksum0(rts, 2611364135U);
  ssSetChecksum1(rts, 968222886U);
  ssSetChecksum2(rts, 3350567654U);
  ssSetChecksum3(rts, 668547662U);

  return NULL;
}

/* [EOF] motor_spd_sf_mid.h */
