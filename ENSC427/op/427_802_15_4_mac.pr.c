/* Process model C form file: 802_15_4_mac.pr.c */
/* Portions of this file copyright 1992-2007 by OPNET Technologies, Inc. */



/* This variable carries the header into the object file */
const char _02_15_4_mac_pr_c [] = "MIL_3_Tfile_Hdr_ 140A 30A op_mko 7 4859A270 4859A270 1 blade9880 root 0 0 none none 0 0 none 0 0 0 0 0 0 0 0 18a9 3                                                                                                                                                                                                                                                                                                                                                                                                            ";
#include <string.h>



/* OPNET system definitions */
#include <opnet.h>



/* Header Block */

/****************************************/
/* Copyright (c) 1987-2007 */
/* by OPNET Technologies, Inc. */
/* (A Delaware Corporation) */
/* 7255 Woodmont Av., Suite 250  */
/*     Bethesda, MD 20814, U.S.A.       */
/* All Rights Reserved. */
/****************************************/


#include <802_15_4.h>
#include <csma_ca.h>

#include <prg_bin_hash.h>
#include <math.h>
#include <oms_dist_support.h>
#include <jammers.h>

#define	PROP_VELOCITY	3.0E+08		

#define WPANC_SCAN_DONE_CODE 		-1
#define WPANC_PROGRESS_SCAN_CODE 	-2

#define NWK_STRM					0
#define WIRELESS_STRM				1

#define WPAN_MAC_DATA_OVERHEAD 144
#define WPAN_MAC_ACK_OVERHEAD 88

#define SCAN_REQUEST 	 	(op_intrpt_type() == OPC_INTRPT_REMOTE && op_intrpt_code() == 0)
#define BEACON_REQUEST 	 	(op_intrpt_type() == OPC_INTRPT_REMOTE && op_intrpt_code() == 1)
#define NWK_PK_RCVD 	 	(op_intrpt_type() == OPC_INTRPT_STRM && op_intrpt_strm() == 0)
#define WIRELESS_PK_RCVD 	(op_intrpt_type() == OPC_INTRPT_STRM && op_intrpt_strm() == 1)
#define PROGRESS_SCAN	 	(op_intrpt_type() == OPC_INTRPT_SELF && op_intrpt_code() == WPANC_PROGRESS_SCAN_CODE)
#define NETWORK_JOIN 	 	(op_intrpt_type() == OPC_INTRPT_REMOTE && op_intrpt_code() == 2)
#define NODE_FAILURE	 	(op_intrpt_type() == OPC_INTRPT_FAIL)
#define NODE_RECOVERY	 	(op_intrpt_type() == OPC_INTRPT_RECOVER)
#define SCAN_DONE 		 	(op_intrpt_type() == OPC_INTRPT_SELF && op_intrpt_code() == WPANC_SCAN_DONE_CODE)
#define ACK_TIMER		 	(op_intrpt_type() == OPC_INTRPT_SELF && op_intrpt_code() != WPANC_PROGRESS_SCAN_CODE && op_intrpt_code () != WPANC_SCAN_DONE_CODE)
#define PAN_LOST		 	(op_intrpt_type() == OPC_INTRPT_REMOTE && op_intrpt_code() == WPANC_PARENT_LOST)
#define TX_DONE 		 	(op_intrpt_type () == OPC_INTRPT_PROCESS && op_intrpt_code () != WPANC_TX_FAILURE)
#define TX_FAILED 		 	(op_intrpt_type () == OPC_INTRPT_PROCESS && op_intrpt_code () == WPANC_TX_FAILURE)


/* Function prototypes for initialization and network join process. */
void wpan_mac_init ();
void wpan_mac_record_beacon ();
void wpan_mac_send_results ();
void wpan_mac_send_beacon ();
void wpan_mac_set_vars ();
void wpan_mac_unset_vars ();
void wpan_mac_beacon_request_send ();
void wpan_mac_initialize_channels ();
void wpan_channel_info_set ();
void wpan_start_scan ();
void wpan_perform_scan ();


/* Function prototypes for transmission and reception of data. */
void wpan_mac_handle_wireless_pk ();
void wpan_mac_handle_nwk_pk ();
void wpan_prepare_mac_pkt_for_tx ();
void wpan_mac_send_ack (Packet* pkptr);
void wpan_mac_retransmit ();
void wpan_tx_info_hash_table_update (Packet* pkptr);
void wpan_handle_pkt_transmission_success ();
void wpan_handle_pkt_transmission_failure ();

/* Function prototypes for statistics update. */
void wpan_mac_register_stats ();
void wpan_mac_rcvd_stats_update (double pk_size);
void wpan_mac_thput_and_e2e_stats_update (Packet* pkptr);
void wpan_mac_load_stats_update (double pk_size);
void wpan_mac_mgmt_sent_stats_update (double pk_size);
void wpan_mac_mgmt_rcvd_stats_update (double pk_size);
void wpan_mac_control_sent_stats_update (double pk_size);
void wpan_mac_control_rcvd_stats_update (double pk_size);

/* Function prototypes for miscellanesous tasks. */
void wpan_mac_drop_pk ();
Boolean wpan_network_pk_is_app_data (Packet *);
Boolean wpan_network_pk_is_join_response (Packet *pk);
void wpan_mac_fields_strip (Packet* pkptr);
void wpan_trans_info_free (void* htable_entry_ptr);
void wpan_mac_hash_initialize ();
int wpan_mac_stathandle_index_get (int curr_pan_id);

/* Globals to maintain the mapping of stathandle indices to corresponding PAN IDs */
int stat_dim_index = 0;
int pan_stat_handle_array [32];

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
	List*	                  		beacon_scan_list                                ;
	Objid	                  		nwk_id                                          ;
	int	                    		my_pan_id                                       ;
	int	                    		my_network_address                              ;
	int	                    		my_parent_address                               ;
	int	                    		my_channel                                      ;
	int	                    		my_beacon_order                                 ;
	int	                    		my_superframe_order                             ;
	Objid	                  		self_id                                         ;
	double	                 		my_beacon_interval                              ;
	Cmohandle	              		wpan_cmo_handle                                 ;
	List*	                  		channel_info_lptr                               ;
	double	                 		channel_sensing_duration                        ;
	Objid	                  		parent_id                                       ;
	Objid	                  		tx_channel_info_objid                           ;
	Objid	                  		rx_channel_info_objid                           ;
	int	                    		band_id_3                                       ;
	int	                    		band_id_2                                       ;
	int	                    		band_id_1                                       ;
	int	                    		channel_index                                   ;
	int	                    		scanning_complete                               ;
	int	                    		ack_enabled                                     ;
	double	                 		ack_duration                                    ;
	List*	                  		outstanding_pk_lptr                             ;
	int	                    		max_retrans                                     ;
	Stathandle	             		gbl_thput_bps_stathandle                        ;
	Stathandle	             		gbl_num_retrans_stathandle                      ;
	Stathandle	             		gbl_data_dropped_stathandle                     ;
	Stathandle	             		gbl_load_dim_stathandle [32]                    ;
	Stathandle	             		thput_bps_stathandle                            ;
	Stathandle	             		num_retrans_stathandle                          ;
	Stathandle	             		data_dropped_stathandle                         ;
	Stathandle	             		gbl_data_rcvd_stathandle                        ;
	Stathandle	             		data_rcvd_stathandle                            ;
	Stathandle	             		gbl_e2e_stathandle                              ;
	Prohandle	              		csma_ca_prohandle                               ;
	int	                    		csma_ca_process_busy                            ;
	PrgT_Bin_Hash_Table*	   		ack_outstanding_htable_ptr                      ;
	int	                    		sequence_number                                 ;
	WPAN_Modmem_Info*	      		modmem_ptr                                      ;
	Objid	                  		tx_objid                                        ;
	Objid	                  		rcvr_objid                                      ;
	Stathandle	             		e2e_stathandle                                  ;
	Stathandle	             		gbl_load_stathandle                             ;
	Stathandle	             		load_stathandle                                 ;
	Stathandle	             		gbl_control_data_rcvd_stathandle                ;
	Stathandle	             		gbl_control_data_sent_stathandle                ;
	Stathandle	             		control_data_rcvd_stathandle                    ;
	Stathandle	             		control_data_sent_stathandle                    ;
	double	                 		drate_sv                                        ;
	Stathandle	             		q_size_stathandle                               ;
	int	                    		joined                                          ;
	int	                    		channel_number                                  ;
	Stathandle	             		gbl_qdelay_stathandle                           ;
	Stathandle	             		qdelay_stathandle                               ;
	Stathandle	             		gbl_mgmt_data_rcvd_stathandle                   ;
	Stathandle	             		gbl_mgmt_data_sent_stathandle                   ;
	Stathandle	             		mgmt_data_rcvd_stathandle                       ;
	Stathandle	             		mgmt_data_sent_stathandle                       ;
	int	                    		packet_type_index                               ;
	int	                    		next_hop_address_index                          ;
	int	                    		stathandles_index                               ;
	int	                    		pan_id_index                                    ;
	int	                    		payload_index                                   ;
	int	                    		stat_dim_size                                   ;
	int                     		WPANC_ACK_PAN_ID_FIELD_INDEX                    ;
	int                     		WPANC_ACK_NEXT_HOP_ADDR_FIELD_INDEX             ;
	int                     		WPANC_ACK_SEQ_NUM_FIELD_INDEX                   ;
	int                     		WPANC_BEACON_PAN_ID_FIELD_INDEX                 ;
	int                     		WPANC_BEACON_SRC_ADDR_FIELD_INDEX               ;
	int                     		WPANC_BEACON_RTR_CAP_FIELD_INDEX                ;
	int                     		WPANC_BEACON_END_DEVICE_CAP_FIELD_INDEX         ;
	int                     		WPANC_BEACON_DEPTH_FIELD_INDEX                  ;
	int                     		WPANC_BEACON_CAP_DURATION_FIELD_INDEX           ;
	int                     		WPANC_BEACON_PARENT_BEACON_OFFSET_FIELD_INDEX   ;
	int                     		WPANC_BEACON_MAX_CHILDREN_FIELD_INDEX           ;
	int                     		WPANC_BEACON_MAX_ROUTERS_FIELD_INDEX            ;
	int                     		WPANC_BEACON_MAX_DEPTH_FIELD_INDEX              ;
	int                     		WPANC_BEACON_BEACON_ORDER_FIELD_INDEX           ;
	int                     		WPANC_BEACON_SUPERFRAME_ORDER_FIELD_INDEX       ;
	int                     		WPANC_BEACON_REQUEST_BAND_868_FIELD_INDEX       ;
	int                     		WPANC_BEACON_REQUEST_BAND_915_FIELD_INDEX       ;
	int                     		WPANC_BEACON_REQUEST_BAND_2450_FIELD_INDEX      ;
	} _02_15_4_mac_state;

#define beacon_scan_list        		op_sv_ptr->beacon_scan_list
#define nwk_id                  		op_sv_ptr->nwk_id
#define my_pan_id               		op_sv_ptr->my_pan_id
#define my_network_address      		op_sv_ptr->my_network_address
#define my_parent_address       		op_sv_ptr->my_parent_address
#define my_channel              		op_sv_ptr->my_channel
#define my_beacon_order         		op_sv_ptr->my_beacon_order
#define my_superframe_order     		op_sv_ptr->my_superframe_order
#define self_id                 		op_sv_ptr->self_id
#define my_beacon_interval      		op_sv_ptr->my_beacon_interval
#define wpan_cmo_handle         		op_sv_ptr->wpan_cmo_handle
#define channel_info_lptr       		op_sv_ptr->channel_info_lptr
#define channel_sensing_duration		op_sv_ptr->channel_sensing_duration
#define parent_id               		op_sv_ptr->parent_id
#define tx_channel_info_objid   		op_sv_ptr->tx_channel_info_objid
#define rx_channel_info_objid   		op_sv_ptr->rx_channel_info_objid
#define band_id_3               		op_sv_ptr->band_id_3
#define band_id_2               		op_sv_ptr->band_id_2
#define band_id_1               		op_sv_ptr->band_id_1
#define channel_index           		op_sv_ptr->channel_index
#define scanning_complete       		op_sv_ptr->scanning_complete
#define ack_enabled             		op_sv_ptr->ack_enabled
#define ack_duration            		op_sv_ptr->ack_duration
#define outstanding_pk_lptr     		op_sv_ptr->outstanding_pk_lptr
#define max_retrans             		op_sv_ptr->max_retrans
#define gbl_thput_bps_stathandle		op_sv_ptr->gbl_thput_bps_stathandle
#define gbl_num_retrans_stathandle		op_sv_ptr->gbl_num_retrans_stathandle
#define gbl_data_dropped_stathandle		op_sv_ptr->gbl_data_dropped_stathandle
#define gbl_load_dim_stathandle 		op_sv_ptr->gbl_load_dim_stathandle
#define thput_bps_stathandle    		op_sv_ptr->thput_bps_stathandle
#define num_retrans_stathandle  		op_sv_ptr->num_retrans_stathandle
#define data_dropped_stathandle 		op_sv_ptr->data_dropped_stathandle
#define gbl_data_rcvd_stathandle		op_sv_ptr->gbl_data_rcvd_stathandle
#define data_rcvd_stathandle    		op_sv_ptr->data_rcvd_stathandle
#define gbl_e2e_stathandle      		op_sv_ptr->gbl_e2e_stathandle
#define csma_ca_prohandle       		op_sv_ptr->csma_ca_prohandle
#define csma_ca_process_busy    		op_sv_ptr->csma_ca_process_busy
#define ack_outstanding_htable_ptr		op_sv_ptr->ack_outstanding_htable_ptr
#define sequence_number         		op_sv_ptr->sequence_number
#define modmem_ptr              		op_sv_ptr->modmem_ptr
#define tx_objid                		op_sv_ptr->tx_objid
#define rcvr_objid              		op_sv_ptr->rcvr_objid
#define e2e_stathandle          		op_sv_ptr->e2e_stathandle
#define gbl_load_stathandle     		op_sv_ptr->gbl_load_stathandle
#define load_stathandle         		op_sv_ptr->load_stathandle
#define gbl_control_data_rcvd_stathandle		op_sv_ptr->gbl_control_data_rcvd_stathandle
#define gbl_control_data_sent_stathandle		op_sv_ptr->gbl_control_data_sent_stathandle
#define control_data_rcvd_stathandle		op_sv_ptr->control_data_rcvd_stathandle
#define control_data_sent_stathandle		op_sv_ptr->control_data_sent_stathandle
#define drate_sv                		op_sv_ptr->drate_sv
#define q_size_stathandle       		op_sv_ptr->q_size_stathandle
#define joined                  		op_sv_ptr->joined
#define channel_number          		op_sv_ptr->channel_number
#define gbl_qdelay_stathandle   		op_sv_ptr->gbl_qdelay_stathandle
#define qdelay_stathandle       		op_sv_ptr->qdelay_stathandle
#define gbl_mgmt_data_rcvd_stathandle		op_sv_ptr->gbl_mgmt_data_rcvd_stathandle
#define gbl_mgmt_data_sent_stathandle		op_sv_ptr->gbl_mgmt_data_sent_stathandle
#define mgmt_data_rcvd_stathandle		op_sv_ptr->mgmt_data_rcvd_stathandle
#define mgmt_data_sent_stathandle		op_sv_ptr->mgmt_data_sent_stathandle
#define packet_type_index       		op_sv_ptr->packet_type_index
#define next_hop_address_index  		op_sv_ptr->next_hop_address_index
#define stathandles_index       		op_sv_ptr->stathandles_index
#define pan_id_index            		op_sv_ptr->pan_id_index
#define payload_index           		op_sv_ptr->payload_index
#define stat_dim_size           		op_sv_ptr->stat_dim_size
#define WPANC_ACK_PAN_ID_FIELD_INDEX		op_sv_ptr->WPANC_ACK_PAN_ID_FIELD_INDEX
#define WPANC_ACK_NEXT_HOP_ADDR_FIELD_INDEX		op_sv_ptr->WPANC_ACK_NEXT_HOP_ADDR_FIELD_INDEX
#define WPANC_ACK_SEQ_NUM_FIELD_INDEX		op_sv_ptr->WPANC_ACK_SEQ_NUM_FIELD_INDEX
#define WPANC_BEACON_PAN_ID_FIELD_INDEX		op_sv_ptr->WPANC_BEACON_PAN_ID_FIELD_INDEX
#define WPANC_BEACON_SRC_ADDR_FIELD_INDEX		op_sv_ptr->WPANC_BEACON_SRC_ADDR_FIELD_INDEX
#define WPANC_BEACON_RTR_CAP_FIELD_INDEX		op_sv_ptr->WPANC_BEACON_RTR_CAP_FIELD_INDEX
#define WPANC_BEACON_END_DEVICE_CAP_FIELD_INDEX		op_sv_ptr->WPANC_BEACON_END_DEVICE_CAP_FIELD_INDEX
#define WPANC_BEACON_DEPTH_FIELD_INDEX		op_sv_ptr->WPANC_BEACON_DEPTH_FIELD_INDEX
#define WPANC_BEACON_CAP_DURATION_FIELD_INDEX		op_sv_ptr->WPANC_BEACON_CAP_DURATION_FIELD_INDEX
#define WPANC_BEACON_PARENT_BEACON_OFFSET_FIELD_INDEX		op_sv_ptr->WPANC_BEACON_PARENT_BEACON_OFFSET_FIELD_INDEX
#define WPANC_BEACON_MAX_CHILDREN_FIELD_INDEX		op_sv_ptr->WPANC_BEACON_MAX_CHILDREN_FIELD_INDEX
#define WPANC_BEACON_MAX_ROUTERS_FIELD_INDEX		op_sv_ptr->WPANC_BEACON_MAX_ROUTERS_FIELD_INDEX
#define WPANC_BEACON_MAX_DEPTH_FIELD_INDEX		op_sv_ptr->WPANC_BEACON_MAX_DEPTH_FIELD_INDEX
#define WPANC_BEACON_BEACON_ORDER_FIELD_INDEX		op_sv_ptr->WPANC_BEACON_BEACON_ORDER_FIELD_INDEX
#define WPANC_BEACON_SUPERFRAME_ORDER_FIELD_INDEX		op_sv_ptr->WPANC_BEACON_SUPERFRAME_ORDER_FIELD_INDEX
#define WPANC_BEACON_REQUEST_BAND_868_FIELD_INDEX		op_sv_ptr->WPANC_BEACON_REQUEST_BAND_868_FIELD_INDEX
#define WPANC_BEACON_REQUEST_BAND_915_FIELD_INDEX		op_sv_ptr->WPANC_BEACON_REQUEST_BAND_915_FIELD_INDEX
#define WPANC_BEACON_REQUEST_BAND_2450_FIELD_INDEX		op_sv_ptr->WPANC_BEACON_REQUEST_BAND_2450_FIELD_INDEX

