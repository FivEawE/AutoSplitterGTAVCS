state("PPSSPPWindows64") { }
state("PPSSPPWindows64", "1.7.4") { }
state("PPSSPPWindows64", "1.8.0") { }

startup {
	settings.Add("balloons", false, "All Red Balloons");
	settings.Add("balloons10", false, "Split every 10 balloons", "balloons");
	settings.Add("stunts", false, "All Unique Stunt Jumps");
}

init
{
	vars.watchers = new MemoryWatcherList();
	vars.offset = 0;
	vars.offsetKeys = 0;

	if (game.MainWindowTitle.StartsWith("PPSSPP v1.7.4"))
	{
		version = "1.7.4";
		vars.offset = 0xD91250;
		vars.offsetKeys = 0xDB14F4;
	}
	else if (game.MainWindowTitle.StartsWith("PPSSPP v1.8.0"))
	{
		version = "1.8.0";
		vars.offset = 0xDC8FB0;
		vars.offsetKeys = 0xDE9254;
	}
	else
	{
		version = "";
	}
	
	vars.watchers.Add(new MemoryWatcher<int>(new DeepPointer(vars.offsetKeys)) { Name = "KeysPressed" });
	vars.watchers.Add(new MemoryWatcher<int>(new DeepPointer(vars.offset, 0x8BB40FC)) { Name = "MissionAttempts" });
	vars.watchers.Add(new MemoryWatcher<int>(new DeepPointer(vars.offset, 0x9F6A338)) { Name = "BalloonsPopped" });
	vars.watchers.Add(new MemoryWatcher<int>(new DeepPointer(vars.offset, 0x9F69A58)) { Name = "StuntsCompleted" });
}

start
{
	if (vars.watchers["MissionAttempts"].Current == 1 && vars.watchers["KeysPressed"].Current == 0x4000)
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