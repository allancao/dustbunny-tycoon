/* Process model C form file: p427_node_linker.pr.c */
/* Portions of this file copyright 1992-2007 by OPNET Technologies, Inc. */



/* This variable carries the header into the object file */
const char p427_node_linker_pr_c [] = "MIL_3_Tfile_Hdr_ 140A 30A op_runsim 7 4BA92E87 4BA92E87 1 payette danh 0 0 none none 0 0 none 0 0 0 0 0 0 0 0 18a9 3                                                                                                                                                                                                                                                                                                                                                                                                           ";
#include <string.h>



/* OPNET system definitions */
#include <opnet.h>



/* Header Block */



// Input stream from the MAC process to this process
#define MAC_STRM_IN 0

// Output stream from this process to the MAC process
#define MAC_STRM_OUT 0

//Interrupt Codes
#define IRC_START_NODE_SEARCH 10

//Events
#define RX_MAC_PKT (op_intrpt_type() == OPC_INTRPT_STRM && op_intrpt_strm() == MAC_STRM_IN)
#define START_NODE_SEARCH (op_intrpt_type() == OPC_INTRPT_SELF && op_intrpt_code() == IRC_START_NODE_SEARCH)

void rx_mac_pkt(void);
void send_becon_request(void);
void schedule_becon_request(void);

void default_intrpt(void);

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
	int	                    		node_search_counter                             ;
	Objid	                  		mac_id                                          ;
	int	                    		send_becons                                     ;
	int	                    		num_becons                                      ;
	} p427_node_linker_state;

#define node_search_counter     		op_sv_ptr->node_search_counter
#define mac_id                  		op_sv_ptr->mac_id
#define send_becons             		op_sv_ptr->send_becons
#define num_becons              		op_sv_ptr->num_becons

/* These macro definitions will define a local variable called	*/
/* "op_sv_ptr" in each function containing a FIN statement.	*/
/* This variable points to the state variable data structure,	*/
/* and can be used from a C debugger to display their values.	*/
#undef FIN_PREAMBLE_DEC
#undef FIN_PREAMBLE_CODE
#define FIN_PREAMBLE_DEC	p427_node_linker_state *op_sv_ptr;
#define FIN_PREAMBLE_CODE	\
		op_sv_ptr = ((p427_node_linker_state *)(OP_SIM_CONTEXT_PTR->_op_mod_state_ptr));


/* Function Block */

#if !defined (VOSD_NO_FIN)
enum { _op_block_origin = __LINE__ + 2};
#endif

void rx_mac_pkt(void)
{
	Packet *pk;
	char message_str[255];
	
	FIN(rx_mac_pkt(void));

	sprintf (message_str, "[%d] NL rx_mac_pkt\n", op_id_self()); 
	printf (message_str);

	pk = op_pk_get (op_intrpt_strm ());
	
	op_pk_send (pk, 1); //To sink
	
	FOUT;
}

void send_becon_request(void)
{
	char message_str[255];

	FIN(send_becon_request(void));
	
	sprintf (message_str, "[%d] NL send_becon_request\n", op_id_self()); 
	printf (message_str);
	
	if(node_search_counter >= num_becons)
	{
		printf("send_becon_request - max counter\n");
		FOUT;
	}
	
	node_search_counter++;
	schedule_becon_request();
	op_intrpt_schedule_remote (op_sim_time (), 0, mac_id); //SCAN_REQUEST

	FOUT;
}

void schedule_becon_request(void)
{
	FIN(schedule_becon_request(void));
	printf("schedule_becon_request\n");
	
	op_intrpt_schedule_self (op_sim_time () + 10, IRC_START_NODE_SEARCH);
	
	FOUT;
}

void default_intrpt(void)
{
	FIN(schedule_becon_request(void));
	printf("default_intrpt\n");
	
	//op_intrpt_schedule_self (op_sim_time () + 0.1, IRC_START_NODE_SEARCH);
	
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
	void p427_node_linker (OP_SIM_CONTEXT_ARG_OPT);
	VosT_Obtype _op_p427_node_linker_init (int * init_block_ptr);
	void _op_p427_node_linker_diag (OP_SIM_CONTEXT_ARG_OPT);
	void _op_p427_node_linker_terminate (OP_SIM_CONTEXT_ARG_OPT);
	VosT_Address _op_p427_node_linker_alloc (VosT_Obtype, int);
	void _op_p427_node_linker_svar (void *, const char *, void **);


#if defined (__cplusplus)
} /* end of 'extern "C"' */
#endif




/* Process model interrupt handling procedure */


