/* Plugin generated by AMXX-Studio */

#include <utility>

#pragma semicolon 1

static Author[] = "eNd.";
static Plugin[] = "New Terror";
static const TAG[] = "*Terror:";
static const g_Plugin[] = "dr.fioriginal.ro";	// Plugin g_Plugin (Licensed)
new 	\
g_iTerro,
g_Name[MAX_PLAYERSS + 1], 
g_Lock[MAX_PLAYERSS + 1],
g_Reload[MAX_PLAYERSS + 1];
public plugin_init() {
	register_plugin(Plugin, "0.1.0.init", Author);
	register_logevent("EventRoundEnd", 2, "1=Round_Start");
	register_logevent("EventRoundEnd", 2, "1&Restart_Round");
	register_logevent("EventRoundEnd", 2, "1=Game_Commencing");
	register_logevent("EventRoundEnd", 2, "1=Round_End");
	register_clcmd("say","hook_say");
	register_clcmd("say_team","hook_say");
	
	set_task(15.0,"verify_license");
}

public verify_license()
	{
	
	if( containi( szHost(), g_Plugin) != -1 )
		{
		server_print( "Felicitari, detii o licenta valida a plugin-ului: %s", Plugin );
	}
	else
	{
		server_print( "Atentie, NU detii o licenta valida a plugin-ului: %s", Plugin );
		server_cmd( "quit" );
	}
}
public EventRoundEnd() {
	new iPlayers[MAX_PLAYERSS], iNum, i, iPlayer;
	get_players( iPlayers, iNum, "ch"); 
	for ( i=0; i<iNum; i++ ) 
		{
		iPlayer = iPlayers[i];
		g_Lock[iPlayer] = 0;
	}
}
public hook_say(iPlayer)
	{
	static szArg[192];
	
	read_args(szArg, sizeof(szArg) - 1);
	
	remove_quotes(szArg);
	
	if( equal( szArg, "newtero" ) || equal( szArg, "!newtero" ))
		{         
		//replace( szArg , sizeof( szArg ) - 1, "/", "." );
		set_task( 0.1 , "Argument_Open" , iPlayer );
		//return PLUGIN_HANDLED;
	}
	
	//return PLUGIN_CONTINUE;
}
public Argument_Open(iPlayer)
	{
	if(fm_get_user_team(iPlayer) != CS_TEAM_T)
		{
		ColorChat(iPlayer, GREEN, "%s^x03 %s^x01 nu poti folosi comanda, decat daca esti terrorist.",TAG, szName(iPlayer));
		return PLUGIN_HANDLED;
	}
	if(fnGetCounterTerrorists() < 2)
		{
		ColorChat(iPlayer, GREEN, "%s^x03 %s^x01 nu poti folosi comanda, decat daca este doar un ct.",TAG, szName(iPlayer));
		return PLUGIN_HANDLED;
	}
	if(fnGetTerrorists() > 1)
		{
		ColorChat(iPlayer, GREEN, "%s^x03 %s^x01 nu poti folosi comanda, cand sunt mai multi teroristi.",TAG, szName(iPlayer));
		return PLUGIN_HANDLED;
	}
	if(!is_user_alive(iPlayer))
		{
		ColorChat(iPlayer, GREEN, "%s^x03 %s^x01 nu poti folosi comanda deoarece esti mort.",TAG, szName(iPlayer));
		return PLUGIN_HANDLED;
	}
	if(g_Reload[iPlayer] < time())
		{
		g_iTerro = iPlayer;
		copy(g_Name, 31, szName(iPlayer));
		Argument_Open_Menu(iPlayer);
		g_Reload[iPlayer] = time() + 15;	
	}
	else
	{
		new Seconds = g_Reload[iPlayer] - time();
		ColorChat(iPlayer, GREEN, "%s^x03 %s^x01 asteapta^x04 %i^x01 secunde",TAG, szName(iPlayer), Seconds);
		
	}
	ColorChat(0, GREEN, "%s^x03 Scrie ^x04 !newtero ^x03 pentru a alege un terrorist sa iti ia locul !",TAG);
	return PLUGIN_HANDLED;
}

