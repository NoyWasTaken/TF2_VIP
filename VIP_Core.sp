#include <sourcemod>
#include <regex>
#include <morecolors>
#include <VIP_Core>

#define PLUGIN_AUTHOR "NoyB"
#define PLUGIN_VERSION "1.0"

#define DAY_TO_SECONDS 86400

enum struct Player
{
	char auth[32];
	char name[MAX_NAME_LENGTH];
	
	int expiration;
	
	void reset()
	{
		this.auth[0] = 0;
		this.name[0] = 0;
		
		this.expiration = 0;
	}
	
	int daysLeft()
	{
		int days = (this.expiration - GetTime()) / DAY_TO_SECONDS;
		return days >= 0 ? days:0;
	}
	
	bool isVip()
	{
		return this.expiration - GetTime() > 0;
	}
}

Player g_aPlayers[MAXPLAYERS + 1];

Database g_dbConnection = null;

GlobalForward g_fwdVipMenuOpen = null;
GlobalForward g_fwdVipGiven = null;
GlobalForward g_fwdVipLoaded = null;

bool g_bLate = false;
bool g_bWriting[MAXPLAYERS + 1] = { false };

int g_iRounds = 0;
int g_iTarget[MAXPLAYERS + 1] = { -1 };
int g_iDuration[MAXPLAYERS + 1] = { 0 };

public Plugin myinfo = 
{
	name = "[TF2] VIP - Core", 
	author = PLUGIN_AUTHOR, 
	description = "", 
	version = PLUGIN_VERSION, 
	url = "https://steamcommunity.com/id/noywastaken"
};

public void OnPluginStart()
{
	SQL_MakeConnection();
	
	HookEvent("round_start", Event_RoundStart);
	
	RegConsoleCmd("sm_vipmenu", Command_VipMenu);
	
	RegAdminCmd("sm_vip", Command_VIP, ADMFLAG_ROOT, "VIP Management");
	RegAdminCmd("sm_addvip", Command_AddVIP, ADMFLAG_ROOT, "This command is used to add a vip using steamid")
	
	if (g_bLate)
		for (int i = 1; i <= MaxClients; i++)if (IsClientInGame(i))OnClientPostAdminCheck(i);
}

/* Natives */

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	g_bLate = late;
	
	CreateNative("VIP_IsPlayerVIP", Native_IsPlayerVIP);
	
	g_fwdVipMenuOpen = new GlobalForward("VIP_OnMenuOpenned", ET_Event, Param_Cell, Param_Cell);
	g_fwdVipLoaded = new GlobalForward("VIP_OnPlayerLoaded", ET_Event, Param_Cell);
	g_fwdVipGiven = new GlobalForward("VIP_OnPlayerGiven", ET_Event, Param_Cell, Param_Cell);
	
	RegPluginLibrary("[TF2] VIP - Core");
	return APLRes_Success;
}

public int Native_IsPlayerVIP(Handle plugin, int numParams)
{
	int iClient = GetNativeCell(1);
	if (iClient < 1 || iClient > MaxClients)
	{
		return ThrowNativeError(SP_ERROR_NATIVE, "Invalid client index (%d)", iClient);
	}
	if (!IsClientConnected(iClient))
	{
		return ThrowNativeError(SP_ERROR_NATIVE, "Client %d is not connected", iClient);
	}
	
	return g_aPlayers[iClient].isVip();
}

/* */

/* Events */

public void OnMapStart()
{
	g_iRounds = 0;
}

public void OnClientPostAdminCheck(int client)
{
	g_aPlayers[client].reset();
	if (!GetClientAuthId(client, AuthId_Steam2, g_aPlayers[client].auth, sizeof(g_aPlayers[].auth)))
	{
		KickClient(client, "Verification problem, please reconnect");
		return;
	}
	
	GetClientName(client, g_aPlayers[client].name, sizeof(g_aPlayers[].name));
	SQL_LoadUser(client);
}

public Action Event_RoundStart(Event event, char[] name, bool dontBroadcast)
{
	g_iRounds++;
	return Plugin_Continue;
}

