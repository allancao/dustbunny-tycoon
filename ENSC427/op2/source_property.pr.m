MIL_3_Tfile_Hdr_ 140A 140A opnet 9 4BB508F3 4BCA9482 4B payette danh 0 0 none none 0 0 none D1C16549 4FF6 0 0 0 0 0 0 18a9 3                                                                                                                                                                                                                                                                                                                                                                                                    ��g�      @  
^  
�  �  �  1�  K�  K�  K�  M�  M�  M�  M�  1w      Property Key    �������    ����           ����          ����          ����           �Z             Property Update Interval   �������      seconds   �      normal (10, 1)      ����      ����         bernoulli (mean)      bernoulli (mean)      $binomial (num_samples, success_prob)      $binomial (num_samples, success_prob)      chi_square (mean)      chi_square (mean)      constant (mean)      constant (mean)      erlang (scale, shape)      erlang (scale, shape)      exponential (mean)      exponential (mean)      extreme (location, scale)      extreme (location, scale)      fast_normal (mean, variance)      fast_normal (mean, variance)      gamma (scale, shape)      gamma (scale, shape)      geometric (success_prob)      geometric (success_prob)      laplace (mean, scale)      laplace (mean, scale)      logistic (mean, scale)      logistic (mean, scale)      lognormal (mean, variance)      lognormal (mean, variance)      normal (mean, variance)      normal (mean, variance)      pareto (location, shape)      pareto (location, shape)      poisson (mean)      poisson (mean)      power function (shape, scale)      power function (shape, scale)      rayleigh (mean)      rayleigh (mean)      triangular (min, max)      triangular (min, max)      uniform (min, max)      uniform (min, max)      uniform_int (min, max)      uniform_int (min, max)      weibull (shape, scale)      weibull (shape, scale)      scripted (filename)      scripted (filename)      None      None         Specifies the distribution    name and arguments to be    used for generating random    
outcomes.         While selecting a distribution,    replace the arguments within    parenthesis (e.g., mean,    variance, location, etc.) with    the desired numerical values.       For the special "scripted"    !distribution, specify a filename     (*.csv or *.gdf) containing the    values required as outcomes.     Values will be picked from this    file in cyclic order.   oms_dist_configure    oms_dist_conf_dbox_click_handler   $oms_dist_conf_dbox_new_value_handler���������Z             	Source ID    �������    ����           ����          ����          ����           �Z             Enable Properties    �������    ����           ����          ����          ����           �Z             	Stop Time   �������      seconds       ��         Infinity              ����              ����         Infinity   ��      ����       �Z                Property Key    �������    ����           ����          ����          ����           �Z             	   begsim intrpt         
   ����   
   doc file            	nd_module      endsim intrpt         
   ����   
   failure intrpts            disabled      intrpt interval         ԲI�%��}����      priority              ����      recovery intrpts            disabled      subqueue                     count    ���   
   ����   
      list   	���   
          
      super priority             ����             int	\prop_key;       int	\prop_key_update_counter;       int	\prop_last_key_updated;       Objid	\self_id;       Evhandle	\next_update_evh;       "OmsT_Dist_Handle	\update_dist_ptr;       int	\source_id;       int	\is_source_mode;       int	\has_one_update;       List *	\active_updates_lst;        Stathandle	\stat_update_success;       -Stathandle	\stat_update_success_limited_loss;       #int	\last_key_update_num_delivered;       double	\stop_time;       Stathandle	\stat_delay;           &   #include	<oms_dist_support.h>       8//Interrupt Codes (codes have no meaning and are random)    #define IC_PROP_VAL_CHANGED 		39    #define IC_UPDATES_DISABLE	 		83   #define IC_UPDATES_ENABLE			84   #define IC_STOP						21       #define IC_GW_PKT_RX				99       %#define SOURCE_MODE		(is_source_mode)       //Interrupts    i#define PROP_VAL_CHANGED	(op_intrpt_type() == OPC_INTRPT_SELF && op_intrpt_code() == IC_PROP_VAL_CHANGED)       n#define DISABLE_PROP_UPDATES	(op_intrpt_type() == OPC_INTRPT_REMOTE && op_intrpt_code() == IC_UPDATES_DISABLE)   m#define ENABLE_PROP_UPDATES		(op_intrpt_type() == OPC_INTRPT_REMOTE && op_intrpt_code() == IC_UPDATES_ENABLE)       a#define I_GW_PKT_RX			(op_intrpt_type() == OPC_INTRPT_REMOTE && op_intrpt_code() == IC_GW_PKT_RX)   ;#define I_END_SIM			(op_intrpt_type() == OPC_INTRPT_ENDSIM)   U#define I_STOP			(op_intrpt_type() == OPC_INTRPT_SELF && op_intrpt_code() == IC_STOP)       typedef struct   {   	int update_counter_number;   	int pkts_alive;   	int has_one_store;   	int gateway_rx;   	double generated_timestamp;   	int mark_for_delete;   	int discard_reason;   } active_update_tacker;       void new_val(void);   void schedule_update(void);       void gw_pkt_rx(void);   void stat_finalize(void);  -           void new_val(void)   {   	FIN (new_val ());       	prop_key_update_counter++;   	schedule_update();   	   	FOUT   }       void schedule_update(void)   {   	double next_update_time;   	   	FIN(schedule_update());   7	next_update_time = oms_dist_outcome (update_dist_ptr);       	if (next_update_time <0)   	{   		next_update_time = 0;   	}       i	next_update_evh      = op_intrpt_schedule_self (op_sim_time () + next_update_time, IC_PROP_VAL_CHANGED);       	FOUT;   }       void gw_pkt_rx()   {   	Ici *iciptr;   	int sourceid;   	int key_update_number;   	int action;   	int discard_reason;   	int tracker_index;   	double generated_timestamp;    	active_update_tacker *pTracker;   	char msg[255];   	int i;       	FIN(gw_pkt_rx());       	iciptr = op_intrpt_ici ();   	if(iciptr == OPC_NIL)   	{   %		op_sim_end("Null ICI", "", "", "");   	}   	   2	op_ici_attr_get (iciptr, "source_id", &sourceid);   C	op_ici_attr_get (iciptr, "key_update_number", &key_update_number);   -	op_ici_attr_get (iciptr, "action", &action);   =	op_ici_attr_get (iciptr, "discard_reason", &discard_reason);   G	op_ici_attr_get (iciptr, "generated_timestamp", &generated_timestamp);       	//DEBUG   $	if(source_id == 9 && prop_key == 2)   	{   U		sprintf(msg, "[DBG] key_update_number=%d, action=%d\n", key_update_number, action);   		printf(msg);   	}   	   	//Basic field checks    	if(sourceid != source_id)   	{   2		op_sim_end("Bad source id for ICI", "", "", "");   	}   O	else if(key_update_number > prop_key_update_counter || key_update_number <= 0)   	{   :		op_sim_end("Bad key_update_number for ICI", "", "", "");   	}   	   	//Find the tracker   	pTracker = OPC_NIL;   ^	for(tracker_index = 0; tracker_index < op_prg_list_size(active_updates_lst); tracker_index++)   	{   %		active_update_tacker *pTrackerTemp;   _		pTrackerTemp = (active_update_tacker *)op_prg_list_access(active_updates_lst, tracker_index);   >		if(pTrackerTemp->update_counter_number == key_update_number)   		{   			pTracker = pTrackerTemp;   				break;   		}   	}   	if(pTracker == OPC_NIL)   	{   		int i;   		char msg1[255];   		char msg2[255];   		char msg3[255];   		   !		printf("Current list state\n");   ;		for(i = 0; i < op_prg_list_size(active_updates_lst); i++)   		{   &			active_update_tacker *pTrackerTemp;   T			pTrackerTemp = (active_update_tacker *)op_prg_list_access(active_updates_lst, i);   			   T			sprintf(msg1, "update_counter_number=%d\n", pTrackerTemp->update_counter_number);   			printf(msg1);   		}   		   g		sprintf(msg1, "Tracker index=%d, List size=%d", tracker_index, op_prg_list_size(active_updates_lst));   p		sprintf(msg2, "key_update_number=%d, prop_key_update_counter=%d", key_update_number, prop_key_update_counter);   %		sprintf(msg3, "Action=%d", action);   		   9		op_sim_end("Could not find tracker", msg1, msg2, msg3);   	}   	   	if(action == 1)   	{   		//Gateway received packe   		if(pTracker->gateway_rx)   		{   7			op_sim_end("Two gateway rx interrupts", "", "", "");   		}   $		else if(pTracker->pkts_alive <= 0)   		{   0			op_sim_end("pkts_alive problem", "", "", "");   		}   		pTracker->gateway_rx = 1;   		   A		op_stat_write(stat_delay, op_sim_time() - generated_timestamp);   *		op_stat_write(stat_update_success, 1.0);   7		op_stat_write(stat_update_success_limited_loss, 1.0);   		   8		if(last_key_update_num_delivered >= key_update_number)   		{   2			op_sim_end("Problem with gateway", "", "", "");   		}   4		last_key_update_num_delivered = key_update_number;   	}   	else if (action == 2)   	{   
		//Store	   A		//if(pTracker->pkts_alive == 0 && pTracker->has_one_store != 0)   		if(pTracker->pkts_alive < 0)   		{   .			op_sim_end("Thats strange...", "", "", "");   		}   		   		pTracker->pkts_alive++;   		pTracker->has_one_store = 1;   	}   	else if (action == 3)   	{   		//Discard   		pTracker->pkts_alive--;   ,		pTracker->discard_reason = discard_reason;   		/*   		if(pTracker->pkts_alive <= 0)   		{   			pTracker->mark_for_delete--;   		}   		       !		//if(pTracker->pkts_alive <= 0)   $		if(pTracker->mark_for_delete <= 0)   		{   &			active_update_tacker *pTrackerTemp;   			   ;			if(pTracker->pkts_alive < 0 &&  pTracker->has_one_store)   			{   0				op_sim_end("Thats strange...", "2", "", "");   			}   			    			if(pTracker->gateway_rx == 0)   			{   )				//Nothing left - update has been lost   ,				op_stat_write(stat_update_success, 0.0);   				   				if(discard_reason == 1)   				{   					//Update   				}    				else if(discard_reason == 2)   				{   					//Mem full   :					if(key_update_number > last_key_update_num_delivered)   					{   ;						op_stat_write(stat_update_success_limited_loss, 0.0);   					}   				}   				else   				{   2					op_sim_end("Bad discard reason", "", "", "");   				}   			}   			   `			pTrackerTemp = (active_update_tacker *)op_prg_list_remove(active_updates_lst, tracker_index);   			if(pTrackerTemp != pTracker)   			{   5				op_sim_end("AHA,not another error!", "", "", "");   			}   			   			op_prg_mem_free(pTracker);   		}   		   		*/   	}   	else   	{   '		op_sim_end("Bad action", "", "", "");   	}   	   	has_one_update = 1;   	   :	for(i = 0; i < op_prg_list_size(active_updates_lst); i++)   	{   O		pTracker = (active_update_tacker *)op_prg_list_access(active_updates_lst, i);   	   		if(pTracker->pkts_alive <= 0)   		{   			pTracker->mark_for_delete--;   		}   		       !		//if(pTracker->pkts_alive <= 0)   $		if(pTracker->mark_for_delete <= 0)   		{   &			active_update_tacker *pTrackerTemp;   			   ;			if(pTracker->pkts_alive < 0 &&  pTracker->has_one_store)   			{   0				op_sim_end("Thats strange...", "2", "", "");   			}   			    			if(pTracker->gateway_rx == 0)   			{   )				//Nothing left - update has been lost   ,				op_stat_write(stat_update_success, 0.0);   				   %				if(pTracker->discard_reason == 1)   				{   					//Update   				}   *				else if(pTracker->discard_reason == 2)   				{   					//Mem full   H					if(pTracker->update_counter_number > last_key_update_num_delivered)   					{   ;						op_stat_write(stat_update_success_limited_loss, 0.0);   					}   				}   				else   				{   2					op_sim_end("Bad discard reason", "", "", "");   				}   			}   			   T			pTrackerTemp = (active_update_tacker *)op_prg_list_remove(active_updates_lst, i);   			if(pTrackerTemp != pTracker)   			{   5				op_sim_end("AHA,not another error!", "", "", "");   			}   			   			op_prg_mem_free(pTracker);   		}   	}   	   	op_ici_destroy(iciptr);   	FOUT;   }       void stat_finalize()   {   	Stathandle oneup;   	int i;       	FIN(stat_finalize());   	   I	oneup = op_stat_reg("One Update",OPC_STAT_INDEX_NONE, OPC_STAT_GLOBAL);	   &	op_stat_write(oneup, has_one_update);   	   :	for(i = 0; i < op_prg_list_size(active_updates_lst); i++)   	{   !		active_update_tacker *pTracker;   O		pTracker = (active_update_tacker *)op_prg_list_access(active_updates_lst, i);   		   		if(pTracker->gateway_rx == 0)   		{   5			//Receiving should already have been taken care of   +			op_stat_write(stat_update_success, 0.0);   			   F			if(pTracker->update_counter_number > last_key_update_num_delivered)   			{   9				op_stat_write(stat_update_success_limited_loss, 0.0);   			}   		}   		   >		if(pTracker->update_counter_number == prop_last_key_updated)   		{    			if(pTracker->gateway_rx == 0)   			{   M				op_stat_write(stat_delay, op_sim_time() - pTracker->generated_timestamp);   			}   		}   	}   	   	FOUT;   }                                         Z   Z          J   init   J       J   !   char msg[100];   char updatedist_str [128];       self_id = op_id_self();       7op_ima_obj_attr_get (self_id, "Source ID", &source_id);   9op_ima_obj_attr_get (self_id, "Property Key", &prop_key);   Jop_ima_obj_attr_get (self_id, "Property Update Interval", updatedist_str);   7op_ima_obj_attr_get (self_id, "Stop Time", &stop_time);       Dop_ima_obj_attr_get (self_id, "Enable Properties", &is_source_mode);       *active_updates_lst = op_prg_list_create();   has_one_update = 0;       prop_key_update_counter = 0;   :prop_last_key_updated = 0; //So it gets updated right away       =update_dist_ptr = oms_dist_load_from_string (updatedist_str);       Gstat_delay = op_stat_reg("Delay",OPC_STAT_INDEX_NONE, OPC_STAT_GLOBAL);   Ystat_update_success = op_stat_reg("Update Success",OPC_STAT_INDEX_NONE, OPC_STAT_GLOBAL);   ~stat_update_success_limited_loss = op_stat_reg("Update Success - Losses by buffer full",OPC_STAT_INDEX_NONE, OPC_STAT_GLOBAL);       if(is_source_mode)   {   	schedule_update();   	   	if(stop_time > 0)   	{   ?		op_intrpt_schedule_self (op_sim_time() + stop_time, IC_STOP);   	}   }   J                     J   ����   J          pr_state           Z          J   active   J       J   +   Packet *pPkt;       4if(prop_key_update_counter != prop_last_key_updated)   {    	active_update_tacker *pTracker;   	int i;   	   	//Error check   :	for(i = 0; i < op_prg_list_size(active_updates_lst); i++)   	{   0		//Might be able to just check the tail instead   	   O		pTracker = (active_update_tacker *)op_prg_list_access(active_updates_lst, i);   >		if(pTracker->update_counter_number == prop_last_key_updated)   		{   #			if(pTracker->has_one_store == 0)   			{   >				op_sim_end("Did not receive store interrupt", "", "", "");   			}   		}   	}       1	prop_last_key_updated = prop_key_update_counter;   	   &	pPkt = op_pk_create_fmt("keyupdate");   5	op_pk_nfd_set_int32(pPkt, "source_id", source_id);		   -	op_pk_nfd_set_int32(pPkt, "key", prop_key);	   I	op_pk_nfd_set_int32(pPkt, "key_update_number", prop_key_update_counter);   ?	op_pk_nfd_set_dbl(pPkt, "generated_timestamp", op_sim_time());   9	op_pk_nfd_set_objid(pPkt, "source_prop_objid", self_id);   	   V	pTracker = (active_update_tacker *) op_prg_mem_alloc (sizeof (active_update_tacker));   ;	pTracker->update_counter_number = prop_key_update_counter;   	pTracker->pkts_alive = 0;   	pTracker->has_one_store = 0;   	pTracker->gateway_rx = 0;   /	pTracker->generated_timestamp = op_sim_time();   	pTracker->mark_for_delete = 3;   	   D	op_prg_list_insert(active_updates_lst, pTracker, OPC_LISTPOS_TAIL);   	   %	op_pk_send(pPkt, 0); //Output stream   }   J                         ����             pr_state           �          J   disable   J       J       J                         ����             pr_state         Z            J   
