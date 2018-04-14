/*
						||\     ||  ||||||||  ||||||||||   |||||||||
						||\\    ||  ||        ||       ||  ||      ||
						|| \\   ||  ||        ||       ||  ||      ||
						||  \\  ||  ||||||||  |||||||||    |||||||||
						||   \\ ||        ||  ||       ||  ||
						||    \\||        ||  ||       ||  ||
						||     \||  ||||||||  ||       ||  ||

								  CREATED BY JASKARAN SINGH

							  Copyright (C) 2018, Netscrew Gaming

									All rights reserved.

	Redistribution and use in any form, with or without modification, are not permitted in any case.
*/

/*----INCLUDES----*/
#include <a_samp>
#include <YSI\Y_ini>
#include <sscanf2>
#include "colors.pwn"
#include <zcmd>

/*----DEFINES----*/
#define GameMode "NSRP v1.0"

#define ACCOUNT_PATH "accounts/"

#define COL_WHITE "{FFFFFF}"
#define COL_RED "{AA3333}"

#define Spawn_X 1685.6904 // default spawn coordinates (LS International)
#define Spawn_Y -2240.9397
#define Spawn_Z 13.5469

/*----GLOBAL VARIABLE DECLARATIONS----*/
new pAccountStatus[MAX_PLAYERS];
new accountstimer[MAX_PLAYERS];
new mutetimer[MAX_PLAYERS];

/*----ENUMS----*/
enum PlayerData
{
	pEmail[128],
	pPassword[129],
	pSex,
	pSkin,
	pCash,
	pAdminLevel,
	pVipLevel,
	pHelperLevel,
	pIsBanned,
	pIsMuted,
	pMuteTime
}
new Player[MAX_PLAYERS][PlayerData];

enum dialogs
{
	DIALOG_LOGIN,
	DIALOG_REGISTER_1,
	DIALOG_REGISTER_2,
	DIALOG_REGISTER_3
}

native WP_Hash(buffer[], len, const str[]);

/*----FORWARDS----*/
forward LoadAccounts(playerid);
forward CheckAccountExist(playerid);
forward OnAccountRegister(playerid);
forward SaveAccount(playerid);
forward OnAccountLoad(playerid);
forward SafeGivePlayerMoney(playerid, money);
forward SafeSetPlayerMoney(playerid, money);
forward SafeResetPlayerMoney(playerid);
forward SafeGetPlayerMoney(playerid);
forward DecMuteTime(playerid);
forward RegisterLog(registerstring[]);
forward AdminLog(playerid, adminstring[]);
forward MuteLog(playerid, mutestring[]);
forward AdminCommandLog(playerid, acmdlogstring[]);

main() {}

/*----Built - In Functions----*/
public OnGameModeInit()
{
	SetGameModeText(GameMode);
	ShowPlayerMarkers(0);
	DisableInteriorEnterExits();
	EnableStuntBonusForAll(0);
	UsePlayerPedAnims();
	ManualVehicleEngineAndLights();

	return 1;
}

public OnPlayerConnect(playerid)
{
	CheckAccountExist(playerid);
	SafeResetPlayerMoney(playerid);

	accountstimer[playerid] = SetTimerEx("SaveAccount", 60000, 1, "i", playerid);
	
	return 1;
}

