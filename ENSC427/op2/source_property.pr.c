/* Process model C form file: source_property.pr.c */
/* Portions of this file copyright 1992-2007 by OPNET Technologies, Inc. */



/* This variable carries the header into the object file */
const char source_property_pr_c [] = "MIL_3_Tfile_Hdr_ 140A 30A op_runsim 7 4BCA670E 4BCA670E 1 payette danh 0 0 none none 0 0 none 0 0 0 0 0 0 0 0 18a9 3                                                                                                                                                                                                                                                                                                                                                                                                           ";
#include <string.h>



/* OPNET system definitions */
#include <opnet.h>



/* Header Block */

#include	<oms_dist_support.h>

//Interrupt Codes (codes have no meaning and are random)
#define IC_PROP_VAL_CHANGED 		39
#define IC_UPDATES_DISABLE	 		83
#define IC_UPDATES_ENABLE			84
#define IC_STOP						21

#define IC_GW_PKT_RX				99

#define SOURCE_MODE		(is_source_mode)

//Interrupts 
#define PROP_VAL_CHANGED	(op_intrpt_type() == OPC_INTRPT_SELF && op_intrpt_code() == IC_PROP_VAL_CHANGED)

#define DISABLE_PROP_UPDATES	(op_intrpt_type() == OPC_INTRPT_REMOTE && op_intrpt_code() == IC_UPDATES_DISABLE)
#define ENABLE_PROP_UPDATES		(op_intrpt_type() == OPC_INTRPT_REMOTE && op_intrpt_code() == IC_UPDATES_ENABLE)

#define I_GW_PKT_RX			(op_intrpt_type() == OPC_INTRPT_REMOTE && op_intrpt_code() == IC_GW_PKT_RX)
#define I_END_SIM			(op_intrpt_type() == OPC_INTRPT_ENDSIM)
#define I_STOP			(op_intrpt_type() == OPC_INTRPT_SELF && op_intrpt_code() == IC_STOP)

typedef struct
{
	int update_counter_number;
	int pkts_alive;
	int has_one_store;
	int gateway_rx;
	double generated_timestamp;
} active_update_tacker;

void new_val(void);
void schedule_update(void);

void gw_pkt_rx(void);
void stat_finalize(void);

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
	int	                    		prop_key                                        ;
	int	                    		prop_key_update_counter                         ;
	int	                    		prop_last_key_updated                           ;
	Objid	                  		self_id                                         ;
	Evhandle	               		next_update_evh                                 ;
	OmsT_Dist_Handle	       		update_dist_ptr                                 ;
	int	                    		source_id                                       ;
	int	                    		is_source_mode                                  ;
	int	                    		has_one_update                                  ;
	List *	                 		active_updates_lst                              ;
	Stathandle	             		stat_update_success                             ;
	Stathandle	             		stat_update_success_limited_loss                ;
	int	                    		last_key_update_num_delivered                   ;
	double	                 		stop_time                                       ;
	Stathandle	             		stat_delay                                      ;
	} source_property_state;

#define prop_key                		op_sv_ptr->prop_key
#define prop_key_update_counter 		op_sv_ptr->prop_key_update_counter
#define prop_last_key_updated   		op_sv_ptr->prop_last_key_updated
#define self_id                 		op_sv_ptr->self_id
#define next_update_evh         		op_sv_ptr->next_update_evh
#define update_dist_ptr         		op_sv_ptr->update_dist_ptr
#define source_id               		op_sv_ptr->source_id
#define is_source_mode          		op_sv_ptr->is_source_mode
#define has_one_update          		op_sv_ptr->has_one_update
#define active_updates_lst      		op_sv_ptr->active_updates_lst
#define stat_update_success     		op_sv_ptr->stat_update_success
#define stat_update_success_limited_loss		op_sv_ptr->stat_update_success_limited_loss
#define last_key_update_num_delivered		op_sv_ptr->last_key_update_num_delivered
#define stop_time               		op_sv_ptr->stop_time
#define stat_delay              		op_sv_ptr->stat_delay

