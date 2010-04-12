/* Process model C form file: storage.pr.c */
/* Portions of this file copyright 1992-2007 by OPNET Technologies, Inc. */



/* This variable carries the header into the object file */
const char storage_pr_c [] = "MIL_3_Tfile_Hdr_ 140A 30A opnet 7 4BC2841B 4BC2841B 1 payette danh 0 0 none none 0 0 none 0 0 0 0 0 0 0 0 18a9 3                                                                                                                                                                                                                                                                                                                                                                                                               ";
#include <string.h>



/* OPNET system definitions */
#include <opnet.h>



/* Header Block */

#define MAX_SRC_IDS		10

#define GATEWAY_MODE	(is_gateway)
#define STORAGE_MODE	(!GATEWAY_MODE)

#define STRM_UM_IN		0
#define STRM_UM_OUT		0

#define STRM_GW_OUT		1

//Interrupt Codes (random numbers)
#define IC_DUMP_UPDATES 		73
#define IC_DUMP_UPDATES_DONE 	74

#define TX_UPDATES 		(op_intrpt_type() == OPC_INTRPT_REMOTE && op_intrpt_code() == IC_DUMP_UPDATES)
//#define TX_UPDATES 		(op_intrpt_type() == OPC_INTRPT_SELF && op_intrpt_code() == IC_DUMP_UPDATES)
#define UPDATE_RECEIVED	(op_intrpt_type() == OPC_INTRPT_STRM)


List *create_stat_lst_loc(const char *);


void store_update(void);
void tx_updates(void);
void gateway_fwrd(void);

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
	List*	                  		pupdate_lst                                     ;
	int	                    		x_intrptScheduled                               ;
	int	                    		x_updatesSent                                   ;
	Objid	                  		self_id                                         ;
	int	                    		maxlistsize                                     ;
	Objid	                  		updatemanager_id                                ;
	int	                    		source_id                                       ;
	int	                    		is_gateway                                      ;
	List*	                  		stat_lst_pdisc_bfull                            ;
	List*	                  		stat_lst_pdisc_old                              ;
	List*	                  		stat_lst_pstored_new                            ;
	List*	                  		stat_lst_pstored_updated                        ;
	Stathandle	             		stat_preceived                                  ;
	List*	                  		stat_lst_pdisc_dup                              ;
	Stathandle	             		stat_neworupdated                               ;
	} storage_state;

#define pupdate_lst             		op_sv_ptr->pupdate_lst
#define x_intrptScheduled       		op_sv_ptr->x_intrptScheduled
#define x_updatesSent           		op_sv_ptr->x_updatesSent
#define self_id                 		op_sv_ptr->self_id
#define maxlistsize             		op_sv_ptr->maxlistsize
#define updatemanager_id        		op_sv_ptr->updatemanager_id
#define source_id               		op_sv_ptr->source_id
#define is_gateway              		op_sv_ptr->is_gateway
#define stat_lst_pdisc_bfull    		op_sv_ptr->stat_lst_pdisc_bfull
#define stat_lst_pdisc_old      		op_sv_ptr->stat_lst_pdisc_old
#define stat_lst_pstored_new    		op_sv_ptr->stat_lst_pstored_new
#define stat_lst_pstored_updated		op_sv_ptr->stat_lst_pstored_updated
#define stat_preceived          		op_sv_ptr->stat_preceived
#define stat_lst_pdisc_dup      		op_sv_ptr->stat_lst_pdisc_dup
#define stat_neworupdated       		op_sv_ptr->stat_neworupdated

/* These macro definitions will define a local variable called	*/
/* "op_sv_ptr" in each function containing a FIN statement.	*/
/* This variable points to the state variable data structure,	*/
/* and can be used from a C debugger to display their values.	*/
#undef FIN_PREAMBLE_DEC
#undef FIN_PREAMBLE_CODE
#define FIN_PREAMBLE_DEC	storage_state *op_sv_ptr;
#define FIN_PREAMBLE_CODE	\
		op_sv_ptr = ((storage_state *)(OP_SIM_CONTEXT_PTR->_op_mod_state_ptr));


