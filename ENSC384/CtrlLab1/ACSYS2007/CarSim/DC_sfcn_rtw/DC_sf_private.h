/*
 * DC_sf_private.h
 *
 * Real-Time Workshop code generation for Simulink model "DC_sf.mdl".
 *
 * Model Version                        : 1.122
 * Real-Time Workshop file version      : 5.0 $Date: 2002/05/30 19:21:33 $
 * Real-Time Workshop file generated on : Wed Jul 30 14:06:53 2003
 * TLC version                          : 5.0 (Jun 18 2002)
 * C source code generated on           : Wed Jul 30 14:06:54 2003
 */

#ifndef _RTW_HEADER_DC_sf_private_h_
# define _RTW_HEADER_DC_sf_private_h_

#ifndef _RTW_COMMON_DEFINES_
# define _RTW_COMMON_DEFINES_

#ifndef TRUE
# define TRUE (1)
#endif
#ifndef FALSE
# define FALSE (0)
#endif
#define rt_VALIDATE_MEMORY(S, ptr) if(!(ptr)) {\
    ssSetErrorStatus(S, RT_MEMORY_ALLOCATION_ERROR);\
    return(S);\
  }

#if !defined(_WIN32)
#define rt_FREE(ptr) if((ptr) != NULL) {\
    free((ptr));\
    (ptr) = NULL;\
  }
#else
/* Visual and other windows compilers delcare free without const! */
#define rt_FREE(ptr) if((ptr) != NULL) {\
    free((void *)(ptr));\
    (ptr) = NULL;\
  }
#endif

#endif                                  /* _RTW_COMMON_DEFINES_ */

#ifndef UCHAR_MAX
#include <limits.h>
#endif

#if ( UCHAR_MAX != (0xFFU) )
#error Fixed point code was generated for compiler with different sized uchars.
#endif

#if ( SCHAR_MAX != (0x7F) )
#error Fixed point code was generated for compiler with different sized chars.
#endif

#if ( USHRT_MAX != (0xFFFFU) )
#error Fixed point code was generated for compiler with different sized ushorts.
#endif

#if ( SHRT_MAX != (0x7FFF) )
#error Fixed point code was generated for compiler with different sized shorts.
#endif

#if ( UINT_MAX != (0xFFFFFFFFU) )
#error Fixed point code was generated for compiler with different sized uints.
#endif

#if ( INT_MAX != (0x7FFFFFFF) )
#error Fixed point code was generated for compiler with different sized ints.
#endif

#if ( ULONG_MAX != (0xFFFFFFFFU) )
#error Fixed point code was generated for compiler with different sized ulongs.
#endif

#if ( LONG_MAX != (0x7FFFFFFF) )
#error Fixed point code was generated for compiler with different sized longs.
#endif

#endif                                  /* _RTW_HEADER_DC_sf_private_h_ */
