MIL_3_Tfile_Hdr_ 140A 140A opnet 9 4BB50865 4BC8F093 6B rfsip5 danh 0 0 none none 0 0 none 5FACECD3 2ECC 0 0 0 0 0 0 18a9 3                                                                                                                                                                                                                                                                                                                                                                                                     ��g�      @  �  �  N  R  �  *�  *�  ,�  ,�  ,�  ,�  ,�  �      Max Packets    �������    ����           ����          ����          ����           �Z             	Source ID    �������    ����       ��������          ����          ����           �Z             
Is Gateway    �������    ����           ����          ����          ����           �Z                 	   begsim intrpt         
   ����   
   doc file            	nd_module      endsim intrpt             ����      failure intrpts            disabled      intrpt interval         ԲI�%��}����      priority              ����      recovery intrpts            disabled      subqueue                     count    ���   
   ����   
      list   	���   
          
      super priority             ����             List*	\pupdate_lst;       int	\x_intrptScheduled;       int	\x_updatesSent;       Objid	\self_id;       int	\maxlistsize;       Objid	\updatemanager_id;       int	\source_id;       int	\is_gateway;       List*	\stat_lst_pdisc_bfull;       List*	\stat_lst_pdisc_old;       List*	\stat_lst_pstored_new;        List*	\stat_lst_pstored_updated;       Stathandle	\stat_preceived;       List*	\stat_lst_pdisc_dup;       Stathandle	\stat_neworupdated;              #define MAX_SRC_IDS		10       !#define GATEWAY_MODE	(is_gateway)   $#define STORAGE_MODE	(!GATEWAY_MODE)       #define STRM_UM_IN		0   #define STRM_UM_OUT		0       #define STRM_GW_OUT		1       "//Interrupt Codes (random numbers)   #define IC_DUMP_UPDATES 		73    #define IC_DUMP_UPDATES_DONE 	74       c#define TX_UPDATES 		(op_intrpt_type() == OPC_INTRPT_REMOTE && op_intrpt_code() == IC_DUMP_UPDATES)   c//#define TX_UPDATES 		(op_intrpt_type() == OPC_INTRPT_SELF && op_intrpt_code() == IC_DUMP_UPDATES)   =#define UPDATE_RECEIVED	(op_intrpt_type() == OPC_INTRPT_STRM)           (List *create_stat_lst_loc(const char *);           void store_update(void);   void tx_updates(void);   void gateway_fwrd(void);   �   void store_update(void)   {   	Packet *pkt;   	Packet *lstPkt;   	char message_str [255];   	Objid prop1_id;   		int key;   	int sourceid;   	int key_updnm;   	int pos_index;   	double gen_ts;   	int newkey;   	int newsourceid;   	int newkey_updnm;   	double newgen_ts;   	int listsize;   	int i, j, k;   	double temp;   	   	   	FIN (store_update ());   	   %	pkt = op_pk_get (op_intrpt_strm ());   	   r	//sprintf (message_str, "[%d STORE] Store Update - List size: %d\n", source_id, op_prg_list_size(pupdate_lst ));    	//printf (message_str);   	   	//get info   $	op_pk_nfd_get(pkt, "key", &newkey);   /	op_pk_nfd_get(pkt, "source_id", &newsourceid);   8	op_pk_nfd_get(pkt, "key_update_number", &newkey_updnm);   7	op_pk_nfd_get(pkt, "generated_timestamp", &newgen_ts);   *	listsize = op_prg_list_size(pupdate_lst);   	   2	if(newsourceid < 0 || newsourceid >= MAX_SRC_IDS)   	{   )		op_sim_end("Bad sourceid", "", "", "");   	}   	   $	op_stat_write(stat_preceived, 1.0);   	   	//Following forloop is for    9	//Search & Compare 'key_update_number'; replace if newer   	for(i = 0; i < listsize; i++)   	{   9		lstPkt = (Packet *)op_prg_list_access (pupdate_lst, i);   %		op_pk_nfd_get(lstPkt, "key", &key);   0		op_pk_nfd_get(lstPkt, "source_id", &sourceid);   9		op_pk_nfd_get(lstPkt, "key_update_number", &key_updnm);   8		op_pk_nfd_get(lstPkt, "generated_timestamp", &gen_ts);   		   #		//COMPARE for matching source/key   		if(newsourceid == sourceid)   		{   			if(newkey == key)   			{   <				if(newkey_updnm > key_updnm)	//if key is newer we update   				{   !					if(newsourceid != source_id)   					{   c						op_stat_write(*((Stathandle *)op_prg_list_access (stat_lst_pstored_updated, sourceid)), 1.0);   ,						op_stat_write(stat_neworupdated, 1.0);   					}   					   )					op_prg_list_remove (pupdate_lst, i);   <					op_prg_list_insert(pupdate_lst, pkt, OPC_LISTPOS_TAIL);   					op_pk_destroy(lstPkt);   
					FOUT;   				}   				else   				{   "					if(newkey_updnm == key_updnm)   					{   ]						op_stat_write(*((Stathandle *)op_prg_list_access (stat_lst_pdisc_dup, sourceid)), 1.0);   					}   						else   					{   ]						op_stat_write(*((Stathandle *)op_prg_list_access (stat_lst_pdisc_old, sourceid)), 1.0);   					}   				   					op_pk_destroy(pkt);   
					FOUT;   				}   			}   		}   	} //forloop       	   8	op_prg_list_insert(pupdate_lst, pkt, OPC_LISTPOS_TAIL);   *	listsize = op_prg_list_size(pupdate_lst);       	if(newsourceid != source_id)   	{   ^		op_stat_write(*((Stathandle *)op_prg_list_access (stat_lst_pstored_new, newsourceid)), 1.0);   (		op_stat_write(stat_neworupdated, 1.0);   	}       )	//See if we need to get rid of something   	if(listsize > maxlistsize)   	{	   		//set first packet for temp   9		lstPkt = (Packet *)op_prg_list_access (pupdate_lst, 0);   8		op_pk_nfd_get(lstPkt, "generated_timestamp", &gen_ts);   		temp = gen_ts;   		   		//find oldest timestamp   		for(j = 0; j < listsize; j++)   		{   :			lstPkt = (Packet *)op_prg_list_access (pupdate_lst, j);   9			op_pk_nfd_get(lstPkt, "generated_timestamp", &gen_ts);   			   			if(gen_ts < temp)   			{   %				temp = gen_ts;	//replace if older   			}   		}   		   /		//delete packet with oldest timestamp, temp,    		for(k = 0; k < listsize; k++)   		{   :			lstPkt = (Packet *)op_prg_list_access (pupdate_lst, k);   9			op_pk_nfd_get(lstPkt, "generated_timestamp", &gen_ts);   1			op_pk_nfd_get(lstPkt, "source_id", &sourceid);   			   			if(temp == gen_ts)   			{   ]				op_stat_write(*((Stathandle *)op_prg_list_access (stat_lst_pdisc_bfull, sourceid)), 1.0);   				   (				op_prg_list_remove (pupdate_lst, k);   				op_pk_destroy(lstPkt);   				   				   t				//sprintf (message_str, "[%d STORE] \tMax list size reached, discarding packet aged: %d\n", source_id, gen_ts);    				//printf (message_str);   				   
				break;   			}   		}   	}        	FOUT;   }       void tx_updates(void)   {   	int i;   	int lstSize;   	Packet *pkt;   	Packet *pPktCopy;   	char message_str [255];   	   	FIN (tx_updates ());   	   '	//updatesSent++;			//increment counter   	//intrptScheduled = 0;       m	//sprintf (message_str, "[%d STORE] Sending Packets: size %d\n", source_id, op_prg_list_size(pupdate_lst));    	//printf (message_str);   	   *	lstSize = op_prg_list_size (pupdate_lst);   	for (i = 0; i < lstSize; i++)   	{   7		pkt = (Packet *) op_prg_list_access (pupdate_lst, i);   		   		pPktCopy = op_pk_copy(pkt);   $		op_pk_send(pPktCopy, STRM_UM_OUT);   	}       R	op_intrpt_schedule_remote(op_sim_time(), IC_DUMP_UPDATES_DONE, updatemanager_id);   	   w 	//sprintf (message_str, "[%d STORE] 	Done Sending Packets: size %d\n", op_id_self(), op_prg_list_size(pupdate_lst));    	//printf (message_str);   			    	FOUT;   }       void tx_updates_done(void)   {   	FIN (tx_updates_done ());   	   R	op_intrpt_schedule_remote(op_sim_time(), IC_DUMP_UPDATES_DONE, updatemanager_id);   	   	FOUT;   }       void gateway_fwrd()   {   	FIN (update_gateway ());       $	op_stat_write(stat_preceived, 1.0);   0	op_pk_send(op_pk_get(STRM_UM_IN), STRM_GW_OUT);   	   	FOUT;   }       /List *create_stat_lst_loc(const char *statName)   {   	List *lst;   	int stat_size_asdf;   	int i;   	char msg1[255];   	char msg2[255];   	   	FIN(create_stat_lst_loc());   	   A	op_stat_dim_size_get(statName, OPC_STAT_LOCAL, &stat_size_asdf);   "	if(stat_size_asdf != MAX_SRC_IDS)   	{   6		sprintf(msg1, "stat_size_asdf: %d", stat_size_asdf);   0		sprintf(msg2, "MAX_SRC_IDS: %d", MAX_SRC_IDS);   9		op_sim_end("Bad stat dimension", statName, msg1, msg2);   	}   	   	lst = op_prg_list_create();   !	for(i = 0; i < MAX_SRC_IDS; i++)   	{   		Stathandle *sth_temp;   C		sth_temp = (Stathandle *) op_prg_mem_alloc (sizeof (Stathandle));   8		*sth_temp = op_stat_reg (statName, i, OPC_STAT_LOCAL);   		   6		op_prg_list_insert(lst, sth_temp, OPC_LISTPOS_TAIL);   	}   	   	FRET(lst);   }                                          Z   �          J   init   J       J      int i;       self_id = op_id_self();       printf("REGISTERING STATS\n");       @stat_lst_pstored_new = create_stat_lst_loc("Pkts Stored - New");   Hstat_lst_pstored_updated = create_stat_lst_loc("Pkts Stored - Updated");       Astat_lst_pdisc_old = create_stat_lst_loc("Pkts Discarded - Old");   Kstat_lst_pdisc_bfull = create_stat_lst_loc("Pkts Discarded - Buffer Full");   Gstat_lst_pdisc_dup = create_stat_lst_loc("Pkts Discarded - Duplicate");           Rstat_preceived = op_stat_reg("Pkts Received",OPC_STAT_INDEX_NONE, OPC_STAT_LOCAL);   dstat_neworupdated = op_stat_reg("Pkts Stored - New or Updated",OPC_STAT_INDEX_NONE, OPC_STAT_LOCAL);       /* allocate an empty list */   %pupdate_lst = op_prg_list_create ();            ;op_ima_obj_attr_get (self_id, "Max Packets", &maxlistsize);   7op_ima_obj_attr_get (self_id, "Source ID", &source_id);   9op_ima_obj_attr_get (self_id, "Is Gateway", &is_gateway);       aupdatemanager_id = op_id_from_name (op_topo_parent(self_id), OPC_OBJTYPE_PROC, "update_manager");   J                     J   ����   J          pr_state           �          J   storage   J       J      if(maxlistsize <= 0)   {   (	//Typically when this node is a gateway   1	op_sim_end("Invalid max list size", "", "", "");   }   J                         ����             pr_state         Z  J          J   gateway   J                                       ����             pr_state                        �   �      c   �     �          J   tr_0   J       J   STORAGE_MODE   J       ����          J    ����   J          ����                       pr_transition                 0        �   �   B  6   E     �          J   tr_1   J       J   UPDATE_RECEIVED   J       J   store_update()   J       J    ����   J          ����                       pr_transition              $          �   �   �  *   �     �          J   tr_2   J       J   
TX_UPDATES   J       J   tx_updates()   J       J    ����   J          ����                       pr_transition                �   �      ]   �   [  C          J   tr_3   J       J   GATEWAY_MODE   J       ����          J    ����   J          ����                       pr_transition               b  �      R  P   ?  �   |  �   ]  P          J   tr_4   J       J   
TX_UPDATES   J       J   tx_updates_done()   J       J    ����   J          ����                       pr_transition                P      j  S   �  �   �  8   d  I          J   tr_5   J       J   UPDATE_RECEIVED   J       J   gateway_fwrd()   J       J    ����   J          ����                       pr_transition                   Pkts Discarded - Buffer Full   
           normal   discrete        ԲI�%��}   Pkts Discarded - Duplicate   
           normal   discrete        ԲI�%��}   Pkts Discarded - Old   
           normal   discrete        ԲI�%��}   Pkts Received        ����   normal   discrete        ԲI�%��}   Pkts Stored - New   
           normal   discrete        ԲI�%��}   Pkts Stored - Updated   
           normal   discrete        ԲI�%��}   Pkts Stored - New or Updated        ����   bucket/1 secs/sum_time   linear        ԲI�%��}                            