/* Function Block */

#if !defined (VOSD_NO_FIN)
enum { _op_block_origin = __LINE__ + 2};
#endif

void store_update(void)
{
	Packet *pkt;
	Packet *lstPkt;
	char message_str [255];
	Objid prop1_id;
	int key;
	int sourceid;
	int key_updnm;
	int pos_index;
	int gen_ts;
	int newkey;
	int newsourceid;
	int newkey_updnm;
	int newgen_ts;
	int listsize;
	int i, j, k, temp;
	
	
	FIN (store_update ());
	
	pkt = op_pk_get (op_intrpt_strm ());
	
	//sprintf (message_str, "[%d STORE] Store Update - List size: %d\n", source_id, op_prg_list_size(pupdate_lst )); 
	//printf (message_str);
	
	//get info
	op_pk_nfd_get(pkt, "key", &newkey);
	op_pk_nfd_get(pkt, "source_id", &newsourceid);
	op_pk_nfd_get(pkt, "key_update_number", &newkey_updnm);
	op_pk_nfd_get(pkt, "generated_timestamp", &newgen_ts);
	listsize = op_prg_list_size(pupdate_lst);
	
	if(newsourceid < 0 || newsourceid >= MAX_SRC_IDS)
	{
		op_sim_end("Bad sourceid", "", "", "");
	}
	
	op_stat_write(stat_preceived, 1.0);
	
	//Following forloop is for 
	//Search & Compare 'key_update_number'; replace if newer
	for(i = 0; i < listsize; i++)
	{
		lstPkt = (Packet *)op_prg_list_access (pupdate_lst, i);
		op_pk_nfd_get(lstPkt, "key", &key);
		op_pk_nfd_get(lstPkt, "source_id", &sourceid);
		op_pk_nfd_get(lstPkt, "key_update_number", &key_updnm);
		op_pk_nfd_get(lstPkt, "generated_timestamp", &gen_ts);
		
		//COMPARE for matching source/key
		if(newsourceid == sourceid)
		{
			if(newkey == key)
			{
				if(newkey_updnm > key_updnm)	//if key is newer we update
				{
					if(newsourceid != source_id)
					{
						op_stat_write(*((Stathandle *)op_prg_list_access (stat_lst_pstored_updated, sourceid)), 1.0);
						op_stat_write(stat_neworupdated, 1.0);
					}
					
					op_prg_list_remove (pupdate_lst, i);
					op_prg_list_insert(pupdate_lst, pkt, OPC_LISTPOS_TAIL);
					op_pk_destroy(lstPkt);
					FOUT;
				}
				else
				{
					if(newkey_updnm == key_updnm)
					{
						op_stat_write(*((Stathandle *)op_prg_list_access (stat_lst_pdisc_dup, sourceid)), 1.0);
					}
					else
					{
						op_stat_write(*((Stathandle *)op_prg_list_access (stat_lst_pdisc_old, sourceid)), 1.0);
					}
				
					op_pk_destroy(pkt);
					FOUT;
				}
			}
		}
	} //forloop

	
	op_prg_list_insert(pupdate_lst, pkt, OPC_LISTPOS_TAIL);
	listsize = op_prg_list_size(pupdate_lst);

	if(newsourceid != source_id)
	{
		op_stat_write(*((Stathandle *)op_prg_list_access (stat_lst_pstored_new, newsourceid)), 1.0);
		op_stat_write(stat_neworupdated, 1.0);
	}

	//See if we need to get rid of something
	if(listsize > maxlistsize)
	{	
		//set first packet for temp
		lstPkt = (Packet *)op_prg_list_access (pupdate_lst, 0);
		op_pk_nfd_get(lstPkt, "generated_timestamp", &gen_ts);
		temp = gen_ts;
		
		//find oldest timestamp
		for(j = 0; j < listsize; j++)
		{
			lstPkt = (Packet *)op_prg_list_access (pupdate_lst, j);
			op_pk_nfd_get(lstPkt, "generated_timestamp", &gen_ts);
			
			if(gen_ts < temp)
			{
				temp = gen_ts;	//replace if older
			}
		}
		
		//delete packet with oldest timestamp, temp, 
		for(k = 0; k < listsize; k++)
		{
			lstPkt = (Packet *)op_prg_list_access (pupdate_lst, k);
			op_pk_nfd_get(lstPkt, "generated_timestamp", &gen_ts);
			op_pk_nfd_get(lstPkt, "source_id", &sourceid);
			
			if(temp == gen_ts)
			{
				op_stat_write(*((Stathandle *)op_prg_list_access (stat_lst_pdisc_bfull, sourceid)), 1.0);
				
				op_prg_list_remove (pupdate_lst, k);
				op_pk_destroy(lstPkt);
				
				
				//sprintf (message_str, "[%d STORE] \tMax list size reached, discarding packet aged: %d\n", source_id, gen_ts); 
				//printf (message_str);
				
				break;
			}
		}
	} 

	FOUT;
}