/* These macro definitions will define a local variable called	*/
/* "op_sv_ptr" in each function containing a FIN statement.	*/
/* This variable points to the state variable data structure,	*/
/* and can be used from a C debugger to display their values.	*/
#undef FIN_PREAMBLE_DEC
#undef FIN_PREAMBLE_CODE
#define FIN_PREAMBLE_DEC	source_property_state *op_sv_ptr;
#define FIN_PREAMBLE_CODE	\
		op_sv_ptr = ((source_property_state *)(OP_SIM_CONTEXT_PTR->_op_mod_state_ptr));


/* Function Block */

#if !defined (VOSD_NO_FIN)
enum { _op_block_origin = __LINE__ + 2};
#endif



void new_val(void)
{
	FIN (new_val ());

	prop_key_update_counter++;
	schedule_update();
	
	FOUT
}

void schedule_update(void)
{
	double next_update_time;
	
	FIN(schedule_update());
	next_update_time = oms_dist_outcome (update_dist_ptr);

	if (next_update_time <0)
	{
		next_update_time = 0;
	}

	next_update_evh      = op_intrpt_schedule_self (op_sim_time () + next_update_time, IC_PROP_VAL_CHANGED);

	FOUT;
}

void gw_pkt_rx()
{
	Ici *iciptr;
	int sourceid;
	int key_update_number;
	int action;
	int discard_reason;
	int tracker_index;
	double generated_timestamp;
	active_update_tacker *pTracker;

	FIN(gw_pkt_rx());

	iciptr = op_intrpt_ici ();
	if(iciptr == OPC_NIL)
	{
		op_sim_end("Null ICI", "", "", "");
	}
	
	op_ici_attr_get (iciptr, "source_id", &sourceid);
	op_ici_attr_get (iciptr, "key_update_number", &key_update_number);
	op_ici_attr_get (iciptr, "action", &action);
	op_ici_attr_get (iciptr, "discard_reason", &discard_reason);
	op_ici_attr_get (iciptr, "generated_timestamp", &generated_timestamp);

	//Basic field checks 
	if(sourceid != source_id)
	{
		op_sim_end("Bad source id for ICI", "", "", "");
	}
	else if(key_update_number > prop_key_update_counter || key_update_number <= 0)
	{
		op_sim_end("Bad key_update_number for ICI", "", "", "");
	}
	
	//Find the tracker
	pTracker = OPC_NIL;
	for(tracker_index = 0; tracker_index < op_prg_list_size(active_updates_lst); tracker_index++)
	{
		active_update_tacker *pTrackerTemp;
		pTrackerTemp = (active_update_tacker *)op_prg_list_access(active_updates_lst, tracker_index);
		if(pTrackerTemp->update_counter_number == key_update_number)
		{
			pTracker = pTrackerTemp;
			break;
		}
	}
	if(pTracker == OPC_NIL)
	{
		op_sim_end("Could not find tracker", "", "", "");
	}
	
	if(action == 1)
	{
		//Gateway received packe
		if(pTracker->gateway_rx)
		{
			op_sim_end("Two gateway rx interrupts", "", "", "");
		}
		else if(pTracker->pkts_alive <= 0)
		{
			op_sim_end("pkts_alive problem", "", "", "");
		}
		pTracker->gateway_rx = 1;
		
		op_stat_write(stat_delay, op_sim_time() - generated_timestamp);
		op_stat_write(stat_update_success, 1.0);
		op_stat_write(stat_update_success_limited_loss, 1.0);
		
		if(last_key_update_num_delivered >= key_update_number)
		{
			op_sim_end("Problem with gateway", "", "", "");
		}
		last_key_update_num_delivered = key_update_number;
	}
	else if (action == 2)
	{
		//Store	
		if(pTracker->pkts_alive == 0 && pTracker->has_one_store != 0)
		{
			op_sim_end("Thats strange...", "", "", "");
		}
		
		pTracker->pkts_alive++;
		pTracker->has_one_store = 1;
	}
	else if (action == 3)
	{
		//Discard
		pTracker->pkts_alive--;
		
		if(pTracker->pkts_alive <= 0)
		{
			active_update_tacker *pTrackerTemp;
			
			if(pTracker->pkts_alive < 0 &&  pTracker->has_one_store)
			{
				op_sim_end("Thats strange...", "2", "", "");
			}
			
			if(pTracker->gateway_rx == 0)
			{
				//Nothing left - update has been lost
				op_stat_write(stat_update_success, 0.0);
				
				if(discard_reason == 1)
				{
					//Update
				}
				else if(discard_reason == 2)
				{
					//Mem full
					if(key_update_number > last_key_update_num_delivered)
					{
						op_stat_write(stat_update_success_limited_loss, 0.0);
					}
				}
				else
				{
					op_sim_end("Bad discard reason", "", "", "");
				}
			}
			
			pTrackerTemp = (active_update_tacker *)op_prg_list_remove(active_updates_lst, tracker_index);
			if(pTrackerTemp != pTracker)
			{
				op_sim_end("AHA,not another error!", "", "", "");
			}
			
			op_prg_mem_free(pTracker);
		}
	}
	else
	{
		op_sim_end("Bad action", "", "", "");
	}
	
	has_one_update = 1;
	
	op_ici_destroy(iciptr);
	FOUT;
}

