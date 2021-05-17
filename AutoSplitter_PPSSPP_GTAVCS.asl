state("PPSSPPWindows64") { }
state("PPSSPPWindows64", "EU") { }
state("PPSSPPWindows64", "US") { }
state("PPSSPPWindows64", "JP") { }
state("PPSSPPWindows64", "JP (Rockstar Classics)") { }

startup {
	settings.Add("any", false, "any%");
	settings.Add("splitDupe", false, "Split on duped missions", "any");
	settings.Add("empires", false, "Split on empires takeover", "any");
	settings.Add("missionStart", false, "Split on mission start", "any");
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
	vars.offsetJumps = 0x9F69A58;
	vars.offsetBalloons = 0x9F6A338;
	vars.offsetEmpires = 0x9F6B344;
	vars.offsetMission = 0;
	vars.offsetLoads = 0x9F68E0C;
	
	//Some things have different offsets in EU and US versions, defaults to EU
	if (game.MainWindowTitle.Contains("ULUS10160"))
	{
		version = "US";
		vars.offsetMissionAttempts = 0x8BB3D1C;
		vars.offsetMovementLock = 0x8BDE6AA;
		vars.offsetMissionsPassed = 0x8BB3D28;
		vars.offsetRampages = 0x8BF1AD4;
		vars.offsetMission = 0x9315D63;
	}
	//Different Japanese version have some different offsets
	else if (game.MainWindowTitle.Contains("ULJM"))
	{
		vars.offsetMissionAttempts = 0x8BB3F94;
		vars.offsetMovementLock = 0x8BCEA7A;
		vars.offsetMissionsPassed = 0x8BB3F98;
		vars.offsetRampages = 0x8BB3FD8;
		vars.offsetJumps = 0x8BB3F8C;
		vars.offsetMission = 0x931A163;
		vars.offsetLoads = 0x8E7A760;
		if (game.MainWindowTitle.Contains("ULJM05297"))
		{
			version = "JP";
			vars.offsetBalloons = 0x9F71F40;
			vars.offsetEmpires = 0x9F72F4C;
		}
		else if (game.MainWindowTitle.Contains("ULJM05884"))
		{
			version = "JP (Rockstar Classics)";
			vars.offsetBalloons = 0x9F71F60;
			vars.offsetEmpires = 0x8E7BC20;
		}
	}
	else
	{
		version = "EU";
		vars.offsetMissionAttempts = 0x8BB40FC;
		vars.offsetMovementLock = 0x8BDEA6A;
		vars.offsetMissionsPassed = 0x8BB4108;
		vars.offsetRampages = 0x8BF1E94;
		vars.offsetMission = 0x9316063;
	}
	
	var page = modules.First();
	var scanner = new SignatureScanner(game, page.BaseAddress, page.ModuleMemorySize);

	IntPtr offsetPtr = scanner.Scan(new SigScanTarget(22, "41 B9 ?? 05 00 00 48 89 44 24 20 8D 4A FC E8 ?? ?? ?? FF 48 8B 0D ?? ?? ?? 00 48 03 CB"));
	IntPtr offsetKeysPtr = scanner.Scan(new SigScanTarget(37, "?? 8B CA ?? 03 C9 ?? 8D 1D ?? ?? ?? ?? 0F 10 05 ?? ?? ?? ?? ?? 0F 11 ?? ?? ?? 8B 44 ?? ?? ?? 89 44 ?? ?? 8B 0D ?? ?? ?? ?? 8B C1 ?? 33 C0 8B D0 ?? 23 D0"));

	vars.offset = (int) (offsetPtr.ToInt64() - page.BaseAddress.ToInt64() + game.ReadValue<int>(offsetPtr) + 0x4);
	vars.offsetKeys = (int) (offsetKeysPtr.ToInt64() - page.BaseAddress.ToInt64() + game.ReadValue<int>(offsetKeysPtr) + 0x4);
	
	vars.watchers.Add(new MemoryWatcher<int>(new DeepPointer(vars.offsetKeys)) { Name = "KeysPressed" });
	vars.watchers.Add(new MemoryWatcher<int>(new DeepPointer(vars.offset, vars.offsetMovementLock)) { Name = "MovementLock" });
	vars.watchers.Add(new MemoryWatcher<int>(new DeepPointer(vars.offset, vars.offsetMissionAttempts)) { Name = "MissionAttempts" });
	vars.watchers.Add(new MemoryWatcher<int>(new DeepPointer(vars.offset, vars.offsetMissionsPassed)) { Name = "MissionsPassed" });
	vars.watchers.Add(new MemoryWatcher<int>(new DeepPointer(vars.offset, vars.offsetBalloons)) { Name = "BalloonsPopped" });
	vars.watchers.Add(new MemoryWatcher<int>(new DeepPointer(vars.offset, vars.offsetJumps)) { Name = "StuntsCompleted" });
	vars.watchers.Add(new MemoryWatcher<int>(new DeepPointer(vars.offset, vars.offsetRampages)) { Name = "RampagesCompleted" });
	vars.watchers.Add(new MemoryWatcher<int>(new DeepPointer(vars.offset, vars.offsetEmpires)) { Name = "Empires" });
	vars.watchers.Add(new StringWatcher(new DeepPointer(vars.offset, vars.offsetMission), 7) { Name = "Mission" });
	vars.watchers.Add(new MemoryWatcher<short>(new DeepPointer(vars.offset, vars.offsetLoads)) { Name = "Loads" });
	
	//Other variables
	vars.missionStarted = false;
	vars.missionPassedOld = 0;
	vars.missionPassedNew = 0;
	vars.balloonsPopped = 0;
	vars.stuntsCompleted = 0;
	vars.rampagesCompleted = 0;
	vars.frames = 0;
	vars.waitFrames = 180; //3 seconds
	
	vars.missionThreadsPrototype = new Dictionary<string, bool>();
	vars.missionThreads = new Dictionary<string, bool>();
	//No need to clutter the memory when not doing any%
	if (settings["any"])
	{
		Dictionary<string, bool> missionThreads = new Dictionary<string, bool>();
		missionThreads.Add("JER_A2", false);
		missionThreads.Add("JER_A3", false);
		missionThreads.Add("PHI_A1", false);
		missionThreads.Add("PHI_A2", false);
		missionThreads.Add("PHI_A3", false);
		missionThreads.Add("PHI_A4", false);
		missionThreads.Add("MAR_A1", false);
		missionThreads.Add("MAR_A2", false);
		missionThreads.Add("MAR_A3", false);
		missionThreads.Add("MAR_A4", false);
		missionThreads.Add("MAR_A5", false);
		missionThreads.Add("LOU_A1", false);
		missionThreads.Add("LOU_A2", false);
		missionThreads.Add("LOU_A3", false);
		missionThreads.Add("LOU_A4", false);
		missionThreads.Add("LOU_B1", false);
		missionThreads.Add("LOU_B2", false);
		missionThreads.Add("LAN_B1", false);
		missionThreads.Add("LAN_B2", false);
		missionThreads.Add("LAN_B3", false);
		missionThreads.Add("LAN_B4", false);
		missionThreads.Add("LAN_B5", false);
		missionThreads.Add("LAN_B6", false);
		missionThreads.Add("UMB_B1", false);
		missionThreads.Add("UMB_B2", false);
		missionThreads.Add("UMB_B3", false);
		missionThreads.Add("UMB_B4", false);
		missionThreads.Add("BRY_B1", false);
		missionThreads.Add("BRY_B3", false);
		missionThreads.Add("BRY_B4", false);
		missionThreads.Add("MEN_C1", false);
		missionThreads.Add("MEN_C2", false);
		missionThreads.Add("MEN_C3", false);
		missionThreads.Add("MEN_C5", false);
		missionThreads.Add("MEN_C6", false);
		missionThreads.Add("REN_C1", false);
		missionThreads.Add("REN_C2", false);
		missionThreads.Add("REN_C3", false);
		missionThreads.Add("REN_C4", false);
		missionThreads.Add("REN_C5", false);
		missionThreads.Add("REN_C6", false);
		missionThreads.Add("REN_C7", false);
		missionThreads.Add("LAN_C1", false);
		missionThreads.Add("LAN_C3", false);
		missionThreads.Add("LAN_C4", false);
		missionThreads.Add("LAN_C5", false);
		missionThreads.Add("LAN_C6", false);
		missionThreads.Add("LAN_C7", false);
		missionThreads.Add("LAN_C8", false);
		missionThreads.Add("LAN_C9", false);
		missionThreads.Add("LAN_C10", false);
		missionThreads.Add("GON_C2", false);
		missionThreads.Add("GON_C3", false);
		missionThreads.Add("GON_C4", false);
		missionThreads.Add("DIA_C1", false);
		missionThreads.Add("DIA_C2", false);
		missionThreads.Add("DIA_C3", false);
		missionThreads.Add("DIA_C4", false);
		missionThreads.Add("DIA_C5", false);
		missionThreads.Add("CRED01", false);
		vars.missionThreadsPrototype = missionThreads;
		vars.missionThreads = new Dictionary<string, bool>(missionThreads);
	}
}