public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
	switch(dialogid)
	{
		case DIALOG_REGISTER_1:
		{
			if(response)
			{
				strmid(Player[playerid][pEmail], inputtext, 0, strlen(inputtext), 128);
				ShowPlayerDialog(playerid, DIALOG_REGISTER_2, DIALOG_STYLE_PASSWORD, "Account Registration", "Please enter a desired password below.", "Next", "Back");
			}
			else
				return Kick(playerid);
		}

		case DIALOG_REGISTER_2:
		{
			if(response)
			{
				if(strlen(inputtext) < 5)
				{ 
					ShowPlayerDialog(playerid, DIALOG_REGISTER_2, DIALOG_STYLE_PASSWORD, ""COL_WHITE"Account Registration", ""COL_WHITE"Your password must contain at least 5 characters.\n"COL_WHITE"Please enter a desired password below to register your account.", "Next", "Back");
				}

				WP_Hash(Player[playerid][pPassword], 129, inputtext);

				ShowPlayerDialog(playerid, DIALOG_REGISTER_3, DIALOG_STYLE_MSGBOX, ""COL_WHITE"Account Registration", ""COL_WHITE"Please choose your sex.", "Male", "Female");
			}
			else
			{
				ShowPlayerDialog(playerid, DIALOG_REGISTER_1, DIALOG_STYLE_INPUT, ""COL_WHITE"Account Registration", ""COL_WHITE"Please enter your email below to register your account.", "Next", "Cancel");
			}
		}

		case DIALOG_REGISTER_3:
		{
			if(response)
			{
				Player[playerid][pSex] = 0; // Male
				Player[playerid][pSkin] = 250;
				OnAccountRegister(playerid);
			}
			else
			{
				Player[playerid][pSex] = 1;	// Female
				Player[playerid][pSkin] = 56;
				OnAccountRegister(playerid);
			}
		}

		case DIALOG_LOGIN:
		{
			if(response)
			{
				new hashpass[129], name[MAX_PLAYER_NAME];
				name = GetName(playerid);

				WP_Hash(hashpass, sizeof(hashpass), inputtext);

				if(strcmp(hashpass, Player[playerid][pPassword]) == 0)
				{
					OnAccountLoad(playerid);
				}
				else
					ShowPlayerDialog(playerid, DIALOG_LOGIN, DIALOG_STYLE_PASSWORD, ""COL_WHITE"Login", ""COL_RED"You have entered an incorrect password.\n"COL_WHITE"Type your password below to login.", "Login", "Quit");
			}
			else
				return Kick(playerid);
		}
	}
	return 1;
}

public OnPlayerRequestClass(playerid, classid)
{
	SetSpawnInfo(playerid, 0, Player[playerid][pSkin], Spawn_X, Spawn_Y, Spawn_Z, 180, -1, -1, -1, -1, -1, -1);
	SpawnPlayer(playerid);
	return 1;
}

public OnPlayerDisconnect(playerid, reason)
{
	KillTimer(accountstimer[playerid]);
	KillTimer(mutetimer[playerid]);
	SaveAccount(playerid);
	return 1;
}

public OnPlayerSpawn(playerid)
{
	ResetPlayerMoney(playerid);
	GivePlayerMoney(playerid, Player[playerid][pCash]);
}

public OnPlayerText(playerid, text[])
{
	new string[512];

	if(Player[playerid][pIsMuted] == 1)
	{
		SendClientMessage(playerid, COLOR_LIGHTNEUTRALBLUE, "You cannot say anything because you are muted by the admins!");
		return 0;
	}

	format(string, sizeof(string), "%s says: %s", GetName(playerid), text);
	SendClientMessage(playerid, COLOR_WHITE, string);
	return 0;
}

/*----USER DEFINED FUNCTIONS----*/
stock GetName(playerid) // Returns the name of a player according to the player id
{
	new name[MAX_PLAYER_NAME];

	GetPlayerName(playerid, name, sizeof(name));
	return name; 
}