void stat_finalize()
{
	Stathandle oneup;
	int i;

	FIN(stat_finalize());
	
	oneup = op_stat_reg("One Update",OPC_STAT_INDEX_NONE, OPC_STAT_GLOBAL);	
	op_stat_write(oneup, has_one_update);
	
	for(i = 0; i < op_prg_list_size(active_updates_lst); i++)
	{
		active_update_tacker *pTracker;
		pTracker = (active_update_tacker *)op_prg_list_access(active_updates_lst, i);
		
		if(pTracker->gateway_rx == 0)
		{
			//Receiving should already have been taken care of
			op_stat_write(stat_update_success, 0.0);
			
			if(pTracker->update_counter_number > last_key_update_num_delivered)
			{
				op_stat_write(stat_update_success_limited_loss, 0.0);
			}
		}
		
		if(pTracker->update_counter_number == prop_last_key_updated)
		{
			if(pTracker->gateway_rx == 0)
			{
				op_stat_write(stat_delay, op_sim_time() - pTracker->generated_timestamp);
			}
		}
	}
	
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
	void source_property (OP_SIM_CONTEXT_ARG_OPT);
	VosT_Obtype _op_source_property_init (int * init_block_ptr);
	void _op_source_property_diag (OP_SIM_CONTEXT_ARG_OPT);
	void _op_source_property_terminate (OP_SIM_CONTEXT_ARG_OPT);
	VosT_Address _op_source_property_alloc (VosT_Obtype, int);
	void _op_source_property_svar (void *, const char *, void **);


#if defined (__cplusplus)
} /* end of 'extern "C"' */
#endif




/* Process model interrupt handling procedure */


