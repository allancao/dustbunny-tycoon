/* Process model C form file: update_manager.pr.c */
/* Portions of this file copyright 1992-2007 by OPNET Technologies, Inc. */



/* This variable carries the header into the object file */
const char update_manager_pr_c [] = "MIL_3_Tfile_Hdr_ 140A 30A opnet 7 4BB7A0BF 4BB7A0BF 1 payette danh 0 0 none none 0 0 none 0 0 0 0 0 0 0 0 18a9 3                                                                                                                                                                                                                                                                                                                                                                                                               ";
#include <string.h>



/* OPNET system definitions */
#include <opnet.h>

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
	} update_manager_state;


/* These macro definitions will define a local variable called	*/
/* "op_sv_ptr" in each function containing a FIN statement.	*/
/* This variable points to the state variable data structure,	*/
/* and can be used from a C debugger to display their values.	*/
#undef FIN_PREAMBLE_DEC
#undef FIN_PREAMBLE_CODE
#define FIN_PREAMBLE_DEC	update_manager_state *op_sv_ptr;
#define FIN_PREAMBLE_CODE	\
		op_sv_ptr = ((update_manager_state *)(OP_SIM_CONTEXT_PTR->_op_mod_state_ptr));


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
	void update_manager (OP_SIM_CONTEXT_ARG_OPT);
	VosT_Obtype _op_update_manager_init (int * init_block_ptr);
	void _op_update_manager_diag (OP_SIM_CONTEXT_ARG_OPT);
	void _op_update_manager_terminate (OP_SIM_CONTEXT_ARG_OPT);
	VosT_Address _op_update_manager_alloc (VosT_Obtype, int);
	void _op_update_manager_svar (void *, const char *, void **);


#if defined (__cplusplus)
} /* end of 'extern "C"' */
#endif




/* Process model interrupt handling procedure */


