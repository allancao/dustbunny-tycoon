#include "opnet.h"

void cust_link_closure (Packet* pk)
{
	double distance;
	int result = 0;

	FIN (cust_link_closure (Packet* pk));

	distance = op_td_get_dbl(pk, OPC_TDA_RA_START_DIST);
	
	if(distance <= 60)
	{
		result = 1;
	}
	
	/* extract required information from packet. */ 
	/* perform calculation of closure indication. */ 
	/* place result in TDA to return to Simulation Kernel. */
	op_td_set_int (pk, OPC_TDA_RA_CLOSURE, result);

	FOUT;
} 