public Action OnClientSayCommand(int client, const char[] command, const char[] args)
{
	if (g_bWriting[client])
	{
		if (!strcmp(args[0], "-1"))
		{
			CPrintToChat(client, "%s Opreation aborted.", PREFIX);
		} else {
			g_iDuration[client] = StringToInt(args[0]);
		}
		
		Menus_ShowPlayer(client);
		g_bWriting[client] = false;
		return Plugin_Handled;
	}
	
	return Plugin_Continue;
}

/* */

/* Commands */

public Action Command_VipMenu(int client, int args)
{
	Menu menu = new Menu(Handler_VipMenu);
	menu.SetTitle("%s VIP Menu (%s days left)\n ", PREFIX_MENU, addCommas(g_aPlayers[client].daysLeft()))
	
	any aResults = 0;
	Call_StartForward(g_fwdVipMenuOpen);
	Call_PushCell(client);
	Call_PushCell(menu);
	Call_Finish(aResults);
	
	menu.Display(client, MENU_TIME_FOREVER);
	return Plugin_Handled;
}

public int Handler_VipMenu(Menu menu, MenuAction action, int client, int itemNum)
{
	if (action == MenuAction_Select)
	{
		char szBuffer[32];
		menu.GetItem(itemNum, szBuffer, sizeof(szBuffer));
		FakeClientCommand(client, "say /%s", szBuffer);
	}
	
	return 0;
}

public Action Command_VIP(int client, int args)
{
	if (!client)
	{
		PrintToServer("This command is for in-game only.");
		return Plugin_Handled;
	}
	
	Menus_ShowMain(client);
	return Plugin_Handled;
}

public Action Command_AddVIP(int client, int args)
{
	if (args != 2)
	{
		CReplyToCommand(client, "%s Usage: sm_addvip <steamid> <days>", PREFIX);
		return Plugin_Handled;
	}
	
	char szArg[32], szArg2[10];
	GetCmdArg(1, szArg, sizeof(szArg));
	GetCmdArg(2, szArg2, sizeof(szArg2));
	
	Regex rSteam = new Regex("STEAM_\\d:\\d:\\d{9}");
	if (!rSteam.Match(szArg))
	{
		delete rSteam;
		
		CReplyToCommand(client, "%s Invalid steamid entered, please try again.", PREFIX);
		return Plugin_Handled;
	}
	
	delete rSteam;
	int iDuration = StringToInt(szArg2);
	if (iDuration < 0)
	{
		CReplyToCommand(client, "%s Invalid amount of days entered, please try again.", PREFIX);
		return Plugin_Handled;
	}
	
	SQL_AddOfflineVIP(szArg, iDuration);
	CShowActivity2(client, PREFIX_ACTIVITY, "Gave a vip to \x02\"%s\" \x01for \x04%s \x01days.", szArg, addCommas(iDuration));
	
	return Plugin_Handled;
}

/* */

/* Menus */

void Menus_ShowMain(int client)
{
	Menu menu = new Menu(Handler_MainMenu);
	menu.SetTitle("%s VIP Management\n ", PREFIX_MENU);
	menu.AddItem("add", "Add a VIP");
	menu.AddItem("manage", "Manage VIPs");
	menu.Display(client, MENU_TIME_FOREVER);
}

public int Handler_MainMenu(Menu menu, MenuAction action, int client, int itemNum)
{
	if (action == MenuAction_Select)
	{
		char szInfo[32];
		menu.GetItem(itemNum, szInfo, sizeof(szInfo));
		
		if (!strcmp(szInfo, "add"))
		{
			Menus_SelectPlayer(client);
		} else if (!strcmp(szInfo, "manage")) {
			SQL_ShowVips(client);
		}
	}
	
	return 0;
}

void Menus_SelectPlayer(int client)
{
	Menu menu = new Menu(Handler_PlayerSelection);
	menu.SetTitle("%s Select a Player:\n ", PREFIX_MENU);
	
	for (int i = 1; i <= MaxClients; i++)
	{
		if (IsClientInGame(i) && !g_aPlayers[i].isVip())
		{
			char szIndex[10], szName[MAX_NAME_LENGTH];
			IntToString(i, szIndex, sizeof(szIndex));
			GetClientName(i, szName, sizeof(szName));
			
			menu.AddItem(szIndex, szName);
		}
	}
	
	menu.ExitBackButton = true;
	menu.Display(client, MENU_TIME_FOREVER);
}

