/* Process model C form file: mac.pr.c */
/* Portions of this file copyright 1992-2007 by OPNET Technologies, Inc. */



/* This variable carries the header into the object file */
const char mac_pr_c [] = "MIL_3_Tfile_Hdr_ 140A 30A opnet 7 4BC27C00 4BC27C00 1 payette danh 0 0 none none 0 0 none 0 0 0 0 0 0 0 0 18a9 3                                                                                                                                                                                                                                                                                                                                                                                                               ";
#include <string.h>



/* OPNET system definitions */
#include <opnet.h>



/* Header Block */



//Streams
#define STRM_INPUT		0
#define STRM_RRX		1

#define STRM_OUTPUT 	0
#define STRM_RTX		1


//Interrupts
#define I_RX_PKT		(op_intrpt_type() == OPC_INTRPT_STRM && op_intrpt_strm() == STRM_RRX)
#define I_INPUT_PKT		(op_intrpt_type() == OPC_INTRPT_STRM && op_intrpt_strm() == STRM_INPUT)

void rrx_to_output(void);
void input_to_rtx(void);

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
	int	                    		source_id                                       ;
	Objid	                  		self_id                                         ;
	} mac_state;

#define source_id               		op_sv_ptr->source_id
#define self_id                 		op_sv_ptr->self_id

/* These macro definitions will define a local variable called	*/
/* "op_sv_ptr" in each function containing a FIN statement.	*/
/* This variable points to the state variable data structure,	*/
/* and can be used from a C debugger to display their values.	*/
#undef FIN_PREAMBLE_DEC
#undef FIN_PREAMBLE_CODE
#define FIN_PREAMBLE_DEC	mac_state *op_sv_ptr;
#define FIN_PREAMBLE_CODE	\
		op_sv_ptr = ((mac_state *)(OP_SIM_CONTEXT_PTR->_op_mod_state_ptr));


/* Function Block */

#if !defined (VOSD_NO_FIN)
enum { _op_block_origin = __LINE__ + 2};
#endif

void rrx_to_output(void)
{
	Packet *pPkt;
	Objid pktsource;
	char message_str[255];
	
	FIN(rrx_to_output());
	
	pPkt = op_pk_get(STRM_RRX);
	op_pk_nfd_get(pPkt, "mac_source", &pktsource);
	
	if(pktsource == self_id)
	{		
		//sprintf (message_str, "[%d] Destroy Pkt From Self\n", op_id_self()); 
		//printf (message_str);
		op_pk_destroy(pPkt);
	}
	else
	{
		op_pk_send(pPkt, STRM_OUTPUT);
	}
	
	FOUT;
}

void input_to_rtx(void)
{
	Packet *pPkt;

	FIN(input_to_rtx());
	
	pPkt = op_pk_get(STRM_INPUT);
	
	op_pk_nfd_set_objid(pPkt, "mac_source", self_id);
	
	op_pk_send(pPkt, STRM_RTX);
	
	FOUT;
}

/* End of Function Block */

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
	void mac (OP_SIM_CONTEXT_ARG_OPT);
	VosT_Obtype _op_mac_init (int * init_block_ptr);
	void _op_mac_diag (OP_SIM_CONTEXT_ARG_OPT);
	void _op_mac_terminate (OP_SIM_CONTEXT_ARG_OPT);
	VosT_Address _op_mac_alloc (VosT_Obtype, int);
	void _op_mac_svar (void *, const char *, void **);


#if defined (__cplusplus)
} /* end of 'extern "C"' */
#endif




/* Process model interrupt handling procedure */