/* These macro definitions will define a local variable called	*/
/* "op_sv_ptr" in each function containing a FIN statement.	*/
/* This variable points to the state variable data structure,	*/
/* and can be used from a C debugger to display their values.	*/
#undef FIN_PREAMBLE_DEC
#undef FIN_PREAMBLE_CODE
#define FIN_PREAMBLE_DEC	_02_15_4_mac_state *op_sv_ptr;
#define FIN_PREAMBLE_CODE	\
		op_sv_ptr = ((_02_15_4_mac_state *)(OP_SIM_CONTEXT_PTR->_op_mod_state_ptr));


/* Function Block */

#if !defined (VOSD_NO_FIN)
enum { _op_block_origin = __LINE__ + 2};
#endif

void
wpan_mac_init ()
	{

	Objid ack_objid;
	Objid ack_info_objid;
	double rx_power_threshold_dbm = 0.0;
	int data_rate;
	Packet * pk;
	
	/* The purpose of this function is to: 			*/
	/* 		- Register statistics					*/
	/* 		- Initialize channels for scanning		*/
	/* 		- Initialize state varibles 			*/
	/* 		- Create CSMA-CA child process			*/
	/* 		- Read in MAC attributes				*/
	/* 		- Initialize module-wide memory			*/
	
	FIN (wpan_mac_init ());
	
	/* Initialize packet index variables. */
	pk = op_pk_create_fmt ("zigbee_network_pdu");
	packet_type_index 	   = op_pk_nfd_name_to_index (pk, "packet_type");
	next_hop_address_index = op_pk_nfd_name_to_index (pk, "next_hop_address");
	stathandles_index 	   = op_pk_nfd_name_to_index (pk, "stathandles");
	pan_id_index 		   = op_pk_nfd_name_to_index (pk, "pan_id");
	payload_index          = op_pk_nfd_name_to_index (pk, "payload");
	op_pk_destroy (pk);
	
	pk = op_pk_create_fmt ("zigbee_beacon");
	WPANC_BEACON_PAN_ID_FIELD_INDEX 			= op_pk_nfd_name_to_index (pk, "pan_id");
	WPANC_BEACON_SRC_ADDR_FIELD_INDEX 			= op_pk_nfd_name_to_index (pk, "source_address");
	WPANC_BEACON_RTR_CAP_FIELD_INDEX 			= op_pk_nfd_name_to_index (pk, "router_capacity");
	WPANC_BEACON_END_DEVICE_CAP_FIELD_INDEX 	= op_pk_nfd_name_to_index (pk, "end_device_capacity");
	WPANC_BEACON_DEPTH_FIELD_INDEX 				= op_pk_nfd_name_to_index (pk, "depth");
	WPANC_BEACON_CAP_DURATION_FIELD_INDEX 		= op_pk_nfd_name_to_index (pk, "cap_duration");
	WPANC_BEACON_PARENT_BEACON_OFFSET_FIELD_INDEX = op_pk_nfd_name_to_index (pk, "parent_beacon_offset");
	WPANC_BEACON_MAX_CHILDREN_FIELD_INDEX 		= op_pk_nfd_name_to_index (pk, "max_children");
	WPANC_BEACON_MAX_ROUTERS_FIELD_INDEX 		= op_pk_nfd_name_to_index (pk, "max_routers");
	WPANC_BEACON_MAX_DEPTH_FIELD_INDEX 			= op_pk_nfd_name_to_index (pk, "max_depth");
	WPANC_BEACON_BEACON_ORDER_FIELD_INDEX 		= op_pk_nfd_name_to_index (pk, "beacon_order");
	WPANC_BEACON_SUPERFRAME_ORDER_FIELD_INDEX 	= op_pk_nfd_name_to_index (pk, "superframe_order");
	op_pk_destroy (pk);
	
	pk = op_pk_create_fmt ("zigbee_beacon_request");
	/*  802.15.4 MAC Beacon Request Frame Fields */
	WPANC_BEACON_REQUEST_BAND_868_FIELD_INDEX  = op_pk_nfd_name_to_index (pk, "band_868");
	WPANC_BEACON_REQUEST_BAND_915_FIELD_INDEX  = op_pk_nfd_name_to_index (pk, "band_915");
	WPANC_BEACON_REQUEST_BAND_2450_FIELD_INDEX = op_pk_nfd_name_to_index (pk, "band_2450");
	op_pk_destroy (pk);
	
	pk = op_pk_create_fmt ("zigbee_ack");
	WPANC_ACK_PAN_ID_FIELD_INDEX 		= op_pk_nfd_name_to_index (pk, "pan_id");
	WPANC_ACK_NEXT_HOP_ADDR_FIELD_INDEX = op_pk_nfd_name_to_index (pk, "next_hop_address");
	WPANC_ACK_SEQ_NUM_FIELD_INDEX 		= op_pk_nfd_name_to_index (pk, "sequence_number");
	op_pk_destroy (pk);
	
	/* Initialize state variables */
	beacon_scan_list 	= OPC_NIL;
	my_pan_id 			= -1;
	my_network_address 	= -1;
	my_parent_address 	= -1;
	my_channel 			= -1;
	stat_dim_index 		= 0;
	outstanding_pk_lptr = op_prg_list_create ();
	self_id = op_id_self();
	nwk_id = op_id_from_name (op_topo_parent (op_id_self ()), OPC_OBJTYPE_PROC, "network_layer");
	parent_id = op_topo_parent (self_id);
	
	/* Initialize categorized memory handle for the WPAN MAC */
	wpan_cmo_handle = op_prg_cmo_define ("WPAN MAC");	

	/* Read in MAC attributes.	*/
	op_ima_obj_attr_get (self_id, "Data Rate", &data_rate);
	op_ima_obj_attr_get (self_id, "Channel Sensing Duration", &channel_sensing_duration);	
	op_ima_obj_attr_get (self_id, "ACK Mechanism", &ack_objid);
	ack_info_objid = op_topo_child (ack_objid, OPC_OBJTYPE_GENERIC, 0);
	op_ima_obj_attr_get (ack_info_objid, "Status", &ack_enabled);
	op_ima_obj_attr_get (ack_info_objid, "ACK Wait Duration", &ack_duration);
	op_ima_obj_attr_get (ack_info_objid, "Number of Retransmissions", &max_retrans);
	
	/* Convert the power threshold (receiver sensitivity) value from dBm to	*/
	/* Watts.																*/
	op_ima_obj_attr_get (self_id, "Packet Reception-Power Threshold", &rx_power_threshold_dbm);
	
	/* Convert the power threshold (receiver sensitivity) value from dBm to	*/
	/* Watts.																*/
	modmem_ptr = (WPAN_Modmem_Info*) op_prg_cmo_alloc (wpan_cmo_handle,sizeof (WPAN_Modmem_Info));
	modmem_ptr->rx_power_threshold = pow (10.0, rx_power_threshold_dbm / 10.0) / 1000.0;
	modmem_ptr->retry_csma_trans_pkptr = OPC_NIL;
	op_pro_modmem_install (modmem_ptr);
	
	/* Get the channel band for this device and populate 		*/
	/* the channel info structures for the applicable channels 	*/
	wpan_mac_initialize_channels (parent_id, data_rate); 
	
	wpan_mac_register_stats ();
	
	/* Create the process handling CSMA-CA 	*/
	csma_ca_prohandle = op_pro_create ("csma_ca", OPC_NIL);
	csma_ca_process_busy = OPC_FALSE;
	
	/* Affliated with a PAN? 	*/
	joined = OPC_FALSE;
	
	FOUT;
	}
	

void
wpan_mac_register_stats ()
	{
	int index = 0;
	
	/** This function register both local and global statistics associated with this MAC */
	
	FIN (wpan_mac_register_stats ());
		
	/* Register global statistics */
	gbl_thput_bps_stathandle = 			op_stat_reg ("ZigBee 802_15_4 MAC.Throughput (bits/sec)", 									OPC_STAT_INDEX_NONE, 	OPC_STAT_GLOBAL);
	gbl_num_retrans_stathandle = 		op_stat_reg ("ZigBee 802_15_4 MAC.Retransmission Attempts (packets)",						OPC_STAT_INDEX_NONE, 	OPC_STAT_GLOBAL);	
	gbl_data_dropped_stathandle = 		op_stat_reg ("ZigBee 802_15_4 MAC.Data Dropped (Retry Threshold Exceeded) (bits/sec)", 		OPC_STAT_INDEX_NONE, 	OPC_STAT_GLOBAL);
	gbl_data_rcvd_stathandle = 			op_stat_reg ("ZigBee 802_15_4 MAC.Data Traffic Rcvd (bits/sec)", 							OPC_STAT_INDEX_NONE, 	OPC_STAT_GLOBAL);
	gbl_mgmt_data_rcvd_stathandle = 	op_stat_reg ("ZigBee 802_15_4 MAC.Management Traffic Rcvd (bits/sec)", 						OPC_STAT_INDEX_NONE, 	OPC_STAT_GLOBAL);
	gbl_control_data_rcvd_stathandle = 	op_stat_reg ("ZigBee 802_15_4 MAC.Control Traffic Rcvd (bits/sec)", 						OPC_STAT_INDEX_NONE, 	OPC_STAT_GLOBAL);
	gbl_e2e_stathandle = 				op_stat_reg ("ZigBee 802_15_4 MAC.Delay (sec)", 											OPC_STAT_INDEX_NONE, 	OPC_STAT_GLOBAL);
	gbl_load_stathandle = 				op_stat_reg ("ZigBee 802_15_4 MAC.Load (bits/sec)", 										OPC_STAT_INDEX_NONE, 	OPC_STAT_GLOBAL);
	gbl_control_data_sent_stathandle = 	op_stat_reg ("ZigBee 802_15_4 MAC.Control Traffic Sent (bits/sec)", 						OPC_STAT_INDEX_NONE, 	OPC_STAT_GLOBAL);
	gbl_mgmt_data_sent_stathandle = 	op_stat_reg ("ZigBee 802_15_4 MAC.Management Traffic Sent (bits/sec)", 						OPC_STAT_INDEX_NONE, 	OPC_STAT_GLOBAL);
	
	op_stat_dim_size_get("ZigBee 802_15_4 MAC.Load per PAN (bits/sec)", OPC_STAT_GLOBAL, &stat_dim_size);
	for (index = 0; index < stat_dim_size; index++)
		{
		gbl_load_dim_stathandle [index] = *((Stathandle*) op_prg_cmo_alloc (wpan_cmo_handle, sizeof (Stathandle)));
		pan_stat_handle_array [index]  = -1;
		}
	
	
	/* Register local statistics */
	thput_bps_stathandle = 				op_stat_reg ("ZigBee 802_15_4 MAC.Throughput (bits/sec)", 									OPC_STAT_INDEX_NONE, 	OPC_STAT_LOCAL);
	num_retrans_stathandle = 			op_stat_reg ("ZigBee 802_15_4 MAC.Retransmission Attempts (packets)", 						OPC_STAT_INDEX_NONE, 	OPC_STAT_LOCAL);
	data_dropped_stathandle = 			op_stat_reg ("ZigBee 802_15_4 MAC.Data Dropped (Retry Threshold Exceeded) (bits/sec)", 		OPC_STAT_INDEX_NONE, 	OPC_STAT_LOCAL);
	data_rcvd_stathandle = 				op_stat_reg ("ZigBee 802_15_4 MAC.Data Traffic Rcvd (bits/sec)", 							OPC_STAT_INDEX_NONE, 	OPC_STAT_LOCAL);
	mgmt_data_rcvd_stathandle =  		op_stat_reg ("ZigBee 802_15_4 MAC.Management Traffic Rcvd (bits/sec)", 						OPC_STAT_INDEX_NONE, 	OPC_STAT_LOCAL);
	control_data_rcvd_stathandle =  	op_stat_reg ("ZigBee 802_15_4 MAC.Control Traffic Rcvd (bits/sec)", 						OPC_STAT_INDEX_NONE, 	OPC_STAT_LOCAL);
	load_stathandle = 					op_stat_reg ("ZigBee 802_15_4 MAC.Load (bits/sec)", 										OPC_STAT_INDEX_NONE, 	OPC_STAT_LOCAL);
	e2e_stathandle = 					op_stat_reg ("ZigBee 802_15_4 MAC.Delay (sec)", 											OPC_STAT_INDEX_NONE, 	OPC_STAT_LOCAL);
	mgmt_data_sent_stathandle = 		op_stat_reg ("ZigBee 802_15_4 MAC.Management Traffic Sent (bits/sec)", 						OPC_STAT_INDEX_NONE, 	OPC_STAT_LOCAL);
	control_data_sent_stathandle = 		op_stat_reg ("ZigBee 802_15_4 MAC.Control Traffic Sent (bits/sec)", 						OPC_STAT_INDEX_NONE, 	OPC_STAT_LOCAL);
	q_size_stathandle = 				op_stat_reg ("ZigBee 802_15_4 MAC.Queue Size (packets)", 									OPC_STAT_INDEX_NONE, 	OPC_STAT_LOCAL);
	qdelay_stathandle = 				op_stat_reg ("ZigBee 802_15_4 MAC.Queuing Delay (sec)", 									OPC_STAT_INDEX_NONE, 	OPC_STAT_LOCAL);

	FOUT;
	}