void tx_updates(void)
{
	int i;
	int lstSize;
	Packet *pkt;
	Packet *pPktCopy;
	char message_str [255];
	
	FIN (tx_updates ());
	
	//updatesSent++;			//increment counter
	//intrptScheduled = 0;

	sprintf (message_str, "[%d STORE] Sending Packets: size %d\n", source_id, op_prg_list_size(pupdate_lst)); 
	printf (message_str);
	
	lstSize = op_prg_list_size (pupdate_lst);
	for (i = 0; i < lstSize; i++)
	{
		pkt = (Packet *) op_prg_list_access (pupdate_lst, i);
		
		pPktCopy = op_pk_copy(pkt);
		op_pk_send(pPktCopy, STRM_UM_OUT);
	}

	op_intrpt_schedule_remote(op_sim_time(), IC_DUMP_UPDATES_DONE, updatemanager_id);
	
 	//sprintf (message_str, "[%d STORE] 	Done Sending Packets: size %d\n", op_id_self(), op_prg_list_size(pupdate_lst)); 
	//printf (message_str);
			 
	FOUT;
}

void tx_updates_done(void)
{
	FIN (tx_updates_done ());
	
	op_intrpt_schedule_remote(op_sim_time(), IC_DUMP_UPDATES_DONE, updatemanager_id);
	
	FOUT;
}

void gateway_fwrd()
{
	FIN (update_gateway ());

	op_stat_write(stat_preceived, 1.0);
	op_pk_send(op_pk_get(STRM_UM_IN), STRM_GW_OUT);
	
	FOUT;
}

List *create_stat_lst_loc(const char *statName)
{
	List *lst;
	int stat_size_asdf;
	int i;
	char msg1[255];
	char msg2[255];
	
	FIN(create_stat_lst_loc());
	
	op_stat_dim_size_get(statName, OPC_STAT_LOCAL, &stat_size_asdf);
	if(stat_size_asdf != MAX_SRC_IDS)
	{
		sprintf(msg1, "stat_size_asdf: %d", stat_size_asdf);
		sprintf(msg2, "MAX_SRC_IDS: %d", MAX_SRC_IDS);
		op_sim_end("Bad stat dimension", statName, msg1, msg2);
	}
	
	lst = op_prg_list_create();
	for(i = 0; i < MAX_SRC_IDS; i++)
	{
		Stathandle *sth_temp;
		sth_temp = (Stathandle *) op_prg_mem_alloc (sizeof (Stathandle));
		*sth_temp = op_stat_reg (statName, i, OPC_STAT_LOCAL);
		
		op_prg_list_insert(lst, sth_temp, OPC_LISTPOS_TAIL);
	}
	
	FRET(lst);
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
	void storage (OP_SIM_CONTEXT_ARG_OPT);
	VosT_Obtype _op_storage_init (int * init_block_ptr);
	void _op_storage_diag (OP_SIM_CONTEXT_ARG_OPT);
	void _op_storage_terminate (OP_SIM_CONTEXT_ARG_OPT);
	VosT_Address _op_storage_alloc (VosT_Obtype, int);
	void _op_storage_svar (void *, const char *, void **);


#if defined (__cplusplus)
} /* end of 'extern "C"' */
#endif




