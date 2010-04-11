/* Process model C form file: update_manager.pr.c */
/* Portions of this file copyright 1992-2007 by OPNET Technologies, Inc. */



/* This variable carries the header into the object file */
const char update_manager_pr_c [] = "MIL_3_Tfile_Hdr_ 140A 30A opnet 7 4BC21872 4BC21872 1 payette danh 0 0 none none 0 0 none 0 0 0 0 0 0 0 0 18a9 3                                                                                                                                                                                                                                                                                                                                                                                                               ";
#include <string.h>



/* OPNET system definitions */
#include <opnet.h>



/* Header Block */

#include	<oms_dist_support.h>


/***********************
 * Streams
 ***********************/
#define STRM_IN_P1		0
#define STRM_IN_P2		1
#define STRM_IN_P3		2

#define STRM_IN_STORE	3
#define STRM_OUT_STORE	0

#define STRM_IN_MAC		4
#define STRM_OUT_MAC 	1

/***********************
 * Interrupt Codes
 ***********************/
#define IC_REQ_STORE_DUMP			73
#define IC_STORE_DUMP_DONE			74

#define IC_PROP_UPDATES_DISABLE		83
#define IC_PROP_UPDATES_ENABLE		84

#define IC_SEND_BEACON_TIMER		42

#define IC_PK_UPDATEORACK			37
#define IC_PK_BEACON				38

/***********************
 * Interrupts
 ***********************/

//Stream
#define I_S_PROP_PKT	(op_intrpt_type() == OPC_INTRPT_STRM && (op_intrpt_strm() == STRM_IN_P1 || op_intrpt_strm() == STRM_IN_P2 || op_intrpt_strm() == STRM_IN_P3))
#define I_S_STORE_PKT	(op_intrpt_type() == OPC_INTRPT_STRM && op_intrpt_strm() == STRM_IN_STORE)
#define I_S_MAC_PKT		(op_intrpt_type() == OPC_INTRPT_STRM && op_intrpt_strm() == STRM_IN_MAC)

//Packet op_intrpt_strm() == STRM_IN_P1
#define I_PK_UPDATEORACK	(op_intrpt_type() == OPC_INTRPT_SELF && op_intrpt_code() == IC_PK_UPDATEORACK)
#define I_PK_BEACON			(op_intrpt_type() == OPC_INTRPT_SELF && op_intrpt_code() == IC_PK_BEACON)

//Remote
#define I_R_STORE_DUMP_DONE	(op_intrpt_type() == OPC_INTRPT_REMOTE && op_intrpt_code() == IC_STORE_DUMP_DONE)

//Local (self)
#define I_L_SEND_BEACON_TIMER (op_intrpt_type() == OPC_INTRPT_SELF && op_intrpt_code() == IC_SEND_BEACON_TIMER)

/***********************
 * Prototypes
 ***********************/
 
//Beacon control
void enable_beacon();
void disable_beacon();
void send_beacon();
void send_beacon_timed();

//Property control
void enable_prop_updates();
void disable_prop_updates();

//Storage control
void request_storage_dump();

//Packet redirection 
void send_to_store();
void send_to_mac();

void generate_mac_pk_interrupt();


void printbad_mac_or_prop_strm(void);

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
	Objid	                  		storage_id                                      ;
	int	                    		is_pkt_interrupt                                ;
	Packet *	               		pPkt_interrupt                                  ;
	Evhandle	               		evh_beacon_tmr                                  ;
	OmsT_Dist_Handle	       		disth_beacon_timer                              ;
	Objid	                  		self_id                                         ;
	int	                    		source_id                                       ;
	Objid	                  		prop1_id                                        ;
	Objid	                  		prop2_id                                        ;
	Objid	                  		prop3_id                                        ;
	} update_manager_state;

#define storage_id              		op_sv_ptr->storage_id
#define is_pkt_interrupt        		op_sv_ptr->is_pkt_interrupt
#define pPkt_interrupt          		op_sv_ptr->pPkt_interrupt
#define evh_beacon_tmr          		op_sv_ptr->evh_beacon_tmr
#define disth_beacon_timer      		op_sv_ptr->disth_beacon_timer
#define self_id                 		op_sv_ptr->self_id
#define source_id               		op_sv_ptr->source_id
#define prop1_id                		op_sv_ptr->prop1_id
#define prop2_id                		op_sv_ptr->prop2_id
#define prop3_id                		op_sv_ptr->prop3_id