void 
wpan_mac_drop_pk ()
	{
	Packet *pk, * encap_pk;
	Stathandle_Bundle * stat_bun_ptr;
	
	/** Destroy the packet and write the Application Data Dropped statisitics. **/
	
	FIN (wpan_mac_drop_pk ());

	pk = op_pk_get (op_intrpt_strm ());
	
	if (wpan_network_pk_is_app_data (pk))
		{
		op_pk_fd_get_pkt (pk, payload_index, &encap_pk);
		op_pk_fd_get_ptr (encap_pk, stathandles_index, (void *) &stat_bun_ptr);
		
		/* Write to application layer packets dropped stathandle. */
		op_stat_write (*(stat_bun_ptr->sh1), 1.0);
		
		/* Free the statbundle.	*/
		op_prg_cmo_dealloc  (stat_bun_ptr);
		}
	
	op_pk_destroy (pk);
	
	FOUT;
	}
	


void
wpan_mac_record_beacon ()
	{
	Packet *pk;
	Neighbor_Entry * entry_ptr;
	char format_name[100];
	int temp = 0, temp2 = 0, i;
	double temp_dbl = 0.0;
	char message_str [255];
	double pk_size = 0.0;

	/** This function store the information in the incoming beacon to be later sent to the Network layer **/	
	
	FIN (wpan_mac_record_beacon ());
		
	pk = op_pk_get (op_intrpt_strm ());
	op_pk_format (pk, format_name);
	
	pk_size = (double) op_pk_total_size_get (pk);
	wpan_mac_mgmt_rcvd_stats_update (pk_size);
	
	/* Check packet type. */
	if (strcmp (format_name, "zigbee_beacon") == 0)
		{		
		op_pk_fd_get_int32 (pk, WPANC_BEACON_PAN_ID_FIELD_INDEX, &temp);
		op_pk_fd_get_int32 (pk, WPANC_BEACON_SRC_ADDR_FIELD_INDEX, &temp2);
		
		for (i = 0; i < op_prg_list_size (beacon_scan_list); i++)
			{
			entry_ptr = (Neighbor_Entry *) op_prg_list_access (beacon_scan_list, i);
			if (entry_ptr->pan_id == temp && entry_ptr->source_address == temp2)
				{
				op_pk_destroy (pk);
				FOUT;
				}
			}
		
		/* Store the beacon information in a list */
		entry_ptr = (Neighbor_Entry *) op_prg_cmo_alloc (wpan_cmo_handle,sizeof (Neighbor_Entry));

		op_pk_fd_get_int32 (pk, WPANC_BEACON_PAN_ID_FIELD_INDEX, &temp);
		entry_ptr->pan_id = temp;

		op_pk_fd_get_int32 (pk, WPANC_BEACON_SRC_ADDR_FIELD_INDEX, &temp);
		entry_ptr->source_address = temp;  	   

		op_pk_fd_get_int32 (pk, WPANC_BEACON_RTR_CAP_FIELD_INDEX, &temp);
		entry_ptr->router_capacity = temp; 	   	

		op_pk_fd_get_int32 (pk, WPANC_BEACON_END_DEVICE_CAP_FIELD_INDEX, &temp);
		entry_ptr->end_device_capacity = temp; 	

		op_pk_fd_get_int32 (pk, WPANC_BEACON_DEPTH_FIELD_INDEX, &temp);
		entry_ptr->depth = temp;

		op_pk_fd_get_dbl (pk, WPANC_BEACON_PARENT_BEACON_OFFSET_FIELD_INDEX, &temp_dbl);
		entry_ptr->parent_beacon_offset = temp_dbl; 

		op_pk_fd_get_int32 (pk, WPANC_BEACON_MAX_CHILDREN_FIELD_INDEX, &temp);
		entry_ptr->max_children = temp;

		op_pk_fd_get_int32 (pk, WPANC_BEACON_MAX_ROUTERS_FIELD_INDEX, &temp);
		entry_ptr->max_routers = temp;	

		op_pk_fd_get_int32 (pk, WPANC_BEACON_MAX_DEPTH_FIELD_INDEX, &temp);
		entry_ptr->max_depth = temp;		

		op_pk_fd_get_int32 (pk, WPANC_BEACON_BEACON_ORDER_FIELD_INDEX, &temp);
		entry_ptr->beacon_order = temp;			

		op_pk_fd_get_int32 (pk, WPANC_BEACON_SUPERFRAME_ORDER_FIELD_INDEX, &temp);
		entry_ptr->superframe_order = temp;	

		entry_ptr->potential_parent	= OPC_TRUE;
		entry_ptr->channel 			= channel_number;
		entry_ptr->time_received    = op_sim_time();
		
		op_prg_list_insert (beacon_scan_list, entry_ptr, OPC_LISTPOS_TAIL);
			
		if (op_prg_odb_ltrace_active ("wpan_mac") || op_prg_odb_ltrace_active ("wpan_mac_join"))
			{
			sprintf (message_str, "Recorded a beacon.\n"); 
			op_prg_odb_print_major (message_str, OPC_NIL, OPC_NIL, OPC_NIL);
			}			
		}
	
	op_pk_destroy (pk);
	
	FOUT;
	}

void
wpan_mac_handle_wireless_pk ()
	{
		
	Packet	 	*pk;
	char 		format_name [100];
	int 		pk_pan_id;
	int 		pk_next_hop;
	int 		pk_source_addr;
	char		message_str [255];
	int  		pk_seq_number;
	double 		pk_size;
	WPAN_Transmission_Info* trans_info_ptr;
	
	/** This function handles all the packets recieved from the lower layers in the joined state. **/
	
	FIN (wpan_mac_handle_wireless_pk ());
	
	pk = op_pk_get (op_intrpt_strm ());	
	pk_size = (double) op_pk_total_size_get (pk);
	
	/* If packet is node's own transmission then drop the packet. */
	if (op_pk_stamp_mod_get (pk) == self_id)
		{
		op_pk_destroy (pk);
		FOUT;
		}	
	
	/* Handle the packet based on its type.	*/
	op_pk_format (pk, format_name);
	
	if (strcmp (format_name, "zigbee_beacon") == 0)
		{
		op_pk_fd_get_int32 (pk, WPANC_BEACON_PAN_ID_FIELD_INDEX, &pk_pan_id);
		op_pk_fd_get_int32 (pk, WPANC_BEACON_SRC_ADDR_FIELD_INDEX, &pk_source_addr);
		
		wpan_mac_mgmt_rcvd_stats_update (pk_size);
		
		op_pk_destroy (pk);
		}
	else if (strcmp (format_name, "zigbee_beacon_request") == 0)
		{
		
		wpan_mac_mgmt_rcvd_stats_update (pk_size);
		
		/* If it's a beacon request, send it up if we're joined. */
		if (my_pan_id != -1)
			{		
			op_pk_send (pk, NWK_STRM);
			
			if (op_prg_odb_ltrace_active ("wpan_mac") || op_prg_odb_ltrace_active ("wpan_mac_join") || op_prg_odb_ltrace_active ("wpan_mac_br"))
				{
				sprintf (message_str, "Recieved beacon request, sending it to the upper layer to generate a beacon.\n"); 
				op_prg_odb_print_major (message_str, OPC_NIL, OPC_NIL, OPC_NIL);
				}			
			}
		else
			op_pk_destroy (pk);
		}
	else if (strcmp (format_name, "zigbee_ack") == 0)
		{
		/* Retrieve relevant information from the packet.	*/
		op_pk_fd_get (pk, WPANC_ACK_PAN_ID_FIELD_INDEX, &pk_pan_id);
		op_pk_fd_get (pk, WPANC_ACK_NEXT_HOP_ADDR_FIELD_INDEX, &pk_next_hop);
		op_pk_fd_get (pk, WPANC_ACK_SEQ_NUM_FIELD_INDEX, &pk_seq_number);
		
		/* Update recieved stats */
		wpan_mac_control_rcvd_stats_update (pk_size);
		
		/* Process this ACK message only if it is destined for this node. */
		if ((pk_pan_id == my_pan_id && pk_next_hop == my_network_address))
			{
			/* Retrieve the hash table entry and free its memory. */
			trans_info_ptr = (WPAN_Transmission_Info*) prg_bin_hash_table_item_remove (ack_outstanding_htable_ptr, &pk_seq_number);
						
			if (trans_info_ptr)
				{
				wpan_trans_info_free (trans_info_ptr);
									
				if (op_prg_odb_ltrace_active ("wpan_mac") || op_prg_odb_ltrace_active ("wpan_mac_ack_retrans"))
					{
					sprintf (message_str, "Recieved an ACK for sequence number %d at %d.\n", pk_seq_number, my_network_address);
					op_prg_odb_print_major (message_str, OPC_NIL, OPC_NIL, OPC_NIL);
					}
				}
			else
				{
				if (op_prg_odb_ltrace_active ("wpan_mac") || op_prg_odb_ltrace_active ("wpan_mac_ack_retrans"))
					{
					sprintf (message_str, "Duplicate ACK for sequence number %d recieved at %d.\n", pk_seq_number, my_network_address);
					op_prg_odb_print_major (message_str, OPC_NIL, OPC_NIL, OPC_NIL);
					}
				}
			}				
		
		/* Destroy the original ACK packet. */
		op_pk_destroy (pk);
		}
	else
		{
		/* This is a data packet. */
		op_pk_fd_get_int32 (pk, pan_id_index, &pk_pan_id);
		op_pk_fd_get_int32 (pk, next_hop_address_index, &pk_next_hop);
		
		/* Update recieved stats */
		wpan_mac_rcvd_stats_update (pk_size);
		
		/* Process the packet only if it is destined for this node or is a broadcast packet. */		
		if ((pk_pan_id == my_pan_id && pk_next_hop == my_network_address) ||
			(my_pan_id == -1 && pk_next_hop == my_network_address)		  ||
			(pk_pan_id == my_pan_id && pk_next_hop == BROADCAST_CODE_ALL) ||
			(pk_pan_id == my_pan_id && pk_next_hop == BROADCAST_CODE_RC))
			{
			if (op_prg_odb_ltrace_active ("wpan_mac"))
				{
				sprintf (message_str, "Received a packet from the wireless medium, sending it upto the network layer.\n"); 
				op_prg_odb_print_major (message_str, OPC_NIL, OPC_NIL, OPC_NIL);
				}
			
			/* Reduce the packet size of the physical layer overhead */
			pk_size = op_pk_total_size_get (pk) - WPAN_MAC_DATA_OVERHEAD; 		
			op_pk_total_size_set (pk, (OpT_Packet_Size) pk_size);
			
			/* Update the throughput and delay statistics. */
			wpan_mac_thput_and_e2e_stats_update (pk);
			
			/* Send an ACK if the sender has requested fot it.	*/
			if (op_pk_fd_is_set (pk, WPANC_MAC_ACK_FIELD_INDEX) == OPC_TRUE)
				wpan_mac_send_ack (pk);
				

			/* Strip the packet of the fields that have local significance and may affect */
			/* the MAC behavior once the packet is resent to this MAC by the upper layer  */
			wpan_mac_fields_strip (pk);
			
			/* Send the packet to network layer */
			op_pk_send (pk, NWK_STRM);
			}
		else
			{
			op_pk_destroy (pk);
			}
		}
	
	FOUT;
	}


void 
wpan_mac_send_beacon ()
	{
		
	Packet *pk;
	Beacon_Format * beacon_contents;
	char message_str [255];
	int pk_size;
	
	/** This function will broadcast a beacon based on the information recieved from the network layer. **/
	
	FIN (wpan_mac_send_beacon ());

	/* Get the information sent by the network layer and create an beacon packet appropriately. */	
	beacon_contents = (Beacon_Format *) op_intrpt_state_ptr_get ();
	
	pk = op_pk_create_fmt ("zigbee_beacon");
	
	op_pk_fd_set_int32 	(pk, WPANC_BEACON_PAN_ID_FIELD_INDEX, 				beacon_contents->pan_id, 				OPC_FIELD_SIZE_UNCHANGED);
	op_pk_fd_set_int32 	(pk, WPANC_BEACON_SRC_ADDR_FIELD_INDEX, 			beacon_contents->source_address, 		OPC_FIELD_SIZE_UNCHANGED);
	op_pk_fd_set_int32 	(pk, WPANC_BEACON_RTR_CAP_FIELD_INDEX, 				beacon_contents->router_capacity, 		OPC_FIELD_SIZE_UNCHANGED);
	op_pk_fd_set_int32 	(pk, WPANC_BEACON_END_DEVICE_CAP_FIELD_INDEX,		beacon_contents->end_device_capacity, 	OPC_FIELD_SIZE_UNCHANGED);
	op_pk_fd_set_int32 	(pk, WPANC_BEACON_MAX_CHILDREN_FIELD_INDEX, 		beacon_contents->max_children, 			OPC_FIELD_SIZE_UNCHANGED);
	op_pk_fd_set_int32 	(pk, WPANC_BEACON_MAX_ROUTERS_FIELD_INDEX, 			beacon_contents->max_routers, 			OPC_FIELD_SIZE_UNCHANGED);
	op_pk_fd_set_int32 	(pk, WPANC_BEACON_MAX_DEPTH_FIELD_INDEX, 			beacon_contents->max_depth, 			OPC_FIELD_SIZE_UNCHANGED);
	op_pk_fd_set_int32 	(pk, WPANC_BEACON_BEACON_ORDER_FIELD_INDEX, 		beacon_contents->beacon_order, 			OPC_FIELD_SIZE_UNCHANGED);
	op_pk_fd_set_int32 	(pk, WPANC_BEACON_SUPERFRAME_ORDER_FIELD_INDEX, 	beacon_contents->superframe_order, 		OPC_FIELD_SIZE_UNCHANGED);
	op_pk_fd_set_dbl   	(pk, WPANC_BEACON_PARENT_BEACON_OFFSET_FIELD_INDEX,	beacon_contents->parent_beacon_offset, 	OPC_FIELD_SIZE_UNCHANGED);
	op_pk_fd_set_int32 	(pk, WPANC_BEACON_DEPTH_FIELD_INDEX,				beacon_contents->depth,					OPC_FIELD_SIZE_UNCHANGED);
	
	/* Free dynamic memory. */
	op_prg_cmo_dealloc (beacon_contents);
	
	if (op_prg_odb_ltrace_active ("wpan_mac") || op_prg_odb_ltrace_active ("wpan_mac_br"))
		{
		sprintf (message_str, "Sending a beacon out on channel %d.\n", my_channel); 
		op_prg_odb_print_major (message_str, OPC_NIL, OPC_NIL, OPC_NIL);
		}
	
	/* Beacon use the longer overhead fields, as per data packets. */
	pk_size = op_pk_total_size_get (pk) + WPAN_MAC_DATA_OVERHEAD;
	op_pk_total_size_set (pk, pk_size);
	
	/* Update the control traffic stats */
	wpan_mac_mgmt_sent_stats_update ((double) op_pk_total_size_get (pk));
	
	/* For coexistence with WLAN model. */
	op_pk_encap_flag_set (pk, OMSC_JAMMER_ENCAP_FLAG_INDEX);
	op_pk_send (pk, WIRELESS_STRM);	

	FOUT;
	}


