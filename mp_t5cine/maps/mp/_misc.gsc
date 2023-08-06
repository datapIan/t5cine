/*
 *	SASS' CINEMATIC MOD - Misc file (#304)
 */

//#include maps\mp\gametypes\_gamelogic;
#include maps\mp\gametypes\_hud_util;
#include maps\mp\_utility;
#include common_scripts\utility;
#include maps\mp\gametypes\_globallogic_ui;

misc()
{
	level thread MiscConnect();

	// Common precache, do not remove !!!
	PrecacheModel("defaultactor");
	PrecacheModel("projectile_rpg7");
	PrecacheModel("projectile_semtex_grenade_bombsquad");
	//PrecacheMPAnim("pb_stand_alert");
	//PrecacheMPAnim("pb_stand_death_chest_blowback");
	precacheItem("lightstick_mp");
}

MiscConnect()
{
	for (;;)
	{
		level waittill("connected", player);

		// LOD tweaks
		setDvar("r_lodBiasRigid", "-1000");
		setDvar("r_lodBiasSkinned", "-1000");

		setDvar("sv_hostname", "^3Sass' Cinematic Mod ^7- Ported to T5 by ^3Forgive");
		setDvar("g_TeamName_Allies", "allies");
		setDvar("g_TeamName_Axis", "axis");
		setDvar("jump_slowdownEnable", "0");

		setObjectiveText(game["attackers"], "^3Sass' Cinematic Mod ^7- Ported to T5 by ^3Forgive");
		setObjectiveText(game["defenders"], "^3Sass' Cinematic Mod ^7- Ported to T5 by ^3Forgive");
		setObjectiveHintText("allies", " ");
		setObjectiveHintText("axis", " ");
		game["strings"]["change_class"] = " ";

		player thread MiscSpawn();
	}
}

MiscSpawn()
{
	self endon("disconnect");

	for (;;)
	{
		self waittill("spawned_player");

		// No fall damage and unlimited sprint.
		setdvar( "scr_giveperk", "specialty_falldamage" );
        setdvar( "scr_giveperk", "specialty_longersprint" );

		// Misc
		thread SetPlayerScore();
		thread GivePlayerKillstreak();
		//thread GivePlayerWeapon();
		thread MsgAbout();
		thread MsgWelcome();
		thread WeaponChangeClass();
		//thread WeaponSecondaryCamo();
		thread CreateClone();
		thread ClearBodies();
		thread LoadPos();
		thread FakeNoclip();

		// Random useless stuff
		thread VerifyModel();
		//thread water();
		//thread dirt();
		//thread earfquake();
		//thread thermal();
		//thread watermark();
		//thread discord();
		//thread splashcard();
		//thread twitchyweapon();
		//thread blurscreen();

	}
}

SetPlayerScore()
{
	self endon("death");
	self endon("disconnect");
	
	setDvar("mvm_score", "Change score per kill");
	for (;;)
	{
		if(getDvar("mvm_score") != "Change score per kill")
        {
		    maps\mp\gametypes\_rank::registerScoreInfo( "kill",  int(getDvarInt("mvm_score")));

		    if ( isSubStr(getDvar("mvm_score"), "Change") || getDvarInt("mvm_score") >= 50 )
		    {
		    	maps\mp\gametypes\_rank::registerScoreInfo( "headshot", 50 );
		    	maps\mp\gametypes\_rank::registerScoreInfo( "execution", 100 );
		    	maps\mp\gametypes\_rank::registerScoreInfo( "avenger", 50 );
		    	maps\mp\gametypes\_rank::registerScoreInfo( "defender", 50 );
		    	maps\mp\gametypes\_rank::registerScoreInfo( "posthumous", 25 );
		    	maps\mp\gametypes\_rank::registerScoreInfo( "revenge", 50 );
		    	maps\mp\gametypes\_rank::registerScoreInfo( "double", 50 );
		    	maps\mp\gametypes\_rank::registerScoreInfo( "triple", 75 );
		    	maps\mp\gametypes\_rank::registerScoreInfo( "multi", 100 );
		    	maps\mp\gametypes\_rank::registerScoreInfo( "buzzkill", 100 );
		    	maps\mp\gametypes\_rank::registerScoreInfo( "firstblood", 0 );
		    	maps\mp\gametypes\_rank::registerScoreInfo( "comeback", 100 );
		    	maps\mp\gametypes\_rank::registerScoreInfo( "longshot", 50 );
		    	maps\mp\gametypes\_rank::registerScoreInfo( "assistedsuicide", 100 );
		    	maps\mp\gametypes\_rank::registerScoreInfo( "knifethrow", 100 );
		    }
		    else 
		    {
		    	maps\mp\gametypes\_rank::registerScoreInfo( "headshot", 0 );
		    	maps\mp\gametypes\_rank::registerScoreInfo( "execution", 0 );
		    	maps\mp\gametypes\_rank::registerScoreInfo( "avenger", 0 );
		    	maps\mp\gametypes\_rank::registerScoreInfo( "defender", 0 );
		    	maps\mp\gametypes\_rank::registerScoreInfo( "posthumous", 0 );
		    	maps\mp\gametypes\_rank::registerScoreInfo( "revenge", 0 );
		    	maps\mp\gametypes\_rank::registerScoreInfo( "double", 0 );
		    	maps\mp\gametypes\_rank::registerScoreInfo( "triple", 0 );
		    	maps\mp\gametypes\_rank::registerScoreInfo( "multi", 0 );
		    	maps\mp\gametypes\_rank::registerScoreInfo( "buzzkill", 0 );
		    	maps\mp\gametypes\_rank::registerScoreInfo( "firstblood", 0 );
		    	maps\mp\gametypes\_rank::registerScoreInfo( "comeback", 0 );
		    	maps\mp\gametypes\_rank::registerScoreInfo( "longshot", 0 );
		    	maps\mp\gametypes\_rank::registerScoreInfo( "assistedsuicide", 0 );
		    	maps\mp\gametypes\_rank::registerScoreInfo( "knifethrow", 0 );
		    }
            iPrintLn("[^3t5cine] ^7Score set to: ^1" + (getDvarInt("mvm_score")));
			setDvar("mvm_score", "Change score per kill");
        }
        wait 0.5;
	}
}