/* Process model interrupt handling procedure */


void
storage (OP_SIM_CONTEXT_ARG_OPT)
	{
#if !defined (VOSD_NO_FIN)
	int _op_block_origin = 0;
#endif
	FIN_MT (storage ());

		{


		FSM_ENTER ("storage")

		FSM_BLOCK_SWITCH
			{
			/*---------------------------------------------------------*/
			/** state (init) enter executives **/
			FSM_STATE_ENTER_FORCED_NOLABEL (0, "init", "storage [init enter execs]")
				FSM_PROFILE_SECTION_IN ("storage [init enter execs]", state0_enter_exec)
				{
				int i;
				
				self_id = op_id_self();
				
				printf("REGISTERING STATS\n");
				
				stat_lst_pstored_new = create_stat_lst_loc("Pkts Stored - New");
				stat_lst_pstored_updated = create_stat_lst_loc("Pkts Stored - Updated");
				
				stat_lst_pdisc_old = create_stat_lst_loc("Pkts Discarded - Old");
				stat_lst_pdisc_bfull = create_stat_lst_loc("Pkts Discarded - Buffer Full");
				stat_lst_pdisc_dup = create_stat_lst_loc("Pkts Discarded - Duplicate");
				
				
				stat_preceived = op_stat_reg("Pkts Received",OPC_STAT_INDEX_NONE, OPC_STAT_LOCAL);
				stat_neworupdated = op_stat_reg("Pkts Stored - New or Updated",OPC_STAT_INDEX_NONE, OPC_STAT_LOCAL);
				
				/* allocate an empty list */
				pupdate_lst = op_prg_list_create (); 
				
				
				op_ima_obj_attr_get (self_id, "Max Packets", &maxlistsize);
				op_ima_obj_attr_get (self_id, "Source ID", &source_id);
				op_ima_obj_attr_get (self_id, "Is Gateway", &is_gateway);
				
				updatemanager_id = op_id_from_name (op_topo_parent(self_id), OPC_OBJTYPE_PROC, "update_manager");
				}
				FSM_PROFILE_SECTION_OUT (state0_enter_exec)

			/** state (init) exit executives **/
			FSM_STATE_EXIT_FORCED (0, "init", "storage [init exit execs]")


			/** state (init) transition processing **/
			FSM_PROFILE_SECTION_IN ("storage [init trans conditions]", state0_trans_conds)
			FSM_INIT_COND (STORAGE_MODE)
			FSM_TEST_COND (GATEWAY_MODE)
			FSM_TEST_LOGIC ("init")
			FSM_PROFILE_SECTION_OUT (state0_trans_conds)

			FSM_TRANSIT_SWITCH
				{
				FSM_CASE_TRANSIT (0, 1, state1_enter_exec, ;, "STORAGE_MODE", "", "init", "storage", "tr_0", "storage [init -> storage : STORAGE_MODE / ]")
				FSM_CASE_TRANSIT (1, 2, state2_enter_exec, ;, "GATEWAY_MODE", "", "init", "gateway", "tr_3", "storage [init -> gateway : GATEWAY_MODE / ]")
				}
				/*---------------------------------------------------------*/



			/** state (storage) enter executives **/
			FSM_STATE_ENTER_UNFORCED (1, "storage", state1_enter_exec, "storage [storage enter execs]")
				FSM_PROFILE_SECTION_IN ("storage [storage enter execs]", state1_enter_exec)
				{
				if(maxlistsize <= 0)
				{
					//Typically when this node is a gateway
					op_sim_end("Invalid max list size", "", "", "");
				}
				}
				FSM_PROFILE_SECTION_OUT (state1_enter_exec)

			/** blocking after enter executives of unforced state. **/
			FSM_EXIT (3,"storage")


			/** state (storage) exit executives **/
			FSM_STATE_EXIT_UNFORCED (1, "storage", "storage [storage exit execs]")


			/** state (storage) transition processing **/
			FSM_PROFILE_SECTION_IN ("storage [storage trans conditions]", state1_trans_conds)
			FSM_INIT_COND (UPDATE_RECEIVED)
			FSM_TEST_COND (TX_UPDATES)
			FSM_TEST_LOGIC ("storage")
			FSM_PROFILE_SECTION_OUT (state1_trans_conds)

			FSM_TRANSIT_SWITCH
				{
				FSM_CASE_TRANSIT (0, 1, state1_enter_exec, store_update();, "UPDATE_RECEIVED", "store_update()", "storage", "storage", "tr_1", "storage [storage -> storage : UPDATE_RECEIVED / store_update()]")
				FSM_CASE_TRANSIT (1, 1, state1_enter_exec, tx_updates();, "TX_UPDATES", "tx_updates()", "storage", "storage", "tr_2", "storage [storage -> storage : TX_UPDATES / tx_updates()]")
				}
				/*---------------------------------------------------------*/



			/** state (gateway) enter executives **/
			FSM_STATE_ENTER_UNFORCED (2, "gateway", state2_enter_exec, "storage [gateway enter execs]")

			/** blocking after enter executives of unforced state. **/
			FSM_EXIT (5,"storage")


			/** state (gateway) exit executives **/
			FSM_STATE_EXIT_UNFORCED (2, "gateway", "storage [gateway exit execs]")


			/** state (gateway) transition processing **/
			FSM_PROFILE_SECTION_IN ("storage [gateway trans conditions]", state2_trans_conds)
			FSM_INIT_COND (TX_UPDATES)
			FSM_TEST_COND (UPDATE_RECEIVED)
			FSM_TEST_LOGIC ("gateway")
			FSM_PROFILE_SECTION_OUT (state2_trans_conds)

			FSM_TRANSIT_SWITCH
				{
				FSM_CASE_TRANSIT (0, 2, state2_enter_exec, tx_updates_done();, "TX_UPDATES", "tx_updates_done()", "gateway", "gateway", "tr_4", "storage [gateway -> gateway : TX_UPDATES / tx_updates_done()]")
				FSM_CASE_TRANSIT (1, 2, state2_enter_exec, gateway_fwrd();, "UPDATE_RECEIVED", "gateway_fwrd()", "gateway", "gateway", "tr_5", "storage [gateway -> gateway : UPDATE_RECEIVED / gateway_fwrd()]")
				}
				/*---------------------------------------------------------*/



			}


		FSM_EXIT (0,"storage")
		}
	}




