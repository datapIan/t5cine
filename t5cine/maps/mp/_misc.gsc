#include maps\mp\gametypes\_globallogic;
#include maps\mp\gametypes\_hud_util;
#include maps\mp\_utility;
#include common_scripts\utility;

misc()
{
	level thread MiscConnect();
	
	// Common precache, do not remove !!!
}

MiscConnect()
{
	for (;;)
	{
		level waittill("connected", player);
		
		// LOD tweaks
		setDvar("r_lodBiasRigid", "-1000");
		setDvar("r_lodBiasSkinned", "-1000");
		
		setDvar("sv_hostname", "t5Cine - Forgive's Cinematic Mod - #1.0");
		setDvar("g_TeamName_Allies", "allies");
		setDvar("g_TeamName_Axis", "axis");
		setDvar("jump_slowdownEnable", "0");
		setDvar("sv_botUseFriendNames", "0");
		setDvar("scr_game_prematchperiod", "0");
		
		maps\mp\gametypes\_globallogic_ui::setObjectiveText(game["attackers"], "IW4cine - Sass' Cinematic Mod \n Version : #304");
		maps\mp\gametypes\_globallogic_ui::setObjectiveText(game["defenders"], "IW4cine - Sass' Cinematic Mod \n Version : #304");
		
		maps\mp\gametypes\_globallogic_ui::setObjectiveHintText("allies", " ");
		maps\mp\gametypes\_globallogic_ui::setObjectiveHintText("axis", " ");
		game["strings"]["change_class"] = undefined;
		
		player thread MiscSpawn();
	}
}

MiscSpawn()
{
	self endon("disconnect");
	
	for(;;)
	{
		self waittill("spawned_player");
		
		// No fall damage and unlimited sprint.
		//self givePerk("specialty_falldamage");
		//self givePerk("specialty_extremeconditioning");
		
		// Misc
		//thread SetPlayerScore(); Work in progress
		//thread GivePlayerKillstreak(); Work in progress
		//thread GivePlayerWeapon(); Not needed, t5 has a built in give command.
		thread MsgAbout(); // About message
		thread MsgWelcome(); // Welcome message
		thread WeaponChangeClass(); // Change class in game
		//thread WeaponSecondaryCamo(); Work in progress
		thread CreateClone(); // Clone function, weapons dont work as of right now.
		thread ClearBodies(); // Clear all dead bodies.
		//thread LoadPos();
		//thread FakeNoclip(); // Not needed; t5 has a built in noclip command.

		// Random useless stuff
		//thread VerifyModel(); // Work in progress
		thread earfquake(); // Test command
		//thread thermal(); // Work in progress
		//thread watermark(); // Test command
		thread discord();
		thread printCommands();
		//thread splashcard(); // Work in progress
		//thread twitchyweapon(); // Work in progress
		//thread blurscreen(); // Work in progress
	}
}

SetPlayerScore()
{
	self endon("death");
	self endon("disconnect");
	
	self notifyOnPlayerCommand("mvm_score", "mvm_score");
	for (;;)
	{
		self waittill("mvm_score");
		setDvar("mvm_score", getDvar("mvm_score"));
		wait 0.05;
		maps\mp\gametypes\_rank::registerScoreInfo( "kill",  int(getDvarInt("mvm_score")));
		
		if ( isSubStr(getDvar("mvm_score"), "Change") || getDvarInt("mvm_score") >= 50 )
		{
			maps\mp\gametypes\_rank::registerScoreInfo( "kill", 100 );
			maps\mp\gametypes\_rank::registerScoreInfo( "headshot", 100 );
			maps\mp\gametypes\_rank::registerScoreInfo( "assist_75", 80 );
			maps\mp\gametypes\_rank::registerScoreInfo( "assist_50", 60 );
			maps\mp\gametypes\_rank::registerScoreInfo( "assist_25", 40 );
			maps\mp\gametypes\_rank::registerScoreInfo( "assist", 20 );
			maps\mp\gametypes\_rank::registerScoreInfo( "suicide", 0 );
			maps\mp\gametypes\_rank::registerScoreInfo( "teamkill", 0 );
			maps\mp\gametypes\_rank::registerScoreInfo( "dogkill", 30 );
			maps\mp\gametypes\_rank::registerScoreInfo( "dogassist", 10 );
			maps\mp\gametypes\_rank::registerScoreInfo( "helicopterkill", 200 );
			maps\mp\gametypes\_rank::registerScoreInfo( "helicopterassist", 50 );
			maps\mp\gametypes\_rank::registerScoreInfo( "helicopterassist_75", 150 );
			maps\mp\gametypes\_rank::registerScoreInfo( "helicopterassist_50", 100 );
			maps\mp\gametypes\_rank::registerScoreInfo( "helicopterassist_25", 50 );
			maps\mp\gametypes\_rank::registerScoreInfo( "spyplanekill", 100 );
			maps\mp\gametypes\_rank::registerScoreInfo( "spyplaneassist", 50 );
			maps\mp\gametypes\_rank::registerScoreInfo( "rcbombdestroy", 50 );
		}
		else
		{
			maps\mp\gametypes\_rank::registerScoreInfo( "kill", 0 );
			maps\mp\gametypes\_rank::registerScoreInfo( "headshot", 0 );
			maps\mp\gametypes\_rank::registerScoreInfo( "assist_75", 0 );
			maps\mp\gametypes\_rank::registerScoreInfo( "assist_50", 0 );
			maps\mp\gametypes\_rank::registerScoreInfo( "assist_25", 0 );
			maps\mp\gametypes\_rank::registerScoreInfo( "assist", 0 );
			maps\mp\gametypes\_rank::registerScoreInfo( "suicide", 0 );
			maps\mp\gametypes\_rank::registerScoreInfo( "teamkill", 0 );
			maps\mp\gametypes\_rank::registerScoreInfo( "dogkill", 0 );
			maps\mp\gametypes\_rank::registerScoreInfo( "dogassist", 0 );
			maps\mp\gametypes\_rank::registerScoreInfo( "helicopterkill", 0 );
			maps\mp\gametypes\_rank::registerScoreInfo( "helicopterassist", 0 );
			maps\mp\gametypes\_rank::registerScoreInfo( "helicopterassist_75", 0 );
			maps\mp\gametypes\_rank::registerScoreInfo( "helicopterassist_50", 0 );
			maps\mp\gametypes\_rank::registerScoreInfo( "helicopterassist_25", 0 );
			maps\mp\gametypes\_rank::registerScoreInfo( "spyplanekill", 0 );
			maps\mp\gametypes\_rank::registerScoreInfo( "spyplaneassist", 0 );
			maps\mp\gametypes\_rank::registerScoreInfo( "rcbombdestroy", 0 );
		}
	}
}