GivePlayerKillstreak()
{
	self endon("death");
	self endon("disconnect");

	setDvar("mvm_killstreak", "Give yourself a killstreak");
	for (;;)
	{
		if(getDvar("mvm_killstreak") != "Give yourself a killstreak")
		{
			self maps\mp\gametypes\_hardpoints::giveKillstreak(getDvar("mvm_killstreak"), false);
			wait 0.1;
			setDvar("mvm_killstreak", "Give yourself a killstreak");
		}
		wait 0.5;
	}
}

MsgAbout()
{
	self endon("death");
	self endon("disconnect");

	setDvar("about", "About the mod...");
	for (;;)
	{
		if(getdvar("about") != "About the mod...")
		{
			self IPrintLnBold("^3Sass' Cinematic Mod");
			wait 1.5;
			self IPrintLnBold("Ported to T5 by ^3Forgive");
			wait 1.5;
			self IPrintLnBold("Thanks for downloading !");
			self IPrintLn("^1Thanks to / Credits :");
			self IPrintLn("- Sass for making the MW2 Mod.");
			self IPrintLn("- Antiga and yoyo1love for .gsc.");
			wait 1.5;
			self IPrintLnBold("Discord server link : discord.gg/COD4Cine");
			setDvar("about", "About the mod...");
		}
		wait 0.5;
	}
}

MsgWelcome()
{
	self endon("death");
	self endon("disconnect");
	{
		if (!isDefined(self.donefirst) && self.pers["isBot"] == false)
		{
			level.prematchPeriodEnd = -1;
			wait 6;
			self IPrintLn("Welcome to ^3Sass' Cinematic Mod");
            self IPrintLn("Ported to T5 by ^3Forgive");
			self IPrintLn("Type ^3/about 1 ^7for more info");
			self.donefirst = 1;
		}
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
			setdvar( "scr_giveperk", "specialty_longersprint" );
		}
		wait .05;
	}
}

CreateClone()
{
	self endon("disconnect");
	self endon("death");

	setDvar("clone", "Spawn a clone of yourself");
	for (;;)
	{
		if(getDvar("clone") != "Spawn a clone of yourself")
		{
			if ( getDvar("clone") == "2") 
			{
				wait .1;
				self ClonePlayer(1);
			}
			else 
			{
				self.weaptoattach delete();
				self ClonePlayer(1);
			}
			setDvar("clone", "Spawn a clone of yourself");
		}
		wait 0.5;	
	}
}

ClearBodies()
{
	self endon("disconnect");
	self endon("death");

	setDvar("clearbodies", "Clear all dead bodies");
	for (;;)
	{
		if(getDvar("clearbodies") != "Clear all dead bodies")
		{
			self iPrintLn("Cleaning up...");
			for (i = 0; i < 15; i++)
			{
				clone = self ClonePlayer(1);
				clone delete();
				wait .1;
			}
			setDvar("clearbodies", "Clear all dead bodies");
		}
		wait 0.5;
	}
}

VerifyModel()
{
	self endon("disconnect");
	if (isDefined(self.modelalready))
	{
		self detachAll();
		self[[game[self.lteam + "_model"][self.lmodel]]]();
	}
}

FakeNoclip()
{
	self endon("disconnect");
	self endon("death");
	self endon("killnoclip");

	setDvar("noclip2", 0);
	maps\mp\gametypes\_spectating::setSpectatePermissions();
	for (;;)
	{
		if(getDvarInt("noclip2") == 1)
		{
			self traverseMode("noclip");
			self allowSpectateTeam("freelook", true);
			self.sessionstate = "spectator";
		}
		else if(getDvarInt("noclip2") == 0)
		{
			//self closeMenu("noclip");
			self.sessionstate = "playing";
			self allowSpectateTeam("freelook", false);
		}
		wait 0.5;
	}
}

LoadPos()
{
	self freezecontrols(true);
	wait .05;
	self setPlayerAngles(self.spawn_angles);
	self setOrigin(self.spawn_origin);
	wait .05;
	self freezecontrols(false);
}