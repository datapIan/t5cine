#include maps\mp\gametypes\_hud_message;
#include maps\mp\gametypes\_hud_util;
#include maps\mp\_utility;
#include common_scripts\utility;
//#include maps\mp\_art;

movie()
{
	level thread MovieConnect();

	level._effect["fire"] = loadfx("props/barrel_fire");
	level._effect["blood"] = loadfx("impacts/flesh_hit_body_fatal_exit");
	game["dialog"]["gametype"] = undefined;
}

MovieConnect()
{
	for (;;)
	{
		level waittill("connected", player);
		if(!player BotTester())
		{
			player thread BotFreeze();
			player thread MovieSpawn();
			if(!isDefined(player.ebmagic))
				player.ebmagic = 2;
			if (!isDefined(player.linke))
				player.linke = false;
		}
	}
}

MovieSpawn()
{
	self endon("disconnect");

	for (;;)
	{
		self waittill("spawned_player");

		// Grenade cam reset
		setDvar("camera_thirdperson", "0");
		self show();

		// Regeneration	
		thread RegenAmmo();
		thread RegenEquip();
		thread RegenSpec();

		//// Bots
		thread BotSpawn();
		thread BotSetup();
		thread BotGiveWeapon();
		thread BotStare();
		thread BotAim();
		thread BotModel();
		thread BotFreeze();

		//// Explosive Bullets
		thread EB();

		//// "Kill" command
		thread BotKill();
		thread EnableLink();

		//// Environement
		thread SpawnProps(); // Uses common_mp or map's xmodel folder unless others are precached.
		thread SpawnEffects(); // Uses common_mp or map's fx folder. Must type out path name... ex: weather/hawk.
		thread TweakFog(); // Was removed in waw, I added it back.
		thread SetVisions(); // Most visions use the same map name; example: mp_berlin
	}
}

RegenAmmo()
{
	for (;;)
	{
		self waittill("reload");
		wait 1;
		currentWeapon = self getCurrentWeapon();
		self giveMaxAmmo(currentWeapon);
	}
}

RegenEquip()
{
	for (;;)
	{
		if(self fragButtonPressed())
		{
			currentOffhand = self GetCurrentOffhand();
			self.pers["equSpec1"] = currentOffhand;
			wait 2;
			self setWeaponAmmoClip(self.pers["equSpec1"], 9999);
			self GiveMaxAmmo(self.pers["equSpec1"]);
		}
		wait 0.1;
	}
}

RegenSpec()
{
	for (;;)
	{
		if(self secondaryOffhandButtonPressed())
		{
			currentOffhand = self GetCurrentOffhand();
			self.pers["equSpec"] = currentOffhand;
			wait 2;
			self giveWeapon(self.pers["equSpec"]);
			self giveMaxAmmo(currentOffhand);
			self setWeaponAmmoClip(currentOffhand, 9999);
		}
		wait 0.1;
	}
}

BotTester()
{
    assert( isDefined( self ) );
    assert( isPlayer( self ) );

    return ( ( isDefined( self.pers["isBot"] ) && self.pers["isBot"] ) || isSubStr( self getguid() + "", "bot" ) );
}

BotFreeze()
{
    self endon("disconnect");
    for(;;)
    {
        for ( i = 0; i < level.players.size; i++ )
        {
            player = level.players[i];
            if(player BotTester())
                player freezeControls(true);
        }
        wait 1;
    }
}

BotSpawn()
{
    self endon("disconnect");
    self endon("death");
	// class = ar, smg, lmg, shotgun, sniper
	// team = allies, axis
    setDvar("mvm_bot_spawn", "Spawn a bot - ^8[class team]");  
    for (;;)
    {
        if(getDvar("mvm_bot_spawn") != "Spawn a bot - ^8[class team]")
        {
            newTestClient = addTestClient();
            newTestClient.pers["isBot"] = true;
            newTestClient.isStaring = false;
            newTestClient thread BotsLevel();
            newTestClient thread BotDoSpawn(self);
            setDvar("mvm_bot_spawn", "Spawn a bot - ^8[class team]");
        }
        wait 0.5;
    }
}