public CheckAccountExist(playerid) // Checks if a player is already registered or not and shows the login/register dialog accordingly
{
	new name[128], string[MAX_PLAYER_NAME];

	name = GetName(playerid);
	format(string, sizeof(string), "accounts/%s.ini", name);

	if(fexist(string))
	{
		pAccountStatus[playerid] = 1;

		if(Player[playerid][pIsBanned] == 0)
		{
			new filename[64], line[256], s, key[64];
			new File:handle;
			
			format(filename, sizeof(filename), ACCOUNT_PATH "%s.ini", name);

			handle = fopen(filename, io_read);
			while(fread(handle, line))
			{
				StripNL(line);
				s = strfind(line, "=");

				if(!line[0] || s < 1)
					continue;

				strmid(key, line, 0, s++);
				if(strcmp(key, "Password") == 0)
					sscanf(line[s], "s[129]", Player[playerid][pPassword]);
			}
			fclose(handle);

			ShowPlayerDialog(playerid, DIALOG_LOGIN, DIALOG_STYLE_PASSWORD, ""COL_WHITE"Account Login", ""COL_WHITE"Please enter your password below to login.", "Login", "Quit");
		}
		else
		{
			SendClientMessage(playerid, COLOR_LIGHTRED, "You are banned from this server");
		}
	}
	else
	{
		pAccountStatus[playerid] = 0;
		ShowPlayerDialog(playerid, DIALOG_REGISTER_1, DIALOG_STYLE_INPUT, ""COL_WHITE"Account Registration", ""COL_WHITE"Please enter your email below to register your account.", "Next", "Cancel");
	}

	return 1;
}

public OnAccountRegister(playerid) // Assigns the information to the player variables on register
{
	new registerstring[256];

	SafeGivePlayerMoney(playerid, 300);
	Player[playerid][pCash] = 300;
	Player[playerid][pAdminLevel] = 0;
	Player[playerid][pVipLevel] = 0;
	Player[playerid][pHelperLevel] = 0;
	Player[playerid][pIsBanned] = 0;
	Player[playerid][pIsMuted] = 0;
	Player[playerid][pMuteTime] = 0;
	pAccountStatus[playerid] = 1;

	new hour, minute, second;
	new year, month, day;

	gettime(hour, minute, second);
	getdate(year, month, day);

	format(registerstring, sizeof(registerstring), "%s has registered. [%d/%d/%d] [%d:%d:%d]", GetName(playerid), day, month, year, hour, minute, second);
	RegisterLog(registerstring);

	SetSpawnInfo(playerid, 0, Player[playerid][pSkin], Spawn_X, Spawn_Y, Spawn_Z, 180, -1, -1, -1, -1, -1, -1);
	SpawnPlayer(playerid);

	SaveAccount(playerid);
	SendClientMessage(playerid, COLOR_GREEN, "You have successfully registered!");
	return 1;
}

public SaveAccount(playerid) // Saves the information to the .ini file
{
	new filename[64], line[256];

	format(filename, sizeof(filename), ACCOUNT_PATH "%s.ini", GetName(playerid));

	new File:handle = fopen(filename, io_write);

	format(line, sizeof(line), "Email=%s\r\n", Player[playerid][pEmail]);
	fwrite(handle, line);

	format(line, sizeof(line), "Password=%s\r\n", Player[playerid][pPassword]);
	fwrite(handle, line);

	format(line, sizeof(line), "Sex=%d\r\n", Player[playerid][pSex]);
	fwrite(handle, line);

	format(line, sizeof(line), "Skin=%d\r\n", Player[playerid][pSkin]);
	fwrite(handle, line);

	format(line, sizeof(line), "Cash=%d\r\n", Player[playerid][pCash]);
	fwrite(handle, line);

	format(line, sizeof(line), "AdminLevel=%d\r\n", Player[playerid][pAdminLevel]);
	fwrite(handle, line);

	format(line, sizeof(line), "VipLevel=%d\r\n", Player[playerid][pVipLevel]);
	fwrite(handle, line);

	format(line, sizeof(line), "HelperLevel=%d\r\n", Player[playerid][pHelperLevel]);
	fwrite(handle, line);
	
	format(line, sizeof(line), "IsBanned=%d\r\n", Player[playerid][pIsBanned]);
	fwrite(handle, line);

	format(line, sizeof(line), "IsMuted=%d\r\n", Player[playerid][pIsMuted]);
	fwrite(handle, line);

	format(line, sizeof(line), "MuteTime=%d\r\n", Player[playerid][pMuteTime]);
	fwrite(handle, line);

	fclose(handle);
	return 1;
}