void 
wpan_mac_handle_nwk_pk ()
	{
	int		pk_next_hop;
	Packet* pkptr;
	double  list_size;
	int* 	channel_ptr;

	/** Handle packets coming from the network layer once the node has successfully completed scanning. **/
	
	FIN (wpan_mac_handle_nwk_pk ());
	
	pkptr = op_pk_get (op_intrpt_strm ());
	op_pk_fd_get_int32 (pkptr, next_hop_address_index, &pk_next_hop);
	
	/* Update the pkt size, store relevant stathandles and stamp the pkt with current time */
	wpan_prepare_mac_pkt_for_tx (pkptr);
	
	if (joined == OPC_FALSE)
		{
		channel_ptr = (int*) op_ev_state (op_ev_current ());
		if (channel_ptr != OPC_NIL)
			wpan_channel_info_set (*channel_ptr, OPC_TRUE);
		else
			op_sim_end ("Unable to retrieve the channel information from the interrupt from Network Layer", "", "", "");
		}
	
	/* Invoke the CSMA-CA process if it is not busy to transmit the incoming packet */
	if (csma_ca_process_busy == OPC_FALSE)
		{
		
		/* If ACK enabled and the packet is not a braodcast packet then store a copy of the packet in the hash table. */
		if (ack_enabled != 0 && (pk_next_hop != BROADCAST_CODE_ALL) && (pk_next_hop != BROADCAST_CODE_RC))
			wpan_tx_info_hash_table_update (pkptr);	
		
		/* Invoke the process and set the busy status. */
		op_pro_invoke (csma_ca_prohandle, pkptr);
		csma_ca_process_busy = OPC_TRUE;
		}
	else
		{
		/* Buffer the packet in the queue and update the queue statistics. */
		op_prg_list_insert (outstanding_pk_lptr, pkptr, OPC_LISTPOS_TAIL);
		list_size = op_prg_list_size (outstanding_pk_lptr);
		op_stat_write (q_size_stathandle, list_size);
		}
	
	FOUT;
	}

void
wpan_tx_info_hash_table_update (Packet* pkptr)
	{
	WPAN_Transmission_Info* trans_ptr;
	
	/* This fuunction updates the hash table for any transmissions that require an ACK back. */
			
	FIN (wpan_tx_info_hash_table_update (Packet* pkptr));
	
	sequence_number++;
		
	/* Set a field requesting an acknowledgement back, sequence number and this node's network address. */
	op_pk_fd_set (pkptr, WPANC_MAC_ACK_FIELD_INDEX, OPC_FIELD_TYPE_INTEGER, 1, 0);
	op_pk_fd_set (pkptr, WPANC_MAC_PHOP_FIELD_INDEX, OPC_FIELD_TYPE_INTEGER, my_network_address, 0);
	op_pk_fd_set (pkptr, WPANC_MAC_SEQ_NUM_FIELD_INDEX, OPC_FIELD_TYPE_INTEGER, sequence_number, 0);
			
	/* Initiate the transmission information structure. */
	trans_ptr = (WPAN_Transmission_Info*) op_prg_cmo_alloc (wpan_cmo_handle,sizeof (WPAN_Transmission_Info));			
	trans_ptr->pkptr = op_pk_copy (pkptr);
	trans_ptr->retrans_count = 0;
	trans_ptr->key_ptr = op_prg_cmo_alloc (wpan_cmo_handle, sizeof (int));
	
	*(trans_ptr->key_ptr) = sequence_number;			
	prg_bin_hash_table_item_insert (ack_outstanding_htable_ptr, trans_ptr->key_ptr, trans_ptr, PRGC_NIL);	
	
	FOUT;
	}

void
wpan_prepare_mac_pkt_for_tx (Packet* pkptr)
	{
	WPAN_MAC_Stathandles_Info* stat_info_ptr;
	OpT_Packet_Size 		pk_size;
	
	/** This function updates the pkt size, store relevant stathandles and stamp the pkt with current time. **/
	
	FIN (wpan_prepare_mac_pkt_for_tx ());
	
	/* Update the load statistics before updating its size. */
	pk_size = op_pk_total_size_get (pkptr);
	wpan_mac_load_stats_update ((double) pk_size);
	
	pk_size = pk_size + WPAN_MAC_DATA_OVERHEAD;
	op_pk_total_size_set (pkptr, pk_size);
			
	/* Store the stathandles that the next hop of this packet will update. */
	stat_info_ptr = (WPAN_MAC_Stathandles_Info*) op_prg_cmo_alloc (wpan_cmo_handle, sizeof (WPAN_MAC_Stathandles_Info));
	stat_info_ptr->senders_e2e_stathandle = &e2e_stathandle;	
 	if (op_pk_fd_set_ptr(pkptr, WPANC_MAC_STATHANDLES_FIELD_INDEX, stat_info_ptr, 0, op_prg_mem_copy_create, op_prg_cmo_dealloc, sizeof (WPAN_MAC_Stathandles_Info)) == OPC_COMPCODE_FAILURE)
		op_sim_end ("Unable to set the stathandle structure field.\n", "", "", "");
	
	/* Stamp the packet for calculating E2E delay at the destination hop. */
	op_pk_stamp (pkptr);

	FOUT;
	}


void
wpan_handle_pkt_transmission_success ()
	{
	int 	key;
	double 	tx_duration;
	double 	pk_size;
	double 	list_size;
	double 	qdelay = 0.0;
	char 	message_str [255];
	Packet* pkptr;
	WPAN_Transmission_Info* trans_info_ptr;
	
	
	/** This function handles the successful transmission by CSMA-CA process: 	**/
	/** 		- Processes the next packet in the queue. 						**/
	/**			- Starts an ACK timer if ACK is enabled.						**/
	
	FIN (wpan_handle_pkt_transmission_success ());
	
	csma_ca_process_busy = OPC_FALSE;
	
	/* Interrrupt code it the sequence number which is the key for the hash table */
	key = op_intrpt_code ();
	
	if (op_prg_odb_ltrace_active ("wpan_mac"))
		{
		sprintf (message_str, "Recieved a notification from CSMA-CA process on successful tx of a packet with sequence number %d.\n", key); 
		op_prg_odb_print_major (message_str, OPC_NIL, OPC_NIL, OPC_NIL);
		}
	
	/* Start the ack timer now if ACKs are enabled for this node. */
	if (ack_enabled != 0)
		{
		trans_info_ptr = (WPAN_Transmission_Info*) prg_bin_hash_table_item_get (ack_outstanding_htable_ptr, (void*) &key);
		
		/* This pointer may be null if we recieved an ACK for the original transmission  */
		/* when the CSMA-CA process was performing a retransmission for it. 			 */
		if (trans_info_ptr)
			{
			pk_size = (double) op_pk_total_size_get (trans_info_ptr->pkptr);
			tx_duration = pk_size/drate_sv;
		
			if (op_pk_fd_is_set (trans_info_ptr->pkptr, WPANC_MAC_ACK_FIELD_INDEX) == OPC_TRUE)
				trans_info_ptr->ack_timer_evhandle = op_intrpt_schedule_self (op_sim_time () + tx_duration + ack_duration, key);
			}
		}
	
		
	/* Check to see if there are any other packets that need to be transmitted. */
	list_size = op_prg_list_size (outstanding_pk_lptr);
	if (list_size > 0.0)
		{
		pkptr = op_prg_list_remove (outstanding_pk_lptr, OPC_LISTPOS_HEAD);
				
		/* Update Queue Size and Queuing Delay statistics */
		op_stat_write (q_size_stathandle, list_size-1);		
		qdelay =  op_sim_time () - op_pk_stamp_time_get (pkptr);
		op_stat_write (qdelay_stathandle, qdelay);		
		
		/* Is this not a retransmission update the hash table, otherwise	*/
		/* table already has a entry in it from the original transmission.  */
		if (ack_enabled != 0)
			{
			if (op_pk_fd_is_set (pkptr, WPANC_MAC_ACK_FIELD_INDEX) == OPC_FALSE)
				{
				wpan_tx_info_hash_table_update (pkptr);
				modmem_ptr->is_retransmission = OPC_FALSE;
				}
			else
				{
				modmem_ptr->is_retransmission = OPC_TRUE;
				}
			}
		
		/* Invoke the process and set the busy status. */
		op_pro_invoke (csma_ca_prohandle, pkptr);
		csma_ca_process_busy = OPC_TRUE;
		}
	
	FOUT;
	}

void
wpan_handle_pkt_transmission_failure ()
	{
	/* This function performs another transmission attempt to send the last failed packet. */
	FIN (wpan_handle_pkt_transmission_failure ());
	
	/* Invoke the process again and set the busy status. */
	op_pro_invoke (csma_ca_prohandle, modmem_ptr->retry_csma_trans_pkptr);
	csma_ca_process_busy = OPC_TRUE;

	FOUT;	
	}


void
wpan_mac_send_ack (Packet* pkptr)
	{
	Packet* ack_pkptr = OPC_NIL;
	int 	pk_pan_id = 0;
	int 	pk_next_hop = 0;
	int 	pk_seq_number = 0;
	char 	message_str1 [255];
	char 	message_str2 [255];
	char	message_str3 [255];
	OpT_Packet_Size pk_size;
	
	/** This function sends an ACK back to the sender of the original transmission (argument). **/
	
	FIN (wpan_mac_send_ack (Packet* pkptr));
	
	ack_pkptr = op_pk_create_fmt ("zigbee_ack");
	
	/* Using information on the original pkptr set the PAN ID and the network address on the ACK. */
	op_pk_fd_get_int32 (pkptr, pan_id_index, &pk_pan_id);
	op_pk_fd_get (pkptr, WPANC_MAC_PHOP_FIELD_INDEX, &pk_next_hop);
	op_pk_fd_get (pkptr, WPANC_MAC_SEQ_NUM_FIELD_INDEX, &pk_seq_number);
	
	op_pk_fd_set (ack_pkptr, WPANC_ACK_PAN_ID_FIELD_INDEX, OPC_FIELD_TYPE_INTEGER, pk_pan_id, 0);
	op_pk_fd_set (ack_pkptr, WPANC_ACK_NEXT_HOP_ADDR_FIELD_INDEX, OPC_FIELD_TYPE_INTEGER, pk_next_hop, 0);
	op_pk_fd_set (ack_pkptr, WPANC_ACK_SEQ_NUM_FIELD_INDEX, OPC_FIELD_TYPE_INTEGER, pk_seq_number, 0);
	
	pk_size = op_pk_total_size_get (ack_pkptr) + WPAN_MAC_ACK_OVERHEAD;
	op_pk_total_size_set (ack_pkptr, pk_size);
	
	/* For coexistence with WLAN model. */
	op_pk_encap_flag_set (ack_pkptr, OMSC_JAMMER_ENCAP_FLAG_INDEX);
	op_pk_send (ack_pkptr, WIRELESS_STRM);
	
	wpan_mac_control_sent_stats_update ((double) pk_size);	
	
	if (op_prg_odb_ltrace_active ("wpan_mac") || op_prg_odb_ltrace_active ("wpan_mac_ack_retrans"))
		{
		sprintf (message_str1, "Sending an ACK from MAC module (ID %d) with network address %d for data with sequence number %d.\n", self_id, my_network_address, pk_seq_number);
		sprintf (message_str2, "\tACK Sent from: %d\n", my_network_address);
		sprintf (message_str3, "\tACK Sent to: %d\n", pk_next_hop);
		op_prg_odb_print_major (message_str1, message_str2, message_str3, OPC_NIL);
		}
		
	FOUT;
	}

void
wpan_mac_fields_strip (Packet* pkptr)
	{
	
	/* This function strips the packet of the MAC specific fields before sending it to the network layer.	*/
	FIN (wpan_mac_fields_strip (Packet pkptr));
	
	if (op_pk_fd_is_set (pkptr, WPANC_MAC_ACK_FIELD_INDEX) == OPC_TRUE)
		op_pk_fd_strip (pkptr, WPANC_MAC_ACK_FIELD_INDEX);
	
	if (op_pk_fd_is_set (pkptr, WPANC_MAC_PHOP_FIELD_INDEX) == OPC_TRUE)
		op_pk_fd_strip (pkptr, WPANC_MAC_PHOP_FIELD_INDEX);
	
	if (op_pk_fd_is_set (pkptr, WPANC_MAC_SEQ_NUM_FIELD_INDEX) == OPC_TRUE)
		op_pk_fd_strip (pkptr, WPANC_MAC_SEQ_NUM_FIELD_INDEX);
	
	if (op_pk_fd_is_set (pkptr, WPANC_MAC_STATHANDLES_FIELD_INDEX) == OPC_TRUE)
		op_pk_fd_strip (pkptr, WPANC_MAC_STATHANDLES_FIELD_INDEX);
	
	FOUT;
	}


void
wpan_mac_retransmit ()
	{
	char 	message_str [255];
	int*  	pk_next_hop;
	Packet* retrans_pkptr;
	int 	key;
	WPAN_Transmission_Info* trans_info_ptr;
	double 	list_size;
	
	/* This function retransmits the unacknowledged packet. */
	FIN (wpan_mac_retransmit ());
	
	/* Get the interrupt code and associated transmission info from the hash table. */
	key = op_intrpt_code ();
	trans_info_ptr = (WPAN_Transmission_Info*) prg_bin_hash_table_item_get (ack_outstanding_htable_ptr, (void*) &key);
	
	if (trans_info_ptr->retrans_count >= max_retrans)
		{
		/* Inform the network layer about the failure to trasmit the packet 						*/
		/* For the data packet and the join additional information is sent to the network layer. 	*/
		if (wpan_network_pk_is_app_data (trans_info_ptr->pkptr))
			{
			pk_next_hop = (int*) op_prg_cmo_alloc (wpan_cmo_handle,sizeof (int));
			op_pk_fd_get_int32 (trans_info_ptr->pkptr, next_hop_address_index, pk_next_hop);
			op_ev_state_install (pk_next_hop, OPC_NIL);
			op_intrpt_schedule_remote (op_sim_time (), WPANC_NWK_FAILURE_CODE, nwk_id);
			op_ev_state_install (OPC_NIL, OPC_NIL);
			}
		else if (wpan_network_pk_is_join_response (trans_info_ptr->pkptr))
			{
			pk_next_hop = (int*) op_prg_cmo_alloc (wpan_cmo_handle,sizeof (int));
			op_pk_fd_get_int32 (trans_info_ptr->pkptr, next_hop_address_index, pk_next_hop);
			op_ev_state_install (pk_next_hop, OPC_NIL);
			op_intrpt_schedule_remote (op_sim_time (), WPANC_NWK_JOIN_RESP_FAILURE_CODE, nwk_id);
			op_ev_state_install (OPC_NIL, OPC_NIL);			
			}
			
		/* Update the MAC dropped stats.	*/
		op_stat_write (gbl_data_dropped_stathandle, op_pk_total_size_get (trans_info_ptr->pkptr));
		op_stat_write (gbl_data_dropped_stathandle, 0.0);
		op_stat_write (data_dropped_stathandle, op_pk_total_size_get (trans_info_ptr->pkptr));
		op_stat_write (data_dropped_stathandle, 0.0);
		
		/* Remove the entry from the hash table. */
		trans_info_ptr = (WPAN_Transmission_Info*) prg_bin_hash_table_item_remove (ack_outstanding_htable_ptr, (void*) &key);
		wpan_trans_info_free (trans_info_ptr);
		
		if (op_prg_odb_ltrace_active ("wpan_mac") || op_prg_odb_ltrace_active ("wpan_mac_ack_retrans"))
			{
			sprintf (message_str, "Sending network failure notification to the network layer from MAC module %d.\n", self_id);
			op_prg_odb_print_major (message_str, OPC_NIL, OPC_NIL, OPC_NIL);
			}
		}
	else
		{
		trans_info_ptr->retrans_count++;
				
		op_stat_write (gbl_num_retrans_stathandle, 1.0);
		op_stat_write (gbl_num_retrans_stathandle, 0.0);
		op_stat_write (num_retrans_stathandle, 1.0);
		op_stat_write (num_retrans_stathandle, 0.0);
		
		retrans_pkptr = op_pk_copy (trans_info_ptr->pkptr);
		
		/* Add this packet to the top of the outstanding packets if the CSMA process is busy.	*/
		/* Otherwise invoke the process to transmit it.										 	*/
		if (csma_ca_process_busy == OPC_TRUE)
			{
			op_prg_list_insert (outstanding_pk_lptr, retrans_pkptr, OPC_LISTPOS_HEAD);
			
			list_size = op_prg_list_size (outstanding_pk_lptr);
			op_stat_write (q_size_stathandle, list_size);
			
			if (op_prg_odb_ltrace_active ("wpan_mac") || op_prg_odb_ltrace_active ("wpan_mac_ack_retrans"))
				{
				sprintf (message_str, "Scheduling retransmission (number %d) for packet with sequence number %d.\n", trans_info_ptr->retrans_count, key);
				op_prg_odb_print_major (message_str, OPC_NIL, OPC_NIL, OPC_NIL);
				}
			}
		else
			{
			if (op_prg_odb_ltrace_active ("wpan_mac") || op_prg_odb_ltrace_active ("wpan_mac_ack_retrans"))
				{
				sprintf (message_str, "Sending retransmission (number %d) for packet with sequence number %d.\n", trans_info_ptr->retrans_count, key);
				op_prg_odb_print_major (message_str, OPC_NIL, OPC_NIL, OPC_NIL);
				}
			
			/* Invoke the process and set the busy status. */
			modmem_ptr->is_retransmission = OPC_TRUE;
			csma_ca_process_busy = OPC_TRUE;
			op_pro_invoke (csma_ca_prohandle, retrans_pkptr);
			}
		
		}
	
	FOUT;
	}