/* These macro definitions will define a local variable called	*/
/* "op_sv_ptr" in each function containing a FIN statement.	*/
/* This variable points to the state variable data structure,	*/
/* and can be used from a C debugger to display their values.	*/
#undef FIN_PREAMBLE_DEC
#undef FIN_PREAMBLE_CODE
#define FIN_PREAMBLE_DEC	update_manager_state *op_sv_ptr;
#define FIN_PREAMBLE_CODE	\
		op_sv_ptr = ((update_manager_state *)(OP_SIM_CONTEXT_PTR->_op_mod_state_ptr));


/* Function Block */

#if !defined (VOSD_NO_FIN)
enum { _op_block_origin = __LINE__ + 2};
#endif

void schedule_beacon()
{
	double next_becon_time;
	
	FIN(schedule_beacon());
	
	next_becon_time = oms_dist_outcome (disth_beacon_timer);
	if (next_becon_time <0)
	{
		next_becon_time = 0;
	}
	
	evh_beacon_tmr = op_intrpt_schedule_self (op_sim_time () + next_becon_time, IC_SEND_BEACON_TIMER);
	
	FOUT;
}

void enable_beacon()
{
	FIN(enable_beacon());
	
	schedule_beacon();
	
	FOUT;
}

void disable_beacon()
{
	FIN(disable_beacon());
	
	if (op_ev_valid (evh_beacon_tmr) == OPC_TRUE)
	{
		op_ev_cancel (evh_beacon_tmr);
	}

	FOUT;
}

void send_beacon()
{
	char message_str[255];
	Packet *pPkt;

	FIN(send_beacon());
	
	//sprintf (message_str, "[%d] Send Beacon\n", op_id_self()); 
	//printf (message_str);
	
	
	pPkt = op_pk_create_fmt("beacon");
	op_pk_nfd_set_int32(pPkt, "source_id", source_id);
	
	//TODO - node type 
	
	op_pk_send(pPkt, STRM_OUT_MAC);
	
	schedule_beacon();
	
	FOUT;
}

//Property control
void enable_prop_updates()
{
	FIN(enable_prop_updates());
	
	op_intrpt_schedule_remote(op_sim_time(), IC_PROP_UPDATES_ENABLE, prop1_id);
	op_intrpt_schedule_remote(op_sim_time(), IC_PROP_UPDATES_ENABLE, prop2_id);
	op_intrpt_schedule_remote(op_sim_time(), IC_PROP_UPDATES_ENABLE, prop3_id);
	
	FOUT;
}
	
void disable_prop_updates()
{
	FIN(disable_prop_updates());

	op_intrpt_schedule_remote(op_sim_time(), IC_PROP_UPDATES_DISABLE, prop1_id);
	op_intrpt_schedule_remote(op_sim_time(), IC_PROP_UPDATES_DISABLE, prop2_id);
	op_intrpt_schedule_remote(op_sim_time(), IC_PROP_UPDATES_DISABLE, prop3_id);
	
	FOUT;
}


void request_storage_dump()
{
	FIN(request_sotrage_dump());
	
	op_intrpt_schedule_remote(op_sim_time(), IC_REQ_STORE_DUMP, storage_id);
	
	FOUT;
}


void send_to_store()
{
	Packet *pPktToForward;
	
	FIN(send_to_store());
	
	if(is_pkt_interrupt)
	{
		is_pkt_interrupt = 0;
		
		if(pPkt_interrupt == OPC_NIL)
		{
			op_sim_end("Nill interrupt pkt", "", "", "");	
		}
		
		pPktToForward = pPkt_interrupt;
		pPkt_interrupt = OPC_NIL;
	}
	else
	{
		if(pPkt_interrupt != OPC_NIL)
		{
			op_sim_end("Not nill interrupt pkt", "", "", "");	
		}
		
		pPktToForward = op_pk_get(op_intrpt_strm());
	}
	
	op_pk_send(pPktToForward, STRM_OUT_STORE);
	
	FOUT;
}
	