public OnAccountLoad(playerid) // Loads player data from the .ini file to the player variables 
{
	new filename[64], line[256], s, key[64];
	new File:handle;

	new name[MAX_PLAYER_NAME];
	name = GetName(playerid);
	
	format(filename, sizeof(filename), ACCOUNT_PATH "%s.ini", name);

	handle = fopen(filename, io_read);
	while(fread(handle, line))
	{
		StripNL(line);
		s = strfind(line, "=");

		if(!line[0] || s < 1)
			continue;

		strmid(key, line, 0, s++);
		if(strcmp(key, "Email") == 0)
			sscanf(line[s], "s[128]", Player[playerid][pEmail]);
		else if(strcmp(key, "Password") == 0)
			sscanf(line[s], "s[129]", Player[playerid][pPassword]);
		else if(strcmp(key, "Sex") == 0)
			Player[playerid][pSex] = strval(line[s]);
		else if(strcmp(key, "Skin") == 0)
			Player[playerid][pSkin] = strval(line[s]);
		else if(strcmp(key, "Cash") == 0)
			Player[playerid][pCash] = strval(line[s]);
		else if(strcmp(key, "AdminLevel") == 0)
			Player[playerid][pAdminLevel] = strval(line[s]);
		else if(strcmp(key, "VipLevel") == 0)
			Player[playerid][pVipLevel] = strval(line[s]);
		else if(strcmp(key, "HelperLevel") == 0)
			Player[playerid][pHelperLevel] = strval(line[s]);
		else if(strcmp(key, "IsBanned") == 0)
			Player[playerid][pIsBanned] = strval(line[s]);
		else if(strcmp(key, "IsMuted") == 0)
			Player[playerid][pIsMuted] = strval(line[s]);
		else if(strcmp(key, "MuteTime") == 0)
			Player[playerid][pMuteTime] = strval(line[s]);
	}

	fclose(handle);

	SafeSetPlayerMoney(playerid, Player[playerid][pCash]);

	SetSpawnInfo(playerid, 0, Player[playerid][pSkin], Spawn_X, Spawn_Y, Spawn_Z, 180, -1, -1, -1, -1, -1, -1);
	SpawnPlayer(playerid);

	SendClientMessage(playerid, COLOR_GREEN, "You have successfully logged in.");

	if(Player[playerid][pIsMuted] == 1)
		mutetimer[playerid] = SetTimerEx("DecMuteTime", 1000, 1, "i", playerid);

	return 1;
}

public DecMuteTime(playerid) // Decreases mute time of player by 1 second
{
	new day, month, year, hour, minute, second, mutestring[128];
	Player[playerid][pMuteTime]--;

	printf("%d", Player[playerid][pMuteTime]);

	if(Player[playerid][pMuteTime] == 0)
	{
		Player[playerid][pIsMuted] = 0;
		KillTimer(mutetimer[playerid]);
		SaveAccount(playerid);

		SendClientMessage(playerid, COLOR_LIGHTBLUEGREEN, "Your mute time has ended.");

		gettime(hour, minute, second);
		getdate(year, month, day);

		format(mutestring, sizeof(mutestring), "Unuted | Automatic [%d/%d/%d] [%d:%d:%d]", day, month, year, hour, minute, second);
		MuteLog(playerid, mutestring);
	}

	return 1;
}

/*----Safe Money Functions (Anti - Money Cheat)----*/
public SafeGivePlayerMoney(playerid, money) // Returns the server - side cash of the player
{
	Player[playerid][pCash] += money;
	ResetPlayerMoney(playerid);
	GivePlayerMoney(playerid, Player[playerid][pCash]);
	return 1;
}

public SafeSetPlayerMoney(playerid, money) // Sets the cash of the player to a particular account
{
	Player[playerid][pCash] = money;
	ResetPlayerMoney(playerid);
	GivePlayerMoney(playerid, Player[playerid][pCash]);
	return 1;
}

public SafeResetPlayerMoney(playerid) // Resets the cash of the player
{
	Player[playerid][pCash] = 0;
	ResetPlayerMoney(playerid);
	GivePlayerMoney(playerid, Player[playerid][pCash]);
	return 1;
}

