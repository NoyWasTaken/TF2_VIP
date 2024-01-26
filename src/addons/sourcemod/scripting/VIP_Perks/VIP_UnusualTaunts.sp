#include <sourcemod>
#include <morecolors>
#include <clientprefs>
#include <tf2>
#include <tf2_stocks>
#include <tf_econ_data>
#include <VIP_Core>

#define PLUGIN_AUTHOR "NoyB"
#define PLUGIN_VERSION "1.0"

#define INVALID_INDEX -1

#define EFFECT_NAME_FORMAT "Attrib_Particle%d"

enum struct ParsedEffect
{
	int index;
	char name[64];
	char particleName[64];
}

ArrayList g_alParsedEffects = null;
StringMap g_smTokensMap = null;
Handle g_hCookie = INVALID_HANDLE;

int g_iEffect[MAXPLAYERS + 1] = { 0 };
int g_iParticle[MAXPLAYERS + 1] = { 0 };

public Plugin myinfo = 
{
	name = "[TF2] VIP - Unusual Taunts", 
	author = PLUGIN_AUTHOR, 
	description = "", 
	version = PLUGIN_VERSION, 
	url = "https://steamcommunity.com/id/noywastaken"
};

public void OnPluginStart()
{
	/* Handles */
	g_smTokensMap = ParseLanguage("english");
	g_alParsedEffects = parseEffects();
	g_hCookie = RegClientCookie("vip_taunt_effect", "Taunt effect of VIP players.", CookieAccess_Protected);
	
	/* Commands */
	RegConsoleCmd("sm_utaunt", Command_Effects);
}

/* Events */

public void OnClientCookiesCached(int client)
{
	if (VIP_IsPlayerVIP(client))
	{
		char szBuffer[10];
		GetClientCookie(client, g_hCookie, szBuffer, sizeof(szBuffer));
		
		if (szBuffer[0] != 0)
		{
			int iEffectIndex = StringToInt(szBuffer);
			g_iEffect[client] = getEffectListIndex(iEffectIndex);
		}
		else
			g_iEffect[client] = INVALID_INDEX;
	}
}

public void TF2_OnConditionAdded(int client, TFCond condition)
{
	if (VIP_IsPlayerVIP(client) && g_iEffect[client] != INVALID_INDEX && condition == TFCond_Taunting)
	{
		float fPos[3] = { 0.0 };
		GetEntPropVector(client, Prop_Send, "m_vecOrigin", fPos, 0);
		
		ParsedEffect peEffect;
		g_alParsedEffects.GetArray(g_iEffect[client], peEffect);
		g_iParticle[client] = createParticle(client, peEffect.particleName, fPos);
	}
}

public void TF2_OnConditionRemoved(int client, TFCond condition)
{
	if (VIP_IsPlayerVIP(client) && g_iEffect[client] != INVALID_INDEX && condition == TFCond_Taunting)
	{
		if (IsValidEntity(g_iParticle[client]))
			AcceptEntityInput(g_iParticle[client], "Kill");
	}
}

public void VIP_OnMenuOpenned(int client, Menu menu)
{
	menu.AddItem("utaunt", "Unusual Taunts");
}

/* */

/* Commands */

public Action Command_Effects(int client, int args)
{
	if (!VIP_IsPlayerVIP(client))
	{
		CReplyToCommand(client, "%s You are not a {axis}VIP {default}member! type {axis}!vips {default}for info.", PREFIX);
		return Plugin_Handled;
	}
	
	Menus_ShowEffects(client);
	return Plugin_Handled;
}

/* */

/* Menus */

void Menus_ShowEffects(int client)
{
	Menu menu = new Menu(Handler_Effects);
	menu.SetTitle("%s Select an Effect\n ", PREFIX_MENU);
	
	for (int i = 0; i < g_alParsedEffects.Length; i++)
	{
		ParsedEffect peEffect;
		g_alParsedEffects.GetArray(i, peEffect);
		
		char szListIndex[10];
		IntToString(i, szListIndex, sizeof(szListIndex));
		
		menu.AddItem(szListIndex, peEffect.name);
	}
	
	menu.ExitBackButton = true;
	menu.Display(client, MENU_TIME_FOREVER);
}

public int Handler_Effects(Menu menu, MenuAction action, int client, int itemNum)
{
	if (action == MenuAction_Cancel && itemNum == MenuCancel_ExitBack)
	{
		FakeClientCommandEx(client, "sm_vip");
	} else if (action == MenuAction_Select) {
		char szListIndex[10];
		menu.GetItem(itemNum, szListIndex, sizeof(szListIndex));
		
		int iListIndex = StringToInt(szListIndex);
		
		ParsedEffect peEffect;
		g_alParsedEffects.GetArray(iListIndex, peEffect);
		
		/* Update Cookie */
		char szEffectIndex[10];
		IntToString(peEffect.index, szEffectIndex, sizeof(szEffectIndex))
		SetClientCookie(client, g_hCookie, szEffectIndex);
		/* */
		
		g_iEffect[client] = iListIndex;
		
		CPrintToChat(client, "%s Changed taunt effect to: %s.", PREFIX, peEffect.name);
	} else if (action == MenuAction_Cancel) {
		delete menu;
	}
	
	return 0;
}

/* */

/* Functions */

int getEffectListIndex(int effectIndex)
{
	for (int i = 0; i < g_alParsedEffects.Length; i++)
	{
		ParsedEffect peEffect;
		g_alParsedEffects.GetArray(i, peEffect);
		
		if (peEffect.index == effectIndex)
			return i;
	}
	
	return INVALID_INDEX;
}

