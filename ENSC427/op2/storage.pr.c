/* Process model C form file: storage.pr.c */
/* Portions of this file copyright 1992-2007 by OPNET Technologies, Inc. */



/* This variable carries the header into the object file */
const char storage_pr_c [] = "MIL_3_Tfile_Hdr_ 140A 30A opnet 7 4BC0EC06 4BC0EC06 1 payette danh 0 0 none none 0 0 none 0 0 0 0 0 0 0 0 18a9 3                                                                                                                                                                                                                                                                                                                                                                                                               ";
#include <string.h>



/* OPNET system definitions */
#include <opnet.h>



/* Header Block */


//Interrupt Codes (random numbers)
#define IC_DUMP_UPDATES 		73
#define IC_DUMP_UPDATES_DONE 	74

#define TX_UPDATES 		(op_intrpt_type() == OPC_INTRPT_REMOTE && op_intrpt_code() == IC_DUMP_UPDATES)
//#define TX_UPDATES 		(op_intrpt_type() == OPC_INTRPT_SELF && op_intrpt_code() == IC_DUMP_UPDATES)
#define UPDATE_RECEIVED	(op_intrpt_type() == OPC_INTRPT_STRM)

void store_update(void);
void tx_updates(void);

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
	int	                    		test_isDisabled                                 ;
	Objid	                  		self_id                                         ;
	int	                    		maxlistsize                                     ;
	Stathandle	             		discarded_stathandle                            ;
	Objid	                  		updatemanager_id                                ;
	int	                    		source_id                                       ;
	} storage_state;

