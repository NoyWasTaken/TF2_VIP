#include <sourcemod>
#include <morecolors>
#include <VIP_Core>

#define PLUGIN_AUTHOR "NoyB"
#define PLUGIN_VERSION "1.0"

public Plugin myinfo = 
{
	name = "[TF2] VIP - Messages Perk", 
	author = PLUGIN_AUTHOR, 
	description = "", 
	version = PLUGIN_VERSION, 
	url = "https://steamcommunity.com/id/noywastaken"
};

public void VIP_OnPlayerLoaded(int client)
{
	SetHudTextParams(-1.0, 0.1, 7.0, 0, 255, 150, 255, 2, 6.0, 0.1, 0.2);
	for (int i = 1; i <= MaxClients; i++)
	{
		if (IsClientInGame(i))
			ShowHudText(i, 0, "VIP %N has connected", client);
	}
	
	CPrintToChatAll("%s {vintage}VIP {teal}%N {vintage}connected to the server.", PREFIX, client);
}

public void OnClientDisconnect(int client)
{
	if (VIP_IsPlayerVIP(client))
	{
		SetHudTextParams(-1.0, 0.1, 7.0, 0, 255, 150, 255, 2, 6.0, 0.1, 0.2);
		for (int i = 1; i <= MaxClients; i++)
		{
			if (IsClientInGame(i))
				ShowHudText(i, 0, "VIP %N has disconnected", client);
		}
		
		CPrintToChatAll("%s {vintage}VIP {teal}%N {vintage}disconnected from the server.", PREFIX, client);
	}
} 