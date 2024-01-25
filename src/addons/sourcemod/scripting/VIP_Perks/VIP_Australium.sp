#include <sourcemod>
#include <morecolors>
#include <clientprefs>
#include <sdktools>
#include <tf2_stocks>
#include <tf2items>
#include <VIP_Core>

#define PLUGIN_AUTHOR "NoyB, Nanochip"
#define PLUGIN_VERSION "1.0"

#define ATTRIBUTES "2027 ; 1 ; 2022 ; 1 ; 542 ; 1"

#define INVALID_WEAPON -1

Handle g_hCookie;

bool g_bAustralium[MAXPLAYERS + 1];

public Plugin myinfo = 
{
	name = "[TF2] VIP - Australium Weapons", 
	author = PLUGIN_AUTHOR, 
	description = "", 
	version = PLUGIN_VERSION, 
	url = "https://steamcommunity.com/id/noywastaken"
};

public void OnPluginStart()
{
	g_hCookie = RegClientCookie("vip_australium", "Spawn australium weapons every round for VIP player", CookieAccess_Protected);
	
	HookEvent("post_inventory_application", Event_PlayerRegen);
	
	RegConsoleCmd("sm_australium", Command_Australium);
}

/* Hooks, Events */

public void OnClientCookiesCached(int client)
{
	if (VIP_IsPlayerVIP(client))
	{
		char szBuffer[16];
		GetClientCookie(client, g_hCookie, szBuffer, sizeof(szBuffer));
		
		if (!strcmp(szBuffer, "true"))
			g_bAustralium[client] = true;
		else
			g_bAustralium[client] = false;
	}
}

public void OnClientDisconnect(int client)
{
	g_bAustralium[client] = false;
}

public Action Event_PlayerRegen(Event event, char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(event.GetInt("userid"));
	if (VIP_IsPlayerVIP(client))
	{
		if (g_bAustralium[client])
			giveAustraliums(client);
	}
	
	return Plugin_Continue;
}

public void VIP_OnMenuOpenned(int client, Menu menu)
{
	menu.AddItem("australium", "Toggle Australium");
}

/* */

/* Commands */

public Action Command_Australium(int client, int args)
{
	if (!VIP_IsPlayerVIP(client))
	{
		CReplyToCommand(client, "%s You are not a {axis}VIP {default}member! type {axis}!vips {default}for info.", PREFIX);
		return Plugin_Handled;
	}
	
	g_bAustralium[client] = !g_bAustralium[client];
	SetClientCookie(client, g_hCookie, g_bAustralium[client] ? "true":"false");
	
	giveAustraliums(client);
	
	CPrintToChat(client, "%s %s the {axis}Australium Weapons{default}.", PREFIX, g_bAustralium[client] ? "Enabled":"Disabled");
	return Plugin_Handled;
}

/* */

/* Functions */