BotDoSpawn(owner)
{
    self endon("disconnect");

    argumentstring = getDvar("mvm_bot_spawn");
    arguments = StrTok(argumentstring, " ,");

    while (!isdefined(self.pers["team"])) 
    wait .05;

    // Picking team
    if ( ( arguments[1] == "allies" || arguments[1] == "axis" ) && isDefined(arguments[1]) )
        {
            self notify("menuresponse", game["menu_team"], arguments[1]);
            wait 0.5;
        }
    else 
        {
            kick(self getEntityNumber());
            owner iPrintLn("[^1ERROR^7] Team name needs to be either ^8allies ^7or ^8axis^7!");
             return;
        }
    wait .1;

    // Picking class
    if (arguments[0] == "ar")
        self notify("menuresponse", "changeclass", "assault_mp");
    else if (arguments[0] == "smg")
        self notify("menuresponse", "changeclass", "specops_mp");
    else if (arguments[0] == "lmg")
        self notify("menuresponse", "changeclass", "heavygunner_mp");
    else if (arguments[0] == "shotgun")
        self notify("menuresponse", "changeclass", "demolitions_mp");
    else if (arguments[0] == "sniper")
        self notify("menuresponse", "changeclass", "sniper_mp");
    else 
        {
            kick(self getEntityNumber());
            owner iPrintLn("[^3WARNING^7] ^8'"+ arguments[0] +"' ^7isn't a valid class." );
            return;
        }
    self waittill("spawned_player");
    //wait 0.1;

    self setOrigin(BulletTrace(owner getTagOrigin("tag_eye"), anglestoforward(owner getPlayerAngles()) * 100000, true, owner)["position"]);
    self setPlayerAngles(owner.angles + (0, 180, 0));
    self thread SaveSpawn();
}

BotSetup()
{
	self endon("death");
	self endon("disconnect");

	setDvar("mvm_bot_setup", "Move bot to x-hair - ^8[name]");
	for (;;)
	{
		if(getDvar("mvm_bot_setup") != "Move bot to x-hair - ^8[name]")
		{
			for ( i = 0; i < level.players.size; i++ )
		    {
                player = level.players[i];
				if (isSubStr(player.name, getDvar("mvm_bot_setup")))
				{
					player setOrigin(BulletTrace(self getTagOrigin("tag_eye"), anglestoforward(self getPlayerAngles()) * 100000, true, self)["position"]);
					player thread SaveSpawn();
				}
			}
			setDvar("mvm_bot_setup", "Move bot to x-hair - ^8[name]");
		}
		wait 0.5;
	}
}

BotAim()
{
	self endon("death");
	self endon("disconnect");

	setDvar("mvm_bot_aim", "Bot aim at closest enemy - ^8[name]");
	for (;;)
	{
		if(getDvar("mvm_bot_aim") != "Bot aim at closest enemy - ^8[name]")
		{
			for ( i = 0; i < level.players.size; i++ )
			{
				player = level.players[i];
				if (isSubStr(player.name, getDvar("mvm_bot_aim")))
				{
					player = level.players[i];
					player thread BotDoAim();
					wait .4;
					player notify("stopaim");
					player thread SaveSpawn();
				}
			}
			setDvar("mvm_bot_aim", "Bot aim at closest enemy - ^8[name]");
		}
		wait 0.5;
	}
}

BotStare()
{
	self endon("death");
	self endon("disconnect");
	
	setDvar("mvm_bot_stare", "Bot stare at closest enemy - ^8[name]");
	for (;;)
	{
		if(getDvar("mvm_bot_stare") != "Bot stare at closest enemy - ^8[name]")
		{
			for ( i = 0; i < level.players.size; i++ )
			{
        	    player = level.players[i];
				if (isSubStr(player.name, getDvar("mvm_bot_stare")))
				{
					if (player.isStaring == false) 
					{
						player thread BotDoAim();
						player.isStaring = true;
					}
					else if (player.isStaring == true) 
					{
						player notify("stopaim");
						player.isStaring = false;
					}
					player thread SaveSpawn();
				}
			}
			setDvar("mvm_bot_stare", "Bot stare at closest enemy - ^8[name]");
		}
		wait 0.5;
	}
}