public int Handler_PlayerSelection(Menu menu, MenuAction action, int client, int itemNum)
{
	if (action == MenuAction_Cancel && itemNum == MenuCancel_ExitBack)
	{
		Menus_ShowMain(client);
	} else if (action == MenuAction_Select) {
		char szInfo[10];
		menu.GetItem(itemNum, szInfo, sizeof(szInfo));
		
		int iTarget = StringToInt(szInfo);
		if (!IsClientInGame(iTarget))
		{
			CPrintToChat(client, "%s Target not available anymore.", PREFIX);
			return 0;
		}
		
		g_iTarget[client] = iTarget;
		Menus_ShowPlayer(client);
	}
	
	return 0;
}

void Menus_ShowPlayer(int client)
{
	Menu menu = new Menu(Handler_PlayerManagement);
	menu.SetTitle("%s Adding a VIP:\n ", PREFIX_MENU);
	
	char szBuffer[MAX_NAME_LENGTH * 2];
	GetClientName(g_iTarget[client], szBuffer, sizeof(szBuffer));
	
	Format(szBuffer, sizeof(szBuffer), "Target: %s", szBuffer);
	menu.AddItem("target", szBuffer);
	
	Format(szBuffer, sizeof(szBuffer), "Duration: %s days", addCommas(g_iDuration[client]));
	menu.AddItem("duration", szBuffer);
	menu.AddItem("add", "Add VIP");
	
	menu.ExitBackButton = true;
	menu.Display(client, MENU_TIME_FOREVER);
}

public int Handler_PlayerManagement(Menu menu, MenuAction action, int client, int itemNum)
{
	if (action == MenuAction_Cancel && itemNum == MenuCancel_ExitBack)
	{
		Menus_SelectPlayer(client);
	} else if (action == MenuAction_Select) {
		char szInfo[32];
		menu.GetItem(itemNum, szInfo, sizeof(szInfo));
		
		if (!strcmp(szInfo, "target"))
		{
			Menus_SelectPlayer(client);
		} else if (!strcmp(szInfo, "duration")) {
			g_bWriting[client] = true;
			CPrintToChat(client, "%s Write the amount of days you want or \x02-1 \x01to abort.", PREFIX);
		} else if (!strcmp(szInfo, "add")) {
			if (!IsClientInGame(g_iTarget[client]))
			{
				CPrintToChat(client, "%s Target is not available anymore.", PREFIX);
				Menus_SelectPlayer(client);
				return 0;
			}
			
			if (g_iDuration[client] <= 0)
			{
				CPrintToChat(client, "%s Invalid time entered, please try again.", PREFIX);
				Menus_ShowPlayer(client);
				return 0;
			}
			
			if (g_aPlayers[g_iTarget[client]].isVip())
			{
				CPrintToChat(client, "%s Target is already a VIP.", PREFIX);
				Menus_SelectPlayer(client);
				return 0;
			}
			
			Call_StartForward(g_fwdVipGiven);
			Call_PushCell(g_iTarget[client]);
			Call_PushCell(g_iDuration[client]);
			Call_Finish();
			
			SQL_AddVIP(client);
			OnClientPostAdminCheck(g_iTarget[client]);
			
			CShowActivity2(client, PREFIX_ACTIVITY, "Gave a vip to \x02%N \x01for \x04%s \x01days.", g_iTarget[client], addCommas(g_iDuration[client]));
			
			g_iTarget[client] = -1;
			g_iDuration[client] = 0;
		}
	}
	
	return 0;
}

public int Handler_ManageVIPs(Menu menu, MenuAction action, int client, int itemNum)
{
	if (action == MenuAction_Cancel && itemNum == MenuCancel_ExitBack)
	{
		Menus_ShowMain(client);
	} else if (action == MenuAction_Select) {
		char szAuth[32];
		menu.GetItem(itemNum, szAuth, sizeof(szAuth));
		
		char szQuery[512];
		SQL_FormatQuery(g_dbConnection, szQuery, sizeof(szQuery), "SELECT * FROM `vips` WHERE `auth` = '%s'", szAuth);
		g_dbConnection.Query(SQL_FetchVIP, szQuery, GetClientSerial(client));
	}
	
	return 0;
}