do_nothing   J                                       ����             pr_state        �   �          J   stop   J       J      char msg_str[255];       .if (op_ev_valid (next_update_evh) == OPC_TRUE)   {   U	sprintf(msg_str, "[%d] Stopping property updates @ %d\n", source_id, op_sim_time());   	printf(msg_str);    	op_ev_cancel (next_update_evh);   }   J                         ����             pr_state                        �   g      q   Z   �   \          J   tr_0   J       J   SOURCE_MODE   J       ����          J    ����   J          ����                       pr_transition               �   �        h  0   �     �          J   tr_1   J       J   DISABLE_PROP_UPDATES   J       J����   J       J    ����   J          ����                       pr_transition                         L   �   )  #   )     J          J   tr_2   J       J   PROP_VAL_CHANGED   J       J   	new_val()   J       J    ����   J          ����                       pr_transition               �  2        �  )     �       �          J   tr_3   J       J   PROP_VAL_CHANGED   J       J   	new_val()   J       J    ����   J          ����                       pr_transition               �   �      �   �   �   �     b          J   tr_4   J       J   ENABLE_PROP_UPDATES   J       ����          J    ����   J          ����                       pr_transition                �   �      W   `   T            J   tr_7   J       J   !SOURCE_MODE   J       ����          J    ����   J          ����                       pr_transition               �  A      k     �     �  *   f            J   tr_8   J       J   default   J       ����          J    ����   J          ����                       pr_transition      	        �   `         a  i   k  b   �     a          J   tr_9   J       J   I_GW_PKT_RX   J       J   gw_pkt_rx()   J       J    ����   J          ����                       pr_transition      
        �       $   �  n   �  ^       �          J   tr_10   J       J   I_GW_PKT_RX   J       J   gw_pkt_rx()   J       J    ����   J          ����                       pr_transition              �   A      �   S  Q   M  Z   8   �   L          J   tr_11   J       J   	I_END_SIM   J       J   stat_finalize()   J       J    ����   J          ����                       pr_transition              �  2        �  Z  ?  b  4     �          J   tr_12   J       J   	I_END_SIM   J       J   stat_finalize()   J       J    ����   J          ����                       pr_transition              ^   �        �  H   �  �   �          J   tr_13   J       J   I_STOP   J       ����          J    ����   J          ����                       pr_transition              b   �     !   d  @   �  �   �          J   tr_14   J       J   I_STOP   J       ����          J    ����   J          ����                       pr_transition              Y   u     �   �  �   l     �  �   �          J   tr_15   J       J   I_GW_PKT_RX   J       J   gw_pkt_rx()   J       J    ����   J          ����                       pr_transition              ]   �     �   �     �  �   �  �   �          J   tr_16   J       J   	I_END_SIM   J       J   stat_finalize()   J       J    ����   J          ����                       pr_transition              [   �     �   �  �   �  �   �  �   �          J   tr_17   J       J   +DISABLE_PROP_UPDATES || ENABLE_PROP_UPDATES   J       ����          J    ����   J          ����                       pr_transition                       
One Update          KThe percentage of properties which have successfully updated at least once.����   bucket/1 total/sample mean����        ԲI�%��}   Update Success        ������������        ԲI�%��}   &Update Success - Losses by buffer full          �Does not count updates lost due to replacement or those lost with a update numer less than what has already been deliverd as losses.������������        ԲI�%��}   Delay        ������������        ԲI�%��}      oms_dist_support   oms_string_support                    