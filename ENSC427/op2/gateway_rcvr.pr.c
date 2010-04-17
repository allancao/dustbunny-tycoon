/* Process model C form file: gateway_rcvr.pr.c */
/* Portions of this file copyright 1992-2007 by OPNET Technologies, Inc. */



/* This variable carries the header into the object file */
const char gateway_rcvr_pr_c [] = "MIL_3_Tfile_Hdr_ 140A 30A opnet 7 4BC8F07A 4BC8F07A 1 rfsip5 danh 0 0 none none 0 0 none 0 0 0 0 0 0 0 0 18a9 3                                                                                                                                                                                                                                                                                                                                                                                                                ";
#include <string.h>



/* OPNET system definitions */
#include <opnet.h>



/* Header Block */

#define MAX_SRC_IDS		10
#define IC_SOURCPROP_RX 99

int has_inited = 0;

int pkt_received[MAX_SRC_IDS*3];

List *p1_last_pkts;
List *p2_last_pkts;
List *p3_last_pkts;

Stathandle stat_neworreplace;
Stathandle stat_delay;

//Statistic lists
List *p1_updates_stat_lst;
List *p2_updates_stat_lst;
List *p3_updates_stat_lst;

//List *update_counter_change_stat_lst;
//List *delay_stat_lst;

List *create_stat_lst(char *);

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
	} gateway_rcvr_state;


/* These macro definitions will define a local variable called	*/
/* "op_sv_ptr" in each function containing a FIN statement.	*/
/* This variable points to the state variable data structure,	*/
/* and can be used from a C debugger to display their values.	*/
#undef FIN_PREAMBLE_DEC
#undef FIN_PREAMBLE_CODE
#define FIN_PREAMBLE_DEC	gateway_rcvr_state *op_sv_ptr;
#define FIN_PREAMBLE_CODE	\
		op_sv_ptr = ((gateway_rcvr_state *)(OP_SIM_CONTEXT_PTR->_op_mod_state_ptr));


/* Function Block */

#if !defined (VOSD_NO_FIN)
enum { _op_block_origin = __LINE__ + 2};
#endif