void
mac (OP_SIM_CONTEXT_ARG_OPT)
	{
#if !defined (VOSD_NO_FIN)
	int _op_block_origin = 0;
#endif
	FIN_MT (mac ());

		{


		FSM_ENTER ("mac")

		FSM_BLOCK_SWITCH
			{
			/*---------------------------------------------------------*/
			/** state (forward) enter executives **/
			FSM_STATE_ENTER_UNFORCED (0, "forward", state0_enter_exec, "mac [forward enter execs]")

			/** blocking after enter executives of unforced state. **/
			FSM_EXIT (1,"mac")


			/** state (forward) exit executives **/
			FSM_STATE_EXIT_UNFORCED (0, "forward", "mac [forward exit execs]")


			/** state (forward) transition processing **/
			FSM_PROFILE_SECTION_IN ("mac [forward trans conditions]", state0_trans_conds)
			FSM_INIT_COND (I_RX_PKT)
			FSM_TEST_COND (I_INPUT_PKT)
			FSM_DFLT_COND
			FSM_TEST_LOGIC ("forward")
			FSM_PROFILE_SECTION_OUT (state0_trans_conds)

			FSM_TRANSIT_SWITCH
				{
				FSM_CASE_TRANSIT (0, 0, state0_enter_exec, rrx_to_output();, "I_RX_PKT", "rrx_to_output()", "forward", "forward", "tr_0", "mac [forward -> forward : I_RX_PKT / rrx_to_output()]")
				FSM_CASE_TRANSIT (1, 0, state0_enter_exec, input_to_rtx();, "I_INPUT_PKT", "input_to_rtx()", "forward", "forward", "tr_1", "mac [forward -> forward : I_INPUT_PKT / input_to_rtx()]")
				FSM_CASE_TRANSIT (2, 0, state0_enter_exec, ;, "default", "", "forward", "forward", "tr_2", "mac [forward -> forward : default / ]")
				}
				/*---------------------------------------------------------*/



			/** state (init) enter executives **/
			FSM_STATE_ENTER_FORCED_NOLABEL (1, "init", "mac [init enter execs]")
				FSM_PROFILE_SECTION_IN ("mac [init enter execs]", state1_enter_exec)
				{
				self_id = op_id_self();
				
				op_ima_obj_attr_get (self_id, "Source ID", &source_id);
				}
				FSM_PROFILE_SECTION_OUT (state1_enter_exec)

			/** state (init) exit executives **/
			FSM_STATE_EXIT_FORCED (1, "init", "mac [init exit execs]")


			/** state (init) transition processing **/
			FSM_TRANSIT_FORCE (0, state0_enter_exec, ;, "default", "", "init", "forward", "tr_3", "mac [init -> forward : default / ]")
				/*---------------------------------------------------------*/



			}


		FSM_EXIT (1,"mac")
		}
	}




void
_op_mac_diag (OP_SIM_CONTEXT_ARG_OPT)
	{
	/* No Diagnostic Block */
	}




void
_op_mac_terminate (OP_SIM_CONTEXT_ARG_OPT)
	{

	FIN_MT (_op_mac_terminate ())


	/* No Termination Block */

	Vos_Poolmem_Dealloc (op_sv_ptr);

	FOUT
	}


/* Undefine shortcuts to state variables to avoid */
/* syntax error in direct access to fields of */
/* local variable prs_ptr in _op_mac_svar function. */
#undef source_id
#undef self_id

#undef FIN_PREAMBLE_DEC
#undef FIN_PREAMBLE_CODE

#define FIN_PREAMBLE_DEC
#define FIN_PREAMBLE_CODE

VosT_Obtype
_op_mac_init (int * init_block_ptr)
	{
	VosT_Obtype obtype = OPC_NIL;
	FIN_MT (_op_mac_init (init_block_ptr))

	obtype = Vos_Define_Object_Prstate ("proc state vars (mac)",
		sizeof (mac_state));
	*init_block_ptr = 2;

	FRET (obtype)
	}

VosT_Address
_op_mac_alloc (VosT_Obtype obtype, int init_block)
	{
#if !defined (VOSD_NO_FIN)
	int _op_block_origin = 0;
#endif
	mac_state * ptr;
	FIN_MT (_op_mac_alloc (obtype))

	ptr = (mac_state *)Vos_Alloc_Object (obtype);
	if (ptr != OPC_NIL)
		{
		ptr->_op_current_block = init_block;
#if defined (OPD_ALLOW_ODB)
		ptr->_op_current_state = "mac [init enter execs]";
#endif
		}
	FRET ((VosT_Address)ptr)
	}



void
_op_mac_svar (void * gen_ptr, const char * var_name, void ** var_p_ptr)
	{
	mac_state		*prs_ptr;

	FIN_MT (_op_mac_svar (gen_ptr, var_name, var_p_ptr))

	if (var_name == OPC_NIL)
		{
		*var_p_ptr = (void *)OPC_NIL;
		FOUT
		}
	prs_ptr = (mac_state *)gen_ptr;

	if (strcmp ("source_id" , var_name) == 0)
		{
		*var_p_ptr = (void *) (&prs_ptr->source_id);
		FOUT
		}
	if (strcmp ("self_id" , var_name) == 0)
		{
		*var_p_ptr = (void *) (&prs_ptr->self_id);
		FOUT
		}
	*var_p_ptr = (void *)OPC_NIL;

	FOUT
	}