void
wpan_mac_set_vars ()
	{
	Address_Info *addr_info_ptr;
	char message_str [255];
	int	index;

	/** Set address, channel, etc. based on command from NWK. **/
	FIN (wpan_mac_set_vars ());
	
	addr_info_ptr = (Address_Info *) op_intrpt_state_ptr_get ();
	
	my_pan_id 			= addr_info_ptr->pan_id;
	my_network_address 	= addr_info_ptr->network_address;
	my_parent_address 	= addr_info_ptr->parent_address;
	my_channel 			= addr_info_ptr->channel;
	my_beacon_order     = addr_info_ptr->beacon_order;
	my_superframe_order = addr_info_ptr->superframe_order;
	op_prg_cmo_dealloc (addr_info_ptr);
		
	if (op_prg_odb_ltrace_active ("wpan_mac") || op_prg_odb_ltrace_active ("wpan_mac_join"))
		{
		sprintf (message_str, "Joining the network with ID %d on channel %d.\n", my_pan_id, my_channel);
		op_prg_odb_print_minor (message_str, OPC_NIL, OPC_NIL, OPC_NIL);
		}

	/* Update the PAN ID to index mapping array */
	index = wpan_mac_stathandle_index_get (my_pan_id);
		
	if (index == -1)
		{
		pan_stat_handle_array [stat_dim_index] = my_pan_id;
		stat_dim_index++;
		}

	/* Set the channel attributes for the transmitter and the receiver. */
	wpan_channel_info_set (my_channel);
	joined = OPC_TRUE;
	
	FOUT;
	}


void
wpan_mac_unset_vars ()
	{
	char message_str [255];
	int  num_pkts_outstanding = 0;
	Packet* pkptr;
	int  index = 0;

	/** Unset address, channel, etc. based on command from NWK. **/
	FIN (wpan_mac_unset_vars ());
	
	if (op_prg_odb_ltrace_active ("wpan_mac") || op_prg_odb_ltrace_active ("wpan_mac_join"))
		{
		sprintf (message_str, "Leaving the network with ID %d on channel %d.\n", my_pan_id, my_channel);
		op_prg_odb_print_minor (message_str, OPC_NIL, OPC_NIL, OPC_NIL);
		}
	
	/* Destroy any outstanding packets in the buffer. */
	num_pkts_outstanding = op_prg_list_size (outstanding_pk_lptr);
	while (index < num_pkts_outstanding)
		{
		pkptr = op_prg_list_remove (outstanding_pk_lptr, OPC_LISTPOS_TAIL);
		
		/* Update the MAC dropped stats.	*/
		op_stat_write (gbl_data_dropped_stathandle, op_pk_total_size_get (pkptr));
		op_stat_write (gbl_data_dropped_stathandle, 0.0);
		op_stat_write (data_dropped_stathandle, op_pk_total_size_get (pkptr));
		op_stat_write (data_dropped_stathandle, 0.0);
		
		op_pk_destroy (pkptr);
		index ++;
		}
	
	op_stat_write (q_size_stathandle, 0.0);	
	
	/* Clear the hash table of the transmissions that are awaiting ACKs. */
	if (ack_outstanding_htable_ptr)
		{
		prg_bin_hash_table_destroy (ack_outstanding_htable_ptr, wpan_trans_info_free);
		ack_outstanding_htable_ptr = OPC_NIL;
		}
	
	my_pan_id 			= -1;
	my_network_address 	= -1;
	my_parent_address 	= -1;
	my_channel 			= -1;
	my_beacon_order     = -1;
	my_superframe_order = -1;
	
	/* Invoke the CSMA-CA process to abort any ongoing transmission. */
	op_pro_invoke (csma_ca_prohandle, OPC_NIL);
	csma_ca_process_busy = OPC_FALSE;
	
	joined = OPC_FALSE;
	
	FOUT;
	}


void
wpan_start_scan ()
	{
	int *temp_net_addr;
	char message_str [255];
	
	/* This function handles the start scan command from the network layer. */
	FIN (wpan_start_scan ());
	
	temp_net_addr = (int *) op_intrpt_state_ptr_get ();
	my_network_address = *temp_net_addr;
	
	/* Reset the channel_index and beacon list from any prior scan. */
	channel_index = 0;	
	
	if (beacon_scan_list != OPC_NIL)		
		op_prg_list_free (beacon_scan_list);
	else
		beacon_scan_list = op_prg_list_create ();	
	
	if (op_prg_odb_ltrace_active ("wpan_mac") || op_prg_odb_ltrace_active ("wpan_mac_join"))
		{
		sprintf (message_str, "Starting the scan.\n"); 
		op_prg_odb_print_major (message_str, OPC_NIL, OPC_NIL, OPC_NIL);
		}
		
	wpan_perform_scan ();
	
	FOUT;
	}


void
wpan_perform_scan ()
	{
	
	char message_str [255];
	double scan_duration;
	
	/** This function updates the channel information based on the channel that needs to be scanned.	**/
	/** It also calls a function to send a beacon request out and informs the higher layer when all 	**/
	/** the active channels are scanned.																**/
	
	FIN (wpan_perform_scan ());
		
	while ((channel_index == 0 && !band_id_1) ||
		   (channel_index > 0 && channel_index <= 10 && !band_id_2) ||
		   (channel_index > 10 && channel_index <= 26 && !band_id_3))
		{
		channel_index++;
		}
	
	/* All channels have been scanned send the list of recorded beacons to network layer.	*/
	if (channel_index > 26)
		{
		op_ev_state_install (beacon_scan_list, OPC_NIL);
		if (op_prg_odb_ltrace_active ("wpan_mac") || op_prg_odb_ltrace_active ("wpan_mac_join"))
			{
			sprintf (message_str, "Sending the beacon list to the higher layer with %d beacons.\n", op_prg_list_size (beacon_scan_list)); 
			op_prg_odb_print_major (message_str, OPC_NIL, OPC_NIL, OPC_NIL);
			}
		op_intrpt_schedule_remote (op_sim_time (), 2, nwk_id);
		op_ev_state_install (OPC_NIL, OPC_NIL);	
		
		/* Move out of scanning state using the beacon_scan_list size.	*/
		op_intrpt_schedule_self (op_sim_time (), WPANC_SCAN_DONE_CODE);

		FOUT;		
		}
	
	if (op_prg_odb_ltrace_active ("wpan_mac"))
		{
		sprintf (message_str, "Starting the scan for channel number %d in the active band.\n", channel_index); 
		op_prg_odb_print_major (message_str, OPC_NIL, OPC_NIL, OPC_NIL);
		}
	
	/* Set the channel info on the physical layer based on the channel that needs to be scanned.	*/
	wpan_channel_info_set (channel_index);
	
	/* Send the beacon request out and wait for the channel sensing duration to record beacons.		*/
	wpan_mac_beacon_request_send ();
	
	/* Increment the channel index for the next channel to be scanned 	*/
	/* and schedule a self interrupt for the same. 						*/
	channel_index++;
	
	if (channel_sensing_duration == -1)
		{
		scan_duration = .05											/* maximum wait for beacon tx  */
					  + ((0.0 +  WPAN_MAC_ACK_OVERHEAD)  / drate_sv)	/* tx delay for beacon request */
					  +	((88.0 + WPAN_MAC_DATA_OVERHEAD) / drate_sv)	/* tx delay for beacon		   */
					  + (2 * 1000.0 / PROP_VELOCITY);					/* prop delay for both	       */
		}
	else
		{
		scan_duration = channel_sensing_duration;
		}
		
	op_intrpt_schedule_self (op_sim_time () + scan_duration, WPANC_PROGRESS_SCAN_CODE);	
	
	FOUT;
	}


void
wpan_mac_beacon_request_send ()
	{
	Packet* pk;
	char message_str [255];
	int pk_size;
	
	/** This function just creates a beacon request and sends it out. **/
	
	FIN (wpan_mac_beacon_request_send ());
	
	pk = op_pk_create_fmt ("zigbee_beacon_request");
	
	op_pk_fd_set_int32 (pk, WPANC_BEACON_REQUEST_BAND_868_FIELD_INDEX,  band_id_1,	OPC_FIELD_SIZE_UNCHANGED);
	op_pk_fd_set_int32 (pk, WPANC_BEACON_REQUEST_BAND_915_FIELD_INDEX,  band_id_2,	OPC_FIELD_SIZE_UNCHANGED);
	op_pk_fd_set_int32 (pk, WPANC_BEACON_REQUEST_BAND_2450_FIELD_INDEX, band_id_3,	OPC_FIELD_SIZE_UNCHANGED);
	
	if (op_prg_odb_ltrace_active ("wpan_mac") || op_prg_odb_ltrace_active ("wpan_mac_join") || op_prg_odb_ltrace_active ("wpan_mac_br"))
		{
		sprintf (message_str, "Sending a beacon request message: %d.\n", channel_index); 
		op_prg_odb_print_major (message_str, OPC_NIL, OPC_NIL, OPC_NIL);
		}
	
	/* Beacon requests use the shorter overhead fields, as per ACKs. */
	pk_size = op_pk_total_size_get (pk) + WPAN_MAC_ACK_OVERHEAD;
	op_pk_total_size_set (pk, pk_size);
	
	wpan_mac_mgmt_sent_stats_update ((double) op_pk_total_size_get (pk)); 

	/* For coexistence with WLAN model. */
	op_pk_encap_flag_set (pk, OMSC_JAMMER_ENCAP_FLAG_INDEX);
	op_pk_send (pk, WIRELESS_STRM);
	
	FOUT;
	}

void
wpan_mac_initialize_channels (Objid my_node_id, int data_rate)
	{
	Objid 	trans_bands_id = OPC_OBJID_INVALID;
	Objid 	trans_info_objid = OPC_OBJID_INVALID;
	Objid 	channel_objid = OPC_OBJID_INVALID;
	WPAN_Channel_Info* channel_info_ptr = OPC_NIL;
	int 	index = 0;
	char	message_str [255];
	double  channel_center_frequency = 0.0;
	
	/* Get the channel band for this device and populate the channel information structures for the applicable channels. */	
	
	FIN (wpan_mac_initialize_channels (my_node_id));
	
	/* Store the channel object ids as state variables. */
	rcvr_objid = op_id_from_name (my_node_id, OPC_OBJTYPE_RARX, "wireless_rx"); 
	op_ima_obj_attr_get (rcvr_objid, "channel", &channel_objid);
	rx_channel_info_objid = op_topo_child (channel_objid, OPC_OBJTYPE_RARXCH, 0);
			
	tx_objid = op_id_from_name (my_node_id, OPC_OBJTYPE_RATX, "wireless_tx");
	op_ima_obj_attr_get (tx_objid, "channel", &channel_objid);
	tx_channel_info_objid = op_topo_child (channel_objid, OPC_OBJTYPE_RATXCH, 0);

	/* Set RX power threshold as a reciever state */
	op_ima_obj_state_set (rcvr_objid, &(modmem_ptr->rx_power_threshold));
	
	/* Get channel bands that are enabled. */
	if (op_ima_obj_attr_exists (my_node_id, "Transmission Bands") == OPC_TRUE)
		{
		op_ima_obj_attr_get (my_node_id, "Transmission Bands", &trans_bands_id);
				   
		trans_info_objid = op_topo_child (trans_bands_id, OPC_OBJTYPE_GENERIC, 0);	
		op_ima_obj_attr_get_toggle (trans_info_objid, "2450 MHz Band", &band_id_3);
		op_ima_obj_attr_get_toggle (trans_info_objid, "915 MHz Band", &band_id_2);
		op_ima_obj_attr_get_toggle (trans_info_objid, "868 MHz Band", &band_id_1);
		}
	
	channel_info_lptr = op_prg_list_create ();
	
	/* For each enabled band allocate the memory associated with its channel and populate the channels. */
	/*band_id_1*/
	channel_info_ptr = (WPAN_Channel_Info*) op_prg_cmo_alloc (wpan_cmo_handle, sizeof (WPAN_Channel_Info));
	channel_info_ptr->min_frequency = WPANC_EUROPE_BAND_FREQ - WPANC_BANDWIDTH/2.0;
	if (data_rate == -1)
		channel_info_ptr->drate = WPANC_EUROPE_BAND_DRATE;
	else
		channel_info_ptr->drate = data_rate;
	
	channel_info_ptr->tx_band = WPANC_EUROPE_BAND;
	
	op_prg_list_insert (channel_info_lptr, channel_info_ptr, OPC_LISTPOS_TAIL);
	
	/*band_id_2*/
	for (index = 1; index < 11; index++)
		{
		channel_info_ptr = (WPAN_Channel_Info*) op_prg_cmo_alloc (wpan_cmo_handle, sizeof (WPAN_Channel_Info));
				
		channel_center_frequency = WPANC_NORTHAMERICA_BAND_FREQ + 2*(index-1);
		channel_info_ptr->min_frequency = channel_center_frequency - WPANC_BANDWIDTH/2.0 ;
			
		if (data_rate == -1)
			channel_info_ptr->drate = WPANC_NORTHAMERICA_BAND_DRATE;
		else
			channel_info_ptr->drate = data_rate;
			
		channel_info_ptr->tx_band = WPANC_NORTHAMERICA_BAND;
			
		op_prg_list_insert (channel_info_lptr, channel_info_ptr, OPC_LISTPOS_TAIL);
		}

	
	/*band_id_3*/
	for (index = 11; index < 27; index++)
		{
		channel_info_ptr = (WPAN_Channel_Info*) op_prg_cmo_alloc (wpan_cmo_handle, sizeof (WPAN_Channel_Info));
			
		channel_center_frequency = WPANC_WORLDWIDE_BAND_FREQ + 5*(index-11);
		channel_info_ptr->min_frequency = channel_center_frequency - WPANC_BANDWIDTH/2.0 ;
			
		if (data_rate == -1)
			channel_info_ptr->drate = WPANC_WORLDWIDE_BAND_DRATE;
		else
			channel_info_ptr->drate = data_rate;
			
		channel_info_ptr->tx_band = WPANC_WORLDWIDE_BAND;
			
		op_prg_list_insert (channel_info_lptr, channel_info_ptr, OPC_LISTPOS_TAIL);
		}
	
	if (op_prg_odb_ltrace_active ("wpan_mac"))
		{
		sprintf (message_str, "Number of channels on which if the information is stored %d.\n", op_prg_list_size (channel_info_lptr));
		op_prg_odb_print_minor (message_str, OPC_NIL, OPC_NIL, OPC_NIL);
		}

			   
	FOUT;
	}

