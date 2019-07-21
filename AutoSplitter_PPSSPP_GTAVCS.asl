state("PPSSPPWindows64") { }
state("PPSSPPWindows64", "1.7.4 EU") { }
state("PPSSPPWindows64", "1.7.4 US") { }
state("PPSSPPWindows64", "1.8.0 EU") { }
state("PPSSPPWindows64", "1.8.0 US") { }

startup {
	settings.Add("any", false, "any%");
	settings.Add("splitDupe", false, "Split on duped missions", "any");
	settings.Add("empires", false, "Split on empires takeover", "any");
	settings.Add("balloons", false, "All Red Balloons");
	settings.Add("balloons10", false, "Split every 10 balloons", "balloons");
	settings.Add("stunts", false, "All Unique Stunt Jumps");
	settings.Add("rampages", false, "All Rampages");
}

init
{
	vars.watchers = new MemoryWatcherList();
	
	//Base offsets
	vars.offset = 0;
	vars.offsetKeys = 0;
	
	//Regular offsets
	vars.offsetMovementLock = 0;
	vars.offsetMissionAttempts = 0;
	vars.offsetMissionsPassed = 0;
	vars.offsetRampages = 0;

	switch (modules.First().FileVersionInfo.FileVersion)
	{
		case "v1.7.4":
			version = "1.7.4";
			vars.offset = 0xD91250;
			vars.offsetKeys = 0xDB14F4;
			break;
		case "v1.8.0":
			version = "1.8.0";
			vars.offset = 0xDC8FB0;
			vars.offsetKeys = 0xDE9254;
			break;
		default:
			version = "";
			break;
	}
	
	//Some things have different offsets in EU and US versions, defaults to EU
	if (game.MainWindowTitle.Contains("ULUS10160"))
	{
		version += " US";
		vars.offsetMissionAttempts = 0x8BB3D1C;
		vars.offsetMovementLock = 0x8BDE6AA;
		vars.offsetMissionsPassed = 0x8BB3D28;
		vars.offsetRampages = 0x8BF1AD4;
	}
	else
	{
		version += " EU";
		vars.offsetMissionAttempts = 0x8BB40FC;
		vars.offsetMovementLock = 0x8BDEA6A;
		vars.offsetMissionsPassed = 0x8BB4108;
		vars.offsetRampages = 0x8BF1E94;
	}
	
	vars.watchers.Add(new MemoryWatcher<int>(new DeepPointer(vars.offsetKeys)) { Name = "KeysPressed" });
	vars.watchers.Add(new MemoryWatcher<int>(new DeepPointer(vars.offset, vars.offsetMovementLock)) { Name = "MovementLock" });
	vars.watchers.Add(new MemoryWatcher<int>(new DeepPointer(vars.offset, vars.offsetMissionAttempts)) { Name = "MissionAttempts" });
	vars.watchers.Add(new MemoryWatcher<int>(new DeepPointer(vars.offset, vars.offsetMissionsPassed)) { Name = "MissionsPassed" });
	vars.watchers.Add(new MemoryWatcher<int>(new DeepPointer(vars.offset, 0x9F6A338)) { Name = "BalloonsPopped" });
	vars.watchers.Add(new MemoryWatcher<int>(new DeepPointer(vars.offset, 0x9F69A58)) { Name = "StuntsCompleted" });
	vars.watchers.Add(new MemoryWatcher<int>(new DeepPointer(vars.offset, vars.offsetRampages)) { Name = "RampagesCompleted" });
	vars.watchers.Add(new MemoryWatcher<int>(new DeepPointer(vars.offset, 0x9F6B344)) { Name = "Empires" });
	
	//Other variables
	vars.missionStarted = false;
	vars.missionPassedOld = 0;
	vars.missionPassedNew = 0;
	vars.balloonsPopped = 0;
	vars.stuntsCompleted = 0;
	vars.rampagesCompleted = 0;
}

start
{
	if (vars.watchers["MovementLock"].Current == 0x20 && vars.watchers["MissionAttempts"].Current == 1 && vars.watchers["KeysPressed"].Current == 0x4000)
	{
		//Reset the variables here
		vars.missionStarted = false;
		vars.missionPassedOld = 0;
		vars.missionPassedNew = 0;
		vars.balloonsPopped = 0;
		vars.stuntsCompleted = 0;
		vars.rampagesCompleted = 0;
		
		return true;
	}
}

update
{
	if (version == "")
	{
		return;
	}
	
	vars.watchers.UpdateAll(game);
	
	//Used for "splitDupe" setting
	if (vars.watchers["MissionAttempts"].Current > vars.watchers["MissionAttempts"].Old)
	{
		vars.missionStarted = true;
	}
	
	//Prevent splitting on reloads
	if (vars.watchers["MissionsPassed"].Current > vars.watchers["MissionsPassed"].Old)
	{
		if (settings["splitDupe"])
		{
			vars.missionPassedNew++;
		}
		else
		{
			if (vars.missionStarted)
			{
				vars.missionStarted = false;
				vars.missionPassedNew++;
			}
		}
	}
}

split
{
	if (settings["any"])
	{
		if (vars.missionPassedNew > vars.missionPassedOld)
		{
			vars.missionPassedOld++;
			return true;
		}
		if (settings["empires"])
		{
			//Prevent splitting on O, Brothel, Where Art Thou?
			if (!vars.missionStarted && vars.watchers["Empires"].Current > vars.watchers["Empires"].Old)
			{
				return true;
			}
		}
	}
	
	if (settings["balloons"])
	{
		if (settings["balloons10"])
		{
			if (vars.watchers["BalloonsPopped"].Current > vars.watchers["BalloonsPopped"].Old && (vars.watchers["BalloonsPopped"].Current % 10 == 0 || vars.watchers["BalloonsPopped"].Current % 99 == 0))
			{
				return true;
			}
		}
		else
		{
			if (vars.watchers["BalloonsPopped"].Current > vars.watchers["BalloonsPopped"].Old && vars.watchers["BalloonsPopped"].Current > vars.balloonsPopped)
			{
				vars.balloonsPopped++;
				return true;
			}
		}
	}
	
	if (settings["stunts"])
	{
		if (vars.watchers["StuntsCompleted"].Current > vars.watchers["StuntsCompleted"].Old && vars.watchers["StuntsCompleted"].Current > vars.stuntsCompleted)
		{
			vars.stuntsCompleted++;
			return true;
		}
	}
	
	if (settings["rampages"])
	{
		if (vars.watchers["RampagesCompleted"].Current > vars.watchers["RampagesCompleted"].Old && vars.watchers["RampagesCompleted"].Current > vars.rampagesCompleted)
		{
			vars.rampagesCompleted++;
			return true;
		}
	}
}

reset
{
	if (vars.watchers["MissionAttempts"].Current == 0 && !settings["any"])
	{
		return true;
	}
}