void giveAustraliums(int client)
{
	if (VIP_IsPlayerVIP(client) && g_bAustralium[client] && IsPlayerAlive(client))
	{
		// primary weapon
		int weaponIndex = getIndexOfWeaponSlot(client, 0);
		if (weaponIndex != INVALID_WEAPON)
		{
			int ammo = getAmmo(client, 0);
			int clip = getClip(client, 0);
			switch (getIndexOfWeaponSlot(client, 0))
			{
				case 13:
				{
					TF2_RemoveWeaponSlot(client, 0);
					spawnWeapon(client, "tf_weapon_scattergun", 200, 69, 6, ATTRIBUTES, "nano_australium");
					setAmmo(client, ammo, 0);
					setClip(client, clip, 0);
				}
				case 45:
				{
					TF2_RemoveWeaponSlot(client, 0);
					spawnWeapon(client, "tf_weapon_scattergun", 45, 69, 6, ATTRIBUTES, "nano_australium");
					setAmmo(client, ammo, 0);
					setClip(client, clip, 0);
				}
				case 18:
				{
					TF2_RemoveWeaponSlot(client, 0);
					spawnWeapon(client, "tf_weapon_rocketlauncher", 205, 69, 6, ATTRIBUTES, "nano_australium");
					setAmmo(client, ammo, 0);
					setClip(client, clip, 0);
				}
				case 228:
				{
					TF2_RemoveWeaponSlot(client, 0);
					spawnWeapon(client, "tf_weapon_rocketlauncher", 228, 69, 6, ATTRIBUTES, "nano_australium");
					setAmmo(client, ammo, 0);
					setClip(client, clip, 0);
				}
				case 21:
				{
					TF2_RemoveWeaponSlot(client, 0);
					spawnWeapon(client, "tf_weapon_flamethrower", 208, 69, 6, ATTRIBUTES, "nano_australium");
					setAmmo(client, ammo, 0);
					setClip(client, clip, 0);
				}
				case 19:
				{
					TF2_RemoveWeaponSlot(client, 0);
					spawnWeapon(client, "tf_weapon_grenadelauncher", 206, 69, 6, ATTRIBUTES, "nano_australium");
					setAmmo(client, ammo, 0);
					setClip(client, clip, 0);
				}
				case 15:
				{
					TF2_RemoveWeaponSlot(client, 0);
					spawnWeapon(client, "tf_weapon_minigun", 202, 69, 6, ATTRIBUTES, "nano_australium");
					setAmmo(client, ammo, 0);
					setClip(client, clip, 0);
				}
				case 424:
				{
					TF2_RemoveWeaponSlot(client, 0);
					spawnWeapon(client, "tf_weapon_minigun", 424, 69, 6, ATTRIBUTES, "nano_australium");
					setAmmo(client, ammo, 0);
					setClip(client, clip, 0);
				}
				case 141:
				{
					TF2_RemoveWeaponSlot(client, 0);
					spawnWeapon(client, "tf_weapon_sentry_revenge", 141, 69, 6, ATTRIBUTES, "nano_australium");
					setAmmo(client, ammo, 0);
					setClip(client, clip, 0);
				}
				case 36:
				{
					TF2_RemoveWeaponSlot(client, 0);
					spawnWeapon(client, "tf_weapon_syringegun_medic", 36, 69, 6, ATTRIBUTES, "nano_australium");
					setAmmo(client, ammo, 0);
					setClip(client, clip, 0);
				}
				case 14:
				{
					TF2_RemoveWeaponSlot(client, 0);
					spawnWeapon(client, "tf_weapon_sniperrifle", 201, 69, 6, ATTRIBUTES, "nano_australium");
					setAmmo(client, ammo, 0);
					setClip(client, clip, 0);
				}
				case 61:
				{
					TF2_RemoveWeaponSlot(client, 0);
					spawnWeapon(client, "tf_weapon_revolver", 61, 69, 6, ATTRIBUTES, "nano_australium");
					setAmmo(client, ammo, 0);
					setClip(client, clip, 0);
				}
			}
		}
		
		// secondary weapon
		weaponIndex = getIndexOfWeaponSlot(client, 1);
		if (weaponIndex != INVALID_WEAPON)
		{
			int ammo = getAmmo(client, 1);
			int clip = getClip(client, 1);
			switch (getIndexOfWeaponSlot(client, 1))
			{
				case 16:
				{
					TF2_RemoveWeaponSlot(client, 1);
					spawnWeapon(client, "tf_weapon_smg", 203, 69, 6, ATTRIBUTES, "nano_australium");
					setAmmo(client, ammo, 1);
					setClip(client, clip, 1);
				}
				case 29:
				{
					TF2_RemoveWeaponSlot(client, 1);
					spawnWeapon(client, "tf_weapon_medigun", 211, 69, 6, ATTRIBUTES, "nano_australium");
				}
				case 20:
				{
					TF2_RemoveWeaponSlot(client, 1);
					spawnWeapon(client, "tf_weapon_pipebomblauncher", 207, 69, 6, ATTRIBUTES, "nano_australium");
					setAmmo(client, ammo, 1);
					setClip(client, clip, 1);
				}
			}
		}
		
		// melee
		switch (getIndexOfWeaponSlot(client, 2))
		{
			case 38:
			{
				TF2_RemoveWeaponSlot(client, 2);
				spawnWeapon(client, "tf_weapon_fireaxe", 38, 69, 6, ATTRIBUTES, "nano_australium");
			}
			case 4:
			{
				TF2_RemoveWeaponSlot(client, 2);
				spawnWeapon(client, "tf_weapon_knife", 194, 69, 6, ATTRIBUTES, "nano_australium");
			}
			case 7:
			{
				TF2_RemoveWeaponSlot(client, 2);
				spawnWeapon(client, "tf_weapon_wrench", 197, 69, 6, ATTRIBUTES, "nano_australium");
			}
			case 132:
			{
				TF2_RemoveWeaponSlot(client, 2);
				spawnWeapon(client, "tf_weapon_sword", 132, 69, 6, ATTRIBUTES, "nano_australium");
			}
			case 0:
			{
				TF2_RemoveWeaponSlot(client, 2);
				spawnWeapon(client, "tf_weapon_bat", 1071, 69, 6, "150 ; 1 ; 542 ; 0", "nano_australium");
			}
			case 6:
			{
				TF2_RemoveWeaponSlot(client, 2);
				spawnWeapon(client, "tf_weapon_shovel", 1071, 69, 6, "150 ; 1 ; 542 ; 0", "nano_australium");
			}
			case 2:
			{
				TF2_RemoveWeaponSlot(client, 2);
				spawnWeapon(client, "tf_weapon_fireaxe", 1071, 69, 6, "150 ; 1 ; 542 ; 0", "nano_australium");
			}
			case 1:
			{
				TF2_RemoveWeaponSlot(client, 2);
				spawnWeapon(client, "tf_weapon_bottle", 1071, 69, 6, "150 ; 1 ; 542 ; 0", "nano_australium");
			}
			case 5:
			{
				TF2_RemoveWeaponSlot(client, 2);
				spawnWeapon(client, "tf_weapon_fists", 1071, 69, 6, "150 ; 1 ; 542 ; 0", "nano_australium");
			}
			case 8:
			{
				TF2_RemoveWeaponSlot(client, 2);
				spawnWeapon(client, "tf_weapon_bonesaw", 1071, 69, 6, "150 ; 1 ; 542 ; 0", "nano_australium");
			}
			case 3:
			{
				TF2_RemoveWeaponSlot(client, 2);
				spawnWeapon(client, "tf_weapon_club", 1071, 69, 6, "150 ; 1 ; 542 ; 0", "nano_australium");
			}
		}
	}
}

