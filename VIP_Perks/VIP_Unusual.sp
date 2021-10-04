#include <sourcemod>
#include <morecolors>
#include <VIP_Core>
#include <tf2_stocks>
#include <tf2items>
#include <itemsgame>

#define PLUGIN_AUTHOR "NoyB, Da Vinci"
#define PLUGIN_VERSION "1.0"
#define MAX_CLASSES 10

Database g_dbDatabase = null;

Handle g_hUnusualItem;

char g_szAuth[MAXPLAYERS + 1][32];

int g_iEffectIndex[MAXPLAYERS + 1][MAX_CLASSES];
int g_iEffectHatIndex[MAXPLAYERS + 1][MAX_CLASSES];

public Plugin myinfo = 
{
	name = "[TF2] VIP - Unusuals", 
	author = PLUGIN_AUTHOR, 
	description = "", 
	version = PLUGIN_VERSION, 
	url = "https://steamcommunity.com/id/noywastaken"
};

public void OnPluginStart()
{
	SQL_MakeConnection();
	
	RegConsoleCmd("sm_effect", Command_Effect);
	
	g_hUnusualItem = TF2Items_CreateItem(56);
	TF2Items_SetNumAttributes(g_hUnusualItem, 1);
	TF2Items_SetQuality(g_hUnusualItem, 5);
}

/* Events */

public void OnClientPostAdminCheck(int client)
{
	if (!GetClientAuthId(client, AuthId_Steam2, g_szAuth[client], sizeof(g_szAuth)))
	{
		KickClient(client, "Verification problem, please reconnect");
		return;
	}
}

public void VIP_OnPlayerLoaded(int client)
{
	char szQuery[512];
	FormatEx(szQuery, sizeof(szQuery), "SELECT `class`, `hat`, `effect` FROM `vip_unusuals` WHERE `auth` = '%s'", g_szAuth[client]);
	g_dbDatabase.Query(SQL_FetchEffects, szQuery, GetClientSerial(client));
}

public void SQL_FetchEffects(Database db, DBResultSet results, const char[] error, any data)
{
	if (!StrEqual(error, ""))
	{
		LogError("Database error, %s", error);
		return;
	}
	
	int iClient = GetClientFromSerial(data);
	while (results.FetchRow())
	{
		int iClass = results.FetchInt(0);
		int iHat = results.FetchInt(1);
		int iEffect = results.FetchInt(2);
		g_iEffectHatIndex[iClient][iClass] = iHat;
		g_iEffectIndex[iClient][iClass] = iEffect;
	}
}

public Action TF2Items_OnGiveNamedItem(int client, char[] classname, int iItemDefinitionIndex, Handle &hItem)
{
	if (VIP_IsPlayerVIP(client))
	{
		if (g_iEffectHatIndex[client][getClientClassId(client)] == iItemDefinitionIndex)
		{
			TF2Items_SetAttribute(g_hUnusualItem, 0, 134, float(g_iEffectIndex[client][getClientClassId(client)]));
			hItem = g_hUnusualItem;
			return Plugin_Changed;
		}
	}
	
	return Plugin_Continue;
}

/* */

/* Commands */

public Action Command_Effect(int client, int args)
{
	if (!VIP_IsPlayerVIP(client))
	{
		CReplyToCommand(client, "%s You are not a {axis}VIP {default}member! type {axis}!vips {default}for info.", PREFIX);
		return Plugin_Handled;
	}
	
	if (args != 1)
	{
		CReplyToCommand(client, "%s Usage: sm_effect <effect(1{axis}~{default}91)|random>", PREFIX);
		return Plugin_Handled;
	}
	
	int iHat = -1;
	if ((iHat = getClientHatEntity(client)) == -1)
	{
		CReplyToCommand(client, "%s Cannot find your hat index.", PREFIX);
		return Plugin_Handled;
	}
	
	char szClass[32], szArg[32];
	GetCmdArg(1, szArg, sizeof(szArg));
	
	int iClass = getClientClassId(client);
	getNameOfClass(iClass, szClass, sizeof(szClass));
	
	if (strcmp(szArg, "0") && strcmp(szArg, "none"))
	{
		int iEffect;
		if (StrEqual(szArg, "random", false))
		{
			while (!(2 <= iEffect <= 20 || 28 <= iEffect <= 40 || 43 <= iEffect <= 47 || 55 <= iEffect <= 110))
				iEffect = GetRandomInt(2, 110);
		} else {
			iEffect = StringToInt(szArg);
		}
		
		if (!(2 <= iEffect <= 20 || 28 <= iEffect <= 40 || 43 <= iEffect <= 47 || 55 <= iEffect <= 110))
		{
			CReplyToCommand(client, "%s No effect found in #%i.", PREFIX, iEffect);
			return Plugin_Handled;
		}
		
		g_iEffectHatIndex[client][iClass] = GetEntProp(iHat, Prop_Send, "m_iItemDefinitionIndex");
		g_iEffectIndex[client][iClass] = iEffect;
		
		SQL_UpdateEffect(client, iClass, g_iEffectHatIndex[client][iClass], iEffect);
		
		CPrintToChat(client, "%s You changed your effect on class {lime}%s {default}to effect {axis}#%i{default}.", PREFIX, szClass, iEffect);
	} else {
		g_iEffectIndex[client][iClass] = 0;
		g_iEffectHatIndex[client][iClass] = 0;
		CPrintToChat(client, "%s You removed your effect on class {lime}%s{default}.", PREFIX, szClass);
	}
	return Plugin_Handled;
}

