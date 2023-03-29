#include <sourcemod>
#include <VIP_Core>
#include <morecolors>
#include <scp>

#define PLUGIN_AUTHOR "NoyB"
#define PLUGIN_VERSION "1.0"

#define SHORT_HEX 6
#define LONG_HEX 8

ConVar g_cvTag;
ConVar g_cvTagColor;
ConVar g_cvChatColor;
ConVar g_cvEnableOnAdmins;

char g_szTag[32];
char g_szTagColor[8];
char g_szChatColor[8];

public Plugin myinfo = 
{
	name = "[TF2] VIP - Chat",
	author = PLUGIN_AUTHOR,
	description = "",
	version = PLUGIN_VERSION,
	url = "https://steamcommunity.com/id/noywastaken"
};

public void OnPluginStart()
{
	g_cvTag = CreateConVar("sm_vip_tag", "[VIP]", "Tag to add in the chat for the VIP players");
	g_cvTagColor = CreateConVar("sv_vip_tag_color", "#FFD700", "Color to put for the tag");
	g_cvChatColor = CreateConVar("sv_vip_chat_color", "#FFD700", "Color to put for the VIP's chat messages");
	g_cvEnableOnAdmins = CreateConVar("sm_vip_admins", "0", "Should we add tags if the user is an admin?", 0, true, 0.0, true, 1.0);
	
	g_cvTag.AddChangeHook(OnCvarChange);
	g_cvTagColor.AddChangeHook(OnCvarChange);
	g_cvChatColor.AddChangeHook(OnCvarChange);
	
	AutoExecConfig();
	updateCvars();
}

public void OnCvarChange(ConVar convar, const char[] oldValue, const char[] newValue)
{
	updateCvars();
}

public Action OnChatMessage(int &author, Handle recipients, char[] name, char[] message)
{
	if(VIP_IsPlayerVIP(author) && (g_cvEnableOnAdmins.BoolValue || GetUserAdmin(author) == INVALID_ADMIN_ID))
	{
		if(strlen(g_szTag) > 0)
		{
			if(strlen(g_szTagColor) == SHORT_HEX)
				Format(name, MAXLENGTH_NAME, "\x07%s%s \x03%s", g_szTagColor, g_szTag, name);
			else if(strlen(g_szTagColor) == LONG_HEX)
				Format(name, MAXLENGTH_NAME, "\x08%s%s \x03%s", g_szTagColor, g_szTag, name);
			else
				Format(name, MAXLENGTH_NAME, "\x01%s \x03%s", g_szTag, name);
		}
			
		if(strlen(g_szChatColor) == SHORT_HEX)
			Format(message, MAXLENGTH_MESSAGE, "\x07FFD700%s", message);
		else if(strlen(g_szChatColor) == LONG_HEX)
			Format(message, MAXLENGTH_MESSAGE, "\x08FFD700%s", message);
			
		return Plugin_Changed;
	}
	
	return Plugin_Continue;
}

void updateCvars()
{
	g_cvTag.GetString(g_szTag, sizeof(g_szTag));
	g_cvTagColor.GetString(g_szTagColor, sizeof(g_szTagColor));
	g_cvChatColor.GetString(g_szChatColor, sizeof(g_szChatColor));
	
	ReplaceString(g_szTagColor, sizeof(g_szTagColor), "#", "");
	ReplaceString(g_szChatColor, sizeof(g_szChatColor), "#", "");
}