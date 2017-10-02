/* Allow Round Finish
About:
This plugin allows the last round to be finnished even if the timelimit has expired

Credits: 
Ops in #AMXmod @ Quakenet for alot of help ( + AssKicR & CheesyPeteza ) 
*/

#include <amxmodx>

new g_IsLastRound = 0

#define TASK_ID_CHECKFORMAPEND 241
#define TASK_ID_DELAYMAPCHANGE 242

public plugin_init()
{
	register_plugin("Allow round finish", "1.0.2" ,"EKS")
	
	register_event("SendAudio","Event_EndRound","a","2=%!MRAD_terwin","2=%!MRAD_ctwin","2=%!MRAD_rounddraw")
	set_task(15.0,"Task_MapEnd",TASK_ID_CHECKFORMAPEND,_,_,"d",1)
}

public Task_MapEnd()
{
	if(get_playersnum())
	{
		g_IsLastRound = 1
		server_cmd("mp_timelimit 0")
		client_print(0,print_chat,"Timelimit has expired, mapchange will happen after this round")
	}
}
public Event_EndRound()
{
	if(g_IsLastRound == 1)
	{
		client_print(0,print_chat,"Round is over, changing map.")
		set_task(3.0,"Task_DelayMapEnd",TASK_ID_DELAYMAPCHANGE,_,_,"a",1) // We delay the end of the map with a few sec, so the last guys death is viewable
	}
}
public server_changelevel(map[])
{
	if(g_IsLastRound == 1)
		Task_DelayMapEnd()
}
public Task_DelayMapEnd()
{
	remove_task(TASK_ID_DELAYMAPCHANGE)
	g_IsLastRound = 0
	if(get_cvar_num("mp_timelimit") == 0)
	{
		new Map[64];
		get_cvar_string("amx_nextmap", Map, charsmax(Map));
		engine_changelevel(Map);
		set_task(2.0, "forceChange");
		
	}
}

public forceChange()
{
	new Map[64];
	get_cvar_string("amx_nextmap", Map, charsmax(Map));
	server_cmd("changelevel %s", Map);
}