BotDoAim()
{
	self endon("disconnect");
	self endon("stopaim");

	for (;;)
	{
		wait .01;
		aimAt = undefined;
		for ( i = 0; i < level.players.size; i++ )
		{
			player = level.players[i];
			if ((player == self) || (level.teamBased && self.pers["team"] == player.pers["team"]) || (!isAlive(player)))
				continue;
			if (isDefined(aimAt))
			{
				if (closer(self getTagOrigin("j_head"), player getTagOrigin("j_head"), aimAt getTagOrigin("j_head")))
					aimAt = player;
			}
			else
				aimAt = player;
		}
		if (isDefined(aimAt))
		{
			self setplayerangles(VectorToAngles((aimAt getTagOrigin("j_head")) - (self getTagOrigin("j_head"))));
		}
	}
}

BotGiveWeapon() 
{
    self endon("death");
    self endon("disconnect");

    setDvar("mvm_bot_weapon", "Give a bot a weapon - ^8[name weapon]");
    for (;;) 
	{
        if (getDvar("mvm_bot_weapon") != "Give a bot a weapon - ^8[name weapon]") 
		{
            argumentString = getDvar("mvm_bot_weapon", "");
            arguments = StrTok(argumentString, " ,");
            for (playerIndex = 0; playerIndex < level.players.size; playerIndex++) 
			{
                player = level.players[playerIndex];
                if (isSubStr(player.name, arguments[0])) 
				{
                    newWeapon = arguments[1];
                    player takeweapon(player getCurrentWeapon());
                    player switchToWeapon(player getCurrentWeapon());
                    wait .05;
                    player giveWeapon(newWeapon);
					player setSpawnWeapon(newWeapon);
                }
            }
   			setDvar("mvm_bot_weapon", "Give a bot a weapon - ^8[name weapon]");
        }
        wait 0.5;
    }
}

BotModel()
{
	self endon("death");
	self endon("disconnect");
	// MODEL == SNIPER, SUPPORT, ASSAULT, RECON, SPECOPS, FLAMETHROWER
	setDvar("mvm_bot_model", "Change bot model - ^8[name MODEL team]");
	for (;;)
	{
		argumentstring = getDvar("mvm_bot_model");
		arguments = StrTok(argumentstring, " ,");
		if(getDvar("mvm_bot_model") != "Change bot model - ^8[name MODEL team]")
		{
			for ( i = 0; i < level.players.size; i++ )
			{
				player = level.players[i];
				if (isSubStr(player.name, arguments[0]))
				{
					player.lteam = arguments[2];
					player.lmodel = arguments[1];
					player detachAll();
					player[[game[player.lteam + "_model"][player.lmodel]]]();
					player.modelalready = true;
				}
			}
			setDvar("mvm_bot_model", "Change bot model - ^8[name MODEL team]");
		}
		wait 0.5;
	}
}

EB()
{
	self endon("death");
	self endon("disconnect");

	setDvar("mvm_eb", "Toggle explosive bullets");
	for (;;)
	{
		if(getDvar("mvm_eb") != "Toggle explosive bullets ^8[everywhere magic off]")
		{
			switch (self.ebmagic)
			{
				case 0:
					self thread ebMagicScript();
					self iPrintLn("Magic explosive bullets - ^2EVERYWHERE");
					self.ebmagic = 1;
					break;
				case 1:
					self notify("eb2off");
					self iPrintLn("Magic explosive bullets - ^3CLOSE");
					self.ebmagic = 2;
					self thread ebCloseScript();
					break;
				case 2:
					self notify("eb2off");
					self notify("eb1off");
					self iPrintLn("Magic explosive bullets - ^1OFF");
					self.ebmagic = false;
					break;
			}
			setDvar("mvm_eb", "Toggle explosive bullets ^8[everywhere magic off]");
		}
		wait 1;
	}
}

ebMagicScript()
{
	self endon("disconnect");
	self endon("eb2off");

	for(;;)
	{
		wait 0.1;
		aimAt = undefined;
		for (i = 0; i < level.players.size; i++)
		{
			player = level.players[i];
			if (player == self || !isAlive(player) || (level.teamBased && self.pers["team"] == player.pers["team"]))
				continue;
			if (isDefined(aimAt))
			{
				if (closer(self getTagOrigin("j_head"), player getTagOrigin("j_head"), aimAt getTagOrigin("j_head")))
					aimAt = player;
			}
			else aimAt = player;
		}
		if (isDefined(aimAt))
		{
			self waittill("weapon_fired");
			aimAt thread[[level.callbackPlayerDamage]](self, self, aimAt.health, 8, "MOD_RIFLE_BULLET", self getCurrentWeapon(), (0, 0, 0), (0, 0, 0), "HEAD", 0);
		}
	}
}

