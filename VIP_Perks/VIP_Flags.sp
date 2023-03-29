#include <sourcemod>
#include <VIP_Core>

#define PLUGIN_AUTHOR "NoyB"
#define PLUGIN_VERSION "1.0"

ConVar g_cvFlags = null;

public Plugin myinfo = 
{
	name = "[TF2] VIP - Flags Perk", 
	author = PLUGIN_AUTHOR, 
	description = "", 
	version = PLUGIN_VERSION, 
	url = "https://steamcommunity.com/id/noywastaken"
};

public void OnPluginStart()
{
	g_cvFlags = CreateConVar("sm_vip_flags", "t", "Flags to give the vip users, empty for nothing");
	
	AutoExecConfig();
}

public void VIP_OnPlayerLoaded(int client)
{
	char szFlags[32];
	g_cvFlags.GetString(szFlags, sizeof(szFlags));
	if (!StrEqual(szFlags, ""))
	{
		int iFlags = ReadFlagString(szFlags);
		int iPlayerFlags = GetUserFlagBits(client);
		
		bool bFlags[AdminFlags_TOTAL];
		bool bPlayerFlags[AdminFlags_TOTAL];
		bool bNewFlags[AdminFlags_TOTAL];
		
		FlagBitsToBitArray(iFlags, bFlags, AdminFlags_TOTAL);
		FlagBitsToBitArray(iPlayerFlags, bPlayerFlags, AdminFlags_TOTAL);
		
		for (int i = 0; i < AdminFlags_TOTAL; i++)
		{
			if (bPlayerFlags[i] || bFlags[i])
				bNewFlags[i] = true;
		}
		
		int iNewFlags = FlagBitArrayToBits(bNewFlags, AdminFlags_TOTAL)
		SetUserFlagBits(client, iNewFlags);
	}
} 