start
{
	if (vars.watchers["Loads"].Current == 0)
	{
		//Reset the variables here
		vars.missionStarted = false;
		vars.missionPassedOld = 0;
		vars.missionPassedNew = 0;
		vars.balloonsPopped = 0;
		vars.stuntsCompleted = 0;
		vars.rampagesCompleted = 0;
		vars.frames = 0;
		
		if (settings["any"])
		{
			vars.missionThreads = new Dictionary<string, bool>(vars.missionThreadsPrototype);
		}
		
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

	//See reset
	if (vars.frames < vars.waitFrames)
	{
		vars.frames++;
	}
	
	if (settings["any"])
	{
		//Last Lance mission is tad longer
		string mission = vars.watchers["Mission"].Current;
		if (mission != "LAN_C10")
		{
			mission = mission.Substring(0, 6);
		}
	
		if (settings["missionStart"])
		{
			//Split on loading the proper mission thread
			if (vars.missionThreads.ContainsKey(mission) && !vars.missionThreads[mission])
			{
				vars.missionThreads[mission] = true;
				vars.missionPassedNew++;
			}
		}
		else
		{		
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
			
			//Split when the credits start
			if (mission == "CRED01" && !vars.missionThreads["CRED01"])
			{
				vars.missionThreads["CRED01"] = true;
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
			if (vars.watchers["BalloonsPopped"].Current > vars.balloonsPopped)
			{
				vars.balloonsPopped++;
				return true;
			}
		}
	}
	
	if (settings["stunts"])
	{
		if (vars.watchers["StuntsCompleted"].Current > vars.stuntsCompleted)
		{
			vars.stuntsCompleted++;
			return true;
		}
	}
	
	if (settings["rampages"])
	{
		if (vars.watchers["RampagesCompleted"].Current > vars.rampagesCompleted)
		{
			vars.rampagesCompleted++;
			return true;
		}
	}
}

reset
{
	//Prevent resets during the start loading screen
	if (vars.watchers["MissionAttempts"].Current == 0 && !settings["any"] && vars.frames >= vars.waitFrames)
	{
		return true;
	}
}