void
update_manager (OP_SIM_CONTEXT_ARG_OPT)
	{
#if !defined (VOSD_NO_FIN)
	int _op_block_origin = 0;
#endif
	FIN_MT (update_manager ());

		{


		FSM_ENTER ("update_manager")

		FSM_BLOCK_SWITCH
			{
			/*---------------------------------------------------------*/
			/** state (init) enter executives **/
			FSM_STATE_ENTER_FORCED_NOLABEL (0, "init", "update_manager [init enter execs]")

			/** state (init) exit executives **/
			FSM_STATE_EXIT_FORCED (0, "init", "update_manager [init exit execs]")


			/** state (init) transition processing **/
			FSM_TRANSIT_FORCE (1, state1_enter_exec, ;, "default", "", "init", "idle", "tr_0", "update_manager [init -> idle : default / ]")
				/*---------------------------------------------------------*/



			/** state (idle) enter executives **/
			FSM_STATE_ENTER_UNFORCED (1, "idle", state1_enter_exec, "update_manager [idle enter execs]")

			/** blocking after enter executives of unforced state. **/
			FSM_EXIT (3,"update_manager")


			/** state (idle) exit executives **/
			FSM_STATE_EXIT_UNFORCED (1, "idle", "update_manager [idle exit execs]")


			/** state (idle) transition processing **/
			FSM_PROFILE_SECTION_IN ("update_manager [idle trans conditions]", state1_trans_conds)
			FSM_INIT_COND (RX_PROP)
			FSM_TEST_COND (RX_STORAGE_PKT)
			FSM_TEST_COND (SEND_BEACON_TIMER)
			FSM_TEST_COND (RX_MAC_BEACONPKT)
			FSM_TEST_COND (RX_MAC_UPDATEPKT)
			FSM_TEST_LOGIC ("idle")
			FSM_PROFILE_SECTION_OUT (state1_trans_conds)

			FSM_TRANSIT_SWITCH
				{
				FSM_CASE_TRANSIT (0, 1, state1_enter_exec, send_to_store();, "RX_PROP", "send_to_store()", "idle", "idle", "tr_5", "update_manager [idle -> idle : RX_PROP / send_to_store()]")
				FSM_CASE_TRANSIT (1, 3, state3_enter_exec, ;, "RX_STORAGE_PKT", "", "idle", "error", "tr_7", "update_manager [idle -> error : RX_STORAGE_PKT / ]")
				FSM_CASE_TRANSIT (2, 1, state1_enter_exec, send_beacon();, "SEND_BEACON_TIMER", "send_beacon()", "idle", "idle", "tr_13", "update_manager [idle -> idle : SEND_BEACON_TIMER / send_beacon()]")
				FSM_CASE_TRANSIT (3, 4, state4_enter_exec, ;, "RX_MAC_BEACONPKT", "", "idle", "tx_start", "tr_14", "update_manager [idle -> tx_start : RX_MAC_BEACONPKT / ]")
				FSM_CASE_TRANSIT (4, 1, state1_enter_exec, send_to_store();, "RX_MAC_UPDATEPKT", "send_to_store()", "idle", "idle", "tr_16", "update_manager [idle -> idle : RX_MAC_UPDATEPKT / send_to_store()]")
				}
				/*---------------------------------------------------------*/



			/** state (tx) enter executives **/
			FSM_STATE_ENTER_UNFORCED (2, "tx", state2_enter_exec, "update_manager [tx enter execs]")

			/** blocking after enter executives of unforced state. **/
			FSM_EXIT (5,"update_manager")


			/** state (tx) exit executives **/
			FSM_STATE_EXIT_UNFORCED (2, "tx", "update_manager [tx exit execs]")


			/** state (tx) transition processing **/
			FSM_PROFILE_SECTION_IN ("update_manager [tx trans conditions]", state2_trans_conds)
			FSM_INIT_COND (RX_STORAGE_PKT)
			FSM_TEST_COND (RX_MAC_UPDATEPKT)
			FSM_TEST_COND (RX_PROP)
			FSM_TEST_COND (STORAGE_DUMP_COMPLETE)
			FSM_TEST_LOGIC ("tx")
			FSM_PROFILE_SECTION_OUT (state2_trans_conds)

			FSM_TRANSIT_SWITCH
				{
				FSM_CASE_TRANSIT (0, 2, state2_enter_exec, send_to_mac();, "RX_STORAGE_PKT", "send_to_mac()", "tx", "tx", "tr_6", "update_manager [tx -> tx : RX_STORAGE_PKT / send_to_mac()]")
				FSM_CASE_TRANSIT (1, 3, state3_enter_exec, ;, "RX_MAC_UPDATEPKT", "", "tx", "error", "tr_9", "update_manager [tx -> error : RX_MAC_UPDATEPKT / ]")
				FSM_CASE_TRANSIT (2, 3, state3_enter_exec, ;, "RX_PROP", "", "tx", "error", "tr_12", "update_manager [tx -> error : RX_PROP / ]")
				FSM_CASE_TRANSIT (3, 5, state5_enter_exec, ;, "STORAGE_DUMP_COMPLETE", "", "tx", "tx_done", "tr_17", "update_manager [tx -> tx_done : STORAGE_DUMP_COMPLETE / ]")
				}
				/*---------------------------------------------------------*/



			/** state (error) enter executives **/
			FSM_STATE_ENTER_UNFORCED (3, "error", state3_enter_exec, "update_manager [error enter execs]")
				FSM_PROFILE_SECTION_IN ("update_manager [error enter execs]", state3_enter_exec)
				{
				//Unrecoverable error
				op_sim_end("Unexpected state");
				}
				FSM_PROFILE_SECTION_OUT (state3_enter_exec)

			/** blocking after enter executives of unforced state. **/
			FSM_EXIT (7,"update_manager")


			/** state (error) exit executives **/
			FSM_STATE_EXIT_UNFORCED (3, "error", "update_manager [error exit execs]")


			/** state (error) transition processing **/
			FSM_TRANSIT_MISSING ("error")
				/*---------------------------------------------------------*/



			/** state (tx_start) enter executives **/
			FSM_STATE_ENTER_FORCED (4, "tx_start", state4_enter_exec, "update_manager [tx_start enter execs]")
				FSM_PROFILE_SECTION_IN ("update_manager [tx_start enter execs]", state4_enter_exec)
				{
				disable_prop_updates();
				
				//clear prop update streams
				
				disable_beacon();
				}
				FSM_PROFILE_SECTION_OUT (state4_enter_exec)

			/** state (tx_start) exit executives **/
			FSM_STATE_EXIT_FORCED (4, "tx_start", "update_manager [tx_start exit execs]")
				FSM_PROFILE_SECTION_IN ("update_manager [tx_start exit execs]", state4_exit_exec)
				{
				request_storage_dump()
				}
				FSM_PROFILE_SECTION_OUT (state4_exit_exec)


			/** state (tx_start) transition processing **/
			FSM_TRANSIT_FORCE (2, state2_enter_exec, ;, "default", "", "tx_start", "tx", "tr_15", "update_manager [tx_start -> tx : default / ]")
				/*---------------------------------------------------------*/



			/** state (tx_done) enter executives **/
			FSM_STATE_ENTER_FORCED (5, "tx_done", state5_enter_exec, "update_manager [tx_done enter execs]")
				FSM_PROFILE_SECTION_IN ("update_manager [tx_done enter execs]", state5_enter_exec)
				{
				enable_prop_updates();
				
				//Allow the node we just received updates from to transmit
				enable_beacon();
				send_beacon();
				}
				FSM_PROFILE_SECTION_OUT (state5_enter_exec)

			/** state (tx_done) exit executives **/
			FSM_STATE_EXIT_FORCED (5, "tx_done", "update_manager [tx_done exit execs]")


			/** state (tx_done) transition processing **/
			FSM_TRANSIT_FORCE (1, state1_enter_exec, ;, "default", "", "tx_done", "idle", "tr_18", "update_manager [tx_done -> idle : default / ]")
				/*---------------------------------------------------------*/



			}


		FSM_EXIT (0,"update_manager")
		}
	}




