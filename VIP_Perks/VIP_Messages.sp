#include <sourcemod>
#include <morecolors>
#include <VIP_Core>

#define PLUGIN_AUTHOR "NoyB"
#define PLUGIN_VERSION "1.0"

ConVar g_cvEnableConnectChat;
ConVar g_cvEnableConnectHud;
ConVar g_cvEnableDisconnectChat;
ConVar g_cvEnableDisconnectHud;

public Plugin myinfo = 
{
	name = "[TF2] VIP - Messages Perk", 
	author = PLUGIN_AUTHOR, 
	description = "", 
	version = PLUGIN_VERSION, 
	url = "https://steamcommunity.com/id/noywastaken"
};

public void OnPluginStart()
{
	g_cvEnableConnectChat = CreateConVar("sm_vip_connect_chat", "1", "Should we display a chat message when a VIP player connects?", 0, true, 0.0, true, 1.0);
	g_cvEnableConnectHud = CreateConVar("sm_vip_connect_hud", "0", "Should we display an HUD message when a VIP player connects?", 0, true, 0.0, true, 1.0);
	g_cvEnableDisconnectChat = CreateConVar("sm_vip_disconnect_chat", "0", "Should we display a chat message when a VIP player disconnects?", 0, true, 0.0, true, 1.0);
	g_cvEnableDisconnectHud = CreateConVar("sm_vip_disconnect_hud", "0", "Should we display an HUD message when a VIP player disconnects?", 0, true, 0.0, true, 1.0);
	AutoExecConfig();
}

public void VIP_OnPlayerLoaded(int client)
{
	if (g_cvEnableConnectHud.BoolValue)
	{
		SetHudTextParams(-1.0, 0.1, 7.0, 0, 255, 150, 255, 2, 6.0, 0.1, 0.2);
		for (int i = 1; i <= MaxClients; i++)
		{
			if (IsClientInGame(i))
				ShowHudText(i, 0, "VIP %N has connected", client);
		}
	}
	
	if (g_cvEnableConnectChat.BoolValue)
		CPrintToChatAll("{vintage}VIP {teal}%N {vintage}connected to the server.", client);
}

public void OnClientDisconnect(int client)
{
	if (VIP_IsPlayerVIP(client))
	{
		if (g_cvEnableDisconnectHud.BoolValue)
		{
			SetHudTextParams(-1.0, 0.1, 7.0, 0, 255, 150, 255, 2, 6.0, 0.1, 0.2);
			for (int i = 1; i <= MaxClients; i++)
			{
				if (IsClientInGame(i))
					ShowHudText(i, 0, "VIP %N has disconnected", client);
			}
		}
		
		if (g_cvEnableDisconnectChat.BoolValue)
			CPrintToChatAll("{vintage}VIP {teal}%N {vintage}disconnected from the server.", client);
	}
} 