public int Handler_ManageVIP(Menu menu, MenuAction action, int client, int itemNum)
{
	if (action == MenuAction_Cancel && itemNum == MenuCancel_ExitBack)
	{
		SQL_ShowVips(client);
	} else if (action == MenuAction_Select) {
		char szAuth[32], szAction[32];
		menu.GetItem(0, szAuth, sizeof(szAuth));
		menu.GetItem(itemNum, szAction, sizeof(szAction));
		
		if (!strcmp(szAction, "remove"))
		{
			SQL_RemoveVIP(szAuth);
			
			int iTarget = getClientOfAuth(szAuth);
			if (iTarget != -1)
			{
				g_aPlayers[iTarget].expiration = 0;
				CShowActivity2(client, PREFIX_ACTIVITY, "Removed vip of %N.", iTarget);
			} else {
				CShowActivity2(client, PREFIX_ACTIVITY, "Removed vip of \"%s\".", szAuth);
			}
		}
	}
	
	return 0;
}

/* */

/* Functions */

int getOnlineUsers()
{
	int iCount = 0;
	for (int i = 1; i <= MaxClients; i++)
	{
		if (IsClientInGame(i))
			iCount++;
	}
	
	return iCount;
}

int getClientOfAuth(char[] auth)
{
	for (int i = 1; i <= MaxClients; i++)
	{
		if (IsClientInGame(i) && !strcmp(g_aPlayers[i].auth, auth))
			return i;
	}
	
	return -1;
}

char[] addCommas(int value, const char[] seperator = ",")
{
	char buffer[MAX_NAME_LENGTH];
	buffer[0] = '\0';
	int divisor = 1000;
	
	while (value >= 1000 || value <= -1000)
	{
		int offcut = value % divisor;
		value = RoundToFloor(float(value) / float(divisor));
		Format(buffer, MAX_NAME_LENGTH, "%c%03.d%s", seperator, offcut, buffer);
	}
	
	Format(buffer, MAX_NAME_LENGTH, "%d%s", value, buffer);
	return buffer;
}

/* */

/* Database */

void SQL_MakeConnection()
{
	if (g_dbConnection != null)
		delete g_dbConnection;
	
	char szError[512];
	g_dbConnection = SQL_Connect(DATABASE_ENTRY, true, szError, sizeof(szError));
	if (g_dbConnection == null)
		SetFailState("Cannot connect to datbase error: %s", szError);
	
	g_dbConnection.SetCharset("utf8mb4");
	g_dbConnection.Query(SQL_CheckForErrors, "CREATE TABLE IF NOT EXISTS `vips` (`auth` VARCHAR(32) NOT NULL, `name` VARCHAR(64) NOT NULL, `expiration` INT(10) NOT NULL, UNIQUE(`auth`))");
}

void SQL_ShowVips(int client)
{
	char szQuery[512];
	SQL_FormatQuery(g_dbConnection, szQuery, sizeof(szQuery), "SELECT * FROM `vips` WHERE `expiration` > %d", GetTime());
	g_dbConnection.Query(SQL_ManageVips, szQuery, GetClientSerial(client));
}

void SQL_LoadUser(int client)
{
	char szQuery[512];
	SQL_FormatQuery(g_dbConnection, szQuery, sizeof(szQuery), "SELECT `expiration` FROM `vips` WHERE `auth` = '%s'", g_aPlayers[client].auth);
	g_dbConnection.Query(SQL_LoadUser_CB, szQuery, GetClientSerial(client));
}

public void SQL_LoadUser_CB(Database db, DBResultSet results, const char[] error, any data)
{
	if (strcmp(error, ""))
	{
		LogError("Database error: %s", error);
		return;
	}
	
	int iClient = GetClientFromSerial(data);
	if (results.FetchRow())
	{
		int iExpiration = results.FetchInt(0);
		if (iExpiration - GetTime() > 0)
		{
			g_aPlayers[iClient].expiration = iExpiration;
			
			// update name in the database
			SQL_UpdatePlayer(iClient);
			
			// call the forward
			Call_StartForward(g_fwdVipLoaded);
			Call_PushCell(iClient);
			Call_Finish();
		} else if (GetMaxHumanPlayers() < getOnlineUsers() && g_iRounds > 1) {
			KickClient(iClient, "Server is full")
		}
	}
}

