MIL_3_Tfile_Hdr_ 140A 140A opnet 9 4BB53224 4BCA5C9A 2D payette danh 0 0 none none 0 0 none 66E522E0 46AB 0 0 0 0 0 0 18a9 3                                                                                                                                                                                                                                                                                                                                                                                                    ��g�      @  	@  	�  �  �  +�  D]  Da  De  Di  D�  D�  D�  +�      Beacon Interval   �������      seconds   �      normal (2.0, 0.2)      ����      ����         bernoulli (mean)      bernoulli (mean)      $binomial (num_samples, success_prob)      $binomial (num_samples, success_prob)      chi_square (mean)      chi_square (mean)      constant (mean)      constant (mean)      erlang (scale, shape)      erlang (scale, shape)      exponential (mean)      exponential (mean)      extreme (location, scale)      extreme (location, scale)      fast_normal (mean, variance)      fast_normal (mean, variance)      gamma (scale, shape)      gamma (scale, shape)      geometric (success_prob)      geometric (success_prob)      laplace (mean, scale)      laplace (mean, scale)      logistic (mean, scale)      logistic (mean, scale)      lognormal (mean, variance)      lognormal (mean, variance)      normal (mean, variance)      normal (mean, variance)      pareto (location, shape)      pareto (location, shape)      poisson (mean)      poisson (mean)      power function (shape, scale)      power function (shape, scale)      rayleigh (mean)      rayleigh (mean)      triangular (min, max)      triangular (min, max)      uniform (min, max)      uniform (min, max)      uniform_int (min, max)      uniform_int (min, max)      weibull (shape, scale)      weibull (shape, scale)      scripted (filename)      scripted (filename)      None      None         Specifies the distribution    name and arguments to be    used for generating random    
outcomes.         While selecting a distribution,    replace the arguments within    parenthesis (e.g., mean,    variance, location, etc.) with    the desired numerical values.       For the special "scripted"    !distribution, specify a filename     (*.csv or *.gdf) containing the    values required as outcomes.     Values will be picked from this    file in cyclic order.   oms_dist_configure    oms_dist_conf_dbox_click_handler   $oms_dist_conf_dbox_new_value_handler���������Z             	Source ID    �������    ����           ����          ����          ����           �Z             	Is Source    �������    ����            ����            ����            ����            �Z                Enable Source Storage    �������    ����          ����           ����            ����            �Z             	   begsim intrpt         
   ����   
   doc file            	nd_module      endsim intrpt             ����      failure intrpts            disabled      intrpt interval         ԲI�%��}����      priority              ����      recovery intrpts            disabled      subqueue                     count    ���   
   ����   
      list   	���   
          
      super priority             ����             Objid	\storage_id;       int	\is_pkt_interrupt;       Packet *	\pPkt_interrupt;       Evhandle	\evh_beacon_tmr;       %OmsT_Dist_Handle	\disth_beacon_timer;       Objid	\self_id;       int	\source_id;       Objid	\prop1_id;       Objid	\prop2_id;       Objid	\prop3_id;       Objid	\queue_id;       int	\is_source;       int	\enable_source_storage;           W   #include	<oms_dist_support.h>           /***********************   
 * Streams    ***********************/   #define STRM_IN_P1		0   #define STRM_IN_P2		1   #define STRM_IN_P3		2       #define STRM_IN_STORE	3   #define STRM_OUT_STORE	0       #define STRM_IN_MAC		4   #define STRM_OUT_MAC 	1       /***********************    * Interrupt Codes    ***********************/   #define IC_REQ_STORE_DUMP			73   #define IC_STORE_DUMP_DONE			74       ##define IC_PROP_UPDATES_DISABLE		83   "#define IC_PROP_UPDATES_ENABLE		84        #define IC_SEND_BEACON_TIMER		42       #define IC_PK_UPDATEORACK			37   #define IC_PK_BEACON				38       #define IC_Q_DISABLE				54   #define IC_Q_ENABLE					55           /***********************    * Interrupts    ***********************/       //Stream   �#define I_S_PROP_PKT	(op_intrpt_type() == OPC_INTRPT_STRM && (op_intrpt_strm() == STRM_IN_P1 || op_intrpt_strm() == STRM_IN_P2 || op_intrpt_strm() == STRM_IN_P3))   `#define I_S_STORE_PKT	(op_intrpt_type() == OPC_INTRPT_STRM && op_intrpt_strm() == STRM_IN_STORE)   ]#define I_S_MAC_PKT		(op_intrpt_type() == OPC_INTRPT_STRM && op_intrpt_strm() == STRM_IN_MAC)       '//Packet op_intrpt_strm() == STRM_IN_P1   g#define I_PK_UPDATEORACK	(op_intrpt_type() == OPC_INTRPT_SELF && op_intrpt_code() == IC_PK_UPDATEORACK)   _#define I_PK_BEACON			(op_intrpt_type() == OPC_INTRPT_SELF && op_intrpt_code() == IC_PK_BEACON)       //Remote   m#define I_R_STORE_DUMP_DONE	(op_intrpt_type() == OPC_INTRPT_REMOTE && op_intrpt_code() == IC_STORE_DUMP_DONE)       //Local (self)   o#define I_L_SEND_BEACON_TIMER (op_intrpt_type() == OPC_INTRPT_SELF && op_intrpt_code() == IC_SEND_BEACON_TIMER)           =#define STORE_UPDATES			(!is_source || enable_source_storage)       /***********************    * Prototypes    ***********************/       //Beacon control   void enable_beacon();   void disable_beacon();   void send_beacon();   void send_beacon_timed();   void reset_beacon_timer();       //Property control   void enable_prop_updates();   void disable_prop_updates();       void disable_q();   void enable_q();       //Storage control   void request_storage_dump();       //Packet redirection    void send_to_store();   void send_to_mac();       !void generate_mac_pk_interrupt();       void clear_pk_interrupt(void);       %void printbad_mac_or_prop_strm(void);   void print_default(void);     void schedule_beacon()   {   	double next_becon_time = 0;   	   	FIN(schedule_beacon());   	   	while(next_becon_time <= 0.1)   	{   :		next_becon_time = oms_dist_outcome (disth_beacon_timer);   	}   	   c	evh_beacon_tmr = op_intrpt_schedule_self (op_sim_time () + next_becon_time, IC_SEND_BEACON_TIMER);   	   	FOUT;   }       void enable_beacon()   {   	FIN(enable_beacon());   	   	schedule_beacon();   	   	FOUT;   }       void disable_beacon()   {   	FIN(disable_beacon());   	   .	if (op_ev_valid (evh_beacon_tmr) == OPC_TRUE)   	{    		op_ev_cancel (evh_beacon_tmr);   	}       	FOUT;   }       void reset_beacon_timer()   {   	FIN(reset_beacon_timer());   	disable_beacon();   	enable_beacon();   	FOUT;   }       void send_beacon()   {   	char message_str[255];   	Packet *pPkt;       	FIN(send_beacon());   	   >	//sprintf (message_str, "[%d] Send Beacon\n", op_id_self());    	//printf (message_str);   	   	   #	pPkt = op_pk_create_fmt("beacon");   3	op_pk_nfd_set_int32(pPkt, "source_id", source_id);   	   	//TODO - node type    	    	op_pk_send(pPkt, STRM_OUT_MAC);   	   	schedule_beacon();   	   	FOUT;   }       //Property control   void enable_prop_updates()   {   	FIN(enable_prop_updates());   	   L	op_intrpt_schedule_remote(op_sim_time(), IC_PROP_UPDATES_ENABLE, prop1_id);   L	op_intrpt_schedule_remote(op_sim_time(), IC_PROP_UPDATES_ENABLE, prop2_id);   L	op_intrpt_schedule_remote(op_sim_time(), IC_PROP_UPDATES_ENABLE, prop3_id);   	   	FOUT;   }   	   void disable_prop_updates()   {   	FIN(disable_prop_updates());       M	op_intrpt_schedule_remote(op_sim_time(), IC_PROP_UPDATES_DISABLE, prop1_id);   M	op_intrpt_schedule_remote(op_sim_time(), IC_PROP_UPDATES_DISABLE, prop2_id);   M	op_intrpt_schedule_remote(op_sim_time(), IC_PROP_UPDATES_DISABLE, prop3_id);   	   	FOUT;   }           void request_storage_dump()   {   	FIN(request_sotrage_dump());   	   I	op_intrpt_schedule_remote(op_sim_time(), IC_REQ_STORE_DUMP, storage_id);   	   	FOUT;   }           void send_to_store()   {   	Packet *pPktToForward;   	   	FIN(send_to_store());   	   	if(is_pkt_interrupt)   	{   		is_pkt_interrupt = 0;   		   		if(pPkt_interrupt == OPC_NIL)   		{   1			op_sim_end("Nill interrupt pkt", "", "", "");	   		}   		   !		pPktToForward = pPkt_interrupt;   		pPkt_interrupt = OPC_NIL;   	}   	else   	{   		if(pPkt_interrupt != OPC_NIL)   		{   5			op_sim_end("Not nill interrupt pkt", "", "", "");	   		}   		   .		pPktToForward = op_pk_get(op_intrpt_strm());   	}   	   +	op_pk_send(pPktToForward, STRM_OUT_STORE);   	   	FOUT;   }   	   void send_to_mac()   {   	char message_str[255];   	Packet *pPktToForward;   	   	FIN(send_to_mac());       	if(is_pkt_interrupt)   	{   		is_pkt_interrupt = 0;   		   		if(pPkt_interrupt == OPC_NIL)   		{   1			op_sim_end("Nill interrupt pkt", "", "", "");	   		}   		   !		pPktToForward = pPkt_interrupt;   		pPkt_interrupt = OPC_NIL;   	}   	else   	{   		if(pPkt_interrupt != OPC_NIL)   		{   5			op_sim_end("Not nill interrupt pkt", "", "", "");	   		}   		   .		pPktToForward = op_pk_get(op_intrpt_strm());   	}   	   ?	//sprintf (message_str, "[%d] Send to mac Pkt\n", source_id);    	//printf (message_str);   	   )	op_pk_send(pPktToForward, STRM_OUT_MAC);   	   	FOUT;   }       void clear_pk_interrupt()   {       	FIN(clear_pk_interrupt());   	   	if(is_pkt_interrupt)   	{   		is_pkt_interrupt = 0;   		   		if(pPkt_interrupt == OPC_NIL)   		{   1			op_sim_end("Nill interrupt pkt", "", "", "");	   		}   		    		op_pk_destroy(pPkt_interrupt);   		pPkt_interrupt = OPC_NIL;   	}   	else   	{   =		op_sim_end("clear_pk_interrupt called wrong", "", "", "");	   	}   	   	FOUT;   }        void generate_mac_pk_interrupt()   {   	char message_str[255];   	char format_name[255];   	   "	FIN(generate_mac_pk_interrupt());   	   /	reset_beacon_timer(); //To prevent a bad state       	if(pPkt_interrupt != OPC_NIL)   	{   4		op_sim_end("Not nill interrupt pkt", "", "", "");	   	}   	else if (is_pkt_interrupt)   	{   ;		op_sim_end("Pkt interrupt flag set (bad)", "", "", "");		   	}   )	else if(op_intrpt_strm() != STRM_IN_MAC)   	{   [		op_sim_end("generate_mac_pk_interrupt called for non mac stream interrupt", "", "", "");	   	}   	   )	pPkt_interrupt = op_pk_get(STRM_IN_MAC);   	is_pkt_interrupt = 1;   	   @	//sprintf (message_str, "[%d] Received Mac Pkt\n", source_id);    	//printf (message_str);   	   ,	op_pk_format (pPkt_interrupt, format_name);   )	if (strcmp (format_name, "beacon") == 0)   	{   8		op_intrpt_schedule_self(op_sim_time(), IC_PK_BEACON);	   	}   1	else if (strcmp (format_name, "keyupdate") == 0)   	{   =		op_intrpt_schedule_self(op_sim_time(), IC_PK_UPDATEORACK);	   	}   	   	FOUT;   }       void disable_q()   {   	FIN(disable_q());   C	op_intrpt_schedule_remote(op_sim_time(), IC_Q_DISABLE, queue_id);	   	FOUT;   }       void enable_q()   {   	FIN(enable_q());   B	op_intrpt_schedule_remote(op_sim_time(), IC_Q_ENABLE, queue_id);	   	FOUT;   }        void printbad_mac_or_prop_strm()   {   	char message_str[255];   	   "	FIN(printbad_mac_or_prop_strm());       X	sprintf (message_str, "[%d UM DIE] Received mac or prop strm interrupt\n", source_id);    	printf (message_str);   	   	FOUT;   }       void print_default()   {   	printf("DEFAULT\n");   }                                          Z   �          J   init   J       J   *       char beacon_dist_str[128];       self_id = op_id_self();   7op_ima_obj_attr_get (self_id, "Source ID", &source_id);       Bop_ima_obj_attr_get (self_id, "Beacon Interval", beacon_dist_str);   Adisth_beacon_timer = oms_dist_load_from_string (beacon_dist_str);       7op_ima_obj_attr_get (self_id, "Is Source", &is_source);   Oop_ima_sim_attr_get (self_id, "Enable Source Storage", &enable_source_storage);       Tstorage_id = op_id_from_name (op_topo_parent(self_id), OPC_OBJTYPE_PROC, "storage");       Pprop1_id = op_id_from_name (op_topo_parent(self_id), OPC_OBJTYPE_PROC, "prop1");   Pprop2_id = op_id_from_name (op_topo_parent(self_id), OPC_OBJTYPE_PROC, "prop2");   Pprop3_id = op_id_from_name (op_topo_parent(self_id), OPC_OBJTYPE_PROC, "prop3");       Uqueue_id = op_id_from_name (op_topo_parent(self_id), OPC_OBJTYPE_PROC, "hold_queue");       //Property stream priorities   9op_intrpt_priority_set (OPC_INTRPT_STRM, STRM_IN_P1, 15);   9op_intrpt_priority_set (OPC_INTRPT_STRM, STRM_IN_P2, 15);   9op_intrpt_priority_set (OPC_INTRPT_STRM, STRM_IN_P3, 15);       //Lower than property inputs   <op_intrpt_priority_set (OPC_INTRPT_STRM, STRM_IN_STORE, 10);   9op_intrpt_priority_set (OPC_INTRPT_STRM, STRM_IN_MAC, 8);       4//Absolute highest - controlled by stream interrupts   ;op_intrpt_priority_set (OPC_INTRPT_SELF, IC_PK_BEACON, 20);   @op_intrpt_priority_set (OPC_INTRPT_SELF, IC_PK_UPDATEORACK, 20);       //Lower than STRM_IN_STORE   Bop_intrpt_priority_set (OPC_INTRPT_REMOTE, IC_STORE_DUMP_DONE, 9);       //Absolute lowest   Bop_intrpt_priority_set (OPC_INTRPT_SELF, IC_SEND_BEACON_TIMER, 0);               enable_beacon();   J                     J   ����   J          pr_state        J   �          J   idle   J                                       ����             pr_state        �  J          J   tx   J                                       ����             pr_state         �  J          J   error   J       J      //Unrecoverable error   +op_sim_end("Unexpected state", "", "", "");   J                     J    ����   J          pr_state        �   �          J   tx_start   J       J   !   if(is_pkt_interrupt)   {   	is_pkt_interrupt = 0;   		   	if(pPkt_interrupt == OPC_NIL)   	{   0		op_sim_end("Nill interrupt pkt", "", "", "");	   	}   		   	op_pk_destroy(pPkt_interrupt);   	pPkt_interrupt = OPC_NIL;   }   else   {   	if(pPkt_interrupt != OPC_NIL)   	{   4		op_sim_end("Not nill interrupt pkt", "", "", "");	   	}   }       %if(op_pk_get(STRM_IN_MAC) != OPC_NIL)   {   9	op_sim_end("STRM_IN_MAC - Packet waiting", "", "", "");	   }       disable_q();   disable_prop_updates();       %//TODO: clear prop update streams (?)       disable_beacon();       request_storage_dump();   J       J       J       J   ����   J          pr_state      	  �   �          J   tx_done   J       J      'if(op_pk_get(STRM_IN_STORE) != OPC_NIL)   {   2	op_sim_end("Store stream not empty", "", "", "");   }       enable_q();   enable_prop_updates();       ://Allow the node we just received updates from to transmit   enable_beacon();       //send_beacon();   J                     J   ����   J          pr_state                        �   �      m   �  ?   �          J   tr_0   J       ����          ����          J    ����   J          ����                       pr_transition              u  $       D  B  6  B  X    I          J   tr_6   J       J   I_S_STORE_PKT   J       J   send_to_mac()   J       J    ����   J          ����                       pr_transition              �   �     ^   �  �   �          J   tr_14   J       J   I_PK_BEACON   J       ����          J    ����   J          ����                       pr_transition              �   �     �   �  �  8          J   tr_15   J       ����          ����          J    ����   J          ����                       pr_transition            	  �       �  8  �   �          J   tr_17   J       J   I_R_STORE_DUMP_DONE   J       ����          J    ����   J          ����                       pr_transition         	     �   �     �   �  �   �  T   �          J   tr_18   J       ����          ����          J    ����   J          ����                       pr_transition               �   f     8   �   �   y     h  >   �          J   tr_19   J       J   I_S_PROP_PKT   J       J   send_to_store()   J       J    ����   J          ����                       pr_transition               �   F     A   �     Z  3   O  I   �          J   tr_20   J       J   I_S_MAC_PKT   J       J   generate_mac_pk_interrupt()   J       J    ����   J          ����                       pr_transition              �   7     M   �  I   L  ]   M  Q   �          J   tr_21   J       J   !I_PK_UPDATEORACK && STORE_UPDATES   J       J   send_to_store()   J       J    ����   J          ����                       pr_transition               z   �     :   �   �  :          J   tr_22   J       J   &(I_S_STORE_PKT || I_R_STORE_DUMP_DONE)   J       ����          J    ����   J          ����                       pr_transition              �   L     V   �  o   R  �   _  \   �          J   tr_23   J       J   I_L_SEND_BEACON_TIMER   J       J   send_beacon()   J       J    ����   J          ����                       pr_transition              S  7     �  A   �  G          J   tr_24   J       J   I_S_MAC_PKT   J       J   printbad_mac_or_prop_strm()   J       J    ����   J          ����                       pr_transition              \  [     �  N  _  e   �  P          J   tr_25   J       J   default   J       J   print_default()   J       J    ����   J          ����                       pr_transition              S   k     T   �  �   i  �   |  M   �          J   tr_27   J       J   "I_PK_UPDATEORACK && !STORE_UPDATES   J       J   clear_pk_interrupt()   J       J    ����   J          ����                       pr_transition      
                     oms_dist_support   oms_string_support                    