ebCloseScript()
{
	self endon("eb1off");
	self endon("disconnect");

	range = 150; // make this a client adjustable variable
	for(;;)
	{
		wait .01;
		aimAt = undefined;
		destination = bulletTrace( self getEye(), anglesToForward( self getPlayerAngles() ) * 1000000, true, self )["position"];
		for ( i = 0; i < level.players.size; i++ )
		{
			player = level.players[i];
			if (player == self)
				continue;
			if (!isAlive(player))
				continue;
			if (level.teamBased && self.pers["team"] == player.pers["team"])
				continue;
			if ( distance( destination, player getOrigin() ) > range )
                continue;
			if (isDefined(aimAt))
			{
				if (closer(self getTagOrigin("j_head"), player getTagOrigin("j_head"), aimAt getTagOrigin("j_head")))
					aimAt = player;
			}
			else aimAt = player;
		}
		if (isDefined(aimAt))
		{
			self waittill("weapon_fired");
			aimAt thread[[level.callbackPlayerDamage]](self, self, aimAt.health, 8, "MOD_RIFLE_BULLET", self getCurrentWeapon(), (0, 0, 0), (0, 0, 0), "HEAD", 0);
		}
	}
}

BotKill()
{
	self endon("death");
	self endon("disconnect");

	setDvar("mvm_bot_kill", "Kill a bot - ^8[name mode]");
	for (;;)
	{
        if(getDvar("mvm_bot_kill") != "Kill a bot - ^8[name mode]")
        {
		    argumentstring = getDvar("mvm_bot_kill", "");
		    arguments = StrTok(argumentstring, " ,");

		    for ( i = 0; i < level.players.size; i++ )
		    {
                player = level.players[i];
		    	if (isSubStr(player.name, arguments[0]))
		    	{
		    		if (self.linke)
		    		{
		    			player PrepareInHandModel();
		    			player takeweapon(player getCurrentWeapon());
		    			wait .05;
		    		}
		    		player thread BotDoKill(arguments[1], self);
		    	}
                setDvar("mvm_bot_kill", "Kill a bot - ^8[name mode]");
		    }
        }
        wait 0.5;
	}
}

BotDoKill(mode, attacker)
{
	self endon("disconnect");
	self endon("death");
	{
		if (mode == "head")
		{
			playFx(level._effect["blood"], self getTagOrigin("j_head"));
			self thread[[level.callbackPlayerDamage]](self, self, 1337, 8, "MOD_SUICIDE", self getCurrentWeapon(), (0, 0, 0), (0, 0, 0), "head", 0);
		}
		else if (mode == "body")
		{
			playFx(level._effect["blood"], self getTagOrigin("j_spine4"));
			self thread[[level.callbackPlayerDamage]](self, self, 1337, 8, "MOD_SUICIDE", self getCurrentWeapon(), (0, 0, 0), (0, 0, 0), "body", 0);
		}
		else if (mode == "shotgun")
		{
			vec = anglestoforward(self.angles);
			end = (vec[0] * (-300), vec[1] * (-300), vec[2] * (-300));
			playFx(level._effect["blood"], self getTagOrigin("j_spine4"));
			self thread[[level.callbackPlayerDamage]](self, self, 1337, 8, "MOD_SUICIDE", "winchester1200_mp", self.origin + end, self.origin, "left_foot", 0);
		}
		else if (mode == "cash")
		{
			playFx(level._effect["fire"], self getTagOrigin("j_spine4"));
			playFx(level._effect["blood"], self getTagOrigin("j_spine4"));
			self thread[[level.callbackPlayerDamage]](self, self, 1337, 8, "MOD_SUICIDE", self getCurrentWeapon(), (0, 0, 0), (0, 0, 0), "body", 0);
		}
        self BotFreeze();
	}
}

