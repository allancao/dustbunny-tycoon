/*
 * DC_sid.h
 *
 * Real-Time Workshop code generation for Simulink model "DC_sf.mdl".
 *
 * Model Version                        : 1.122
 * Real-Time Workshop file version      : 5.0 $Date: 2002/05/30 19:21:33 $
 * Real-Time Workshop file generated on : Wed Jul 30 14:06:53 2003
 * TLC version                          : 5.0 (Jun 18 2002)
 * C source code generated on           : Wed Jul 30 14:06:54 2003
 *
 * SOURCES: DC_sf.c 
 */

/* statically allocated instance data for model: DC */
{
  {
    /* Local SimStruct for RTW generated S-Function */
    static LocalS slS;
    LocalS *lS = &slS;
    ssSetUserData(rts, lS);

    /* block I/O */
    {
      static DC_BlockIO sfcnB;
      void *b = (real_T *) &sfcnB;

      ssSetLocalBlockIO(rts, b);
      {
        int_T i;
        /* simstruct variables */
        DC_BlockIO *DC_B = (DC_BlockIO *) ssGetLocalBlockIO(rts);

        b =&DC_B->Velocity;
        for (i = 0; i < 6; i++) {
          ((real_T*)b)[i] = 0.0;
        }
      }
    }

    /* model checksums */
    ssSetChecksumVal(rts, 0, 2736057333U);
    ssSetChecksumVal(rts, 1, 1968661418U);
    ssSetChecksumVal(rts, 2, 4146205130U);
    ssSetChecksumVal(rts, 3, 2793567489U);
  }
}