void
_op_storage_diag (OP_SIM_CONTEXT_ARG_OPT)
	{
	/* No Diagnostic Block */
	}




void
_op_storage_terminate (OP_SIM_CONTEXT_ARG_OPT)
	{

	FIN_MT (_op_storage_terminate ())


	/* No Termination Block */

	Vos_Poolmem_Dealloc (op_sv_ptr);

	FOUT
	}


/* Undefine shortcuts to state variables to avoid */
/* syntax error in direct access to fields of */
/* local variable prs_ptr in _op_storage_svar function. */
#undef pupdate_lst
#undef x_intrptScheduled
#undef x_updatesSent
#undef self_id
#undef maxlistsize
#undef updatemanager_id
#undef source_id
#undef is_gateway
#undef stat_lst_pdisc_bfull
#undef stat_lst_pdisc_old
#undef stat_lst_pstored_new
#undef stat_lst_pstored_updated
#undef stat_preceived
#undef stat_lst_pdisc_dup
#undef stat_neworupdated

#undef FIN_PREAMBLE_DEC
#undef FIN_PREAMBLE_CODE

#define FIN_PREAMBLE_DEC
#define FIN_PREAMBLE_CODE

VosT_Obtype
_op_storage_init (int * init_block_ptr)
	{
	VosT_Obtype obtype = OPC_NIL;
	FIN_MT (_op_storage_init (init_block_ptr))

	obtype = Vos_Define_Object_Prstate ("proc state vars (storage)",
		sizeof (storage_state));
	*init_block_ptr = 0;

	FRET (obtype)
	}