public SafeGetPlayerMoney(playerid) // Returns the server - side cash of the player
{
	return Player[playerid][pCash];
}

/*----Log Functions----*/
public RegisterLog(registerstring[]) // Makes log of player registrations
{
	new entry[256];
	format(entry, sizeof(entry), "%s\r\n", registerstring);

	new File:hFile;
	hFile = fopen("logs/registrations.log", io_append);
	fwrite(hFile, entry);

	fclose(hFile);
}

public AdminLog(playerid, adminstring[]) // Makes log of admin creates, removes, promotions and demotions
{
	new entry[256], string[128];
	format(entry, sizeof(entry), "%s\r\n", adminstring);

	new File:hFile;
	format(string, sizeof(string), "logs/admins/%s.log", GetName(playerid));
	hFile = fopen(string, io_append);
	fwrite(hFile, entry);

	fclose(hFile);
}

public MuteLog(playerid, mutestring[]) // Makes log of player's mutes and unmutes
{
	new entry[256], string[128];
	format(entry, sizeof(entry), "%s\r\n", mutestring);

	new File:hFile;
	format(string, sizeof(string), "logs/mutes/%s.log", GetName(playerid));
	hFile = fopen(string, io_append);
	fwrite(hFile, entry);

	fclose(hFile);
}

public AdminCommandLog(playerid, acmdlogstring[]) // Makes log of admin's every command
{
	new entry[256], string[128];
	format(entry, sizeof(entry), "%s\r\n", acmdlogstring);

	new File:hFile;
	format(string, sizeof(string), "logs/admincommands/%s.log", GetName(playerid));
	hFile = fopen(string, io_append);
	fwrite(hFile, entry);

	fclose(hFile);
}

/*----Admin Commands----*/
CMD:ma(playerid, params[])
	return cmd_makeadmin(playerid, params);

CMD:makeadmin(playerid, params[]) // Makes a player admin (Can only be used by admin level 6)
{
	new targetid, level, string[128], adminstring[256], hour, minute, second, year, month, day, acmdlogstring[128];
	if(Player[playerid][pAdminLevel] == 6 || IsPlayerAdmin(playerid))
	{
		if(sscanf(params, "ui", targetid, level))
			return SendClientMessage(playerid, COLOR_LIGHTCYAN, "Syntax: /ma [playerid/PartOfName] [level]");

		if(IsPlayerConnected(targetid))
		{
			if(Player[targetid][pAdminLevel] != 0)
				return SendClientMessage(playerid, COLOR_NEUTRAL, "The player is already an admin.");

			if(level == 0)
				return SendClientMessage(playerid, COLOR_NEUTRAL, "Invalid level!");

			Player[targetid][pAdminLevel] = level;
			SaveAccount(targetid);

			gettime(hour, minute, second);
			getdate(year, month, day);

			format(acmdlogstring, sizeof(acmdlogstring), "Command: /makeadmin %s %d [%d/%d/%d] [%d:%d:%d]", GetName(targetid), level, day, month, year, hour, minute, second);
			AdminCommandLog(targetid, acmdlogstring);

			format(adminstring, sizeof(adminstring), "Made | Level: %d | By: %s [%d/%d/%d] [%d:%d:%d]", level, GetName(playerid), day, month, year, hour, minute, second);
			AdminLog(playerid, adminstring);

			format(string, sizeof(string), "You have made %s an admin level %d.", GetName(targetid), level);
			SendClientMessage(playerid, COLOR_LIGHTBLUE, string);

			format(string, sizeof(string), "Admin %s has made you an admin level %d.", GetName(playerid), level);
			SendClientMessage(targetid, COLOR_LIGHTBLUE, string);
		}
		else
			return SendClientMessage(playerid, COLOR_LIGHTNEUTRALBLUE, "The player is not connected!");
	}
	else
		return SendClientMessage(playerid, COLOR_LIGHTNEUTRALBLUE, "You are not authorized to use this command!");
	return 1;
}