#define pupdate_lst             		op_sv_ptr->pupdate_lst
#define x_intrptScheduled       		op_sv_ptr->x_intrptScheduled
#define x_updatesSent           		op_sv_ptr->x_updatesSent
#define test_isDisabled         		op_sv_ptr->test_isDisabled
#define self_id                 		op_sv_ptr->self_id
#define maxlistsize             		op_sv_ptr->maxlistsize
#define discarded_stathandle    		op_sv_ptr->discarded_stathandle
#define updatemanager_id        		op_sv_ptr->updatemanager_id
#define source_id               		op_sv_ptr->source_id

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
	
	//DEBUG
	//if(intrptScheduled == 0)
	//{
	//	intrptScheduled = 1;
	//	op_intrpt_schedule_self (op_sim_time () + 10, IC_DUMP_UPDATES);
	//}
	
	
	pkt = op_pk_get (op_intrpt_strm ());
	
	sprintf (message_str, "[%d STORE] Store Update - List size: %d\n", source_id, op_prg_list_size(pupdate_lst )); 
	printf (message_str);
	
	//get info
	op_pk_nfd_get(pkt, "key", &newkey);
	op_pk_nfd_get(pkt, "source_id", &newsourceid);
	op_pk_nfd_get(pkt, "key_update_number", &newkey_updnm);
	op_pk_nfd_get(pkt, "generated_timestamp", &newgen_ts);
	listsize = op_prg_list_size(pupdate_lst);
	
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
					op_prg_list_remove (pupdate_lst, i);
					op_prg_list_insert(pupdate_lst, pkt, OPC_LISTPOS_TAIL);
					op_pk_destroy(lstPkt);
					FOUT;
				}
				else
				{
					op_pk_destroy(pkt);
					FOUT;
				}
			}
		}
	} //forloop

	
	op_prg_list_insert(pupdate_lst, pkt, OPC_LISTPOS_TAIL);
	listsize = op_prg_list_size(pupdate_lst);

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
		
		//delete packet with oldest timestamp, temp, with incoming packet
		for(k = 0; k < listsize; k++)
		{
			lstPkt = (Packet *)op_prg_list_access (pupdate_lst, k);
			op_pk_nfd_get(lstPkt, "generated_timestamp", &gen_ts);
			
			if(temp == gen_ts)
			{
				//TODO: add statistic
				op_prg_list_remove (pupdate_lst, k);
				op_pk_destroy(lstPkt);
				op_stat_write(discarded_stathandle, 1.0);
				
				sprintf (message_str, "[%d STORE] \tMax list size reached, discarding packet aged: %d\n", source_id, gen_ts); 
				printf (message_str);
				
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
		//pkt = (Packet *) op_prg_list_remove (pupdate_lst, OPC_LISTPOS_HEAD);
		pkt = (Packet *) op_prg_list_access (pupdate_lst, i);
		
		pPktCopy = op_pk_copy(pkt);
		
		//TODO: Need to duplicate packet - dont remove
		op_pk_send(pPktCopy, 0);
	}

	op_intrpt_schedule_remote(op_sim_time(), IC_DUMP_UPDATES_DONE, updatemanager_id);
	
 	sprintf (message_str, "[%d STORE] 	Done Sending Packets: size %d\n", op_id_self(), op_prg_list_size(pupdate_lst)); 
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
				discarded_stathandle = op_stat_reg ("Discarded Pkts",OPC_STAT_INDEX_NONE, OPC_STAT_LOCAL);
				
				/* allocate an empty list */
				//intrptScheduled = 0;
				//updatesSent = 0;
				test_isDisabled = 0;
				pupdate_lst = op_prg_list_create (); 
				
				//printf("Enter exec debug\n");
				self_id = op_id_self();
				op_ima_obj_attr_get (self_id, "Max Packets", &maxlistsize);
				op_ima_obj_attr_get (self_id, "Source ID", &source_id);
				
				updatemanager_id = op_id_from_name (op_topo_parent(self_id), OPC_OBJTYPE_PROC, "update_manager");
				
				//printf("Enter exec done \n");
				}
				FSM_PROFILE_SECTION_OUT (state0_enter_exec)

			/** state (init) exit executives **/
			FSM_STATE_EXIT_FORCED (0, "init", "storage [init exit execs]")


			/** state (init) transition processing **/
			FSM_TRANSIT_FORCE (1, state1_enter_exec, ;, "default", "", "init", "idle", "tr_0", "storage [init -> idle : default / ]")
				/*---------------------------------------------------------*/



			/** state (idle) enter executives **/
			FSM_STATE_ENTER_UNFORCED (1, "idle", state1_enter_exec, "storage [idle enter execs]")

			/** blocking after enter executives of unforced state. **/
			FSM_EXIT (3,"storage")


			/** state (idle) exit executives **/
			FSM_STATE_EXIT_UNFORCED (1, "idle", "storage [idle exit execs]")


			/** state (idle) transition processing **/
			FSM_PROFILE_SECTION_IN ("storage [idle trans conditions]", state1_trans_conds)
			FSM_INIT_COND (UPDATE_RECEIVED)
			FSM_TEST_COND (TX_UPDATES)
			FSM_TEST_LOGIC ("idle")
			FSM_PROFILE_SECTION_OUT (state1_trans_conds)

			FSM_TRANSIT_SWITCH
				{
				FSM_CASE_TRANSIT (0, 1, state1_enter_exec, store_update();, "UPDATE_RECEIVED", "store_update()", "idle", "idle", "tr_1", "storage [idle -> idle : UPDATE_RECEIVED / store_update()]")
				FSM_CASE_TRANSIT (1, 1, state1_enter_exec, tx_updates();, "TX_UPDATES", "tx_updates()", "idle", "idle", "tr_2", "storage [idle -> idle : TX_UPDATES / tx_updates()]")
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
#undef test_isDisabled
#undef self_id
#undef maxlistsize
#undef discarded_stathandle
#undef updatemanager_id
#undef source_id

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
	if (strcmp ("test_isDisabled" , var_name) == 0)
		{
		*var_p_ptr = (void *) (&prs_ptr->test_isDisabled);
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
	if (strcmp ("discarded_stathandle" , var_name) == 0)
		{
		*var_p_ptr = (void *) (&prs_ptr->discarded_stathandle);
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
	*var_p_ptr = (void *)OPC_NIL;

	FOUT
	}

