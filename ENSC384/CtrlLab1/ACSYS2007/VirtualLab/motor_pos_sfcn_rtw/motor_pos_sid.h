/*
 * motor_pos_sid.h
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

/* statically allocated instance data for model: motor_pos */
{
  extern motor_pos_Parameters motor_pos_DefaultParameters;
  {
    /* Local SimStruct for RTW generated S-Function */
    static LocalS lS;
    ssSetUserData(rts, &lS);

    /* block I/O */
    {
      static motor_pos_BlockIO sfcnB;
      void *b = (real_T *) &sfcnB;

      ssSetLocalBlockIO(rts, b);

      {
        int_T i;

        for (i = 0; i < 6; i++) {
          ((real_T*) b)[i] = 0.0;
        }
      }
    }

    /* model parameters */
    ssSetLocalDefaultParam(rts, (real_T *) &motor_pos_DefaultParameters);

    /* model checksums */
    ssSetChecksum0(rts, 1717487887U);
    ssSetChecksum1(rts, 622268618U);
    ssSetChecksum2(rts, 2045583605U);
    ssSetChecksum3(rts, 3364179664U);
  }
}

/* [EOF] motor_pos_sf_sid.h */
