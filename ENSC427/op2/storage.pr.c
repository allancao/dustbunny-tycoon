/* Process model C form file: storage.pr.c */
/* Portions of this file copyright 1992-2007 by OPNET Technologies, Inc. */



/* This variable carries the header into the object file */
const char storage_pr_c [] = "MIL_3_Tfile_Hdr_ 140A 30A opnet 7 4BB93CFC 4BB93CFC 1 rfsip11 tty2 0 0 none none 0 0 none 0 0 0 0 0 0 0 0 18a9 3                                                                                                                                                                                                                                                                                                                                                                                                               ";
#include <string.h>



/* OPNET system definitions */
#include <opnet.h>



/* Header Block */


//Interrupt Codes (random numbers)
#define IC_DUMP_UPDATES 3

//#define TX_UPDATES 		(op_intrpt_type() == OPC_INTRPT_REMOTE && op_intrpt_code() == IC_DUMP_UPDATES)
#define TX_UPDATES 		(op_intrpt_type() == OPC_INTRPT_SELF && op_intrpt_code() == IC_DUMP_UPDATES)
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
	int	                    		intrptScheduled                                 ;
	int	                    		updatesSent                                     ;
	int	                    		test_isDisabled                                 ;
	} storage_state;

#define pupdate_lst             		op_sv_ptr->pupdate_lst
#define intrptScheduled         		op_sv_ptr->intrptScheduled
#define updatesSent             		op_sv_ptr->updatesSent
#define test_isDisabled         		op_sv_ptr->test_isDisabled

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
	int newkey;
	int sourceid;
	int newsourceid;
	int key_updnm;
	int newkey_updnm;
	int pos_index;
	int listsize;
	int srcloc;
	int i;

	
	FIN (store_update ());
	
	//TODO: Search the list for old keys
	
	//DEBUG
	if(intrptScheduled == 0)
	{
		intrptScheduled = 1;
		op_intrpt_schedule_self (op_sim_time () + 10, IC_DUMP_UPDATES);
	}
	
	
	pkt = op_pk_get (op_intrpt_strm ());
	
	//op_prg_list_insert(pupdate_lst, pkt, OPC_LISTPOS_TAIL);
	
	sprintf (message_str, "[%d] Store Update - List size: %d\n", op_id_self(), op_prg_list_size(pupdate_lst )); 
	printf (message_str);
	
	//get info
	op_pk_nfd_get(pkt, "key", &newkey);
	op_pk_nfd_get(pkt, "source_id", &newsourceid);
	op_pk_nfd_get(pkt, "key_update_number", &newkey_updnm);
	listsize = op_prg_list_size(pupdate_lst);
	
	//Search & Compare key_update_number
	for(i = 0; i < listsize; i++)
	{
		lstPkt = (Packet *)op_prg_list_access (pupdate_lst, i);
		op_pk_nfd_get(lstPkt, "key", &key);
		op_pk_nfd_get(lstPkt, "source_id", &sourceid);
		op_pk_nfd_get(lstPkt, "key_update_number", &key_updnm);
		
		//COMPARE
		if(newsourceid == sourceid)
		{
			if(newkey == key)
			{
				if(newkey_updnm > key_updnm)	//key is newer we update
				{
					op_prg_list_remove (pupdate_lst, i);
					op_prg_list_insert(pupdate_lst, pkt, OPC_LISTPOS_TAIL);
					op_pk_destroy(lstPkt);
					FOUT;
				}
				else //(newkey_updnm <= key_updnm)
				{
					//do nothing
				}
			}
		}
	} //end forloop
	
	op_prg_list_insert(pupdate_lst, pkt, OPC_LISTPOS_TAIL);
	//op_pk_destroy(pkt);
	
	
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
	
	updatesSent++;			//increment counter
	intrptScheduled = 0;

	sprintf (message_str, "[%d] Sending Packets: size %d\n", op_id_self(), op_prg_list_size(pupdate_lst)); 
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

 	sprintf (message_str, "[%d] 	Done Sending Packets: size %d\n", op_id_self(), op_prg_list_size(pupdate_lst)); 
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
				/* allocate an empty list */
				intrptScheduled = 0;
				updatesSent = 0;
				test_isDisabled = 0;
				pupdate_lst = op_prg_list_create (); 
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
#undef intrptScheduled
#undef updatesSent
#undef test_isDisabled

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
	if (strcmp ("intrptScheduled" , var_name) == 0)
		{
		*var_p_ptr = (void *) (&prs_ptr->intrptScheduled);
		FOUT
		}
	if (strcmp ("updatesSent" , var_name) == 0)
		{
		*var_p_ptr = (void *) (&prs_ptr->updatesSent);
		FOUT
		}
	if (strcmp ("test_isDisabled" , var_name) == 0)
		{
		*var_p_ptr = (void *) (&prs_ptr->test_isDisabled);
		FOUT
		}
	*var_p_ptr = (void *)OPC_NIL;

	FOUT
	}