List *create_stat_lst(char *statName)
{
	List *lst;
	int stat_size;
	int i;
	
	FIN(create_stat_lst(char *statName));
	
	op_stat_dim_size_get (statName, OPC_STAT_GLOBAL, &stat_size);
	if(stat_size != MAX_SRC_IDS)
	{
		op_sim_end("Bad stat dimension", statName, "", "");
	}
	
	lst = op_prg_list_create();
	for(i = 0; i < MAX_SRC_IDS; i++)
	{
		Stathandle *sth_temp;
		sth_temp = (Stathandle *) op_prg_mem_alloc (sizeof (Stathandle));
		*sth_temp = op_stat_reg (statName, i, OPC_STAT_GLOBAL);
		
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
	void gateway_rcvr (OP_SIM_CONTEXT_ARG_OPT);
	VosT_Obtype _op_gateway_rcvr_init (int * init_block_ptr);
	void _op_gateway_rcvr_diag (OP_SIM_CONTEXT_ARG_OPT);
	void _op_gateway_rcvr_terminate (OP_SIM_CONTEXT_ARG_OPT);
	VosT_Address _op_gateway_rcvr_alloc (VosT_Obtype, int);
	void _op_gateway_rcvr_svar (void *, const char *, void **);


#if defined (__cplusplus)
} /* end of 'extern "C"' */
#endif




/* Process model interrupt handling procedure */


void
gateway_rcvr (OP_SIM_CONTEXT_ARG_OPT)
	{
#if !defined (VOSD_NO_FIN)
	int _op_block_origin = 0;
#endif
	FIN_MT (gateway_rcvr ());

		{


		FSM_ENTER_NO_VARS ("gateway_rcvr")

		FSM_BLOCK_SWITCH
			{
			/*---------------------------------------------------------*/
			/** state (init) enter executives **/
			FSM_STATE_ENTER_FORCED_NOLABEL (0, "init", "gateway_rcvr [init enter execs]")
				FSM_PROFILE_SECTION_IN ("gateway_rcvr [init enter execs]", state0_enter_exec)
				{
				int stat_size_temp;
				int i;
				
				if(has_inited == 0)
				{
					printf("INITIALIZING gateway statistics\n");
					has_inited = 1;
					
					p1_updates_stat_lst = create_stat_lst("P1 Updates Received");
					p2_updates_stat_lst = create_stat_lst("P2 Updates Received");
					p3_updates_stat_lst = create_stat_lst("P3 Updates Received");
					
					p1_last_pkts = op_prg_list_create();
					p2_last_pkts = op_prg_list_create();
					p3_last_pkts = op_prg_list_create();
					
					for(i = 0; i < MAX_SRC_IDS; i++)
					{
						op_prg_list_insert(p1_last_pkts, OPC_NIL, OPC_LISTPOS_TAIL);
						op_prg_list_insert(p2_last_pkts, OPC_NIL, OPC_LISTPOS_TAIL);
						op_prg_list_insert(p3_last_pkts, OPC_NIL, OPC_LISTPOS_TAIL);
					}
					
					for(i = 0; i < MAX_SRC_IDS*3; i++)
					{
						pkt_received[i] = 0;
					}
					
					stat_neworreplace = op_stat_reg("Update Pkt - New or Replace" ,OPC_STAT_INDEX_NONE, OPC_STAT_GLOBAL);
					stat_delay = op_stat_reg("Delay" ,OPC_STAT_INDEX_NONE, OPC_STAT_GLOBAL);
				}
				}
				FSM_PROFILE_SECTION_OUT (state0_enter_exec)

			/** state (init) exit executives **/
			FSM_STATE_EXIT_FORCED (0, "init", "gateway_rcvr [init exit execs]")


			/** state (init) transition processing **/
			FSM_TRANSIT_FORCE (1, state1_enter_exec, ;, "default", "", "init", "record", "tr_0", "gateway_rcvr [init -> record : default / ]")
				/*---------------------------------------------------------*/



			/** state (record) enter executives **/
			FSM_STATE_ENTER_UNFORCED (1, "record", state1_enter_exec, "gateway_rcvr [record enter execs]")

			/** blocking after enter executives of unforced state. **/
			FSM_EXIT (3,"gateway_rcvr")


			/** state (record) exit executives **/
			FSM_STATE_EXIT_UNFORCED (1, "record", "gateway_rcvr [record exit execs]")
				FSM_PROFILE_SECTION_IN ("gateway_rcvr [record exit execs]", state1_exit_exec)
				{
				Packet *pPkt;
				Packet *pPktOld;
				
				int key;
				int sourceid;
				int key_updnm;
				double generated_timestamp;
				
				Objid source_prop_id;
				
				char message_str [255];
				
				List *lastPktLst;
				Stathandle *received_stat;
				
				pPkt = op_pk_get(op_intrpt_strm());
				
				op_pk_nfd_get(pPkt, "source_id", &sourceid);
				op_pk_nfd_get(pPkt, "key", &key);
				op_pk_nfd_get(pPkt, "key_update_number", &key_updnm);
				op_pk_nfd_get(pPkt, "source_prop_objid", &source_prop_id);
				op_pk_nfd_get(pPkt, "generated_timestamp", &generated_timestamp);
				
				//Check the fields
				if(sourceid < 0 || sourceid >= MAX_SRC_IDS)
				{
					op_sim_end("Bad source id", "", "", "");
				}
				else if(key_updnm < 0)
				{
					op_sim_end("Bad key_updnm", "", "", "");
				}
				
				//Basic record
				if(key == 1)
				{
					received_stat = (Stathandle *)op_prg_list_access (p1_updates_stat_lst, sourceid);
					lastPktLst = p1_updates_stat_lst;
				}
				else if (key == 2)
				{
					received_stat = (Stathandle *)op_prg_list_access (p2_updates_stat_lst, sourceid);
					lastPktLst = p2_updates_stat_lst;
				}
				else if (key == 3)
				{
					received_stat = (Stathandle *)op_prg_list_access (p3_updates_stat_lst, sourceid);
					lastPktLst = p3_updates_stat_lst;
				}
				else
				{
					op_sim_end("Bad key", "", "", "");
				}
				
				pPktOld = (Packet *)op_prg_list_access(lastPktLst, sourceid);
				if(pkt_received[sourceid*3 + (key-1)])
				{
					int oldkey_updnm;
					
					//printf("[GATEWAY] Update");
					op_pk_nfd_get(pPktOld, "key_update_number", &oldkey_updnm);
					
					if(oldkey_updnm < key_updnm)
					{
						//Trigger stat interrupt on source
						Ici *iciptr = op_ici_create ("gw_rx");
						op_ici_attr_set (iciptr, "source_id", sourceid);
						op_ici_attr_set (iciptr, "key_update_number", key_updnm);
						op_ici_install(iciptr);
						op_intrpt_schedule_remote (op_sim_time (), IC_SOURCPROP_RX, source_prop_id);
				
						//printf("[GATEWAY]	 stat_neworreplace\n");
						op_stat_write(stat_neworreplace, 1.0);
						op_stat_write(stat_delay, (op_sim_time () - generated_timestamp));
						//printf("[GATEWAY]	 	stat_neworreplace done\n");
						
						op_prg_list_remove(lastPktLst, sourceid);
						op_prg_list_insert(lastPktLst, pPkt, sourceid); 
					
						op_pk_destroy(pPktOld);
					
					}
					else
					{
						op_pk_destroy(pPkt);
					}
				}
				else
				{
					//Trigger stat interrupt on source
					Ici *iciptr = op_ici_create ("gw_rx");
					op_ici_attr_set (iciptr, "source_id", sourceid);
					op_ici_attr_set (iciptr, "key_update_number", key_updnm);
					op_ici_install(iciptr);
					op_intrpt_schedule_remote (op_sim_time (), IC_SOURCPROP_RX, source_prop_id);
				
					//printf("[GATEWAY] New");
					pkt_received[sourceid*3 + (key-1)] = 1;
					op_stat_write(stat_neworreplace, 1.0);
					op_stat_write(stat_delay, (op_sim_time () - generated_timestamp));
				
					op_prg_list_remove(lastPktLst, sourceid);
					op_prg_list_insert(lastPktLst, pPkt, sourceid); 
				}
				
				/*
				sprintf (message_str, "[GATEWAY] %d : %d\n", sourceid, key); 
				printf (message_str);
				
				printf("[GATEWAY]	 received_stat\n");
				op_stat_write(*received_stat, 1.0);
				printf("[GATEWAY]	 	received_stat done\n ");
				*/
				}
				FSM_PROFILE_SECTION_OUT (state1_exit_exec)


			/** state (record) transition processing **/
			FSM_TRANSIT_FORCE (1, state1_enter_exec, ;, "default", "", "record", "record", "tr_1", "gateway_rcvr [record -> record : default / ]")
				/*---------------------------------------------------------*/



			}


		FSM_EXIT (0,"gateway_rcvr")
		}
	}




void
_op_gateway_rcvr_diag (OP_SIM_CONTEXT_ARG_OPT)
	{
	/* No Diagnostic Block */
	}




void
_op_gateway_rcvr_terminate (OP_SIM_CONTEXT_ARG_OPT)
	{

	FIN_MT (_op_gateway_rcvr_terminate ())


	/* No Termination Block */

	Vos_Poolmem_Dealloc (op_sv_ptr);

	FOUT
	}


#undef FIN_PREAMBLE_DEC
#undef FIN_PREAMBLE_CODE

#define FIN_PREAMBLE_DEC
#define FIN_PREAMBLE_CODE

VosT_Obtype
_op_gateway_rcvr_init (int * init_block_ptr)
	{
	VosT_Obtype obtype = OPC_NIL;
	FIN_MT (_op_gateway_rcvr_init (init_block_ptr))

	obtype = Vos_Define_Object_Prstate ("proc state vars (gateway_rcvr)",
		sizeof (gateway_rcvr_state));
	*init_block_ptr = 0;

	FRET (obtype)
	}

VosT_Address
_op_gateway_rcvr_alloc (VosT_Obtype obtype, int init_block)
	{
#if !defined (VOSD_NO_FIN)
	int _op_block_origin = 0;
#endif
	gateway_rcvr_state * ptr;
	FIN_MT (_op_gateway_rcvr_alloc (obtype))

	ptr = (gateway_rcvr_state *)Vos_Alloc_Object (obtype);
	if (ptr != OPC_NIL)
		{
		ptr->_op_current_block = init_block;
#if defined (OPD_ALLOW_ODB)
		ptr->_op_current_state = "gateway_rcvr [init enter execs]";
#endif
		}
	FRET ((VosT_Address)ptr)
	}



void
_op_gateway_rcvr_svar (void * gen_ptr, const char * var_name, void ** var_p_ptr)
	{

	FIN_MT (_op_gateway_rcvr_svar (gen_ptr, var_name, var_p_ptr))

	*var_p_ptr = (void *)OPC_NIL;

	FOUT
	}