void
p427_node_linker (OP_SIM_CONTEXT_ARG_OPT)
	{
#if !defined (VOSD_NO_FIN)
	int _op_block_origin = 0;
#endif
	FIN_MT (p427_node_linker ());

		{


		FSM_ENTER ("p427_node_linker")

		FSM_BLOCK_SWITCH
			{
			/*---------------------------------------------------------*/
			/** state (init) enter executives **/
			FSM_STATE_ENTER_FORCED_NOLABEL (0, "init", "p427_node_linker [init enter execs]")
				FSM_PROFILE_SECTION_IN ("p427_node_linker [init enter execs]", state0_enter_exec)
				{
				char message_str[255];
				
				sprintf (message_str, "[%d] NL STATE: init\n", op_id_self()); 
				printf (message_str);
				
				node_search_counter = 0;
				mac_id = op_id_from_name (op_topo_parent (op_id_self ()), OPC_OBJTYPE_PROC, "802_15_4_mac");
				
				op_ima_obj_attr_get (op_id_self(), "Send Becons", &send_becons);
				op_ima_obj_attr_get (op_id_self(), "Num Becons", &num_becons);
				
				if(send_becons)
					schedule_becon_request();
				}
				FSM_PROFILE_SECTION_OUT (state0_enter_exec)

			/** state (init) exit executives **/
			FSM_STATE_EXIT_FORCED (0, "init", "p427_node_linker [init exit execs]")


			/** state (init) transition processing **/
			FSM_TRANSIT_FORCE (1, state1_enter_exec, ;, "default", "", "init", "idle", "tr_0", "p427_node_linker [init -> idle : default / ]")
				/*---------------------------------------------------------*/



			/** state (idle) enter executives **/
			FSM_STATE_ENTER_UNFORCED (1, "idle", state1_enter_exec, "p427_node_linker [idle enter execs]")
				FSM_PROFILE_SECTION_IN ("p427_node_linker [idle enter execs]", state1_enter_exec)
				{
				printf("Node linker idle enter\n");
				}
				FSM_PROFILE_SECTION_OUT (state1_enter_exec)

			/** blocking after enter executives of unforced state. **/
			FSM_EXIT (3,"p427_node_linker")


			/** state (idle) exit executives **/
			FSM_STATE_EXIT_UNFORCED (1, "idle", "p427_node_linker [idle exit execs]")


			/** state (idle) transition processing **/
			FSM_PROFILE_SECTION_IN ("p427_node_linker [idle trans conditions]", state1_trans_conds)
			FSM_INIT_COND (RX_MAC_PKT)
			FSM_TEST_COND (START_NODE_SEARCH)
			FSM_DFLT_COND
			FSM_TEST_LOGIC ("idle")
			FSM_PROFILE_SECTION_OUT (state1_trans_conds)

			FSM_TRANSIT_SWITCH
				{
				FSM_CASE_TRANSIT (0, 1, state1_enter_exec, rx_mac_pkt();, "RX_MAC_PKT", "rx_mac_pkt()", "idle", "idle", "tr_1", "p427_node_linker [idle -> idle : RX_MAC_PKT / rx_mac_pkt()]")
				FSM_CASE_TRANSIT (1, 1, state1_enter_exec, send_becon_request();, "START_NODE_SEARCH", "send_becon_request()", "idle", "idle", "tr_4", "p427_node_linker [idle -> idle : START_NODE_SEARCH / send_becon_request()]")
				FSM_CASE_TRANSIT (2, 1, state1_enter_exec, default_intrpt();, "default", "default_intrpt()", "idle", "idle", "default", "p427_node_linker [idle -> idle : default / default_intrpt()]")
				}
				/*---------------------------------------------------------*/



			}


		FSM_EXIT (0,"p427_node_linker")
		}
	}




void
_op_p427_node_linker_diag (OP_SIM_CONTEXT_ARG_OPT)
	{
	/* No Diagnostic Block */
	}




void
_op_p427_node_linker_terminate (OP_SIM_CONTEXT_ARG_OPT)
	{

	FIN_MT (_op_p427_node_linker_terminate ())


	/* No Termination Block */

	Vos_Poolmem_Dealloc (op_sv_ptr);

	FOUT
	}


/* Undefine shortcuts to state variables to avoid */
/* syntax error in direct access to fields of */
/* local variable prs_ptr in _op_p427_node_linker_svar function. */
#undef node_search_counter
#undef mac_id
#undef send_becons
#undef num_becons

#undef FIN_PREAMBLE_DEC
#undef FIN_PREAMBLE_CODE

#define FIN_PREAMBLE_DEC
#define FIN_PREAMBLE_CODE

VosT_Obtype
_op_p427_node_linker_init (int * init_block_ptr)
	{
	VosT_Obtype obtype = OPC_NIL;
	FIN_MT (_op_p427_node_linker_init (init_block_ptr))

	obtype = Vos_Define_Object_Prstate ("proc state vars (p427_node_linker)",
		sizeof (p427_node_linker_state));
	*init_block_ptr = 0;

	FRET (obtype)
	}

VosT_Address
_op_p427_node_linker_alloc (VosT_Obtype obtype, int init_block)
	{
#if !defined (VOSD_NO_FIN)
	int _op_block_origin = 0;
#endif
	p427_node_linker_state * ptr;
	FIN_MT (_op_p427_node_linker_alloc (obtype))

	ptr = (p427_node_linker_state *)Vos_Alloc_Object (obtype);
	if (ptr != OPC_NIL)
		{
		ptr->_op_current_block = init_block;
#if defined (OPD_ALLOW_ODB)
		ptr->_op_current_state = "p427_node_linker [init enter execs]";
#endif
		}
	FRET ((VosT_Address)ptr)
	}



void
_op_p427_node_linker_svar (void * gen_ptr, const char * var_name, void ** var_p_ptr)
	{
	p427_node_linker_state		*prs_ptr;

	FIN_MT (_op_p427_node_linker_svar (gen_ptr, var_name, var_p_ptr))

	if (var_name == OPC_NIL)
		{
		*var_p_ptr = (void *)OPC_NIL;
		FOUT
		}
	prs_ptr = (p427_node_linker_state *)gen_ptr;

	if (strcmp ("node_search_counter" , var_name) == 0)
		{
		*var_p_ptr = (void *) (&prs_ptr->node_search_counter);
		FOUT
		}
	if (strcmp ("mac_id" , var_name) == 0)
		{
		*var_p_ptr = (void *) (&prs_ptr->mac_id);
		FOUT
		}
	if (strcmp ("send_becons" , var_name) == 0)
		{
		*var_p_ptr = (void *) (&prs_ptr->send_becons);
		FOUT
		}
	if (strcmp ("num_becons" , var_name) == 0)
		{
		*var_p_ptr = (void *) (&prs_ptr->num_becons);
		FOUT
		}
	*var_p_ptr = (void *)OPC_NIL;

	FOUT
	}