CMD:ra(playerid, params[])
	return cmd_removeadmin(playerid, params);

CMD:removeadmin(playerid, params[]) // Removes an admin (Can only be used by admin level 6)
{
	new targetid, string[128], adminstring[256], hour, minute, second, year, month, day, acmdlogstring[128];
	if(Player[playerid][pAdminLevel] == 6 || IsPlayerAdmin(playerid))
	{
		if(sscanf(params, "u", targetid))
			return SendClientMessage(playerid, COLOR_LIGHTCYAN, "Syntax: /ra [playerid/PartOfName]");

		if(IsPlayerConnected(targetid))
		{
			if(Player[targetid][pAdminLevel] == 0)
				return SendClientMessage(playerid, COLOR_NEUTRAL, "The player is not an admin.");

			Player[targetid][pAdminLevel] = 0;
			SaveAccount(targetid);

			gettime(hour, minute, second);
			getdate(year, month, day);

			format(acmdlogstring, sizeof(acmdlogstring), "Command: /removeadmin %s [%d/%d/%d] [%d:%d:%d]", GetName(targetid), day, month, year, hour, minute, second);
			AdminCommandLog(targetid, acmdlogstring);

			format(adminstring, sizeof(adminstring), "%s: Removed | By: %s [%d/%d/%d] [%d:%d:%d]", GetName(targetid), GetName(playerid), day, month, year, hour, minute, second);
			AdminLog(playerid, adminstring);

			format(string, sizeof(string), "You have revoked %s's admin status.", GetName(targetid));
			SendClientMessage(playerid, COLOR_LIGHTBLUE, string);

			format(string, sizeof(string), "Admin %s has revoked your admin status.", GetName(playerid));
			SendClientMessage(targetid, COLOR_LIGHTBLUE, string);
		}
		else
			return SendClientMessage(playerid, COLOR_LIGHTNEUTRALBLUE, "The player is not connected!");
	}
	else
		return SendClientMessage(playerid, COLOR_LIGHTNEUTRALBLUE, "You are not authorized to use this command!");
	return 1;
}

CMD:asetlevel(playerid, params[]) // Promote or Demote an admin (Can only be used by admin level 6)
{
	new targetid, level, string[128], adminstring[256], hour, minute, second, year, month, day, acmdlogstring[128];
	if(Player[playerid][pAdminLevel] == 6 || IsPlayerAdmin(playerid))
	{
		if(sscanf(params, "ui", targetid, level))
			return SendClientMessage(playerid, COLOR_LIGHTCYAN, "Syntax: /asetlevel [playerid/PartOfName] [level]");

		if(IsPlayerConnected(targetid))
		{
			if(Player[targetid][pAdminLevel] == 0)
				return SendClientMessage(playerid, COLOR_NEUTRAL, "The player is not an admin.");

			if(level == 0)
				return SendClientMessage(playerid, COLOR_NEUTRAL, "Invalid level!");

			gettime(hour, minute, second);
			getdate(year, month, day);

			format(acmdlogstring, sizeof(acmdlogstring), "Command: /asetlevel %s %d [%d/%d/%d] [%d:%d:%d]", GetName(targetid), level, day, month, year, hour, minute, second);
			AdminCommandLog(targetid, acmdlogstring);

			if(Player[targetid][pAdminLevel] < level)
			{
				format(adminstring, sizeof(adminstring), "%s: Promoted | Level: %d | By: %s. [%d/%d/%d] [%d:%d:%d]", GetName(targetid), level, GetName(playerid), day, month, year, hour, minute, second);
				AdminLog(playerid, adminstring);

				format(string, sizeof(string), "You have promoted %s to admin level %d.", GetName(targetid), level);
				SendClientMessage(playerid, COLOR_LIGHTBLUE, string);

				format(string, sizeof(string), "Admin %s has promoted you to admin level %d.", GetName(playerid), level);
				SendClientMessage(targetid, COLOR_LIGHTBLUE, string);
			}
			else
			{
				format(adminstring, sizeof(adminstring), "%s: Demoted | Level: %d | By: %s [%d/%d/%d] [%d:%d:%d]", GetName(targetid), level, GetName(playerid), day, month, year, hour, minute, second);
				AdminLog(playerid, adminstring);

				format(string, sizeof(string), "You have demoted %s to admin level %d.", GetName(targetid), level);
				SendClientMessage(playerid, COLOR_LIGHTBLUE, string);

				format(string, sizeof(string), "Admin %s has demoted you to admin level %d.", GetName(playerid), level);
				SendClientMessage(targetid, COLOR_LIGHTBLUE, string);				
			}

			Player[targetid][pAdminLevel] = level;
			SaveAccount(targetid);
		}
		else
			return SendClientMessage(playerid, COLOR_LIGHTNEUTRALBLUE, "The player is not connected!");
	}
	else
		return SendClientMessage(playerid, COLOR_LIGHTNEUTRALBLUE, "You are not authorized to use this command!");
	return 1;
}