void
source_property (OP_SIM_CONTEXT_ARG_OPT)
	{
#if !defined (VOSD_NO_FIN)
	int _op_block_origin = 0;
#endif
	FIN_MT (source_property ());

		{


		FSM_ENTER ("source_property")

		FSM_BLOCK_SWITCH
			{
			/*---------------------------------------------------------*/
			/** state (init) enter executives **/
			FSM_STATE_ENTER_FORCED_NOLABEL (0, "init", "source_property [init enter execs]")
				FSM_PROFILE_SECTION_IN ("source_property [init enter execs]", state0_enter_exec)
				{
				char msg[100];
				char updatedist_str [128];
				
				self_id = op_id_self();
				
				op_ima_obj_attr_get (self_id, "Source ID", &source_id);
				op_ima_obj_attr_get (self_id, "Property Key", &prop_key);
				op_ima_obj_attr_get (self_id, "Property Update Interval", updatedist_str);
				op_ima_obj_attr_get (self_id, "Stop Time", &stop_time);
				
				op_ima_obj_attr_get (self_id, "Enable Properties", &is_source_mode);
				
				active_updates_lst = op_prg_list_create();
				has_one_update = 0;
				
				prop_key_update_counter = 0;
				prop_last_key_updated = 0; //So it gets updated right away
				
				update_dist_ptr = oms_dist_load_from_string (updatedist_str);
				
				stat_delay = op_stat_reg("Delay",OPC_STAT_INDEX_NONE, OPC_STAT_GLOBAL);
				stat_update_success = op_stat_reg("Update Success",OPC_STAT_INDEX_NONE, OPC_STAT_GLOBAL);
				stat_update_success_limited_loss = op_stat_reg("Update Success - Losses by buffer full",OPC_STAT_INDEX_NONE, OPC_STAT_GLOBAL);
				
				if(is_source_mode)
				{
					schedule_update();
					
					if(stop_time > 0)
					{
						op_intrpt_schedule_self (op_sim_time() + stop_time, IC_STOP);
					}
				}
				}
				FSM_PROFILE_SECTION_OUT (state0_enter_exec)

			/** state (init) exit executives **/
			FSM_STATE_EXIT_FORCED (0, "init", "source_property [init exit execs]")


			/** state (init) transition processing **/
			FSM_PROFILE_SECTION_IN ("source_property [init trans conditions]", state0_trans_conds)
			FSM_INIT_COND (SOURCE_MODE)
			FSM_TEST_COND (!SOURCE_MODE)
			FSM_TEST_LOGIC ("init")
			FSM_PROFILE_SECTION_OUT (state0_trans_conds)

			FSM_TRANSIT_SWITCH
				{
				FSM_CASE_TRANSIT (0, 1, state1_enter_exec, ;, "SOURCE_MODE", "", "init", "active", "tr_0", "source_property [init -> active : SOURCE_MODE / ]")
				FSM_CASE_TRANSIT (1, 3, state3_enter_exec, ;, "!SOURCE_MODE", "", "init", "do_nothing", "tr_7", "source_property [init -> do_nothing : !SOURCE_MODE / ]")
				}
				/*---------------------------------------------------------*/



			/** state (active) enter executives **/
			FSM_STATE_ENTER_UNFORCED (1, "active", state1_enter_exec, "source_property [active enter execs]")
				FSM_PROFILE_SECTION_IN ("source_property [active enter execs]", state1_enter_exec)
				{
				Packet *pPkt;
				
				if(prop_key_update_counter != prop_last_key_updated)
				{
					active_update_tacker *pTracker;
					int i;
					
					//Error check
					for(i = 0; i < op_prg_list_size(active_updates_lst); i++)
					{
						//Might be able to just check the tail instead
					
						pTracker = (active_update_tacker *)op_prg_list_access(active_updates_lst, i);
						if(pTracker->update_counter_number == prop_last_key_updated)
						{
							if(pTracker->has_one_store == 0)
							{
								op_sim_end("Did not receive store interrupt", "", "", "");
							}
						}
					}
				
					prop_last_key_updated = prop_key_update_counter;
					
					pPkt = op_pk_create_fmt("keyupdate");
					op_pk_nfd_set_int32(pPkt, "source_id", source_id);		
					op_pk_nfd_set_int32(pPkt, "key", prop_key);	
					op_pk_nfd_set_int32(pPkt, "key_update_number", prop_key_update_counter);
					op_pk_nfd_set_dbl(pPkt, "generated_timestamp", op_sim_time());
					op_pk_nfd_set_objid(pPkt, "source_prop_objid", self_id);
					
					pTracker = (active_update_tacker *) op_prg_mem_alloc (sizeof (active_update_tacker));
					pTracker->update_counter_number = prop_key_update_counter;
					pTracker->pkts_alive = 0;
					pTracker->has_one_store = 0;
					pTracker->gateway_rx = 0;
					pTracker->generated_timestamp = op_sim_time();
					
					op_prg_list_insert(active_updates_lst, pTracker, OPC_LISTPOS_TAIL);
					
					op_pk_send(pPkt, 0); //Output stream
				}
				}
				FSM_PROFILE_SECTION_OUT (state1_enter_exec)

			/** blocking after enter executives of unforced state. **/
			FSM_EXIT (3,"source_property")


			/** state (active) exit executives **/
			FSM_STATE_EXIT_UNFORCED (1, "active", "source_property [active exit execs]")


			/** state (active) transition processing **/
			FSM_PROFILE_SECTION_IN ("source_property [active trans conditions]", state1_trans_conds)
			FSM_INIT_COND (DISABLE_PROP_UPDATES)
			FSM_TEST_COND (PROP_VAL_CHANGED)
			FSM_TEST_COND (I_GW_PKT_RX)
			FSM_TEST_COND (I_END_SIM)
			FSM_TEST_COND (I_STOP)
			FSM_TEST_LOGIC ("active")
			FSM_PROFILE_SECTION_OUT (state1_trans_conds)

			FSM_TRANSIT_SWITCH
				{
				FSM_CASE_TRANSIT (0, 2, state2_enter_exec, ;, "DISABLE_PROP_UPDATES", "", "active", "disable", "tr_1", "source_property [active -> disable : DISABLE_PROP_UPDATES / ]")
				FSM_CASE_TRANSIT (1, 1, state1_enter_exec, new_val();, "PROP_VAL_CHANGED", "new_val()", "active", "active", "tr_2", "source_property [active -> active : PROP_VAL_CHANGED / new_val()]")
				FSM_CASE_TRANSIT (2, 1, state1_enter_exec, gw_pkt_rx();, "I_GW_PKT_RX", "gw_pkt_rx()", "active", "active", "tr_9", "source_property [active -> active : I_GW_PKT_RX / gw_pkt_rx()]")
				FSM_CASE_TRANSIT (3, 1, state1_enter_exec, stat_finalize();, "I_END_SIM", "stat_finalize()", "active", "active", "tr_11", "source_property [active -> active : I_END_SIM / stat_finalize()]")
				FSM_CASE_TRANSIT (4, 4, state4_enter_exec, ;, "I_STOP", "", "active", "stop", "tr_14", "source_property [active -> stop : I_STOP / ]")
				}
				/*---------------------------------------------------------*/



			/** state (disable) enter executives **/
			FSM_STATE_ENTER_UNFORCED (2, "disable", state2_enter_exec, "source_property [disable enter execs]")

			/** blocking after enter executives of unforced state. **/
			FSM_EXIT (5,"source_property")


			/** state (disable) exit executives **/
			FSM_STATE_EXIT_UNFORCED (2, "disable", "source_property [disable exit execs]")


			/** state (disable) transition processing **/
			FSM_PROFILE_SECTION_IN ("source_property [disable trans conditions]", state2_trans_conds)
			FSM_INIT_COND (PROP_VAL_CHANGED)
			FSM_TEST_COND (ENABLE_PROP_UPDATES)
			FSM_TEST_COND (I_GW_PKT_RX)
			FSM_TEST_COND (I_END_SIM)
			FSM_TEST_COND (I_STOP)
			FSM_TEST_LOGIC ("disable")
			FSM_PROFILE_SECTION_OUT (state2_trans_conds)

			FSM_TRANSIT_SWITCH
				{
				FSM_CASE_TRANSIT (0, 2, state2_enter_exec, new_val();, "PROP_VAL_CHANGED", "new_val()", "disable", "disable", "tr_3", "source_property [disable -> disable : PROP_VAL_CHANGED / new_val()]")
				FSM_CASE_TRANSIT (1, 1, state1_enter_exec, ;, "ENABLE_PROP_UPDATES", "", "disable", "active", "tr_4", "source_property [disable -> active : ENABLE_PROP_UPDATES / ]")
				FSM_CASE_TRANSIT (2, 2, state2_enter_exec, gw_pkt_rx();, "I_GW_PKT_RX", "gw_pkt_rx()", "disable", "disable", "tr_10", "source_property [disable -> disable : I_GW_PKT_RX / gw_pkt_rx()]")
				FSM_CASE_TRANSIT (3, 2, state2_enter_exec, stat_finalize();, "I_END_SIM", "stat_finalize()", "disable", "disable", "tr_12", "source_property [disable -> disable : I_END_SIM / stat_finalize()]")
				FSM_CASE_TRANSIT (4, 4, state4_enter_exec, ;, "I_STOP", "", "disable", "stop", "tr_13", "source_property [disable -> stop : I_STOP / ]")
				}
				/*---------------------------------------------------------*/



			/** state (do_nothing) enter executives **/
			FSM_STATE_ENTER_UNFORCED (3, "do_nothing", state3_enter_exec, "source_property [do_nothing enter execs]")

			/** blocking after enter executives of unforced state. **/
			FSM_EXIT (7,"source_property")


			/** state (do_nothing) exit executives **/
			FSM_STATE_EXIT_UNFORCED (3, "do_nothing", "source_property [do_nothing exit execs]")


			/** state (do_nothing) transition processing **/
			FSM_TRANSIT_FORCE (3, state3_enter_exec, ;, "default", "", "do_nothing", "do_nothing", "tr_8", "source_property [do_nothing -> do_nothing : default / ]")
				/*---------------------------------------------------------*/



			/** state (stop) enter executives **/
			FSM_STATE_ENTER_UNFORCED (4, "stop", state4_enter_exec, "source_property [stop enter execs]")
				FSM_PROFILE_SECTION_IN ("source_property [stop enter execs]", state4_enter_exec)
				{
				char msg_str[255];
				
				if (op_ev_valid (next_update_evh) == OPC_TRUE)
				{
					sprintf(msg_str, "[%d] Stopping property updates @ %d\n", source_id, op_sim_time());
					printf(msg_str);
					op_ev_cancel (next_update_evh);
				}
				}
				FSM_PROFILE_SECTION_OUT (state4_enter_exec)

			/** blocking after enter executives of unforced state. **/
			FSM_EXIT (9,"source_property")


			/** state (stop) exit executives **/
			FSM_STATE_EXIT_UNFORCED (4, "stop", "source_property [stop exit execs]")


			/** state (stop) transition processing **/
			FSM_PROFILE_SECTION_IN ("source_property [stop trans conditions]", state4_trans_conds)
			FSM_INIT_COND (I_GW_PKT_RX)
			FSM_TEST_COND (I_END_SIM)
			FSM_TEST_COND (DISABLE_PROP_UPDATES || ENABLE_PROP_UPDATES)
			FSM_TEST_LOGIC ("stop")
			FSM_PROFILE_SECTION_OUT (state4_trans_conds)

			FSM_TRANSIT_SWITCH
				{
				FSM_CASE_TRANSIT (0, 4, state4_enter_exec, gw_pkt_rx();, "I_GW_PKT_RX", "gw_pkt_rx()", "stop", "stop", "tr_15", "source_property [stop -> stop : I_GW_PKT_RX / gw_pkt_rx()]")
				FSM_CASE_TRANSIT (1, 4, state4_enter_exec, stat_finalize();, "I_END_SIM", "stat_finalize()", "stop", "stop", "tr_16", "source_property [stop -> stop : I_END_SIM / stat_finalize()]")
				FSM_CASE_TRANSIT (2, 4, state4_enter_exec, ;, "DISABLE_PROP_UPDATES || ENABLE_PROP_UPDATES", "", "stop", "stop", "tr_17", "source_property [stop -> stop : DISABLE_PROP_UPDATES || ENABLE_PROP_UPDATES / ]")
				}
				/*---------------------------------------------------------*/



			}


		FSM_EXIT (0,"source_property")
		}
	}




