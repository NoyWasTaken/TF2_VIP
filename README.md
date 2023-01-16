# TF2 - VIP System
An advanced VIP management system made for Play-IL's TF2 community.

# Dependencies
###### [TF2Items](https://forums.alliedmods.net/showthread.php?p=1050170) ######
###### [TF2Attributes](https://forums.alliedmods.net/showthread.php?t=210221) ######
###### [TF2Items Give Weapon](https://forums.alliedmods.net/showthread.php?p=1337899) ######
###### [ItemsGame Manager](https://forums.alliedmods.net/showthread.php?p=1446438) ######

# Installation
- Install all dependencies.
- Download the [sound files](https://mega.nz/file/SrYmGTgB#cJlemrAtriYUEQqa4UNn3Y6wBzBgAbD0q9ZpSldPv0U) and extract to your fastdl.
- Download the smx files and extract to your plugins folder.
- Add an entry in your databases.cfg and call it "playil_vip"
```
 "playil_vip"
  {
      "driver"            "<DRIVER>" // recommended mysql
      "host"                "<HOSTNAME>"
      "database"            "<DATABASE>"
      "user"                "<USERNAME>"
      "pass"                "<PASSWORD>"
      "port"            "<PORT>"
  }
```
# Features
- Managements of VIP players by duration.
- Already made perks for your own usage.
- Fully dynamically for updates and changes using natives and forwards. 

# Made Perks (sp included)
- Reserved slots (Built in core).
- Australium weapons (Requires VIP_Australium.smx).
- Burp sound using command (Requires VIP_Burp.smx).
- Body color selection (Requires VIP_BodyColor.smx).
- Weapon color selection (Requires VIP_WeaponColor.smx).
- Unusual effects for hats (Requires VIP_Unusual.smx).
- Fart sound using command (Requires VIP_Fart.smx).
- Golden kills (Requires VIP_Golden.smx).
- Saxxy weapon (Requires VIP_Saxxy.smx).
- Footprints/trails selection (Requires VIP_Trails.smx).
- Unusual effects for taunts (Requires VIP_UnusualTaunts.smx).
- Weapon size selection (Requires VIP_WeaponSize.smx).
- Flags giving (Requires VIP_Flags.smx).
- Connect and disconnect messages in chat and screen (Requires VIP_Messages.smx).
- Killstreak effects, sheens and types selection (Requires VIP_KillStreak.smx).

# Cvars
- sm_vip_flags - (Default: t - CUSTOM6) Flags to give to the vip users (Requires VIP_Flags.smx).

# Commands
- sm_vip - (Default Access: Root) Opens the VIP management menu.
- sm_addvip (Default Access: Root) Allows adding of a VIP using SteamID (offline adding).
- sm_vipmenu (Default Access: Everyone) Opens the VIP menu.
- sm_australium - (Default Access: Everyone) Toggles australium weapons (Requires VIP_Australium.smx).
- sm_burp - (Default Access: Everyone) Make a burp sound (Requires VIP_Burp.smx).
- sm_color - (Default Access: Everyone) Select a body color (Requires VIP_BodyColor.smx).
- sm_cw - (Default Access: Everyone) Select a weapon color (Requires VIP_WeaponColor.smx).
- sm_wcolor - (Default Access: Everyone) Select a weapon color (Requires VIP_WeaponColor.smx)
- sm_effect - (Default Access: Everyone) Select an unusual effect for your hat (Requires VIP_Unusual.smx).
- sm_fart - (Default Access: Everyone) Make a fart sound (Requires VIP_Fart.smx).
- sm_golden - (Default Access: Everyone) Toggles golden kills (Requires VIP_Golden.smx).
- sm_saxxy - (Default Access: Everyone) Toggles saxxy weapon (Requires VIP_Saxxy.smx).
- sm_trails - (Default Access: Everyone) Select a trail (Requires VIP_Trails.smx).
- sm_footprints - (Default Access: Everyone) Select a trail (Requires VIP_Trails.smx).
- sm_utaunt - (Default Access: Everyone) Select an unusual effect for your taunts (Requires VIP_UnusualTaunts.smx).
- sm_rw - (Default Access: Everyone) Change size of weapons (Requires VIP_WeaponResize.smx).
- sm_ks (Default Access: Everyone) Select killstreak type, effect and sheen (Requires VIP_KillStreak.smx).

# Natives & Forwards
- Check VIP_Core.inc for information.

# Credits
- Da Vinci - Original plugin idea and design, code in VIP_Unusual
- Nanochip - Australium weapons functions from his [plugin](https://forums.alliedmods.net/showthread.php?p=2445005)