CMD:mute(playerid, params[]) // Mute a player
{
	new targetid, reason[128], time, string[128], mutestring[128], day, month, year, hour, minute, second, acmdlogstring[128];
	if(Player[playerid][pAdminLevel] >= 1 || IsPlayerAdmin(playerid))
	{
		if(sscanf(params, "us[128]i", targetid, reason, time))
				return SendClientMessage(playerid, COLOR_LIGHTCYAN, "Syntax: /mute [playerid/PartOfName] [reason] [time]");

		if(IsPlayerConnected(targetid))
		{
			if(Player[playerid][pIsMuted] == 1)
				return SendClientMessage(playerid, COLOR_NEUTRAL, "The player is already muted!");

			Player[targetid][pIsMuted] = 1;
			Player[targetid][pMuteTime] = time * 60;

			SaveAccount(targetid);

			gettime(hour, minute, second);
			getdate(year, month, day);

			format(acmdlogstring, sizeof(acmdlogstring), "Command: /mute %s %d [%d/%d/%d] [%d:%d:%d]", GetName(targetid), time, day, month, year, hour, minute, second);
			AdminCommandLog(targetid, acmdlogstring);

			format(mutestring, sizeof(mutestring), "Muted | Duration: %d | By: %s [%d/%d/%d] [%d:%d:%d]", time, GetName(playerid), day, month, year, hour, minute, second);
			MuteLog(targetid, mutestring);

			mutetimer[targetid] = SetTimerEx("DecMuteTime", 1000, 1, "i", playerid);

			format(string, sizeof(string), "You have muted %s for %d minutes. Reason: %s", GetName(targetid), time, reason);
			SendClientMessage(playerid, COLOR_LIGHTBLUE, string);

			format(string, sizeof(string), "You are muted by admin %s for %d minutes. Reason: %s", GetName(playerid), time, reason);
			SendClientMessage(playerid, COLOR_RED, string);

			format(string, sizeof(string), "%s is muted by admin %s for %d minutes. Reason: %s", GetName(targetid), GetName(playerid), time, reason);
			SendClientMessageToAll(COLOR_RED, string);
		}
		else
			return SendClientMessage(playerid, COLOR_LIGHTNEUTRALBLUE, "The player is not connected!");
	}
	else
		return SendClientMessage(playerid, COLOR_LIGHTNEUTRALBLUE, "You are not authorized to use this command!");
	return 1;
}