void
wpan_channel_info_set (int index)
	{
	
	/* Set the channel information on both transmitter and reciever. */
	
	WPAN_Channel_Info* channel_info_ptr = OPC_NIL;
	
	FIN (wpan_channel_info_set (int index, Boolean index_absolute));
	
	/* If none of the bands are enabled then this function is a no-op */
	if (!(band_id_1 || band_id_2 || band_id_3))
		FOUT;
	
	/* Set the channel attributes using the channel information initialized. */
	channel_info_ptr = (WPAN_Channel_Info*) op_prg_list_access (channel_info_lptr, index);
	
	op_ima_obj_attr_set (rx_channel_info_objid, "data rate", channel_info_ptr->drate);
	op_ima_obj_attr_set (rx_channel_info_objid, "min frequency", channel_info_ptr->min_frequency);
	
	op_ima_obj_attr_set (tx_channel_info_objid, "data rate", channel_info_ptr->drate);
	op_ima_obj_attr_set (tx_channel_info_objid, "min frequency", channel_info_ptr->min_frequency);
	
	/* Also update the module wide memory with appropriate symbol rate. */
	/* Here is how symbol rate is determined:							*/
	/*	- For Worldwide band it is 62500 (per spec)						*/
	/*	- For North American band it is 40000 (per spec)				*/
	/*  - For Eureopean band it is 20000 (per spec)						*/
	/* 	- For all custom data rates it is 0.25*data_rate 				*/
	if (channel_info_ptr->tx_band == WPANC_NORTHAMERICA_BAND || channel_info_ptr->tx_band == WPANC_EUROPE_BAND)
		modmem_ptr->symbol_rate = channel_info_ptr->drate;
	else
		modmem_ptr->symbol_rate = 0.25* (channel_info_ptr->drate);
	
	drate_sv = channel_info_ptr->drate;
	
	/* Set the modulation scheme appropriately 	*/
	if (channel_info_ptr->tx_band == WPANC_WORLDWIDE_BAND)
		{
		op_ima_obj_attr_set (tx_objid, "modulation", "qpsk");
		op_ima_obj_attr_set (rcvr_objid, "modulation", "qpsk");
		}
	else
		{
		/* Set modulation back to bpsk when we're not in 2.4 GHz */
		op_ima_obj_attr_set (tx_objid, "modulation", "bpsk");
		op_ima_obj_attr_set (rcvr_objid, "modulation", "bpsk");
		}
	
	/* Also update the state variable that tracks the current channel number this node is on. */
	channel_number = index;
			
	FOUT;
	}


void
wpan_trans_info_free (void* htable_entry_ptr)
	{
	WPAN_Transmission_Info* trans_info_ptr;
	
	/* Frees up the memory associated with a given hash table entry. */
	FIN (wpan_trans_info_free ());
	
	trans_info_ptr = (WPAN_Transmission_Info*) htable_entry_ptr;
	
	op_pk_destroy (trans_info_ptr->pkptr);
	
	op_prg_cmo_dealloc (trans_info_ptr->key_ptr);

	/* If the ACK event handle is not expired and the current event		*/
	/* is not ACK expiry event cancel the ACK event handle.				*/		
	if (op_ev_valid (trans_info_ptr->ack_timer_evhandle))
		{
		if (op_ev_equal  (op_ev_current (), trans_info_ptr->ack_timer_evhandle) == OPC_FALSE)
			op_ev_cancel (trans_info_ptr->ack_timer_evhandle);
		}
	op_prg_cmo_dealloc (trans_info_ptr);
	
	FOUT;
	}

void
wpan_mac_thput_and_e2e_stats_update (Packet* pkptr)
	{
	double 						pk_size = 0.0;
	double 						delay = 0.0;
	WPAN_MAC_Stathandles_Info* 	sender_stat_info_ptr = OPC_NIL;
	
	/* This function updates the throughput and MAC hop delay statistics. 	*/
	/* For the local statistics it uses the stathandles that are being 		*/
	/* set by the sender MAC.												*/
	
	FIN (wpan_mac_thput_and_e2e_stats_update (Packet* pkptr));
		
	pk_size = (double) op_pk_total_size_get (pkptr);
	op_stat_write (gbl_thput_bps_stathandle, pk_size);
	op_stat_write (gbl_thput_bps_stathandle, 0.0);
	
	op_stat_write (thput_bps_stathandle, pk_size);
	op_stat_write (thput_bps_stathandle, 0.0);
	
	delay = op_sim_time () - op_pk_stamp_time_get (pkptr);
	op_stat_write (gbl_e2e_stathandle, delay);
	op_pk_fd_get_ptr (pkptr, WPANC_MAC_STATHANDLES_FIELD_INDEX, (void *) &sender_stat_info_ptr);
	
	if (sender_stat_info_ptr)
		{
		op_stat_write (*(sender_stat_info_ptr->senders_e2e_stathandle), delay);
		op_prg_cmo_dealloc (sender_stat_info_ptr);
		}
		
	FOUT;	
	}

void
wpan_mac_load_stats_update (double pk_size)
	{
	int 	index;
	char annot_string [8];
	
	/* This function updates both the global and local load statistics. */

	FIN (wpan_mac_load_stats_update (double pk_size));
		
	op_stat_write (gbl_load_stathandle, pk_size);
	op_stat_write (gbl_load_stathandle, 0.0);
	
	/* Update the global statistics per PAN */
	if (my_pan_id != -1)
		{
		index = wpan_mac_stathandle_index_get (my_pan_id);
		
		gbl_load_dim_stathandle [index] = op_stat_reg ("ZigBee 802_15_4 MAC.Load per PAN (bits/sec)", index, OPC_STAT_GLOBAL);
		sprintf (annot_string, "PAN %d", my_pan_id);
		op_stat_annotate (gbl_load_dim_stathandle [index], annot_string);
		
		op_stat_write (gbl_load_dim_stathandle [index], pk_size);
		op_stat_write (gbl_load_dim_stathandle [index], 0.0);
		}
	
	op_stat_write (load_stathandle, pk_size);
	op_stat_write (load_stathandle, 0.0);
		
	FOUT;	
	}



void
wpan_mac_rcvd_stats_update (double pk_size)
	{
	/* This function updates both the global and local data recieved statistics. */

	FIN (wpan_mac_rcvd_stats_update (double pk_size));
	
	op_stat_write (gbl_data_rcvd_stathandle, pk_size);
	op_stat_write (gbl_data_rcvd_stathandle, 0.0);

	op_stat_write (data_rcvd_stathandle, pk_size);
	op_stat_write (data_rcvd_stathandle, 0.0);
	
	FOUT;
	}

void
wpan_mac_mgmt_rcvd_stats_update (double pk_size)
	{

	/* This function updates both the global and local mgmt traffic recieved statistics. */

	FIN (wpan_mac_mgmt_rcvd_stats_update (double pk_size));
	
	op_stat_write (gbl_mgmt_data_rcvd_stathandle, pk_size);
	op_stat_write (gbl_mgmt_data_rcvd_stathandle, 0.0);

	op_stat_write (mgmt_data_rcvd_stathandle, pk_size);
	op_stat_write (mgmt_data_rcvd_stathandle, 0.0);
	
	FOUT;
	}


void
wpan_mac_mgmt_sent_stats_update (double pk_size)
	{
	
	/* This function updates both the global and local mgmt traffic sent statistics. */

	
	FIN (wpan_mac_mgmt_rcvd_stats_update (double pk_size));
	
	op_stat_write (gbl_mgmt_data_sent_stathandle, pk_size);
	op_stat_write (gbl_mgmt_data_sent_stathandle, 0.0);

	op_stat_write (mgmt_data_sent_stathandle, pk_size);
	op_stat_write (mgmt_data_sent_stathandle, 0.0);
	
	FOUT;
	}

void
wpan_mac_control_rcvd_stats_update (double pk_size)
	{

	/* This function updates both the global and local control traffic recieved statistics. */

	FIN (wpan_mac_control_rcvd_stats_update (double pk_size));
	
	op_stat_write (gbl_control_data_rcvd_stathandle, pk_size);
	op_stat_write (gbl_control_data_rcvd_stathandle, 0.0);

	op_stat_write (control_data_rcvd_stathandle, pk_size);
	op_stat_write (control_data_rcvd_stathandle, 0.0);
	
	FOUT;
	}


void
wpan_mac_control_sent_stats_update (double pk_size)
	{
	
	/* This function updates both the global and local control traffic sent statistics. */

	
	FIN (wpan_mac_control_sent_stats_update (double pk_size));
	
	op_stat_write (gbl_control_data_sent_stathandle, pk_size);
	op_stat_write (gbl_control_data_sent_stathandle, 0.0);

	op_stat_write (control_data_sent_stathandle, pk_size);
	op_stat_write (control_data_sent_stathandle, 0.0);
	
	FOUT;
	}

Boolean wpan_network_pk_is_app_data (Packet *pk)
	{
	int pk_type;
	char format_name[100];
	
	/* Performs a check on the network PDU to determine whether it is an Application traffic. */
	FIN (wpan_network_pk_is_app_data (void));
	
	/* Check if the packet is a network pdu. */
	op_pk_format (pk, format_name);
	if (strcmp (format_name, "zigbee_network_pdu") != 0)
		FRET (OPC_FALSE);
	
	/* Check if the packet is application data. */
	op_pk_fd_get_int32 (pk, packet_type_index, &pk_type);
	if (pk_type != 0)
		FRET (OPC_FALSE);
	
	FRET (OPC_TRUE);
	}


Boolean 
wpan_network_pk_is_join_response (Packet *pk)
	{
	int pk_type;
	char format_name[100];
	
	/* Performs a check on the network PDU to determine whether it is an Application traffic. */
	FIN (wpan_network_pk_is_join_response (void));
	
	/* Check if the packet is a network pdu. */
	op_pk_format (pk, format_name);
	if (strcmp (format_name, "zigbee_network_pdu") != 0)
		FRET (OPC_FALSE);
	
	/* Check if the packet is application data. */
	op_pk_fd_get_int32 (pk, packet_type_index, &pk_type);
	if (pk_type != 1)
		FRET (OPC_FALSE);
	
	FRET (OPC_TRUE);
	}

void
wpan_mac_hash_initialize ()
	{
	/* If ACK is enabled create a hash table to store the packets using key as their sequence numbers. */
	
	FIN (wpan_mac_hash_initialize ());
	
	/* This is the old hash table that is not freed up beacuse the node never successfully joined a PAN */
	if (ack_outstanding_htable_ptr)
		prg_bin_hash_table_destroy (ack_outstanding_htable_ptr, wpan_trans_info_free);
	
	if (ack_enabled != 0)
		{
		/* This hash can store upto 256 entries, meaning this is the maximum number 	*/
		/* of packets that can be outstanding waiting for an ACK.					 	*/
		ack_outstanding_htable_ptr =  prg_bin_hash_table_create (8, sizeof (int));	
		}
	
	FOUT;
	}

int
wpan_mac_stathandle_index_get (int curr_pan_id)
	{
	int index;
	int pan_id;

	/* This function determines the index of the global stat handle for a given PAN ID */
	
	FIN (wpan_mac_stathandle_index_get (int curr_pan_id));
	
	for (index = 0; index < stat_dim_size; index ++)
		{
		pan_id = pan_stat_handle_array [index];
		
		if (pan_id == curr_pan_id)
			FRET (index);
		}
	
	FRET (-1);
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
	void _02_15_4_mac (OP_SIM_CONTEXT_ARG_OPT);
	VosT_Obtype _op__02_15_4_mac_init (int * init_block_ptr);
	void _op__02_15_4_mac_diag (OP_SIM_CONTEXT_ARG_OPT);
	void _op__02_15_4_mac_terminate (OP_SIM_CONTEXT_ARG_OPT);
	VosT_Address _op__02_15_4_mac_alloc (VosT_Obtype, int);
	void _op__02_15_4_mac_svar (void *, const char *, void **);


#if defined (__cplusplus)
} /* end of 'extern "C"' */
#endif




/* Process model interrupt handling procedure */


