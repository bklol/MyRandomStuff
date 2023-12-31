#include <sourcemod>
#include <sdktools>

public Plugin myinfo =
{
	name = "Steam3Server().SteamGameServer()->WasRestartRequested()",
	author = "neko AKA bklol"
}

public void OnPluginStart()
{
	GameData hGameConf = LoadGameConfigFile("steamserver.games");
	if (!hGameConf)
	{
		SetFailState("where is steamserver.games ?");
		return;
	}
	Address SteamGameServer;
	char szBuf[14];
	GetCommandLine(szBuf, sizeof szBuf);
	bool g_bWindows = strcmp(szBuf, "./srcds_linux") != 0;
	if(!g_bWindows)
	{
		Address Steam3Server = GameConfGetAddress(hGameConf, "Steam3Server");
		if (Steam3Server == Address_Null) 
			SetFailState("Failed to get address: Steam3Server");
			
		SteamGameServer = Dereference(Steam3Server, 0x4);
	}
	else
	{
		Address Steam3Server = GameConfGetAddress(hGameConf, "SteamGameServer");
		if (Steam3Server == Address_Null) 
			SetFailState("Failed to get address: Steam3Server");
			
		SteamGameServer = Dereference(Steam3Server);
		
	}
	Address WasRestartRequested = Dereference(Dereference(SteamGameServer), 0x2c);
	StartPrepSDKCall(SDKCall_Raw);
	PrepSDKCall_SetAddress(WasRestartRequested);
	PrepSDKCall_SetReturnInfo(SDKType_Bool, SDKPass_Plain);
	Handle hWasRestartRequested = EndPrepSDKCall();

	if(!hWasRestartRequested) 
		SetFailState("Could not initialize call to hWasRestartRequested");
		
	bool bWasRestartRequested = view_as<bool>(SDKCall(hWasRestartRequested, SteamGameServer));
	PrintToServer("Server %s update", bWasRestartRequested ? "need" : "don't need");
}

stock any Dereference( Address ptr, int offset = 0, NumberType type = NumberType_Int32 )
{
	return view_as<Address>(LoadFromAddress(ptr + view_as<Address>(offset), type));
}