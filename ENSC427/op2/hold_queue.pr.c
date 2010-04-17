/* Process model C form file: hold_queue.pr.c */
/* Portions of this file copyright 1992-2007 by OPNET Technologies, Inc. */



/* This variable carries the header into the object file */
const char hold_queue_pr_c [] = "MIL_3_Tfile_Hdr_ 140A 30A opnet 7 4BC8FF16 4BC8FF16 1 rfsip5 danh 0 0 none none 0 0 none 0 0 0 0 0 0 0 0 18a9 3                                                                                                                                                                                                                                                                                                                                                                                                                ";
#include <string.h>



/* OPNET system definitions */
#include <opnet.h>



/* Header Block */

#define IC_DISABLE	54
#define IC_ENABLE	55

#define I_DISABLE	(op_intrpt_type() == OPC_INTRPT_REMOTE && op_intrpt_code() == IC_DISABLE)
#define I_ENABLE	(op_intrpt_type() == OPC_INTRPT_REMOTE && op_intrpt_code() == IC_ENABLE)

/* End of Header Block */

#if !defined (VOSD_NO_FIN)
#undef	BIN
#undef	BOUT
#define	BIN		FIN_LOCAL_FIELD(_op_last_line_passed) = __LINE__ - _op_block_origin;
#define	BOUT	BIN
#define	BINIT	FIN_LOCAL_FIELD(_op_last_line_passed) = 0; _op_block_origin = __LINE__;
#else
#define	BINIT
#endif /* #if !defined (VOSD_NO_FIN) */



/* State variable definitions */
typedef struct
	{
	/* Internal state tracking for FSM */
	FSM_SYS_STATE
	/* State Variables */
	List *	                 		lst_pkts                                        ;
	} hold_queue_state;

#define lst_pkts                		op_sv_ptr->lst_pkts

/* These macro definitions will define a local variable called	*/
/* "op_sv_ptr" in each function containing a FIN statement.	*/
/* This variable points to the state variable data structure,	*/
/* and can be used from a C debugger to display their values.	*/
#undef FIN_PREAMBLE_DEC
#undef FIN_PREAMBLE_CODE
#define FIN_PREAMBLE_DEC	hold_queue_state *op_sv_ptr;
#define FIN_PREAMBLE_CODE	\
		op_sv_ptr = ((hold_queue_state *)(OP_SIM_CONTEXT_PTR->_op_mod_state_ptr));


/* No Function Block */

#if !defined (VOSD_NO_FIN)
enum { _op_block_origin = __LINE__ };
#endif

/* Undefine optional tracing in FIN/FOUT/FRET */
/* The FSM has its own tracing code and the other */
/* functions should not have any tracing.		  */
#undef FIN_TRACING
#define FIN_TRACING

#undef FOUTRET_TRACING
#define FOUTRET_TRACING

#if defined (__cplusplus)
extern "C" {
#endif
	void hold_queue (OP_SIM_CONTEXT_ARG_OPT);
	VosT_Obtype _op_hold_queue_init (int * init_block_ptr);
	void _op_hold_queue_diag (OP_SIM_CONTEXT_ARG_OPT);
	void _op_hold_queue_terminate (OP_SIM_CONTEXT_ARG_OPT);
	VosT_Address _op_hold_queue_alloc (VosT_Obtype, int);
	void _op_hold_queue_svar (void *, const char *, void **);


#if defined (__cplusplus)
} /* end of 'extern "C"' */
#endif




/* Process model interrupt handling procedure */