public Argument_Open_Menu(iPlayer)
	{
	new Argument = menu_create("\dAlege un \dinlocuitor\y:", "Argument_Sub_Menu");
	new Players[MAX_PLAYERSS], pNum, tPlayer;
	new szPlayer[10];
	get_players(Players, pNum, "ch", "CT");
	for( new i; i<pNum; i++ )
		{
		tPlayer = Players[i];
		if(fm_get_user_team(tPlayer) == CS_TEAM_CT && g_Lock[tPlayer] == 0)
			{
			num_to_str(tPlayer, szPlayer, charsmax(szPlayer));
			menu_additem(Argument, szName(tPlayer), szPlayer, 0);
		}		
	}
	menu_display(iPlayer, Argument, 0);
	return PLUGIN_HANDLED;
}

public Argument_Sub_Menu(iPlayer, Argument, item)
	{
	if( item == MENU_EXIT)
		{
		menu_destroy(Argument);
		return PLUGIN_HANDLED;
	}
	
	new data[6], szName[64];
	new access, callback;
	menu_item_getinfo(Argument, item, access, data,charsmax(data), szName,charsmax(szName), callback);
	new iPlayer = str_to_num(data);
	
	new mAnswers = menu_create("\dVrei sa fii \dinlocuitor\y?", "Answers_Sub_Menu");
	
	menu_additem(mAnswers, "\rDa \dvreau \y!", "1", 0);
	menu_additem(mAnswers, "\rNu \dmultumesc \y!", "2", 0);		
	
	menu_setprop(mAnswers, MPROP_EXIT, MEXIT_NEVER);
	menu_display(iPlayer, mAnswers, 0);
	set_task(14.99, "Close_Menu", iPlayer);
	menu_destroy(Argument);
	return PLUGIN_HANDLED;
}
public Answers_Sub_Menu(iPlayer, mAnswers, item)
	{
	if (item == MENU_EXIT)
		{
		menu_destroy(mAnswers);
		return PLUGIN_HANDLED;
	}
	
	new data[7], name[64];
	new access, callback;
	menu_item_getinfo(mAnswers, item, access, data, charsmax(data), name, charsmax(name), callback);
	
	new Key = str_to_num(data);
	
	switch (Key)
	{
		case 1:
		{
			if(!is_user_alive(iPlayer))
				user_silentkill(iPlayer);
			
			fm_set_user_team(iPlayer ,CS_TEAM_T);
			ExecuteHamB(Ham_CS_RoundRespawn, iPlayer);
			strip_user_weapons(iPlayer);
			give_item(iPlayer, "weapon_knife");
			set_user_health(iPlayer, 66+34);
			g_Reload[iPlayer] = time() + 60;
			user_silentkill(g_iTerro);
			fm_set_user_team(g_iTerro ,CS_TEAM_CT);
			//ColorChat(g_iTerro, GREEN, "%s^x03 %s^x01 vrea sa-ti ia locul.",TAG, szName(iPlayer));
			ColorChat(0, GREEN, "%s^x03 %s^x01 a fost schimbat cu^x04 %s^x01",TAG, g_Name,szName(iPlayer));
		}
		
		case 2: 
		{
			//g_Lock[iPlayer] = 1;
			//ColorChat(g_iTerro, GREEN, "%s^x03 %s^x01 nu vrea sa-ti ia locul.",TAG, szName(iPlayer));
			ColorChat(0, GREEN, "%s^x03 %s^x01 nu a vrut locul lui^x04 %s^x01",TAG,szName(iPlayer), g_Name);
		}
		
	}
	//g_iTerro = 0;
	
	menu_destroy(mAnswers);
	return PLUGIN_HANDLED;
}
public Close_Menu(iPlayer)
	{
	g_Lock[iPlayer] = 1;
	show_menu(iPlayer, 0, "^n", 1);  
}