ArrayList parseEffects()
{
	ArrayList alParsedEffects = new ArrayList(sizeof(ParsedEffect));
	
	/* Loop through the effects and parse them */
	ArrayList alEffects = TF2Econ_GetParticleAttributeList(ParticleSet_TauntUnusualEffects)
	for (int i = 0; i < alEffects.Length; i++)
	{
		int iEffectIndex = alEffects.Get(i);
		
		/* Get Particle Name */
		char szParticleName[64];
		if (!TF2Econ_GetParticleAttributeSystemName(iEffectIndex, szParticleName, sizeof(szParticleName)))
		{
			LogError("Failed to get an effect name on index #%d", iEffectIndex);
			continue;
		}
		/* */
		
		/* Parse Translation Name */
		char szAttribName[64];
		FormatEx(szAttribName, sizeof(szAttribName), EFFECT_NAME_FORMAT, iEffectIndex);
		
		char szParsedName[64];
		if (!LocalizeToken(szAttribName, szParsedName, sizeof(szParsedName)))
			strcopy(szParsedName, sizeof(szParsedName), szAttribName);
		/* */
		
		ParsedEffect peEffect;
		peEffect.index = iEffectIndex;
		strcopy(peEffect.name, sizeof(peEffect.name), szParsedName);
		strcopy(peEffect.particleName, sizeof(peEffect.particleName), szParticleName);
		
		alParsedEffects.PushArray(peEffect);
	}
	
	return alParsedEffects;
}

int createParticle(int client, char[] effect, float fPos[3])
{
	int iParticle = CreateEntityByName("info_particle_system", -1);
	if (iParticle != -1)
	{
		TeleportEntity(iParticle, fPos, NULL_VECTOR, NULL_VECTOR);
		
		char szName[16];
		FormatEx(szName, sizeof(szName), "target%d", client);
		DispatchKeyValue(client, "targetname", szName);
		DispatchKeyValue(iParticle, "targetname", "tf2particle");
		DispatchKeyValue(iParticle, "parentname", szName);
		DispatchKeyValue(iParticle, "effect_name", effect);
		DispatchSpawn(iParticle);
		SetVariantString(szName);
		AcceptEntityInput(iParticle, "SetParent", iParticle, iParticle);
		ActivateEntity(iParticle);
		AcceptEntityInput(iParticle, "start");
		return iParticle;
	}
	
	return -1;
}

/* */

/*
	Localization Functions
	Taken from: https://github.com/x07x08/TF2-Econ-Taunts/blob/main/addons/sourcemod/scripting/TF2EconUnusualTaunts.sp
	(originally from https://github.com/DoctorMcKay/sourcemod-plugins/blob/master/scripting/enhanced_items.sp)
*/

bool LocalizeToken(const char[] token, char[] output, int maxLen)
{
	if (g_smTokensMap == null)
	{
		LogError("Unable to localize token for server language!");
		return false;
	}
	
	return g_smTokensMap.GetString(token, output, maxLen);
}

StringMap ParseLanguage(const char[] strLanguage)
{
	char strFilename[64];
	Format(strFilename, sizeof(strFilename), "resource/tf_%s.txt", strLanguage);
	File hFile = OpenFile(strFilename, "r");
	
	if (hFile == null)
	{
		LogError("Couldn't find language file for %s", strLanguage);
		return null;
	}
	
	// The localization files are encoded in UCS-2, breaking all of our available parsing options
	// We have to go byte-by-byte then line-by-line :(
	
	// This parser isn't perfect since some values span multiple lines, but since we're only interested in single-line values, this is sufficient
	
	StringMap hLang = new StringMap();
	hLang.SetString("__name__", strLanguage);
	
	int iData, i = 0;
	char strLine[2048];
	
	while (ReadFileCell(hFile, iData, 2) == 1)
	{
		if (iData < 0x80)
		{
			// It's a single-byte character
			strLine[i++] = iData;
			
			if (iData == '\n')
			{
				strLine[i] = '\0';
				HandleLangLine(strLine, hLang);
				i = 0;
			}
		}
		else if (iData < 0x800)
		{
			// It's a two-byte character
			strLine[i++] = (iData >> 6) | 0xC0;
			strLine[i++] = (iData & 0x3F) | 0x80;
		}
		else if (iData < 0xFFFF && iData >= 0xD800 && iData <= 0xDFFF)
		{
			strLine[i++] = (iData >> 12) | 0xE0;
			strLine[i++] = ((iData >> 6) & 0x3F) | 0x80;
			strLine[i++] = (iData & 0x3F) | 0x80;
		}
		else if (iData >= 0x10000 && iData < 0x10FFFF)
		{
			strLine[i++] = (iData >> 18) | 0xF0;
			strLine[i++] = ((iData >> 12) & 0x3F) | 0x80;
			strLine[i++] = ((iData >> 6) & 0x3F) | 0x80;
			strLine[i++] = (iData & 0x3F) | 0x80;
		}
	}
	
	delete hFile;
	
	return hLang;
}

void HandleLangLine(char[] strLine, StringMap hLang)
{
	TrimString(strLine);
	
	if (strLine[0] != '"')
	{
		// Not a line containing at least one quoted string
		return;
	}
	
	char strToken[128], strValue[1024];
	int iPos = BreakString(strLine, strToken, sizeof(strToken));
	
	if (iPos == -1)
	{
		// This line doesn't have two quoted strings
		return;
	}
	
	BreakString(strLine[iPos], strValue, sizeof(strValue));
	
	if (StrContains(strToken, "Attrib_Particle") != -1) // Only particles should be added
	{
		hLang.SetString(strToken, strValue);
	}
}