/* */

/* Functions */

int getClientHatEntity(int client)
{
	int iEnt = -1;
	char strName[16];
	while ((iEnt = FindEntityByClassname(iEnt, "tf_wearable")) != -1)
	{
		if (client == GetEntPropEnt(iEnt, Prop_Send, "m_hOwnerEntity", 0))
		{
			ItemsGameInfo(GetEntProp(iEnt, Prop_Send, "m_iItemDefinitionIndex"), "equip_region", strName, 16);
			if (StrContains(strName, "hat", false) != -1)
				return iEnt;
			
			ItemsGameInfo(GetEntProp(iEnt, Prop_Send, "m_iItemDefinitionIndex"), "equip_regions_hat", strName, 16);
			if (!strcmp(strName, "1", false))
				return iEnt;
		}
	}
	return -1;
}

int getClientClassId(int client)
{
	switch (TF2_GetPlayerClass(client))
	{
		case TFClass_Scout:
		{
			return 1;
		}
		case TFClass_Sniper:
		{
			return 2;
		}
		case TFClass_Soldier:
		{
			return 3;
		}
		case TFClass_DemoMan:
		{
			return 4;
		}
		case TFClass_Medic:
		{
			return 5;
		}
		case TFClass_Heavy:
		{
			return 6;
		}
		case TFClass_Pyro:
		{
			return 7;
		}
		case TFClass_Spy:
		{
			return 8;
		}
		case TFClass_Engineer:
		{
			return 9;
		}
	}
	return -1;
}

void getNameOfClass(int iClass, char[] class, int len)
{
	switch (iClass)
	{
		case 1:
		{
			Format(class, len, "scout");
		}
		case 2:
		{
			Format(class, len, "sniper");
		}
		case 3:
		{
			Format(class, len, "soldier");
		}
		case 4:
		{
			Format(class, len, "demoman");
		}
		case 5:
		{
			Format(class, len, "medic");
		}
		case 6:
		{
			Format(class, len, "heavy");
		}
		case 7:
		{
			Format(class, len, "pyro");
		}
		case 8:
		{
			Format(class, len, "spy");
		}
		case 9:
		{
			Format(class, len, "engineer");
		}
		default:
		{
			Format(class, len, "unknown");
		}
	}
}

/* */

/* Database */

void SQL_MakeConnection()
{
	if (g_dbDatabase != null)
		delete g_dbDatabase;
	
	char szError[512];
	g_dbDatabase = SQL_Connect(DATABASE_ENTRY, true, szError, sizeof(szError));
	if (g_dbDatabase == null)
		SetFailState("Cannot connect to datbase error: %s", szError);
	
	g_dbDatabase.Query(SQL_CheckForErrors, "CREATE TABLE IF NOT EXISTS `vip_unusuals` (`auth` VARCHAR(32) NOT NULL, `class` INT(10) NOT NULL, `hat` INT(10) NOT NULL, `effect` INT(10) NOT NULL, UNIQUE(`auth`, `class`))");
}

void SQL_UpdateEffect(int client, int class, int hat, int effect)
{
	char szQuery[512];
	FormatEx(szQuery, sizeof(szQuery), "INSERT INTO `vip_unusuals` (`auth`, `class`, `hat`, `effect`) VALUES ('%s', %d, %d, %d) ON DUPLICATE KEY UPDATE `hat` = %d, `effect` = %d", g_szAuth[client], class, hat, effect, hat, effect);
	g_dbDatabase.Query(SQL_CheckForErrors, szQuery);
}

public void SQL_CheckForErrors(Database db, DBResultSet results, const char[] error, any data)
{
	if (!StrEqual(error, ""))
	{
		LogError("Database error, %s", error);
		return;
	}
}

/* */