int getClip(int client, int slot)
{
	int weapon = GetPlayerWeaponSlot(client, slot);
	int iAmmoTable = FindSendPropInfo("CTFWeaponBase", "m_iClip1");
	return GetEntData(weapon, iAmmoTable);
}

int getAmmo(int client, int slot)
{
	int weapon = GetPlayerWeaponSlot(client, slot);
	int iOffset = GetEntProp(weapon, Prop_Send, "m_iPrimaryAmmoType", 1) * 4;
	int iAmmoTable = FindSendPropInfo("CTFPlayer", "m_iAmmo");
	return GetEntData(client, iOffset + iAmmoTable);
}

void setClip(int client, int ammo, int slot)
{
	int weapon = GetPlayerWeaponSlot(client, slot);
	int iAmmoTable = FindSendPropInfo("CTFWeaponBase", "m_iClip1");
	SetEntData(weapon, iAmmoTable, ammo, 4, true);
}

void setAmmo(int client, int ammo, int slot)
{
	int weapon = GetPlayerWeaponSlot(client, slot);
	int iOffset = GetEntProp(weapon, Prop_Send, "m_iPrimaryAmmoType", 1) * 4;
	int iAmmoTable = FindSendPropInfo("CTFPlayer", "m_iAmmo");
	SetEntData(client, iAmmoTable + iOffset, ammo, 4, true);
}

void spawnWeapon(int client, char[] name, int index, int level, int quality, char[] att, char[] targetname, bool preserve = true)
{
	int flags = OVERRIDE_ALL | FORCE_GENERATION;
	if (preserve)
	{
		flags |= PRESERVE_ATTRIBUTES;
	}
	Handle hWeapon = TF2Items_CreateItem(flags);
	if (hWeapon == INVALID_HANDLE)
	{
		return;
	}
	
	TF2Items_SetClassname(hWeapon, name);
	TF2Items_SetItemIndex(hWeapon, index);
	TF2Items_SetLevel(hWeapon, level);
	TF2Items_SetQuality(hWeapon, quality);
	char atts[32][32];
	int count = ExplodeString(att, ";", atts, 32, 32);
	
	if (count % 2)
	{
		--count;
	}
	
	if (count > 0)
	{
		TF2Items_SetNumAttributes(hWeapon, count / 2);
		int i2;
		for (new i; i < count; i += 2)
		{
			int attrib = StringToInt(atts[i]);
			if (!attrib)
			{
				LogError("Bad weapon attribute passed: %s ; %s", atts[i], atts[i + 1]);
				CloseHandle(hWeapon);
				return;
			}
			
			TF2Items_SetAttribute(hWeapon, i2, attrib, StringToFloat(atts[i + 1]));
			i2++;
		}
	}
	else
	{
		TF2Items_SetNumAttributes(hWeapon, 0);
	}
	
	int entity = TF2Items_GiveNamedItem(client, hWeapon);
	DispatchKeyValue(entity, "targetname", targetname);
	CloseHandle(hWeapon);
	EquipPlayerWeapon(client, entity);
}

int getIndexOfWeaponSlot(int client, int slot)
{
	return getWeaponIndex(GetPlayerWeaponSlot(client, slot));
}

int getWeaponIndex(int weapon)
{
	return isValidEnt(weapon) ? GetEntProp(weapon, Prop_Send, "m_iItemDefinitionIndex") : INVALID_WEAPON;
}

bool isValidEnt(int ent)
{
	return ent > MaxClients && IsValidEntity(ent);
}

/* */