CMD:unmute(playerid, params[]) // Unmute a player
{
	new targetid, string[256], day, month, year, hour, minute, second, mutestring[128], acmdlogstring[128];

	if(Player[playerid][pAdminLevel] >= 1 || IsPlayerAdmin(playerid))
	{
		if(sscanf(params, "u", targetid))
				return SendClientMessage(playerid, COLOR_LIGHTCYAN, "Syntax: /unmute [playerid/PartOfName]");

		if(IsPlayerConnected(targetid))
		{
			if(Player[playerid][pIsMuted] == 0)
				return SendClientMessage(playerid, COLOR_NEUTRAL, "The player is not muted!");

			Player[targetid][pIsMuted] = 0;
			Player[targetid][pMuteTime] = 0;

			SaveAccount(targetid);

			gettime(hour, minute, second);
			getdate(year, month, day);

			format(acmdlogstring, sizeof(acmdlogstring), "Command: /unmute %s [%d/%d/%d] [%d:%d:%d]", GetName(targetid), day, month, year, hour, minute, second);
			AdminCommandLog(targetid, acmdlogstring);

			format(mutestring, sizeof(mutestring), "Unuted | By: %s [%d/%d/%d] [%d:%d:%d]", GetName(playerid), day, month, year, hour, minute, second);
			MuteLog(targetid, mutestring);

			KillTimer(mutetimer[targetid]);

			format(string, sizeof(string), "You have unmuted %s.", GetName(targetid));
			SendClientMessage(playerid, COLOR_LIGHTBLUE, string);

			format(string, sizeof(string), "You are unmuted by admin %s.", GetName(playerid));
			SendClientMessage(playerid, COLOR_RED, string);
		}
		else
			return SendClientMessage(playerid, COLOR_LIGHTNEUTRALBLUE, "The player is not connected!");
	}
	else
		return SendClientMessage(playerid, COLOR_LIGHTNEUTRALBLUE, "You are not authorized to use this command!");
	return 1;	
}

CMD:goto(playerid, params[]) // Teleports to a player
{
	new targetid, acmdlogstring[128], day, month, year, hour, minute, second, Float:x, Float:y, Float:z;

	if(Player[playerid][pAdminLevel] >= 3)
	{
		if(sscanf(params, "u", targetid))
			return SendClientMessage(playerid, COLOR_LIGHTCYAN, "Syntax: /goto [playerid/PartOfName]");

		if(IsPlayerConnected(targetid))
		{
			if(targetid == playerid)
				return SendClientMessage(playerid, COLOR_NEUTRAL, "You cannot use this command on yourself.");

			gettime(hour, minute, second);
			getdate(year, month, day);

			GetPlayerPos(targetid, x, y, z);
			SetPlayerPos(playerid, x + 1, y + 1, z);

			format(acmdlogstring, sizeof(acmdlogstring), "Command: /goto %s [%d/%d/%d] [%d:%d:%d]", GetName(targetid), day, month, year, hour, minute, second);
			AdminCommandLog(targetid, acmdlogstring);
		}
		else
			return SendClientMessage(playerid, COLOR_LIGHTNEUTRALBLUE, "The player is not connected!");
	}
	else
		return SendClientMessage(playerid, COLOR_LIGHTNEUTRALBLUE, "You are not authorized to use this command!");
	return 1;
}

CMD:gethere(playerid, params[])
{
	new targetid, acmdlogstring[128], day, month, year, hour, minute, second, Float:x, Float:y, Float:z;

	if(Player[playerid][pAdminLevel] >= 3)
	{
		if(sscanf(params, "u", targetid))
			return SendClientMessage(playerid, COLOR_LIGHTCYAN, "Syntax: /gethere [playerid/PartOfName]");

		if(IsPlayerConnected(targetid))
		{
			if(targetid == playerid)
				return SendClientMessage(playerid, COLOR_NEUTRAL, "You cannot use this command on yourself.");

			gettime(hour, minute, second);
			getdate(year, month, day);

			GetPlayerPos(playerid, x, y, z);
			SetPlayerPos(targetid, x + 1, y + 1, z);

			format(acmdlogstring, sizeof(acmdlogstring), "Command: /gethere %s [%d/%d/%d] [%d:%d:%d]", GetName(targetid), day, month, year, hour, minute, second);
			AdminCommandLog(targetid, acmdlogstring);
		}
		else
			return SendClientMessage(playerid, COLOR_LIGHTNEUTRALBLUE, "The player is not connected!");
	}
	else
		return SendClientMessage(playerid, COLOR_LIGHTNEUTRALBLUE, "You are not authorized to use this command!");
	return 1;
}