void
_02_15_4_mac (OP_SIM_CONTEXT_ARG_OPT)
	{
#if !defined (VOSD_NO_FIN)
	int _op_block_origin = 0;
#endif
	FIN_MT (_02_15_4_mac ());

		{


		FSM_ENTER ("_02_15_4_mac")

		FSM_BLOCK_SWITCH
			{
			/*---------------------------------------------------------*/
			/** state (init) enter executives **/
			FSM_STATE_ENTER_FORCED_NOLABEL (0, "init", "802_15_4_mac [init enter execs]")
				FSM_PROFILE_SECTION_IN ("802_15_4_mac [init enter execs]", state0_enter_exec)
				{
				wpan_mac_init();
				}
				FSM_PROFILE_SECTION_OUT (state0_enter_exec)

			/** state (init) exit executives **/
			FSM_STATE_EXIT_FORCED (0, "init", "802_15_4_mac [init exit execs]")


			/** state (init) transition processing **/
			FSM_TRANSIT_FORCE (1, state1_enter_exec, ;, "default", "", "init", "idle", "tr_0", "_02_15_4_mac [init -> idle : default / ]")
				/*---------------------------------------------------------*/



			/** state (idle) enter executives **/
			FSM_STATE_ENTER_UNFORCED (1, "idle", state1_enter_exec, "802_15_4_mac [idle enter execs]")

			/** blocking after enter executives of unforced state. **/
			FSM_EXIT (3,"_02_15_4_mac")


			/** state (idle) exit executives **/
			FSM_STATE_EXIT_UNFORCED (1, "idle", "802_15_4_mac [idle exit execs]")


			/** state (idle) transition processing **/
			FSM_PROFILE_SECTION_IN ("_02_15_4_mac [idle trans conditions]", state1_trans_conds)
			FSM_INIT_COND (NODE_FAILURE)
			FSM_TEST_COND (SCAN_REQUEST)
			FSM_TEST_LOGIC ("idle")
			FSM_PROFILE_SECTION_OUT (state1_trans_conds)

			FSM_TRANSIT_SWITCH
				{
				FSM_CASE_TRANSIT (0, 4, state4_enter_exec, ;, "NODE_FAILURE", "", "idle", "failure", "tr_13", "_02_15_4_mac [idle -> failure : NODE_FAILURE / ]")
				FSM_CASE_TRANSIT (1, 3, state3_enter_exec, wpan_start_scan ();, "SCAN_REQUEST", "wpan_start_scan ()", "idle", "scanning", "tr_6", "_02_15_4_mac [idle -> scanning : SCAN_REQUEST / wpan_start_scan ()]")
				}
				/*---------------------------------------------------------*/



			/** state (active) enter executives **/
			FSM_STATE_ENTER_UNFORCED (2, "active", state2_enter_exec, "802_15_4_mac [active enter execs]")

			/** blocking after enter executives of unforced state. **/
			FSM_EXIT (5,"_02_15_4_mac")


			/** state (active) exit executives **/
			FSM_STATE_EXIT_UNFORCED (2, "active", "802_15_4_mac [active exit execs]")


			/** state (active) transition processing **/
			FSM_PROFILE_SECTION_IN ("_02_15_4_mac [active trans conditions]", state2_trans_conds)
			FSM_INIT_COND (WIRELESS_PK_RCVD)
			FSM_TEST_COND (BEACON_REQUEST)
			FSM_TEST_COND (NWK_PK_RCVD)
			FSM_TEST_COND (NODE_FAILURE)
			FSM_TEST_COND (ACK_TIMER)
			FSM_TEST_COND (TX_DONE)
			FSM_TEST_COND (TX_FAILED)
			FSM_TEST_COND (NETWORK_JOIN)
			FSM_TEST_COND (PAN_LOST)
			FSM_TEST_COND (SCAN_REQUEST)
			FSM_TEST_LOGIC ("active")
			FSM_PROFILE_SECTION_OUT (state2_trans_conds)

			FSM_TRANSIT_SWITCH
				{
				FSM_CASE_TRANSIT (0, 2, state2_enter_exec, wpan_mac_handle_wireless_pk ();, "WIRELESS_PK_RCVD", "wpan_mac_handle_wireless_pk ()", "active", "active", "tr_3", "_02_15_4_mac [active -> active : WIRELESS_PK_RCVD / wpan_mac_handle_wireless_pk ()]")
				FSM_CASE_TRANSIT (1, 2, state2_enter_exec, wpan_mac_send_beacon();, "BEACON_REQUEST", "wpan_mac_send_beacon()", "active", "active", "tr_4", "_02_15_4_mac [active -> active : BEACON_REQUEST / wpan_mac_send_beacon()]")
				FSM_CASE_TRANSIT (2, 2, state2_enter_exec, wpan_mac_handle_nwk_pk ();, "NWK_PK_RCVD", "wpan_mac_handle_nwk_pk ()", "active", "active", "tr_5", "_02_15_4_mac [active -> active : NWK_PK_RCVD / wpan_mac_handle_nwk_pk ()]")
				FSM_CASE_TRANSIT (3, 4, state4_enter_exec, ;, "NODE_FAILURE", "", "active", "failure", "tr_11", "_02_15_4_mac [active -> failure : NODE_FAILURE / ]")
				FSM_CASE_TRANSIT (4, 2, state2_enter_exec, wpan_mac_retransmit ();, "ACK_TIMER", "wpan_mac_retransmit ()", "active", "active", "tr_21", "_02_15_4_mac [active -> active : ACK_TIMER / wpan_mac_retransmit ()]")
				FSM_CASE_TRANSIT (5, 2, state2_enter_exec, wpan_handle_pkt_transmission_success ();, "TX_DONE", "wpan_handle_pkt_transmission_success ()", "active", "active", "tr_29", "_02_15_4_mac [active -> active : TX_DONE / wpan_handle_pkt_transmission_success ()]")
				FSM_CASE_TRANSIT (6, 2, state2_enter_exec, wpan_handle_pkt_transmission_failure ();, "TX_FAILED", "wpan_handle_pkt_transmission_failure ()", "active", "active", "tr_30", "_02_15_4_mac [active -> active : TX_FAILED / wpan_handle_pkt_transmission_failure ()]")
				FSM_CASE_TRANSIT (7, 2, state2_enter_exec, wpan_mac_set_vars();, "NETWORK_JOIN", "wpan_mac_set_vars()", "active", "active", "tr_2", "_02_15_4_mac [active -> active : NETWORK_JOIN / wpan_mac_set_vars()]")
				FSM_CASE_TRANSIT (8, 1, state1_enter_exec, wpan_mac_unset_vars ();, "PAN_LOST", "wpan_mac_unset_vars ()", "active", "idle", "tr_27", "_02_15_4_mac [active -> idle : PAN_LOST / wpan_mac_unset_vars ()]")
				FSM_CASE_TRANSIT (9, 3, state3_enter_exec, wpan_start_scan ();, "SCAN_REQUEST", "wpan_start_scan ()", "active", "scanning", "tr_9", "_02_15_4_mac [active -> scanning : SCAN_REQUEST / wpan_start_scan ()]")
				}
				/*---------------------------------------------------------*/



			/** state (scanning) enter executives **/
			FSM_STATE_ENTER_UNFORCED (3, "scanning", state3_enter_exec, "802_15_4_mac [scanning enter execs]")

			/** blocking after enter executives of unforced state. **/
			FSM_EXIT (7,"_02_15_4_mac")


			/** state (scanning) exit executives **/
			FSM_STATE_EXIT_UNFORCED (3, "scanning", "802_15_4_mac [scanning exit execs]")


			/** state (scanning) transition processing **/
			FSM_PROFILE_SECTION_IN ("_02_15_4_mac [scanning trans conditions]", state3_trans_conds)
			FSM_INIT_COND (SCAN_DONE)
			FSM_TEST_COND (BEACON_REQUEST)
			FSM_TEST_COND (NODE_FAILURE)
			FSM_TEST_COND (WIRELESS_PK_RCVD)
			FSM_TEST_COND (PROGRESS_SCAN)
			FSM_TEST_LOGIC ("scanning")
			FSM_PROFILE_SECTION_OUT (state3_trans_conds)

			FSM_TRANSIT_SWITCH
				{
				FSM_CASE_TRANSIT (0, 2, state2_enter_exec, wpan_mac_hash_initialize ();, "SCAN_DONE", "wpan_mac_hash_initialize ()", "scanning", "active", "tr_7", "_02_15_4_mac [scanning -> active : SCAN_DONE / wpan_mac_hash_initialize ()]")
				FSM_CASE_TRANSIT (1, 3, state3_enter_exec, ;, "BEACON_REQUEST", "", "scanning", "scanning", "tr_28", "_02_15_4_mac [scanning -> scanning : BEACON_REQUEST / ]")
				FSM_CASE_TRANSIT (2, 4, state4_enter_exec, ;, "NODE_FAILURE", "", "scanning", "failure", "tr_12", "_02_15_4_mac [scanning -> failure : NODE_FAILURE / ]")
				FSM_CASE_TRANSIT (3, 3, state3_enter_exec, wpan_mac_record_beacon();, "WIRELESS_PK_RCVD", "wpan_mac_record_beacon()", "scanning", "scanning", "tr_8", "_02_15_4_mac [scanning -> scanning : WIRELESS_PK_RCVD / wpan_mac_record_beacon()]")
				FSM_CASE_TRANSIT (4, 3, state3_enter_exec, wpan_perform_scan ();, "PROGRESS_SCAN", "wpan_perform_scan ()", "scanning", "scanning", "tr_17", "_02_15_4_mac [scanning -> scanning : PROGRESS_SCAN / wpan_perform_scan ()]")
				}
				/*---------------------------------------------------------*/



			/** state (failure) enter executives **/
			FSM_STATE_ENTER_UNFORCED (4, "failure", state4_enter_exec, "802_15_4_mac [failure enter execs]")
				FSM_PROFILE_SECTION_IN ("802_15_4_mac [failure enter execs]", state4_enter_exec)
				{
				if (op_intrpt_type() == OPC_INTRPT_FAIL)
					{
					op_intrpt_clear_self ();
					op_strm_flush (OPC_STRM_ALL);
					}
				}
				FSM_PROFILE_SECTION_OUT (state4_enter_exec)

			/** blocking after enter executives of unforced state. **/
			FSM_EXIT (9,"_02_15_4_mac")


			/** state (failure) exit executives **/
			FSM_STATE_EXIT_UNFORCED (4, "failure", "802_15_4_mac [failure exit execs]")
				FSM_PROFILE_SECTION_IN ("802_15_4_mac [failure exit execs]", state4_exit_exec)
				{
				int i;
				
				for (i = 0; !op_strm_empty (0); i++)
					op_pk_destroy (op_pk_get (0));
				
				
				for (i = 0; !op_strm_empty (1); i++)
					op_pk_destroy (op_pk_get (1));
				
				}
				FSM_PROFILE_SECTION_OUT (state4_exit_exec)


			/** state (failure) transition processing **/
			FSM_PROFILE_SECTION_IN ("_02_15_4_mac [failure trans conditions]", state4_trans_conds)
			FSM_INIT_COND (NODE_RECOVERY)
			FSM_TEST_COND (op_intrpt_type() == OPC_INTRPT_STRM)
			FSM_TEST_LOGIC ("failure")
			FSM_PROFILE_SECTION_OUT (state4_trans_conds)

			FSM_TRANSIT_SWITCH
				{
				FSM_CASE_TRANSIT (0, 1, state1_enter_exec, wpan_mac_unset_vars ();, "NODE_RECOVERY", "wpan_mac_unset_vars ()", "failure", "idle", "tr_14", "_02_15_4_mac [failure -> idle : NODE_RECOVERY / wpan_mac_unset_vars ()]")
				FSM_CASE_TRANSIT (1, 4, state4_enter_exec, wpan_mac_drop_pk();, "op_intrpt_type() == OPC_INTRPT_STRM", "wpan_mac_drop_pk()", "failure", "failure", "tr_16", "_02_15_4_mac [failure -> failure : op_intrpt_type() == OPC_INTRPT_STRM / wpan_mac_drop_pk()]")
				}
				/*---------------------------------------------------------*/



			}


		FSM_EXIT (0,"_02_15_4_mac")
		}
	}




void
_op__02_15_4_mac_diag (OP_SIM_CONTEXT_ARG_OPT)
	{
	/* No Diagnostic Block */
	}




void
_op__02_15_4_mac_terminate (OP_SIM_CONTEXT_ARG_OPT)
	{

	FIN_MT (_op__02_15_4_mac_terminate ())


	/* No Termination Block */

	Vos_Poolmem_Dealloc (op_sv_ptr);

	FOUT
	}


/* Undefine shortcuts to state variables to avoid */
/* syntax error in direct access to fields of */
/* local variable prs_ptr in _op__02_15_4_mac_svar function. */
#undef beacon_scan_list
#undef nwk_id
#undef my_pan_id
#undef my_network_address
#undef my_parent_address
#undef my_channel
#undef my_beacon_order
#undef my_superframe_order
#undef self_id
#undef my_beacon_interval
#undef wpan_cmo_handle
#undef channel_info_lptr
#undef channel_sensing_duration
#undef parent_id
#undef tx_channel_info_objid
#undef rx_channel_info_objid
#undef band_id_3
#undef band_id_2
#undef band_id_1
#undef channel_index
#undef scanning_complete
#undef ack_enabled
#undef ack_duration
#undef outstanding_pk_lptr
#undef max_retrans
#undef gbl_thput_bps_stathandle
#undef gbl_num_retrans_stathandle
#undef gbl_data_dropped_stathandle
#undef gbl_load_dim_stathandle
#undef thput_bps_stathandle
#undef num_retrans_stathandle
#undef data_dropped_stathandle
#undef gbl_data_rcvd_stathandle
#undef data_rcvd_stathandle
#undef gbl_e2e_stathandle
#undef csma_ca_prohandle
#undef csma_ca_process_busy
#undef ack_outstanding_htable_ptr
#undef sequence_number
#undef modmem_ptr
#undef tx_objid
#undef rcvr_objid
#undef e2e_stathandle
#undef gbl_load_stathandle
#undef load_stathandle
#undef gbl_control_data_rcvd_stathandle
#undef gbl_control_data_sent_stathandle
#undef control_data_rcvd_stathandle
#undef control_data_sent_stathandle
#undef drate_sv
#undef q_size_stathandle
#undef joined
#undef channel_number
#undef gbl_qdelay_stathandle
#undef qdelay_stathandle
#undef gbl_mgmt_data_rcvd_stathandle
#undef gbl_mgmt_data_sent_stathandle
#undef mgmt_data_rcvd_stathandle
#undef mgmt_data_sent_stathandle
#undef packet_type_index
#undef next_hop_address_index
#undef stathandles_index
#undef pan_id_index
#undef payload_index
#undef stat_dim_size
#undef WPANC_ACK_PAN_ID_FIELD_INDEX
#undef WPANC_ACK_NEXT_HOP_ADDR_FIELD_INDEX
#undef WPANC_ACK_SEQ_NUM_FIELD_INDEX
#undef WPANC_BEACON_PAN_ID_FIELD_INDEX
#undef WPANC_BEACON_SRC_ADDR_FIELD_INDEX
#undef WPANC_BEACON_RTR_CAP_FIELD_INDEX
#undef WPANC_BEACON_END_DEVICE_CAP_FIELD_INDEX
#undef WPANC_BEACON_DEPTH_FIELD_INDEX
#undef WPANC_BEACON_CAP_DURATION_FIELD_INDEX
#undef WPANC_BEACON_PARENT_BEACON_OFFSET_FIELD_INDEX
#undef WPANC_BEACON_MAX_CHILDREN_FIELD_INDEX
#undef WPANC_BEACON_MAX_ROUTERS_FIELD_INDEX
#undef WPANC_BEACON_MAX_DEPTH_FIELD_INDEX
#undef WPANC_BEACON_BEACON_ORDER_FIELD_INDEX
#undef WPANC_BEACON_SUPERFRAME_ORDER_FIELD_INDEX
#undef WPANC_BEACON_REQUEST_BAND_868_FIELD_INDEX
#undef WPANC_BEACON_REQUEST_BAND_915_FIELD_INDEX
#undef WPANC_BEACON_REQUEST_BAND_2450_FIELD_INDEX

#undef FIN_PREAMBLE_DEC
#undef FIN_PREAMBLE_CODE

#define FIN_PREAMBLE_DEC
#define FIN_PREAMBLE_CODE

VosT_Obtype
_op__02_15_4_mac_init (int * init_block_ptr)
	{
	VosT_Obtype obtype = OPC_NIL;
	FIN_MT (_op__02_15_4_mac_init (init_block_ptr))

	obtype = Vos_Define_Object_Prstate ("proc state vars (_02_15_4_mac)",
		sizeof (_02_15_4_mac_state));
	*init_block_ptr = 0;

	FRET (obtype)
	}

VosT_Address
_op__02_15_4_mac_alloc (VosT_Obtype obtype, int init_block)
	{
#if !defined (VOSD_NO_FIN)
	int _op_block_origin = 0;
#endif
	_02_15_4_mac_state * ptr;
	FIN_MT (_op__02_15_4_mac_alloc (obtype))

	ptr = (_02_15_4_mac_state *)Vos_Alloc_Object (obtype);
	if (ptr != OPC_NIL)
		{
		ptr->_op_current_block = init_block;
#if defined (OPD_ALLOW_ODB)
		ptr->_op_current_state = "802_15_4_mac [init enter execs]";
#endif
		}
	FRET ((VosT_Address)ptr)
	}



