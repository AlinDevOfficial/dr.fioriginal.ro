#include < amxmodx >
	#include < ddhudmessage >
	
	#pragma semicolon 1

		// --| Credite lui CryWolf pentru 'layout' !!
	new const
		PLUGIN_NAME[ ] 		= "DHUD Team Details",
		PLUGIN_VERSION[ ] 	= "0.1.7";
	
	/* Copyright (c) 2013 Askhanar  @eXtreamCS.com
	
	http://www.eXtreamCS.com/forum
	http://www.amxmodx.org
	http://www.amxmodx.ro
	 
	*/
	
	
	// --| Culorile in RRR GGG BBB ( poate fi luata si in paint ).
	
	#define	iTerroRed	255
	#define	iTerroGreen	0
	#define	iTerroBlue	0
	
	#define	iCtRed	0
	#define	iCtGreen	0
	#define	iCtBlue	255
	
	#define	iRoundsRed	255
	#define	iRoundsGreen	255
	#define	iRoundsBlue	255
	
	#define	iLastWonRed	255
	#define	iLastWonGreen	255
	#define	iLastWonBlue	0
	
	new const
		g_szCts[ ] 	= "^t^t Ct-Strike %02i",
		g_szTerrorists[ ]	= "^t^t%02i Terrorists",
		g_szRounds[ ]	= "[ %02i ]^n%02i Wins %02i";
		
		
	enum _:iTeamWons
	{
		TERRO,
		CT
	}
	
	new g_iTeamWons[ iTeamWons ];
	new g_iRounds;
	new g_iLastWon;
				
public plugin_init( )
{
	
	register_plugin( PLUGIN_NAME, PLUGIN_VERSION, "Askhanar" );
	
	
	register_event( "HLTV", "ev_NewRound", "a", "1=0", "2=0" );
	register_event( "TextMsg", "ev_RoundRestart", "a", "2&#Game_C", "2&#Game_w" );
	
	register_event( "SendAudio", "ev_TerroristWin", "a", "2&%!MRAD_terwin" );
	register_event( "SendAudio", "ev_CtWin", "a", "2&%!MRAD_ctwin" );
	
	g_iRounds = 0;
	g_iTeamWons[ TERRO ] = 0;
	g_iTeamWons[ CT ] = 0;
	g_iLastWon = -1;
	
	set_task( 1.0, "task_DisplayHudScore", _, _, _, "b", 0 );
	// Add your code here...
}


public ev_NewRound( )	g_iRounds++;
public ev_RoundRestart( )
{
	g_iLastWon = -1;
	g_iRounds = 0;
	
	g_iTeamWons[ TERRO ] = 0;
	g_iTeamWons[ CT ] = 0;
}
public ev_TerroristWin( )
{ 	
	g_iLastWon = TERRO;
	g_iTeamWons[ TERRO ]++;
}
public ev_CtWin( )
{	
	g_iLastWon = CT;
	g_iTeamWons[ CT ]++;
}

public task_DisplayHudScore( )
{
	
	static iPlayers[ 32 ];
	static iPlayersNum;
		
	get_players( iPlayers, iPlayersNum, "ch" );
	if( !iPlayersNum )
		return;
	
	static szCrap[ 32 ];
	static iTerro, iCt;
	
	get_players( szCrap, iTerro, "aech", "TERRORIST" );
	get_players( szCrap, iCt, "aech", "CT" );
	
	static id, i;
	for( i = 0; i < iPlayersNum; i++ )
	{
		id = iPlayers[ i ];
		
		set_ddhudmessage( iCtRed, iCtGreen, iCtBlue, 0.30, is_user_alive( id ) ? 0.01 : 0.16 , 0, _, 2.0, 1.0, 1.0, false );
		show_ddhudmessage( id, g_szCts, iCt );
		

		set_ddhudmessage( iRoundsRed, iRoundsGreen, iRoundsBlue, -1.0, is_user_alive( id ) ? 0.01 : 0.16 , 0, _, 2.0, 1.0, 1.0, false );
		show_ddhudmessage( id, g_szRounds, g_iRounds, g_iTeamWons[ CT ], g_iTeamWons[ TERRO ] );
		
		set_ddhudmessage( iTerroRed, iTerroGreen, iTerroBlue, 0.51, is_user_alive( id ) ? 0.01 : 0.16 , 0, _, 2.0, 1.0, 1.0, false );
		show_ddhudmessage( id, g_szTerrorists, iTerro );
		
		
		if( g_iLastWon != -1 )
		{
			switch( g_iLastWon )
			{
				case TERRO:
				{
					set_ddhudmessage( iLastWonRed, iLastWonGreen, iLastWonBlue, 0.58, is_user_alive( id ) ? 0.01 : 0.16 , 0, _, 2.0, 1.0, 1.0, false );
					show_ddhudmessage( id, "^n>" );
				}
				case CT:
				{
					set_ddhudmessage( iLastWonRed, iLastWonGreen, iLastWonBlue, 0.41, is_user_alive( id ) ? 0.01 : 0.16 , 0, _, 2.0, 1.0, 1.0, false );
					show_ddhudmessage( id, "^n<" );
				}
				
			}
			
		}
		
		
	}
	
}
