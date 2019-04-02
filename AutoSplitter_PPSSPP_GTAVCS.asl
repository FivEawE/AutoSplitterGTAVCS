state("PPSSPPWindows64") { }
state("PPSSPPWindows64", "1.7.4 EU") { }
state("PPSSPPWindows64", "1.7.4 US") { }
state("PPSSPPWindows64", "1.8.0 EU") { }
state("PPSSPPWindows64", "1.8.0 US") { }

startup {
	settings.Add("any", false, "any%");
	settings.Add("balloons", false, "All Red Balloons");
	settings.Add("balloons10", false, "Split every 10 balloons", "balloons");
	settings.Add("stunts", false, "All Unique Stunt Jumps");
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
	}
	else
	{
		version += " EU";
		vars.offsetMissionAttempts = 0x8BB40FC;
		vars.offsetMovementLock = 0x8BDEA6A;
		vars.offsetMissionsPassed = 0x8BB4108;
	}
	
	vars.watchers.Add(new MemoryWatcher<int>(new DeepPointer(vars.offsetKeys)) { Name = "KeysPressed" });
	vars.watchers.Add(new MemoryWatcher<int>(new DeepPointer(vars.offset, vars.offsetMovementLock)) { Name = "MovementLock" });
	vars.watchers.Add(new MemoryWatcher<int>(new DeepPointer(vars.offset, vars.offsetMissionAttempts)) { Name = "MissionAttempts" });
	vars.watchers.Add(new MemoryWatcher<int>(new DeepPointer(vars.offset, vars.offsetMissionsPassed)) { Name = "MissionsPassed" });
	vars.watchers.Add(new MemoryWatcher<int>(new DeepPointer(vars.offset, 0x9F6A338)) { Name = "BalloonsPopped" });
	vars.watchers.Add(new MemoryWatcher<int>(new DeepPointer(vars.offset, 0x9F69A58)) { Name = "StuntsCompleted" });
}

start
{
	if (vars.watchers["MovementLock"].Current == 0x20 && vars.watchers["MissionAttempts"].Current == 1 && vars.watchers["KeysPressed"].Current == 0x4000)
	{
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
}

split
{
	if (settings["any"])
	{
		if (vars.watchers["MissionsPassed"].Current > vars.watchers["MissionsPassed"].Old)
		{
			return true;
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
			if (vars.watchers["BalloonsPopped"].Current > vars.watchers["BalloonsPopped"].Old)
			{
				return true;
			}
		}
	}
	
	if (settings["stunts"])
	{
		if (vars.watchers["StuntsCompleted"].Current > vars.watchers["StuntsCompleted"].Old)
		{
			return true;
		}
	}
}

reset
{
	if (vars.watchers["MissionAttempts"].Current == 0)
	{
		return true;
	}
}