void SQL_AddVIP(int client)
{
	int iTarget = g_iTarget[client];
	int iExpiration = GetTime() + (g_iDuration[client] * DAY_TO_SECONDS);
	g_aPlayers[iTarget].expiration = iExpiration;
	
	char szQuery[512];
	SQL_FormatQuery(g_dbConnection, szQuery, sizeof(szQuery), "INSERT INTO `vips` (`auth`, `name`, `expiration`) VALUES ('%s', '%s', %d) ON DUPLICATE KEY UPDATE `expiration` = %d, `name` = '%s'", g_aPlayers[iTarget].auth, g_aPlayers[iTarget].name, iExpiration, iExpiration, g_aPlayers[iTarget].name);
	g_dbConnection.Query(SQL_CheckForErrors, szQuery);
}

void SQL_AddOfflineVIP(char[] auth, int duration)
{
	int iExpiration = GetTime() + (duration * DAY_TO_SECONDS);
	
	char szQuery[512];
	SQL_FormatQuery(g_dbConnection, szQuery, sizeof(szQuery), "INSERT INTO `vips` (`auth`, `name`, `expiration`) VALUES ('%s', 'Added Offline', %d) ON DUPLICATE KEY UPDATE `expiration` = %d", auth, iExpiration, iExpiration);
	g_dbConnection.Query(SQL_CheckForErrors, szQuery);
}

void SQL_UpdatePlayer(int client)
{
	char szQuery[512];
	SQL_FormatQuery(g_dbConnection, szQuery, sizeof(szQuery), "UPDATE `vips` SET `name` = '%s' WHERE `auth` = '%s'", g_aPlayers[client].name, g_aPlayers[client].auth);
	g_dbConnection.Query(SQL_CheckForErrors, szQuery);
}

void SQL_RemoveVIP(char[] auth)
{
	char szQuery[512];
	SQL_FormatQuery(g_dbConnection, szQuery, sizeof(szQuery), "DELETE FROM `vips` WHERE `auth` = '%s'", auth);
	g_dbConnection.Query(SQL_CheckForErrors, szQuery);
}

public void SQL_ManageVips(Database db, DBResultSet results, const char[] error, any data)
{
	if (strcmp(error, ""))
	{
		LogError("Database error, %s", error);
		return;
	}
	
	int iClient = GetClientFromSerial(data);
	
	Menu menu = new Menu(Handler_ManageVIPs);
	menu.SetTitle("%s Manage VIPs - Select a Player:\n ", PREFIX_MENU);
	
	int iCount = 0;
	while (results.FetchRow())
	{
		iCount++;
		
		char szAuth[32], szName[MAX_NAME_LENGTH];
		results.FetchString(0, szAuth, sizeof(szAuth));
		results.FetchString(1, szName, sizeof(szName));
		
		menu.AddItem(szAuth, szName);
	}
	
	if (!iCount)
		menu.AddItem("", "No vip players were found in the database.", ITEMDRAW_DISABLED);
	
	menu.ExitBackButton = true;
	menu.Display(iClient, MENU_TIME_FOREVER);
}

public void SQL_FetchVIP(Database db, DBResultSet results, const char[] error, any data)
{
	if (strcmp(error, ""))
	{
		LogError("Database error, %s", error);
		return;
	}
	
	int iClient = GetClientFromSerial(data);
	
	if (results.FetchRow())
	{
		char szAuth[32], szName[MAX_NAME_LENGTH];
		results.FetchString(0, szAuth, sizeof(szAuth));
		results.FetchString(1, szName, sizeof(szName));
		
		char szTime[64];
		FormatTime(szTime, sizeof(szTime), "%d/%m/%Y %R", results.FetchInt(2));
		
		Menu menu = new Menu(Handler_ManageVIP);
		menu.SetTitle("%s Manage VIP - Viewing \"%s\"\nExpiration Date: %s\n ", PREFIX_MENU, szName, szTime);
		menu.AddItem(szAuth, szName, ITEMDRAW_IGNORE);
		menu.AddItem("remove", "Remove VIP");
		menu.ExitBackButton = true;
		menu.Display(iClient, MENU_TIME_FOREVER);
	}
}

public void SQL_CheckForErrors(Database db, DBResultSet results, const char[] error, any data)
{
	if (strcmp(error, ""))
	{
		LogError("Database error: %s", error);
	}
}

/* */