void
hold_queue (OP_SIM_CONTEXT_ARG_OPT)
	{
#if !defined (VOSD_NO_FIN)
	int _op_block_origin = 0;
#endif
	FIN_MT (hold_queue ());

		{


		FSM_ENTER ("hold_queue")

		FSM_BLOCK_SWITCH
			{
			/*---------------------------------------------------------*/
			/** state (init) enter executives **/
			FSM_STATE_ENTER_FORCED_NOLABEL (0, "init", "hold_queue [init enter execs]")
				FSM_PROFILE_SECTION_IN ("hold_queue [init enter execs]", state0_enter_exec)
				{
				lst_pkts = op_prg_list_create (); 
				}
				FSM_PROFILE_SECTION_OUT (state0_enter_exec)

			/** state (init) exit executives **/
			FSM_STATE_EXIT_FORCED (0, "init", "hold_queue [init exit execs]")


			/** state (init) transition processing **/
			FSM_TRANSIT_FORCE (1, state1_enter_exec, ;, "default", "", "init", "forward", "tr_0", "hold_queue [init -> forward : default / ]")
				/*---------------------------------------------------------*/



			/** state (forward) enter executives **/
			FSM_STATE_ENTER_UNFORCED (1, "forward", state1_enter_exec, "hold_queue [forward enter execs]")
				FSM_PROFILE_SECTION_IN ("hold_queue [forward enter execs]", state1_enter_exec)
				{
				Packet *pPkt;
				int len;
				
				len = op_prg_list_size(lst_pkts);
				while(len > 0)
				{
					op_pk_send(op_prg_list_remove (lst_pkts, OPC_LISTPOS_HEAD), 0);
					len = op_prg_list_size(lst_pkts);	
				}
				
				pPkt = op_pk_get(0);
				while(pPkt != OPC_NIL)
				{
					op_pk_send(pPkt, 0);
					pPkt = op_pk_get(0);
				}
				}
				FSM_PROFILE_SECTION_OUT (state1_enter_exec)

			/** blocking after enter executives of unforced state. **/
			FSM_EXIT (3,"hold_queue")


			/** state (forward) exit executives **/
			FSM_STATE_EXIT_UNFORCED (1, "forward", "hold_queue [forward exit execs]")


			/** state (forward) transition processing **/
			FSM_PROFILE_SECTION_IN ("hold_queue [forward trans conditions]", state1_trans_conds)
			FSM_INIT_COND (I_DISABLE)
			FSM_DFLT_COND
			FSM_TEST_LOGIC ("forward")
			FSM_PROFILE_SECTION_OUT (state1_trans_conds)

			FSM_TRANSIT_SWITCH
				{
				FSM_CASE_TRANSIT (0, 2, state2_enter_exec, ;, "I_DISABLE", "", "forward", "hold", "tr_2", "hold_queue [forward -> hold : I_DISABLE / ]")
				FSM_CASE_TRANSIT (1, 1, state1_enter_exec, ;, "default", "", "forward", "forward", "tr_4", "hold_queue [forward -> forward : default / ]")
				}
				/*---------------------------------------------------------*/



			/** state (hold) enter executives **/
			FSM_STATE_ENTER_UNFORCED (2, "hold", state2_enter_exec, "hold_queue [hold enter execs]")
				FSM_PROFILE_SECTION_IN ("hold_queue [hold enter execs]", state2_enter_exec)
				{
				Packet *pPkt;
				
				pPkt = op_pk_get(0);
				while(pPkt != OPC_NIL)
				{
					op_prg_list_insert(lst_pkts, pPkt, OPC_LISTPOS_TAIL);
					pPkt = op_pk_get(0);
				}
				}
				FSM_PROFILE_SECTION_OUT (state2_enter_exec)

			/** blocking after enter executives of unforced state. **/
			FSM_EXIT (5,"hold_queue")


			/** state (hold) exit executives **/
			FSM_STATE_EXIT_UNFORCED (2, "hold", "hold_queue [hold exit execs]")


			/** state (hold) transition processing **/
			FSM_PROFILE_SECTION_IN ("hold_queue [hold trans conditions]", state2_trans_conds)
			FSM_INIT_COND (I_ENABLE)
			FSM_DFLT_COND
			FSM_TEST_LOGIC ("hold")
			FSM_PROFILE_SECTION_OUT (state2_trans_conds)

			FSM_TRANSIT_SWITCH
				{
				FSM_CASE_TRANSIT (0, 1, state1_enter_exec, ;, "I_ENABLE", "", "hold", "forward", "tr_3", "hold_queue [hold -> forward : I_ENABLE / ]")
				FSM_CASE_TRANSIT (1, 2, state2_enter_exec, ;, "default", "", "hold", "hold", "tr_5", "hold_queue [hold -> hold : default / ]")
				}
				/*---------------------------------------------------------*/



			}


		FSM_EXIT (0,"hold_queue")
		}
	}




void
_op_hold_queue_diag (OP_SIM_CONTEXT_ARG_OPT)
	{
	/* No Diagnostic Block */
	}




void
_op_hold_queue_terminate (OP_SIM_CONTEXT_ARG_OPT)
	{

	FIN_MT (_op_hold_queue_terminate ())


	/* No Termination Block */

	Vos_Poolmem_Dealloc (op_sv_ptr);

	FOUT
	}


/* Undefine shortcuts to state variables to avoid */
/* syntax error in direct access to fields of */
/* local variable prs_ptr in _op_hold_queue_svar function. */
#undef lst_pkts

#undef FIN_PREAMBLE_DEC
#undef FIN_PREAMBLE_CODE

#define FIN_PREAMBLE_DEC
#define FIN_PREAMBLE_CODE

VosT_Obtype
_op_hold_queue_init (int * init_block_ptr)
	{
	VosT_Obtype obtype = OPC_NIL;
	FIN_MT (_op_hold_queue_init (init_block_ptr))

	obtype = Vos_Define_Object_Prstate ("proc state vars (hold_queue)",
		sizeof (hold_queue_state));
	*init_block_ptr = 0;

	FRET (obtype)
	}

VosT_Address
_op_hold_queue_alloc (VosT_Obtype obtype, int init_block)
	{
#if !defined (VOSD_NO_FIN)
	int _op_block_origin = 0;
#endif
	hold_queue_state * ptr;
	FIN_MT (_op_hold_queue_alloc (obtype))

	ptr = (hold_queue_state *)Vos_Alloc_Object (obtype);
	if (ptr != OPC_NIL)
		{
		ptr->_op_current_block = init_block;
#if defined (OPD_ALLOW_ODB)
		ptr->_op_current_state = "hold_queue [init enter execs]";
#endif
		}
	FRET ((VosT_Address)ptr)
	}



void
_op_hold_queue_svar (void * gen_ptr, const char * var_name, void ** var_p_ptr)
	{
	hold_queue_state		*prs_ptr;

	FIN_MT (_op_hold_queue_svar (gen_ptr, var_name, var_p_ptr))

	if (var_name == OPC_NIL)
		{
		*var_p_ptr = (void *)OPC_NIL;
		FOUT
		}
	prs_ptr = (hold_queue_state *)gen_ptr;

	if (strcmp ("lst_pkts" , var_name) == 0)
		{
		*var_p_ptr = (void *) (&prs_ptr->lst_pkts);
		FOUT
		}
	*var_p_ptr = (void *)OPC_NIL;

	FOUT
	}

