/*
 * motor_spd_sid.h
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

/* statically allocated instance data for model: motor_spd */
{
  {
    /* Local SimStruct for RTW generated S-Function */
    static LocalS lS;
    ssSetUserData(rts, &lS);

    /* block I/O */
    {
      static motor_spd_BlockIO sfcnB;
      void *b = (real_T *) &sfcnB;

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
  }
}

/* [EOF] motor_spd_sf_sid.h */
