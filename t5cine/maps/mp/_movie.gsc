#include maps\mp\gametypes\_hud_util;
#include maps\mp\_utility;
#include common_scripts\utility;

movie()
{
	level thread MovieConnect();
}

MovieConnect()
{
	for (;;)
	{
		level waittill("connected", player);
		
		player thread MovieSpawn();
	}
}

MovieSpawn()
{
	self endon("disconnect");
	for(;;)
	{
		self waittill("spawned_player");
		
		// Grenade cam reset
		setDvar("cg_thirdperson", "0");
		
		// Regeneration
		thread RegenAmmo();
		thread RegenEquip();
		thread RegenSpec();
		
		// Bots
		thread BotSpawn();
		thread BotFreeze();
		thread BotSetup();
		thread BotStare();
		//thread BotAim();
		//thread BotModel();
		
		// Explosive Bullets; Half done
		thread EBClose();
		//thread EBMagic();
		
		// "Kill" command
		//thread BotKill();
		//thread EnableLink();

		// Environement
		//thread SpawnProps();
		//thread SpawnEffects();
		//thread TweakFog();
		//thread SetVisions();
	}
}

RegenAmmo()
{
	for (;;)
	{
		self notifyOnPlayerCommand("reload", "+reload");
		self waittill("reload");
		wait 1;
		if (self.pers["rAmmo"] == "true")
		{
			currentWeapon = self getCurrentWeapon();
			self giveMaxAmmo(currentWeapon);
		}
	}
}

RegenEquip()
{
	for (;;)
	{
		self notifyOnPlayerCommand("frag", "+frag");
		self waittill("frag");
		currentOffhand = self GetCurrentOffhand();
		self.pers["equ"] = currentOffhand;
		wait 1;
		if (self.pers["rEquip"] == "true")
		{
			self setWeaponAmmoClip(currentOffhand, 9999);
			self GiveMaxAmmo(currentOffhand);
		}
	}
}

RegenSpec()
{
	for (;;)
	{
		self notifyOnPlayerCommand("smoke", "+smoke");
		self waittill("smoke");
		currentOffhand = self GetCurrentOffhand();
		self.pers["equSpec"] = currentOffhand;
		wait 1;
		if (self.pers["rSpec"] == "true")
		{
			self giveWeapon(self.pers["equSpec"]);
			self giveMaxAmmo(currentOffhand);
			self setWeaponAmmoClip(currentOffhand, 9999);
		}
	}
}

BotSpawn()
{
	self endon("disconnect");
	self endon("death");
	self notifyOnPlayerCommand("mvm_bot_spawn", "mvm_bot_spawn");
	for (;;)
	{
		self waittill("mvm_bot_spawn");

		team = self.pers["team"];
		bot = self.pers["bot"];
		newTestClient = addTestClient();
		newTestClient.pers["isBot"] = true;
		newTestClient.isStaring = false;
		newTestClient thread maps\mp\gametypes\_bot::bot_spawn_think(getOtherTeam(team));
		bot freezeControls(true);
	}
}

BotFreeze()
{
    players = level.players;
    for ( i = 0; i < players.size; i++ )
    {   
        player = players[i];
        if(isdefined(player.pers["isBot"]) && player.pers["isBot"])
        {
            player freezecontrols(true);
            player unsetPerk("specialty_pistoldeath");
            player unsetPerk("specialty_finalstand");
			player setOrigin(player.pers["bot_position"]);
			player setplayerangles(player.pers["bot_angle"]);
        }
        wait 0.05;
    }
}

BotSetup()
{
	self endon("disconnect");
	self notifyonplayercommand("mvm_bot_setup", "mvm_bot_setup");
	for(;;)
	{
        self waittill("mvm_bot_setup");
		players = level.players;
		for ( i = 0; i < players.size; i++ )
		{   
			player = players[i];
			if(isdefined(player.pers["isBot"]) && player.pers["isBot"])
			{
				player setOrigin(bullettrace(self gettagorigin("tag_eye"), self gettagorigin("tag_eye") + anglesToForward(self getplayerangles()) * 1000000, 0, self)["position"]);
				player.pers["bot_position"] = bullettrace(self gettagorigin("tag_eye"), self gettagorigin("tag_eye") + anglesToForward(self getplayerangles()) * 1000000, 0, self)["position"];
			}
			wait 0.05;
		}
	}
}

BotStare()
{
	self endon("disconnect");
	self notifyonplayercommand("mvm_bot_stare", "mvm_bot_stare");
	for(;;)
	{
		self waittill("mvm_bot_stare");
		players = level.players;
		for ( i = 0; i < players.size; i++ )
		{   
			player = players[i];
			if(isdefined(player.pers["isBot"]) && player.pers["isBot"])
			{
				self.pers["my_location"] = self getOrigin();
				player setplayerangles(VectorToAngles(((self.pers["my_location"])) - (player getTagOrigin("j_head"))));
				player.pers["bot_angle"] = player getplayerangles();
			}
			wait 0.05;
		}
    }
}

EBClose()
{
	self endon("death");
	self endon("disconnect");

	self notifyOnPlayerCommand("mvm_eb_close", "mvm_eb_close");
	for (;;)
	{
		self waittill("mvm_eb_close");

		if (!isDefined(self.ebclose) || self.ebclose == false)
		{
			self thread ebCloseScript();
			self iPrintLnBold("Close explosive bullets - ^2ON");
			self.ebclose = true;
		}
		else if (self.ebclose == true)
		{
			self notify("eb1off");
			self iPrintLnBold("Close explosive bullets - ^1OFF");
			self.ebclose = false;
		}
	}
}

ebCloseScript()
{
	self endon("eb1off");
	self endon("disconnect");

	while (1)
	{
		self waittill("weapon_fired");
		my = self gettagorigin("j_head");
		trace = bullettrace(my, my + anglestoforward(self getplayerangles()) * 100000, true, self)["position"];
		playfx(level.expbullt, trace);
		dis = distance(self.origin, trace);
		if (dis < 101) RadiusDamage(trace, dis, 200, 50, self);
		RadiusDamage(trace, 100, 800, 50, self);
	}
}