void
_op__02_15_4_mac_svar (void * gen_ptr, const char * var_name, void ** var_p_ptr)
	{
	_02_15_4_mac_state		*prs_ptr;

	FIN_MT (_op__02_15_4_mac_svar (gen_ptr, var_name, var_p_ptr))

	if (var_name == OPC_NIL)
		{
		*var_p_ptr = (void *)OPC_NIL;
		FOUT
		}
	prs_ptr = (_02_15_4_mac_state *)gen_ptr;

	if (strcmp ("beacon_scan_list" , var_name) == 0)
		{
		*var_p_ptr = (void *) (&prs_ptr->beacon_scan_list);
		FOUT
		}
	if (strcmp ("nwk_id" , var_name) == 0)
		{
		*var_p_ptr = (void *) (&prs_ptr->nwk_id);
		FOUT
		}
	if (strcmp ("my_pan_id" , var_name) == 0)
		{
		*var_p_ptr = (void *) (&prs_ptr->my_pan_id);
		FOUT
		}
	if (strcmp ("my_network_address" , var_name) == 0)
		{
		*var_p_ptr = (void *) (&prs_ptr->my_network_address);
		FOUT
		}
	if (strcmp ("my_parent_address" , var_name) == 0)
		{
		*var_p_ptr = (void *) (&prs_ptr->my_parent_address);
		FOUT
		}
	if (strcmp ("my_channel" , var_name) == 0)
		{
		*var_p_ptr = (void *) (&prs_ptr->my_channel);
		FOUT
		}
	if (strcmp ("my_beacon_order" , var_name) == 0)
		{
		*var_p_ptr = (void *) (&prs_ptr->my_beacon_order);
		FOUT
		}
	if (strcmp ("my_superframe_order" , var_name) == 0)
		{
		*var_p_ptr = (void *) (&prs_ptr->my_superframe_order);
		FOUT
		}
	if (strcmp ("self_id" , var_name) == 0)
		{
		*var_p_ptr = (void *) (&prs_ptr->self_id);
		FOUT
		}
	if (strcmp ("my_beacon_interval" , var_name) == 0)
		{
		*var_p_ptr = (void *) (&prs_ptr->my_beacon_interval);
		FOUT
		}
	if (strcmp ("wpan_cmo_handle" , var_name) == 0)
		{
		*var_p_ptr = (void *) (&prs_ptr->wpan_cmo_handle);
		FOUT
		}
	if (strcmp ("channel_info_lptr" , var_name) == 0)
		{
		*var_p_ptr = (void *) (&prs_ptr->channel_info_lptr);
		FOUT
		}
	if (strcmp ("channel_sensing_duration" , var_name) == 0)
		{
		*var_p_ptr = (void *) (&prs_ptr->channel_sensing_duration);
		FOUT
		}
	if (strcmp ("parent_id" , var_name) == 0)
		{
		*var_p_ptr = (void *) (&prs_ptr->parent_id);
		FOUT
		}
	if (strcmp ("tx_channel_info_objid" , var_name) == 0)
		{
		*var_p_ptr = (void *) (&prs_ptr->tx_channel_info_objid);
		FOUT
		}
	if (strcmp ("rx_channel_info_objid" , var_name) == 0)
		{
		*var_p_ptr = (void *) (&prs_ptr->rx_channel_info_objid);
		FOUT
		}
	if (strcmp ("band_id_3" , var_name) == 0)
		{
		*var_p_ptr = (void *) (&prs_ptr->band_id_3);
		FOUT
		}
	if (strcmp ("band_id_2" , var_name) == 0)
		{
		*var_p_ptr = (void *) (&prs_ptr->band_id_2);
		FOUT
		}
	if (strcmp ("band_id_1" , var_name) == 0)
		{
		*var_p_ptr = (void *) (&prs_ptr->band_id_1);
		FOUT
		}
	if (strcmp ("channel_index" , var_name) == 0)
		{
		*var_p_ptr = (void *) (&prs_ptr->channel_index);
		FOUT
		}
	if (strcmp ("scanning_complete" , var_name) == 0)
		{
		*var_p_ptr = (void *) (&prs_ptr->scanning_complete);
		FOUT
		}
	if (strcmp ("ack_enabled" , var_name) == 0)
		{
		*var_p_ptr = (void *) (&prs_ptr->ack_enabled);
		FOUT
		}
	if (strcmp ("ack_duration" , var_name) == 0)
		{
		*var_p_ptr = (void *) (&prs_ptr->ack_duration);
		FOUT
		}
	if (strcmp ("outstanding_pk_lptr" , var_name) == 0)
		{
		*var_p_ptr = (void *) (&prs_ptr->outstanding_pk_lptr);
		FOUT
		}
	if (strcmp ("max_retrans" , var_name) == 0)
		{
		*var_p_ptr = (void *) (&prs_ptr->max_retrans);
		FOUT
		}
	if (strcmp ("gbl_thput_bps_stathandle" , var_name) == 0)
		{
		*var_p_ptr = (void *) (&prs_ptr->gbl_thput_bps_stathandle);
		FOUT
		}
	if (strcmp ("gbl_num_retrans_stathandle" , var_name) == 0)
		{
		*var_p_ptr = (void *) (&prs_ptr->gbl_num_retrans_stathandle);
		FOUT
		}
	if (strcmp ("gbl_data_dropped_stathandle" , var_name) == 0)
		{
		*var_p_ptr = (void *) (&prs_ptr->gbl_data_dropped_stathandle);
		FOUT
		}
	if (strcmp ("gbl_load_dim_stathandle" , var_name) == 0)
		{
		*var_p_ptr = (void *) (prs_ptr->gbl_load_dim_stathandle);
		FOUT
		}
	if (strcmp ("thput_bps_stathandle" , var_name) == 0)
		{
		*var_p_ptr = (void *) (&prs_ptr->thput_bps_stathandle);
		FOUT
		}
	if (strcmp ("num_retrans_stathandle" , var_name) == 0)
		{
		*var_p_ptr = (void *) (&prs_ptr->num_retrans_stathandle);
		FOUT
		}
	if (strcmp ("data_dropped_stathandle" , var_name) == 0)
		{
		*var_p_ptr = (void *) (&prs_ptr->data_dropped_stathandle);
		FOUT
		}
	if (strcmp ("gbl_data_rcvd_stathandle" , var_name) == 0)
		{
		*var_p_ptr = (void *) (&prs_ptr->gbl_data_rcvd_stathandle);
		FOUT
		}
	if (strcmp ("data_rcvd_stathandle" , var_name) == 0)
		{
		*var_p_ptr = (void *) (&prs_ptr->data_rcvd_stathandle);
		FOUT
		}
	if (strcmp ("gbl_e2e_stathandle" , var_name) == 0)
		{
		*var_p_ptr = (void *) (&prs_ptr->gbl_e2e_stathandle);
		FOUT
		}
	if (strcmp ("csma_ca_prohandle" , var_name) == 0)
		{
		*var_p_ptr = (void *) (&prs_ptr->csma_ca_prohandle);
		FOUT
		}
	if (strcmp ("csma_ca_process_busy" , var_name) == 0)
		{
		*var_p_ptr = (void *) (&prs_ptr->csma_ca_process_busy);
		FOUT
		}
	if (strcmp ("ack_outstanding_htable_ptr" , var_name) == 0)
		{
		*var_p_ptr = (void *) (&prs_ptr->ack_outstanding_htable_ptr);
		FOUT
		}
	if (strcmp ("sequence_number" , var_name) == 0)
		{
		*var_p_ptr = (void *) (&prs_ptr->sequence_number);
		FOUT
		}
	if (strcmp ("modmem_ptr" , var_name) == 0)
		{
		*var_p_ptr = (void *) (&prs_ptr->modmem_ptr);
		FOUT
		}
	if (strcmp ("tx_objid" , var_name) == 0)
		{
		*var_p_ptr = (void *) (&prs_ptr->tx_objid);
		FOUT
		}
	if (strcmp ("rcvr_objid" , var_name) == 0)
		{
		*var_p_ptr = (void *) (&prs_ptr->rcvr_objid);
		FOUT
		}
	if (strcmp ("e2e_stathandle" , var_name) == 0)
		{
		*var_p_ptr = (void *) (&prs_ptr->e2e_stathandle);
		FOUT
		}
	if (strcmp ("gbl_load_stathandle" , var_name) == 0)
		{
		*var_p_ptr = (void *) (&prs_ptr->gbl_load_stathandle);
		FOUT
		}
	if (strcmp ("load_stathandle" , var_name) == 0)
		{
		*var_p_ptr = (void *) (&prs_ptr->load_stathandle);
		FOUT
		}
	if (strcmp ("gbl_control_data_rcvd_stathandle" , var_name) == 0)
		{
		*var_p_ptr = (void *) (&prs_ptr->gbl_control_data_rcvd_stathandle);
		FOUT
		}
	if (strcmp ("gbl_control_data_sent_stathandle" , var_name) == 0)
		{
		*var_p_ptr = (void *) (&prs_ptr->gbl_control_data_sent_stathandle);
		FOUT
		}
	if (strcmp ("control_data_rcvd_stathandle" , var_name) == 0)
		{
		*var_p_ptr = (void *) (&prs_ptr->control_data_rcvd_stathandle);
		FOUT
		}
	if (strcmp ("control_data_sent_stathandle" , var_name) == 0)
		{
		*var_p_ptr = (void *) (&prs_ptr->control_data_sent_stathandle);
		FOUT
		}
	if (strcmp ("drate_sv" , var_name) == 0)
		{
		*var_p_ptr = (void *) (&prs_ptr->drate_sv);
		FOUT
		}
	if (strcmp ("q_size_stathandle" , var_name) == 0)
		{
		*var_p_ptr = (void *) (&prs_ptr->q_size_stathandle);
		FOUT
		}
	if (strcmp ("joined" , var_name) == 0)
		{
		*var_p_ptr = (void *) (&prs_ptr->joined);
		FOUT
		}
	if (strcmp ("channel_number" , var_name) == 0)
		{
		*var_p_ptr = (void *) (&prs_ptr->channel_number);
		FOUT
		}
	if (strcmp ("gbl_qdelay_stathandle" , var_name) == 0)
		{
		*var_p_ptr = (void *) (&prs_ptr->gbl_qdelay_stathandle);
		FOUT
		}
	if (strcmp ("qdelay_stathandle" , var_name) == 0)
		{
		*var_p_ptr = (void *) (&prs_ptr->qdelay_stathandle);
		FOUT
		}
	if (strcmp ("gbl_mgmt_data_rcvd_stathandle" , var_name) == 0)
		{
		*var_p_ptr = (void *) (&prs_ptr->gbl_mgmt_data_rcvd_stathandle);
		FOUT
		}
	if (strcmp ("gbl_mgmt_data_sent_stathandle" , var_name) == 0)
		{
		*var_p_ptr = (void *) (&prs_ptr->gbl_mgmt_data_sent_stathandle);
		FOUT
		}
	if (strcmp ("mgmt_data_rcvd_stathandle" , var_name) == 0)
		{
		*var_p_ptr = (void *) (&prs_ptr->mgmt_data_rcvd_stathandle);
		FOUT
		}
	if (strcmp ("mgmt_data_sent_stathandle" , var_name) == 0)
		{
		*var_p_ptr = (void *) (&prs_ptr->mgmt_data_sent_stathandle);
		FOUT
		}
	if (strcmp ("packet_type_index" , var_name) == 0)
		{
		*var_p_ptr = (void *) (&prs_ptr->packet_type_index);
		FOUT
		}
	if (strcmp ("next_hop_address_index" , var_name) == 0)
		{
		*var_p_ptr = (void *) (&prs_ptr->next_hop_address_index);
		FOUT
		}
	if (strcmp ("stathandles_index" , var_name) == 0)
		{
		*var_p_ptr = (void *) (&prs_ptr->stathandles_index);
		FOUT
		}
	if (strcmp ("pan_id_index" , var_name) == 0)
		{
		*var_p_ptr = (void *) (&prs_ptr->pan_id_index);
		FOUT
		}
	if (strcmp ("payload_index" , var_name) == 0)
		{
		*var_p_ptr = (void *) (&prs_ptr->payload_index);
		FOUT
		}
	if (strcmp ("stat_dim_size" , var_name) == 0)
		{
		*var_p_ptr = (void *) (&prs_ptr->stat_dim_size);
		FOUT
		}
	if (strcmp ("WPANC_ACK_PAN_ID_FIELD_INDEX" , var_name) == 0)
		{
		*var_p_ptr = (void *) (&prs_ptr->WPANC_ACK_PAN_ID_FIELD_INDEX);
		FOUT
		}
	if (strcmp ("WPANC_ACK_NEXT_HOP_ADDR_FIELD_INDEX" , var_name) == 0)
		{
		*var_p_ptr = (void *) (&prs_ptr->WPANC_ACK_NEXT_HOP_ADDR_FIELD_INDEX);
		FOUT
		}
	if (strcmp ("WPANC_ACK_SEQ_NUM_FIELD_INDEX" , var_name) == 0)
		{
		*var_p_ptr = (void *) (&prs_ptr->WPANC_ACK_SEQ_NUM_FIELD_INDEX);
		FOUT
		}
	if (strcmp ("WPANC_BEACON_PAN_ID_FIELD_INDEX" , var_name) == 0)
		{
		*var_p_ptr = (void *) (&prs_ptr->WPANC_BEACON_PAN_ID_FIELD_INDEX);
		FOUT
		}
	if (strcmp ("WPANC_BEACON_SRC_ADDR_FIELD_INDEX" , var_name) == 0)
		{
		*var_p_ptr = (void *) (&prs_ptr->WPANC_BEACON_SRC_ADDR_FIELD_INDEX);
		FOUT
		}
	if (strcmp ("WPANC_BEACON_RTR_CAP_FIELD_INDEX" , var_name) == 0)
		{
		*var_p_ptr = (void *) (&prs_ptr->WPANC_BEACON_RTR_CAP_FIELD_INDEX);
		FOUT
		}
	if (strcmp ("WPANC_BEACON_END_DEVICE_CAP_FIELD_INDEX" , var_name) == 0)
		{
		*var_p_ptr = (void *) (&prs_ptr->WPANC_BEACON_END_DEVICE_CAP_FIELD_INDEX);
		FOUT
		}
	if (strcmp ("WPANC_BEACON_DEPTH_FIELD_INDEX" , var_name) == 0)
		{
		*var_p_ptr = (void *) (&prs_ptr->WPANC_BEACON_DEPTH_FIELD_INDEX);
		FOUT
		}
	if (strcmp ("WPANC_BEACON_CAP_DURATION_FIELD_INDEX" , var_name) == 0)
		{
		*var_p_ptr = (void *) (&prs_ptr->WPANC_BEACON_CAP_DURATION_FIELD_INDEX);
		FOUT
		}
	if (strcmp ("WPANC_BEACON_PARENT_BEACON_OFFSET_FIELD_INDEX" , var_name) == 0)
		{
		*var_p_ptr = (void *) (&prs_ptr->WPANC_BEACON_PARENT_BEACON_OFFSET_FIELD_INDEX);
		FOUT
		}
	if (strcmp ("WPANC_BEACON_MAX_CHILDREN_FIELD_INDEX" , var_name) == 0)
		{
		*var_p_ptr = (void *) (&prs_ptr->WPANC_BEACON_MAX_CHILDREN_FIELD_INDEX);
		FOUT
		}
	if (strcmp ("WPANC_BEACON_MAX_ROUTERS_FIELD_INDEX" , var_name) == 0)
		{
		*var_p_ptr = (void *) (&prs_ptr->WPANC_BEACON_MAX_ROUTERS_FIELD_INDEX);
		FOUT
		}
	if (strcmp ("WPANC_BEACON_MAX_DEPTH_FIELD_INDEX" , var_name) == 0)
		{
		*var_p_ptr = (void *) (&prs_ptr->WPANC_BEACON_MAX_DEPTH_FIELD_INDEX);
		FOUT
		}
	if (strcmp ("WPANC_BEACON_BEACON_ORDER_FIELD_INDEX" , var_name) == 0)
		{
		*var_p_ptr = (void *) (&prs_ptr->WPANC_BEACON_BEACON_ORDER_FIELD_INDEX);
		FOUT
		}
	if (strcmp ("WPANC_BEACON_SUPERFRAME_ORDER_FIELD_INDEX" , var_name) == 0)
		{
		*var_p_ptr = (void *) (&prs_ptr->WPANC_BEACON_SUPERFRAME_ORDER_FIELD_INDEX);
		FOUT
		}
	if (strcmp ("WPANC_BEACON_REQUEST_BAND_868_FIELD_INDEX" , var_name) == 0)
		{
		*var_p_ptr = (void *) (&prs_ptr->WPANC_BEACON_REQUEST_BAND_868_FIELD_INDEX);
		FOUT
		}
	if (strcmp ("WPANC_BEACON_REQUEST_BAND_915_FIELD_INDEX" , var_name) == 0)
		{
		*var_p_ptr = (void *) (&prs_ptr->WPANC_BEACON_REQUEST_BAND_915_FIELD_INDEX);
		FOUT
		}
	if (strcmp ("WPANC_BEACON_REQUEST_BAND_2450_FIELD_INDEX" , var_name) == 0)
		{
		*var_p_ptr = (void *) (&prs_ptr->WPANC_BEACON_REQUEST_BAND_2450_FIELD_INDEX);
		FOUT
		}
	*var_p_ptr = (void *)OPC_NIL;

	FOUT
	}