void
_op_source_property_diag (OP_SIM_CONTEXT_ARG_OPT)
	{
	/* No Diagnostic Block */
	}




void
_op_source_property_terminate (OP_SIM_CONTEXT_ARG_OPT)
	{

	FIN_MT (_op_source_property_terminate ())


	/* No Termination Block */

	Vos_Poolmem_Dealloc (op_sv_ptr);

	FOUT
	}


/* Undefine shortcuts to state variables to avoid */
/* syntax error in direct access to fields of */
/* local variable prs_ptr in _op_source_property_svar function. */
#undef prop_key
#undef prop_key_update_counter
#undef prop_last_key_updated
#undef self_id
#undef next_update_evh
#undef update_dist_ptr
#undef source_id
#undef is_source_mode
#undef has_one_update
#undef active_updates_lst
#undef stat_update_success
#undef stat_update_success_limited_loss
#undef last_key_update_num_delivered
#undef stop_time
#undef stat_delay

#undef FIN_PREAMBLE_DEC
#undef FIN_PREAMBLE_CODE

#define FIN_PREAMBLE_DEC
#define FIN_PREAMBLE_CODE

VosT_Obtype
_op_source_property_init (int * init_block_ptr)
	{
	VosT_Obtype obtype = OPC_NIL;
	FIN_MT (_op_source_property_init (init_block_ptr))

	obtype = Vos_Define_Object_Prstate ("proc state vars (source_property)",
		sizeof (source_property_state));
	*init_block_ptr = 0;

	FRET (obtype)
	}

