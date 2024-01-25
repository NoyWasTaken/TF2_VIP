/*
**
*/
#if defined _VIP_CORE_included
#endinput
#endif
#define _VIP_CORE_included

#define DATABASE_ENTRY "playil_vip"

#define PREFIX "{lime}[Level9]{default}"
#define PREFIX_ACTIVITY "{lime}[Level9]{default} "
#define PREFIX_MENU "[Level9]"

/**
* Check if player is a vip.
*
* @param client				client to check.
* @return whether the player is a vip or not. 
*/
native bool VIP_IsPlayerVIP(int client);

/**
* Called when a vip player is openning the vip menu.
*
* @param client the vip players
* @param menu the menu
*/
forward void VIP_OnMenuOpenned(int client, Menu menu);

/*
* Called when a vip player has been loaded.
*
* @param client				the vip player.
* @noreturn
*/
forward void VIP_OnPlayerLoaded(int client);

/* 
* Called when a vip has been given to a player.
*
* @param client				the player who receieved the vip.
* @param item				the time of the new vip given (in days).
* @noreturn
*/
forward void VIP_OnPlayerGiven(int client, int duration);

#if !defined REQUIRE_PLUGIN
public __pl_VIP_CORE_SetNTVOptional()
{
	MarkNativeAsOptional("VIP_IsPlayerVIP");
}
#endif

public SharedPlugin __pl_VIP = 
{
	name = "[TF2] VIP - Core", 
	file = "VIP_Core.smx", 
	#if defined REQUIRE_PLUGIN
	required = 1, 
	#else
	required = 0, 
	#endif
}; 