void send_to_mac()
{
	char message_str[255];
	Packet *pPktToForward;
	
	FIN(send_to_mac());

	if(is_pkt_interrupt)
	{
		is_pkt_interrupt = 0;
		
		if(pPkt_interrupt == OPC_NIL)
		{
			op_sim_end("Nill interrupt pkt", "", "", "");	
		}
		
		pPktToForward = pPkt_interrupt;
		pPkt_interrupt = OPC_NIL;
	}
	else
	{
		if(pPkt_interrupt != OPC_NIL)
		{
			op_sim_end("Not nill interrupt pkt", "", "", "");	
		}
		
		pPktToForward = op_pk_get(op_intrpt_strm());
	}
	
	sprintf (message_str, "[%d] Send to mac Pkt\n", source_id); 
	printf (message_str);
	
	op_pk_send(pPktToForward, STRM_OUT_MAC);
	
	FOUT;
}

void generate_mac_pk_interrupt()
{
	char message_str[255];
	char format_name[255];
	
	FIN(generate_mac_pk_interrupt());

	if(pPkt_interrupt != OPC_NIL)
	{
		op_sim_end("Not nill interrupt pkt", "", "", "");	
	}
	else if (is_pkt_interrupt)
	{
		op_sim_end("Pkt interrupt flag set (bad)", "", "", "");		
	}
	else if(op_intrpt_strm() != STRM_IN_MAC)
	{
		op_sim_end("generate_mac_pk_interrupt called for non mac stream interrupt", "", "", "");	
	}
	
	pPkt_interrupt = op_pk_get(STRM_IN_MAC);
	is_pkt_interrupt = 1;
	
	sprintf (message_str, "[%d] Received Mac Pkt\n", source_id); 
	printf (message_str);
	
	op_pk_format (pPkt_interrupt, format_name);
	if (strcmp (format_name, "beacon") == 0)
	{
		op_intrpt_schedule_self(op_sim_time(), IC_PK_BEACON);	
	}
	else if (strcmp (format_name, "keyupdate") == 0)
	{
		op_intrpt_schedule_self(op_sim_time(), IC_PK_UPDATEORACK);	
	}
	
	FOUT;
}