void
_op_update_manager_diag (OP_SIM_CONTEXT_ARG_OPT)
	{
	/* No Diagnostic Block */
	}




void
_op_update_manager_terminate (OP_SIM_CONTEXT_ARG_OPT)
	{

	FIN_MT (_op_update_manager_terminate ())


	/* No Termination Block */

	Vos_Poolmem_Dealloc (op_sv_ptr);

	FOUT
	}


#undef FIN_PREAMBLE_DEC
#undef FIN_PREAMBLE_CODE

#define FIN_PREAMBLE_DEC
#define FIN_PREAMBLE_CODE

VosT_Obtype
_op_update_manager_init (int * init_block_ptr)
	{
	VosT_Obtype obtype = OPC_NIL;
	FIN_MT (_op_update_manager_init (init_block_ptr))

	obtype = Vos_Define_Object_Prstate ("proc state vars (update_manager)",
		sizeof (update_manager_state));
	*init_block_ptr = 0;

	FRET (obtype)
	}

VosT_Address
_op_update_manager_alloc (VosT_Obtype obtype, int init_block)
	{
#if !defined (VOSD_NO_FIN)
	int _op_block_origin = 0;
#endif
	update_manager_state * ptr;
	FIN_MT (_op_update_manager_alloc (obtype))

	ptr = (update_manager_state *)Vos_Alloc_Object (obtype);
	if (ptr != OPC_NIL)
		{
		ptr->_op_current_block = init_block;
#if defined (OPD_ALLOW_ODB)
		ptr->_op_current_state = "update_manager [init enter execs]";
#endif
		}
	FRET ((VosT_Address)ptr)
	}



void
_op_update_manager_svar (void * gen_ptr, const char * var_name, void ** var_p_ptr)
	{

	FIN_MT (_op_update_manager_svar (gen_ptr, var_name, var_p_ptr))

	*var_p_ptr = (void *)OPC_NIL;

	FOUT
	}

