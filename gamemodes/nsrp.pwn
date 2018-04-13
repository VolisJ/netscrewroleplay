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
new accountstimer;

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
	pIsDead
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
forward RegisterLog(registerstring[]);

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

	accountstimer = SetTimerEx("SaveAccount", 10000, 1, "i", playerid);
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

public OnGameModeExit()
{
	KillTimer(accountstimer);
	return 1;
}

public OnPlayerDisconnect(playerid, reason)
{
	SaveAccount(playerid);
	return 1;
}

public OnPlayerSpawn(playerid)
{
	ResetPlayerMoney(playerid);
	GivePlayerMoney(playerid, Player[playerid][pCash]);
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
	}

	fclose(handle);

	SafeSetPlayerMoney(playerid, Player[playerid][pCash]);

	SetSpawnInfo(playerid, 0, Player[playerid][pSkin], Spawn_X, Spawn_Y, Spawn_Z, 180, -1, -1, -1, -1, -1, -1);
	SpawnPlayer(playerid);

	SendClientMessage(playerid, COLOR_GREEN, "You have successfully logged in.");

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
public RegisterLog(registerstring[])
{
	new entry[256];
	format(entry, sizeof(entry), "%s\r\n", registerstring);

	new File:hFile;
	hFile = fopen("logs/register.log", io_append);
	fwrite(hFile, entry);

	fclose(hFile);
}