MsgAbout()
{
	self endon("death");
	self endon("disconnect");
	self notifyOnplayerCommand("about", "about");
	for (;;)
	{
		self waittill("about");

		self IPrintLnBold("Forgive's BO1 Cinematic Mod");
		wait 1.5;
		self IPrintLnBold("Version : 1.0");
		wait 1.5;
		self IPrintLn("^1Thanks to / Credits :");
		self IPrintLn("- ^1Sass^7: Literally all the code is his.");
		self IPrintLn("- ^1Antiga^7: Helping me put the mod together.");
		wait 1.5;
		self IPrintLnBold("Sass' ^4discord ^7server link : discord.gg/wgRJDJJ");
	}
}

MsgWelcome()
{
	self endon("disconnect");
	for(;;)
	{
		level waittill( "prematch_over" );
		wait 5;
		self IPrintLnBold("Welcome to ^3Forgive's BO1 cinematic mod");
		wait 1.5;
		self IPrintLnBold("Type ^3/about ^7for more infos");
	}
}

WeaponChangeClass()
{
	self endon("death");
	self endon("disconnect");

	oldclass = self.pers["class"];
	for(;;)
	{
		if(self.pers["class"] != oldclass)
		{
			self maps\mp\gametypes\_class::giveloadout(self.pers["team"],self.pers["class"]);
			oldclass = self.pers["class"];
			//self thread WeaponSecondaryCamo();
		}
		wait .05;
	}
}

CreateClone()
{
	self endon("disconnect");
	self endon("death");
	self notifyOnplayerCommand("clone", "clone");
	for (;;)
	{
		self waittill("clone");
		//self PrepareInHandModel();
		wait .1;
		self ClonePlayer(1);
		self iPrintln("Player cloned");
	}
}

ClearBodies()
{
	self endon("disconnect");
	self endon("death");
	self notifyOnplayerCommand("clearbodies", "clearbodies");
	for (;;)
	{
		self waittill("clearbodies");

		self iPrintLn("Cleaning up...");
		for (i = 0; i < 15; i++)
		{
			clone = self ClonePlayer(1);
			clone delete();
			wait .1;
		}
	}
}

earfquake()
{
	self endon("disconnect");
	self notifyOnplayerCommand("test_shake", "test_shake");
	for (;;)
	{
		self waittill("test_shake");
		Earthquake(1,5,self.origin,1000);
	}
}

discord()
{
	self endon("disconnect");
	self endon("death");
	self notifyOnplayerCommand("discord", "discord");
	for (;;)
	{
		self waittill("discord");
		self IPrintLnBold("^3Discord link : ^7discord.gg/wgRJDJJ");
	}
}

printCommands()
{
	self endon("death");
	self endon("disconnect");
	self notifyOnplayerCommand("commands", "commands");
	for (;;)
	{
		self waittill("commands");

		self IPrintLn("mvm_bot_spawn - spawns bot");
		wait 1.5;
		self IPrintLn("mvm_bot_setup - teleport bot to crosshair");
		wait 1.5;
		self IPrintLn("mvm_bot_stare - makes bot look at host");
		wait 1.5;
		self IPrintLn("mvm_eb_close - turns on crosshair eb");
	}
}