void printbad_mac_or_prop_strm()
{
	char message_str[255];
	
	FIN(printbad_mac_or_prop_strm());

	sprintf (message_str, "[%d UM DIE] Received mac or prop strm interrupt\n", source_id); 
	printf (message_str);
	
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
				FSM_PROFILE_SECTION_IN ("update_manager [init enter execs]", state0_enter_exec)
				{
				
				char beacon_dist_str[128];
				
				self_id = op_id_self();
				op_ima_obj_attr_get (self_id, "Source ID", &source_id);
				
				op_ima_obj_attr_get (self_id, "Beacon Interval", beacon_dist_str);
				disth_beacon_timer = oms_dist_load_from_string (beacon_dist_str);
				
				storage_id = op_id_from_name (op_topo_parent(self_id), OPC_OBJTYPE_PROC, "storage");
				
				prop1_id = op_id_from_name (op_topo_parent(self_id), OPC_OBJTYPE_PROC, "prop1");
				prop2_id = op_id_from_name (op_topo_parent(self_id), OPC_OBJTYPE_PROC, "prop2");
				prop3_id = op_id_from_name (op_topo_parent(self_id), OPC_OBJTYPE_PROC, "prop3");
				
				//Property stream priorities
				op_intrpt_priority_set (OPC_INTRPT_STRM, STRM_IN_P1, 15);
				op_intrpt_priority_set (OPC_INTRPT_STRM, STRM_IN_P2, 15);
				op_intrpt_priority_set (OPC_INTRPT_STRM, STRM_IN_P3, 15);
				
				//Lower than property inputs
				op_intrpt_priority_set (OPC_INTRPT_STRM, STRM_IN_STORE, 10);
				op_intrpt_priority_set (OPC_INTRPT_STRM, STRM_IN_MAC, 10);
				
				//Absolute highest - controlled by stream interrupts
				op_intrpt_priority_set (OPC_INTRPT_SELF, IC_PK_BEACON, 20);
				op_intrpt_priority_set (OPC_INTRPT_SELF, IC_PK_UPDATEORACK, 20);
				
				//Lower than STRM_IN_STORE
				op_intrpt_priority_set (OPC_INTRPT_REMOTE, IC_STORE_DUMP_DONE, 5);
				
				//Absolute lowest
				op_intrpt_priority_set (OPC_INTRPT_SELF, IC_SEND_BEACON_TIMER, 0);
				
				
				
				enable_beacon();
				}
				FSM_PROFILE_SECTION_OUT (state0_enter_exec)

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
			FSM_INIT_COND (I_PK_BEACON)
			FSM_TEST_COND (I_S_PROP_PKT)
			FSM_TEST_COND (I_S_MAC_PKT)
			FSM_TEST_COND (I_PK_UPDATEORACK)
			FSM_TEST_COND ((I_S_STORE_PKT || I_R_STORE_DUMP_DONE))
			FSM_TEST_COND (I_L_SEND_BEACON_TIMER)
			FSM_TEST_LOGIC ("idle")
			FSM_PROFILE_SECTION_OUT (state1_trans_conds)

			FSM_TRANSIT_SWITCH
				{
				FSM_CASE_TRANSIT (0, 4, state4_enter_exec, ;, "I_PK_BEACON", "", "idle", "tx_start", "tr_14", "update_manager [idle -> tx_start : I_PK_BEACON / ]")
				FSM_CASE_TRANSIT (1, 1, state1_enter_exec, send_to_store();, "I_S_PROP_PKT", "send_to_store()", "idle", "idle", "tr_19", "update_manager [idle -> idle : I_S_PROP_PKT / send_to_store()]")
				FSM_CASE_TRANSIT (2, 1, state1_enter_exec, generate_mac_pk_interrupt();, "I_S_MAC_PKT", "generate_mac_pk_interrupt()", "idle", "idle", "tr_20", "update_manager [idle -> idle : I_S_MAC_PKT / generate_mac_pk_interrupt()]")
				FSM_CASE_TRANSIT (3, 1, state1_enter_exec, send_to_store();, "I_PK_UPDATEORACK", "send_to_store()", "idle", "idle", "tr_21", "update_manager [idle -> idle : I_PK_UPDATEORACK / send_to_store()]")
				FSM_CASE_TRANSIT (4, 3, state3_enter_exec, ;, "(I_S_STORE_PKT || I_R_STORE_DUMP_DONE)", "", "idle", "error", "tr_22", "update_manager [idle -> error : (I_S_STORE_PKT || I_R_STORE_DUMP_DONE) / ]")
				FSM_CASE_TRANSIT (5, 1, state1_enter_exec, send_beacon();, "I_L_SEND_BEACON_TIMER", "send_beacon()", "idle", "idle", "tr_23", "update_manager [idle -> idle : I_L_SEND_BEACON_TIMER / send_beacon()]")
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
			FSM_INIT_COND (I_S_STORE_PKT)
			FSM_TEST_COND (I_R_STORE_DUMP_DONE)
			FSM_TEST_COND (I_S_MAC_PKT || I_S_PROP_PKT)
			FSM_DFLT_COND
			FSM_TEST_LOGIC ("tx")
			FSM_PROFILE_SECTION_OUT (state2_trans_conds)

			FSM_TRANSIT_SWITCH
				{
				FSM_CASE_TRANSIT (0, 2, state2_enter_exec, send_to_mac();, "I_S_STORE_PKT", "send_to_mac()", "tx", "tx", "tr_6", "update_manager [tx -> tx : I_S_STORE_PKT / send_to_mac()]")
				FSM_CASE_TRANSIT (1, 5, state5_enter_exec, ;, "I_R_STORE_DUMP_DONE", "", "tx", "tx_done", "tr_17", "update_manager [tx -> tx_done : I_R_STORE_DUMP_DONE / ]")
				FSM_CASE_TRANSIT (2, 3, state3_enter_exec, printbad_mac_or_prop_strm();, "I_S_MAC_PKT || I_S_PROP_PKT", "printbad_mac_or_prop_strm()", "tx", "error", "tr_24", "update_manager [tx -> error : I_S_MAC_PKT || I_S_PROP_PKT / printbad_mac_or_prop_strm()]")
				FSM_CASE_TRANSIT (3, 3, state3_enter_exec, ;, "default", "", "tx", "error", "tr_25", "update_manager [tx -> error : default / ]")
				}
				/*---------------------------------------------------------*/



			/** state (error) enter executives **/
			FSM_STATE_ENTER_UNFORCED (3, "error", state3_enter_exec, "update_manager [error enter execs]")
				FSM_PROFILE_SECTION_IN ("update_manager [error enter execs]", state3_enter_exec)
				{
				//Unrecoverable error
				op_sim_end("Unexpected state", "", "", "");
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
				if(is_pkt_interrupt)
				{
					is_pkt_interrupt = 0;
						
					if(pPkt_interrupt == OPC_NIL)
					{
						op_sim_end("Nill interrupt pkt", "", "", "");	
					}
						
					op_pk_destroy(pPkt_interrupt);
					pPkt_interrupt = OPC_NIL;
				}
				else
				{
					if(pPkt_interrupt != OPC_NIL)
					{
						op_sim_end("Not nill interrupt pkt", "", "", "");	
					}
				}
				
				disable_prop_updates();
				
				//TODO: clear prop update streams (?)
				
				disable_beacon();
				
				request_storage_dump();
				}
				FSM_PROFILE_SECTION_OUT (state4_enter_exec)

			/** state (tx_start) exit executives **/
			FSM_STATE_EXIT_FORCED (4, "tx_start", "update_manager [tx_start exit execs]")


			/** state (tx_start) transition processing **/
			FSM_TRANSIT_FORCE (2, state2_enter_exec, ;, "default", "", "tx_start", "tx", "tr_15", "update_manager [tx_start -> tx : default / ]")
				/*---------------------------------------------------------*/



			/** state (tx_done) enter executives **/
			FSM_STATE_ENTER_FORCED (5, "tx_done", state5_enter_exec, "update_manager [tx_done enter execs]")
				FSM_PROFILE_SECTION_IN ("update_manager [tx_done enter execs]", state5_enter_exec)
				{
				if(op_pk_get(STRM_IN_STORE) != OPC_NIL)
				{
					op_sim_end("Store stream not empty", "", "", "");
				}
				
				enable_prop_updates();
				
				//Allow the node we just received updates from to transmit
				enable_beacon();
				
				//send_beacon();
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


/* Undefine shortcuts to state variables to avoid */
/* syntax error in direct access to fields of */
/* local variable prs_ptr in _op_update_manager_svar function. */
#undef storage_id
#undef is_pkt_interrupt
#undef pPkt_interrupt
#undef evh_beacon_tmr
#undef disth_beacon_timer
#undef self_id
#undef source_id
#undef prop1_id
#undef prop2_id
#undef prop3_id

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
	update_manager_state		*prs_ptr;

	FIN_MT (_op_update_manager_svar (gen_ptr, var_name, var_p_ptr))

	if (var_name == OPC_NIL)
		{
		*var_p_ptr = (void *)OPC_NIL;
		FOUT
		}
	prs_ptr = (update_manager_state *)gen_ptr;

	if (strcmp ("storage_id" , var_name) == 0)
		{
		*var_p_ptr = (void *) (&prs_ptr->storage_id);
		FOUT
		}
	if (strcmp ("is_pkt_interrupt" , var_name) == 0)
		{
		*var_p_ptr = (void *) (&prs_ptr->is_pkt_interrupt);
		FOUT
		}
	if (strcmp ("pPkt_interrupt" , var_name) == 0)
		{
		*var_p_ptr = (void *) (&prs_ptr->pPkt_interrupt);
		FOUT
		}
	if (strcmp ("evh_beacon_tmr" , var_name) == 0)
		{
		*var_p_ptr = (void *) (&prs_ptr->evh_beacon_tmr);
		FOUT
		}
	if (strcmp ("disth_beacon_timer" , var_name) == 0)
		{
		*var_p_ptr = (void *) (&prs_ptr->disth_beacon_timer);
		FOUT
		}
	if (strcmp ("self_id" , var_name) == 0)
		{
		*var_p_ptr = (void *) (&prs_ptr->self_id);
		FOUT
		}
	if (strcmp ("source_id" , var_name) == 0)
		{
		*var_p_ptr = (void *) (&prs_ptr->source_id);
		FOUT
		}
	if (strcmp ("prop1_id" , var_name) == 0)
		{
		*var_p_ptr = (void *) (&prs_ptr->prop1_id);
		FOUT
		}
	if (strcmp ("prop2_id" , var_name) == 0)
		{
		*var_p_ptr = (void *) (&prs_ptr->prop2_id);
		FOUT
		}
	if (strcmp ("prop3_id" , var_name) == 0)
		{
		*var_p_ptr = (void *) (&prs_ptr->prop3_id);
		FOUT
		}
	*var_p_ptr = (void *)OPC_NIL;

	FOUT
	}