EnableLink()
{
    self endon("death");
    self endon("disconnect");

    setDvar("mvm_bot_holdgun", "Toggle bots holding their gun when dying");
    for (;;)
    {
        if(getDvar("mvm_bot_holdgun") != "Toggle bots holding their gun when dying")
        {
            if (self.linke == false)
			{
                self iPrintLn("Bots hold weapon on mvm_bot_kill : ^2TRUE");
                self.linke = true;
            }
            else if (self.linke == true)
           {
                self iPrintLn("Bots hold weapon on mvm_bot_kill : ^1FALSE");
                self.linke = false;
            }
            setDvar("mvm_bot_holdgun", "Toggle bots holding their gun when dying");
        }
        wait 0.5;
    }
}

TweakFog()
{
	self endon("death");
	self endon("disconnect");

	setDvar("mvm_env_fog", "Custom fog - ^8[start half r g b]");
	for (;;)
	{
		if(getDvar("mvm_env_fog") != "Custom fog - ^8[start half r g b]")
		{
			argumentstring = getDvar("mvm_env_fog", "Custom fog - ^8[start half r g b]");
			arguments = StrTok(argumentstring, " ,");
			//SetExpFog( <startDist>, <halfwayDist>, <red>, <green>, <blue>, <transition time> );
			setExpFog(int(arguments[0]), int(arguments[1]), int(arguments[2]), int(arguments[3]), int(arguments[4]), 1);
			setDvar("mvm_env_fog", "Custom fog - ^8[start half r g b]");
		}
		 wait 0.2;
	}
}

SetVisions()
{
	self endon("disconnect");
	self endon("death");

	setDvar("mvm_env_colors", "Change vision - ^8[vision]");
	for (;;)
	{
        if(getDvar("mvm_env_colors") != "Change vision - ^8[vision]")
        {
		    visionSetNaked(getDvar("mvm_env_colors", "visname"));
		    self IPrintLn("Vision changed to : " + getDvar("mvm_env_colors"));
            wait 0.5;
            setDvar("mvm_env_colors", "Change vision - ^8[vision]");
	    }
        wait 0.5;
    }
}

SpawnEffects()
{
	self endon("disconnect");

	setDvar("mvm_env_fx", "Spawn an effect - ^8[fx]");
	for (;;)
	{
        if(getDvar("mvm_env_fx") != "Spawn an effect - ^8[fx]")
        {
			start = self getTagOrigin("tag_eye");
			end = anglestoforward(self getPlayerAngles()) * 1000000;
			fxpos = BulletTrace(start, end, true, self)["position"];
			level._effect[getDvar("mvm_env_fx", "")] = loadfx((getDvar("mvm_env_fx", "")));
			playFX(level._effect[getDvar("mvm_env_fx", "")], fxpos);
			self IPrintLn("^7FX: " + getDvar("mvm_env_fx", "") + " ^3spawned ! ");
			setDvar("mvm_env_fx", "Spawn an effect - ^8[fx]");
		}
		wait 0.5;
	}
}

SpawnProps()
{
	self endon("death");
	self endon("disconnect");

	setDvar("mvm_env_prop", "Spawn a prop - ^8[prop]");
	for (;;)
	{
        if(getDvar("mvm_env_prop") != "Spawn a prop - ^8[prop]")
        {
			prop = spawn("script_model", self.origin);
			prop.angles = self.angles;
			prop setModel(getDvar("mvm_env_prop", ""));
			self IPrintLn("^7Prop: " + getDvar("mvm_env_prop", "") + " ^3spawned ! ");
			setDvar("mvm_env_prop", "Spawn a prop - ^8[prop]");
		}
		wait 0.5;
	}
}

SaveSpawn()
{
	self.spawn_origin = self.origin;
	self.spawn_angles = self getPlayerAngles();
}

BotsLevel()
{
	//self setPlayerData("prestige", RandomInt(11));
	//self setPlayerData("experience", 2400000);
}

PrepareInHandModel()
{
	currentWeapon = self getCurrentWeapon();

	if (isDefined(self.weaptoattach))
		self.weaptoattach delete();

	self.weaptoattach = getWeaponModel(currentWeapon);
	self attach(self.weaptoattach, "tag_weapon_right", true);

	self.weaptoattach thread maps\mp\gametypes\_weapons::deletePickupAfterAWhile();
}