VosT_Address
_op_storage_alloc (VosT_Obtype obtype, int init_block)
	{
#if !defined (VOSD_NO_FIN)
	int _op_block_origin = 0;
#endif
	storage_state * ptr;
	FIN_MT (_op_storage_alloc (obtype))

	ptr = (storage_state *)Vos_Alloc_Object (obtype);
	if (ptr != OPC_NIL)
		{
		ptr->_op_current_block = init_block;
#if defined (OPD_ALLOW_ODB)
		ptr->_op_current_state = "storage [init enter execs]";
#endif
		}
	FRET ((VosT_Address)ptr)
	}



void
_op_storage_svar (void * gen_ptr, const char * var_name, void ** var_p_ptr)
	{
	storage_state		*prs_ptr;

	FIN_MT (_op_storage_svar (gen_ptr, var_name, var_p_ptr))

	if (var_name == OPC_NIL)
		{
		*var_p_ptr = (void *)OPC_NIL;
		FOUT
		}
	prs_ptr = (storage_state *)gen_ptr;

	if (strcmp ("pupdate_lst" , var_name) == 0)
		{
		*var_p_ptr = (void *) (&prs_ptr->pupdate_lst);
		FOUT
		}
	if (strcmp ("x_intrptScheduled" , var_name) == 0)
		{
		*var_p_ptr = (void *) (&prs_ptr->x_intrptScheduled);
		FOUT
		}
	if (strcmp ("x_updatesSent" , var_name) == 0)
		{
		*var_p_ptr = (void *) (&prs_ptr->x_updatesSent);
		FOUT
		}
	if (strcmp ("self_id" , var_name) == 0)
		{
		*var_p_ptr = (void *) (&prs_ptr->self_id);
		FOUT
		}
	if (strcmp ("maxlistsize" , var_name) == 0)
		{
		*var_p_ptr = (void *) (&prs_ptr->maxlistsize);
		FOUT
		}
	if (strcmp ("updatemanager_id" , var_name) == 0)
		{
		*var_p_ptr = (void *) (&prs_ptr->updatemanager_id);
		FOUT
		}
	if (strcmp ("source_id" , var_name) == 0)
		{
		*var_p_ptr = (void *) (&prs_ptr->source_id);
		FOUT
		}
	if (strcmp ("is_gateway" , var_name) == 0)
		{
		*var_p_ptr = (void *) (&prs_ptr->is_gateway);
		FOUT
		}
	if (strcmp ("stat_lst_pdisc_bfull" , var_name) == 0)
		{
		*var_p_ptr = (void *) (&prs_ptr->stat_lst_pdisc_bfull);
		FOUT
		}
	if (strcmp ("stat_lst_pdisc_old" , var_name) == 0)
		{
		*var_p_ptr = (void *) (&prs_ptr->stat_lst_pdisc_old);
		FOUT
		}
	if (strcmp ("stat_lst_pstored_new" , var_name) == 0)
		{
		*var_p_ptr = (void *) (&prs_ptr->stat_lst_pstored_new);
		FOUT
		}
	if (strcmp ("stat_lst_pstored_updated" , var_name) == 0)
		{
		*var_p_ptr = (void *) (&prs_ptr->stat_lst_pstored_updated);
		FOUT
		}
	if (strcmp ("stat_preceived" , var_name) == 0)
		{
		*var_p_ptr = (void *) (&prs_ptr->stat_preceived);
		FOUT
		}
	if (strcmp ("stat_lst_pdisc_dup" , var_name) == 0)
		{
		*var_p_ptr = (void *) (&prs_ptr->stat_lst_pdisc_dup);
		FOUT
		}
	if (strcmp ("stat_neworupdated" , var_name) == 0)
		{
		*var_p_ptr = (void *) (&prs_ptr->stat_neworupdated);
		FOUT
		}
	*var_p_ptr = (void *)OPC_NIL;

	FOUT
	}