VosT_Address
_op_source_property_alloc (VosT_Obtype obtype, int init_block)
	{
#if !defined (VOSD_NO_FIN)
	int _op_block_origin = 0;
#endif
	source_property_state * ptr;
	FIN_MT (_op_source_property_alloc (obtype))

	ptr = (source_property_state *)Vos_Alloc_Object (obtype);
	if (ptr != OPC_NIL)
		{
		ptr->_op_current_block = init_block;
#if defined (OPD_ALLOW_ODB)
		ptr->_op_current_state = "source_property [init enter execs]";
#endif
		}
	FRET ((VosT_Address)ptr)
	}



void
_op_source_property_svar (void * gen_ptr, const char * var_name, void ** var_p_ptr)
	{
	source_property_state		*prs_ptr;

	FIN_MT (_op_source_property_svar (gen_ptr, var_name, var_p_ptr))

	if (var_name == OPC_NIL)
		{
		*var_p_ptr = (void *)OPC_NIL;
		FOUT
		}
	prs_ptr = (source_property_state *)gen_ptr;

	if (strcmp ("prop_key" , var_name) == 0)
		{
		*var_p_ptr = (void *) (&prs_ptr->prop_key);
		FOUT
		}
	if (strcmp ("prop_key_update_counter" , var_name) == 0)
		{
		*var_p_ptr = (void *) (&prs_ptr->prop_key_update_counter);
		FOUT
		}
	if (strcmp ("prop_last_key_updated" , var_name) == 0)
		{
		*var_p_ptr = (void *) (&prs_ptr->prop_last_key_updated);
		FOUT
		}
	if (strcmp ("self_id" , var_name) == 0)
		{
		*var_p_ptr = (void *) (&prs_ptr->self_id);
		FOUT
		}
	if (strcmp ("next_update_evh" , var_name) == 0)
		{
		*var_p_ptr = (void *) (&prs_ptr->next_update_evh);
		FOUT
		}
	if (strcmp ("update_dist_ptr" , var_name) == 0)
		{
		*var_p_ptr = (void *) (&prs_ptr->update_dist_ptr);
		FOUT
		}
	if (strcmp ("source_id" , var_name) == 0)
		{
		*var_p_ptr = (void *) (&prs_ptr->source_id);
		FOUT
		}
	if (strcmp ("is_source_mode" , var_name) == 0)
		{
		*var_p_ptr = (void *) (&prs_ptr->is_source_mode);
		FOUT
		}
	if (strcmp ("has_one_update" , var_name) == 0)
		{
		*var_p_ptr = (void *) (&prs_ptr->has_one_update);
		FOUT
		}
	if (strcmp ("active_updates_lst" , var_name) == 0)
		{
		*var_p_ptr = (void *) (&prs_ptr->active_updates_lst);
		FOUT
		}
	if (strcmp ("stat_update_success" , var_name) == 0)
		{
		*var_p_ptr = (void *) (&prs_ptr->stat_update_success);
		FOUT
		}
	if (strcmp ("stat_update_success_limited_loss" , var_name) == 0)
		{
		*var_p_ptr = (void *) (&prs_ptr->stat_update_success_limited_loss);
		FOUT
		}
	if (strcmp ("last_key_update_num_delivered" , var_name) == 0)
		{
		*var_p_ptr = (void *) (&prs_ptr->last_key_update_num_delivered);
		FOUT
		}
	if (strcmp ("stop_time" , var_name) == 0)
		{
		*var_p_ptr = (void *) (&prs_ptr->stop_time);
		FOUT
		}
	if (strcmp ("stat_delay" , var_name) == 0)
		{
		*var_p_ptr = (void *) (&prs_ptr->stat_delay);
		FOUT
		}
	*var_p_ptr = (void *)OPC_NIL;

	FOUT
	}

