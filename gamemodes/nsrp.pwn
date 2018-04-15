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

// -----------------------------------------Includes-----------------------------------------
#include <a_samp>
#include <YSI\Y_ini>
#include <sscanf2>
#include "colors.pwn"
#include <zcmd>

// ------------------------------------------Defines-----------------------------------------
#define GameMode "NSRP v1.0"

#define ACCOUNT_PATH "accounts/"

#define COL_WHITE "{FFFFFF}"
#define COL_RED "{AA3333}"

#define Spawn_X 1685.6904 // Default spawn coordinates (LS International)
#define Spawn_Y -2240.9397
#define Spawn_Z 13.5469

// ---------------------------------Global Variable Declarations------------------------------
new accountstimer[MAX_PLAYERS];
new mutetimer[MAX_PLAYERS];
new gobackstatus[MAX_PLAYERS];
new Float:savedposx[MAX_PLAYERS];
new Float:savedposy[MAX_PLAYERS];
new Float:savedposz[MAX_PLAYERS];

new VehicleNames[][] = {
	"Landstalker","Bravura","Buffalo","Linerunner","Perennial","Sentinel","Dumper","Firetruck","Trashmaster","Stretch","Manana","Infernus",
	"Voodoo","Pony","Mule","Cheetah","Ambulance","Leviathan","Moonbeam","Esperanto","Taxi","Washington","Bobcat","Mr Whoopee","BF Injection",
	"Hunter","Premier","Enforcer","Securicar","Banshee","Predator","Bus","Rhino","Barracks","Hotknife","Trailer","Previon","Coach","Cabbie",
	"Stallion","Rumpo","RC Bandit","Romero","Packer","Monster","Admiral","Squalo","Seasparrow","Pizzaboy","Tram","Trailer","Turismo","Speeder",
	"Reefer","Tropic","Flatbed","Yankee","Caddy","Solair","Berkley's RC Van","Skimmer","PCJ-600","Faggio","Freeway","RC Baron","RC Raider",
	"Glendale","Oceanic","Sanchez","Sparrow","Patriot","Quad","Coastguard","Dinghy","Hermes","Sabre","Rustler","ZR3 50","Walton","Regina",
	"Comet","BMX","Burrito","Camper","Marquis","Baggage","Dozer","Maverick","News Chopper","Rancher","FBI Rancher","Virgo","Greenwood",
	"Jetmax","Hotring","Sandking","Blista Compact","Police Maverick","Boxville","Benson","Mesa","RC Goblin","Hotring Racer A","Hotring Racer B",
	"Bloodring Banger","Rancher","Super GT","Elegant","Journey","Bike","Mountain Bike","Beagle","Cropdust","Stunt","Tanker","RoadTrain",
	"Nebula","Majestic","Buccaneer","Shamal","Hydra","FCR-900","NRG-500","HPV1000","Cement Truck","Tow Truck","Fortune","Cadrona","FBI Truck",
	"Willard","Forklift","Tractor","Combine","Feltzer","Remington","Slamvan","Blade","Freight","Streak","Vortex","Vincent","Bullet","Clover",
	"Sadler","Firetruck","Hustler","Intruder","Primo","Cargobob","Tampa","Sunrise","Merit","Utility","Nevada","Yosemite","Windsor","Monster A",
	"Monster B","Uranus","Jester","Sultan","Stratum","Elegy","Raindance","RC Tiger","Flash","Tahoma","Savanna","Bandito","Freight","Trailer",
	"Kart","Mower","Duneride","Sweeper","Broadway","Tornado","AT-400","DFT-30","Huntley","Stafford","BF-400","Newsvan","Tug","Trailer A","Emperor",
	"Wayfarer","Euros","Hotdog","Club","Trailer B","Trailer C","Andromada","Dodo","RC Cam","Launch","Police Car (LSPD)","Police Car (SFPD)",
	"Police Car (LVPD)","Police Ranger","Picador","S.W.A.T. Van","Alpha","Phoenix","Glendale","Sadler","Luggage Trailer A","Luggage Trailer B",
	"Stair Trailer","Boxville","Farm Plow","Utility Trailer"
};

// -------------------------------------------Enums-------------------------------------------
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
	pMuteTime,
	pWarns,
	pRegCheck,
	pBanTime,
	pBanExp
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

// ------------------------------------------Forwards-----------------------------------------
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

forward DelayedKick(playerid);
forward DelayedBan(playerid);
forward BanCheck(playerid);

forward SendToAdmins(color, text[]);

forward DestroyTempVehicle(vehicleid);

forward RegisterLog(registerstring[]);
forward AdminLog(playerid, adminstring[]);
forward MuteLog(playerid, mutestring[]);
forward AdminCommandLog(playerid, acmdlogstring[]);
forward KickLog(playerid, kickstring[]);
forward WarnLog(playerid, warnstring[]);
forward BanLog(playerid, banstring[]);
forward IpBanLog(ip[], ipbanstring[]);
forward GotoLog(playerid, gotostring[]);
forward ReportLog(reportstring[]);
forward PMLog(playerid, pmlogstring[]);

main() {}

// ------------------------------------Built - In Functions------------------------------------
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
	TogglePlayerSpectating(playerid, 1);
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

// -----------------------------------User Defined Functions-------------------------------------
stock GetName(playerid) // Returns the name of a player according to the player id
{
	new name[MAX_PLAYER_NAME];

	GetPlayerName(playerid, name, sizeof(name));
	return name; 
}

stock IsNumeric(const string[]) // Checks if the parameter is numeric
{
	for(new x = 0; string[x]; x++)
	{
		if(string[x] < '0' || string[x] > '9')
			return 0;
	}
	return 1;
}

stock GetVehicleModelIDFromName(const vname[]) // Returns vehicle's mode id from vehicle name
{
	for(new x=0; x < sizeof(VehicleNames); x++)
	{
		if(strfind(VehicleNames[x], vname, true) != -1)
			return x + 400;
	}
	return -1;
}

stock GetVehicleName(vehicleid) // Returns the vehicle name for a vehicle id
{
	new string[256];
	format(string, sizeof(string), "%s", VehicleNames[GetVehicleModel(vehicleid) - 400]);
	return string;
}

public CheckAccountExist(playerid) // Checks if a player is already registered or not and shows the login/register dialog accordingly
{
	new name[128], string[MAX_PLAYER_NAME];

	name = GetName(playerid);
	format(string, sizeof(string), "accounts/%s.ini", name);

	if(fexist(string))
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
			else if(strcmp(key, "RegCheck") == 0)
				Player[playerid][pRegCheck] = strval(line[s]);
		}
		fclose(handle);

		if(Player[playerid][pRegCheck] == 1)
			ShowPlayerDialog(playerid, DIALOG_LOGIN, DIALOG_STYLE_PASSWORD, ""COL_WHITE"Account Login", ""COL_WHITE"Please enter your password below to login.", "Login", "Quit");
		else
			ShowPlayerDialog(playerid, DIALOG_REGISTER_1, DIALOG_STYLE_INPUT, ""COL_WHITE"Account Registration", ""COL_WHITE"Please enter your email below to register your account.", "Next", "Cancel");
	}
	else
		ShowPlayerDialog(playerid, DIALOG_REGISTER_1, DIALOG_STYLE_INPUT, ""COL_WHITE"Account Registration", ""COL_WHITE"Please enter your email below to register your account.", "Next", "Cancel");

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
	Player[playerid][pWarns] = 0;
	Player[playerid][pRegCheck] = 1;
	Player[playerid][pBanTime] = 0;
	Player[playerid][pBanExp] = 0;

	new hour, minute, second;
	new year, month, day;

	gettime(hour, minute, second);
	getdate(year, month, day);

	format(registerstring, sizeof(registerstring), "%s has registered. [%d/%d/%d] [%d:%d:%d]", GetName(playerid), day, month, year, hour, minute, second);
	RegisterLog(registerstring);

	TogglePlayerSpectating(playerid, 0);

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

	format(line, sizeof(line), "Warns=%d\r\n", Player[playerid][pWarns]);
	fwrite(handle, line);

	format(line, sizeof(line), "RegCheck=%d\r\n", Player[playerid][pRegCheck]);
	fwrite(handle, line);

	format(line, sizeof(line), "BanTime=%d\r\n", Player[playerid][pBanTime]);
	fwrite(handle, line);

	format(line, sizeof(line), "BanExp=%d\r\n", Player[playerid][pBanExp]);
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
		else if(strcmp(key, "Warns") == 0)
			Player[playerid][pWarns] = strval(line[s]);
		else if(strcmp(key, "RegCheck") == 0)
			Player[playerid][pRegCheck] = strval(line[s]);
		else if(strcmp(key, "BanTime") == 0)
			Player[playerid][pBanTime] = strval(line[s]);
		else if(strcmp(key, "BanExp") == 0)
			Player[playerid][pBanExp] = strval(line[s]);
	}
	fclose(handle);

	BanCheck(playerid);

	SafeSetPlayerMoney(playerid, Player[playerid][pCash]);

	TogglePlayerSpectating(playerid, 0);

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

		format(mutestring, sizeof(mutestring), "Unmuted | Automatic [%d/%d/%d] [%d:%d:%d]", day, month, year, hour, minute, second);
		MuteLog(playerid, mutestring);
	}

	return 1;
}

public DelayedKick(playerid) // Kicks a player from the server
{
	Kick(playerid);
	return 1;
}

public DelayedBan(playerid) // Bans a player from the server
{
	Player[playerid][pIsBanned] = 1;
	Ban(playerid);
	return 1;
}

public BanCheck(playerid) // Checks if a player is banned and kicks the player if banned showing the time left for unban (if temporarily banned)
{
	new kickstring[128], day, month, year, hour, minute, second, timestamp, string2[256];

	if(Player[playerid][pIsBanned] == 1)
	{
		timestamp = gettime(hour, minute, second);
		getdate(year, month, day);

		if(Player[playerid][pBanExp] == -1)
		{
			SendClientMessage(playerid, COLOR_BRIGHTRED, "You are banned from this server!");
			SetTimerEx("DelayedKick", 1000, 0, "i", playerid); // calls the function DelayedKick to kick player with a delay of 1 second to show the message

			format(kickstring, sizeof(kickstring), "Reason: Login failed due to ban [%d/%d/%d] [%d:%d:%d]", day, month, year, hour, minute, second);
			KickLog(playerid, kickstring);
		}

		if(timestamp <= Player[playerid][pBanExp])
		{
			SendClientMessage(playerid, COLOR_BRIGHTRED, "You are banned from this server!");
			format(string2, sizeof(string2), "Time left for unban: %d hours", (Player[playerid][pBanExp] - gettime())/3600);
			SendClientMessage(playerid, COLOR_BRIGHTRED, string2);

			SetTimerEx("DelayedKick", 1000, 0, "i", playerid); // calls the function DelayedKick to kick player with a delay of 1 second to show the message

			format(kickstring, sizeof(kickstring), "Reason: Login failed due to ban [%d/%d/%d] [%d:%d:%d]", day, month, year, hour, minute, second);
			KickLog(playerid, kickstring);
		}
		else
		{
			Player[playerid][pIsBanned] = 0;
			Player[playerid][pBanTime] = 0;
			Player[playerid][pBanExp] = 0;
			SaveAccount(playerid);
		}
	}
}

public SendToAdmins(color, text[]) // Sends a mesage to all admins
{
	for(new i; i < MAX_PLAYERS; i++)
	{
		if(Player[i][pAdminLevel] >= 1 || IsPlayerAdmin(i))
		{
			SendClientMessage(i, color, text);
		}
	}
	return 1;
}

// ------------------------Safe Money Functions (Anti - Money Cheat)------------------------------
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

public DestroyTempVehicle(vehicleid) // Destroys a vehicle from the server
{
	DestroyVehicle(vehicleid);
	return 1;
}

// -------------------------------------Log Functions---------------------------------------------
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

public KickLog(playerid, kickstring[]) // Makes log of player kicks
{
	new entry[256], string[128];
	format(entry, sizeof(entry), "%s\r\n", kickstring);

	new File:hFile;
	format(string, sizeof(string), "logs/kicks/%s.log", GetName(playerid));
	hFile = fopen(string, io_append);
	fwrite(hFile, entry);

	fclose(hFile);
}

public WarnLog(playerid, warnstring[]) // Makes log of player warns
{
	new entry[256], string[128];
	format(entry, sizeof(entry), "%s\r\n", warnstring);

	new File:hFile;
	format(string, sizeof(string), "logs/warns/%s.log", GetName(playerid));
	hFile = fopen(string, io_append);
	fwrite(hFile, entry);

	fclose(hFile);
}

public BanLog(playerid, banstring[]) // Makes log of player bans
{
	new entry[256], string[128];
	format(entry, sizeof(entry), "%s\r\n", banstring);

	new File:hFile;
	format(string, sizeof(string), "logs/bans/%s.log", GetName(playerid));
	hFile = fopen(string, io_append);
	fwrite(hFile, entry);

	fclose(hFile);
}

public IpBanLog(ip[], ipbanstring[]) // Makes log of IP adress bans
{
	new entry[256], string[128];
	format(entry, sizeof(entry), "%s\r\n", ipbanstring);

	new File:hFile;
	format(string, sizeof(string), "logs/ipbans/%s.log", ip);
	hFile = fopen(string, io_append);
	fwrite(hFile, entry);

	fclose(hFile);
}

public GotoLog(playerid, gotostring[]) // Makes log of player bans
{
	new entry[256], string[128];
	format(entry, sizeof(entry), "%s\r\n", gotostring);

	new File:hFile;
	format(string, sizeof(string), "logs/gotos/%s.log", GetName(playerid));
	hFile = fopen(string, io_append);
	fwrite(hFile, entry);

	fclose(hFile);
}

public ReportLog(reportstring[]) // Makes log of reports sent by players
{
	new entry[256], string[128];
	format(entry, sizeof(entry), "%s\r\n", reportstring);

	new File:hFile;
	format(string, sizeof(string), "logs/reports.log");
	hFile = fopen(string, io_append);
	fwrite(hFile, entry);

	fclose(hFile);
}

public PMLog(playerid, pmlogstring[]) // Makes log of PMs sent by admins to players
{
	new entry[256], string[128];
	format(entry, sizeof(entry), "%s\r\n", pmlogstring);

	new File:hFile;
	format(string, sizeof(string), "logs/pms/%s.log", GetName(playerid));
	hFile = fopen(string, io_append);
	fwrite(hFile, entry);

	fclose(hFile);
}

// ------------------------------------------COMMANDS---------------------------------------------

// ---------------------------------------Admin Commands------------------------------------------
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
			AdminCommandLog(playerid, acmdlogstring);

			format(adminstring, sizeof(adminstring), "Made | Level: %d | By: %s [%d/%d/%d] [%d:%d:%d]", level, GetName(playerid), day, month, year, hour, minute, second);
			AdminLog(targetid, adminstring);

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
			AdminCommandLog(playerid, acmdlogstring);

			format(adminstring, sizeof(adminstring), "%s: Removed | By: %s [%d/%d/%d] [%d:%d:%d]", GetName(targetid), GetName(playerid), day, month, year, hour, minute, second);
			AdminLog(targetid, adminstring);

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
			AdminCommandLog(playerid, acmdlogstring);

			if(Player[targetid][pAdminLevel] < level)
			{
				format(adminstring, sizeof(adminstring), "%s: Promoted | Level: %d | By: %s. [%d/%d/%d] [%d:%d:%d]", GetName(targetid), level, GetName(playerid), day, month, year, hour, minute, second);
				AdminLog(targetid, adminstring);

				format(string, sizeof(string), "You have promoted %s to admin level %d.", GetName(targetid), level);
				SendClientMessage(playerid, COLOR_LIGHTBLUE, string);

				format(string, sizeof(string), "Admin %s has promoted you to admin level %d.", GetName(playerid), level);
				SendClientMessage(targetid, COLOR_LIGHTBLUE, string);
			}
			else
			{
				format(adminstring, sizeof(adminstring), "%s: Demoted | Level: %d | By: %s [%d/%d/%d] [%d:%d:%d]", GetName(targetid), level, GetName(playerid), day, month, year, hour, minute, second);
				AdminLog(targetid, adminstring);

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

// ------------------------------------------------------------------------------------------------
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
			AdminCommandLog(playerid, acmdlogstring);

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
			AdminCommandLog(playerid, acmdlogstring);

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

// ------------------------------------------------------------------------------------------------
CMD:kick(playerid, params[]) // Kicks a player from the server
{
	new targetid, reason[256], string[128], day, month, year, hour, minute, second, acmdlogstring[128], kickstring[128];

	if(Player[playerid][pAdminLevel] >= 1 || IsPlayerAdmin(playerid))
	{
		if(sscanf(params, "us[128]", targetid, reason))
			return SendClientMessage(playerid, COLOR_LIGHTCYAN, "Syntax: /kick [playerid/PartOfName] [reason]");

		if(IsPlayerConnected(targetid))
		{
			if(targetid == playerid)
				return SendClientMessage(playerid, COLOR_NEUTRAL, "You cannot use this command on yourself.");

			gettime(hour, minute, second);
			getdate(year, month, day);

			format(string, sizeof(string), "You have kicked %s from the server. Reason: %s", GetName(targetid), reason);
			SendClientMessage(playerid, COLOR_LIGHTBLUE, string);

			format(string, sizeof(string), "%s has been kicked from the server by admin %s. Reason: %s", GetName(targetid), GetName(playerid), reason);
			SendClientMessageToAll(COLOR_RED, string);

			format(string, sizeof(string), "You are kicked from the server by admin %s. Reason: %s", GetName(playerid), reason);
			SendClientMessage(targetid, COLOR_RED, string);

			SetTimerEx("DelayedKick", 1000, 0, "i", targetid); // calls the function DelayedKick to kick player with a delay of 1 second to show the message

			format(kickstring, sizeof(kickstring), "Reason: %s | By: %s [%d/%d/%d] [%d:%d:%d]", reason, GetName(playerid), day, month, year, hour, minute, second);
			KickLog(targetid, kickstring);

			format(acmdlogstring, sizeof(acmdlogstring), "Command: /kick %s | Reason: %s [%d/%d/%d] [%d:%d:%d]", GetName(targetid), reason, day, month, year, hour, minute, second);
			AdminCommandLog(playerid, acmdlogstring);
		}
		else
			return SendClientMessage(playerid, COLOR_LIGHTNEUTRALBLUE, "The player is not connected!");
	}
	else
		return SendClientMessage(playerid, COLOR_LIGHTNEUTRALBLUE, "You are not authorized to use this command!");
	return 1;
}

// ------------------------------------------------------------------------------------------------
CMD:warn(playerid, params[]) // Warns a player and bans on the third warn
{
	new targetid, reason[128], string[256], acmdlogstring[128], warnstring[128], banstring[128], day, month, year, hour, minute, second, timestamp;

	if(Player[playerid][pAdminLevel] >= 1 || IsPlayerAdmin(playerid))
	{
		if(sscanf(params, "us[128]", targetid, reason))
			return SendClientMessage(playerid, COLOR_LIGHTCYAN, "Syntax: /warn [playerid/PartOfName] [reason]");

		if(IsPlayerConnected(targetid))
		{
			if(targetid == playerid)
				return SendClientMessage(playerid, COLOR_NEUTRAL, "You cannot use this command on yourself.");

			timestamp = gettime(hour, minute, second);
			getdate(year, month, day);

			format(string, sizeof(string), "You have warned %s. Reason: %s", GetName(targetid), reason);
			SendClientMessage(playerid, COLOR_LIGHTBLUE, string);

			format(string, sizeof(string), "%s has been warned by admin %s. Reason: %s", GetName(targetid), GetName(playerid), reason);
			SendClientMessageToAll(COLOR_RED, string);

			format(string, sizeof(string), "You are warned by admin %s. Reason: %s", GetName(playerid), reason);
			SendClientMessage(targetid, COLOR_RED, string);

			format(warnstring, sizeof(warnstring), "Warned | Reason: %s | By: %s [%d/%d/%d] [%d:%d:%d]", reason, GetName(playerid), day, month, year, hour, minute, second);
			WarnLog(targetid, warnstring);

			format(acmdlogstring, sizeof(acmdlogstring), "Command: /warn %s | Reason: %s [%d/%d/%d] [%d:%d:%d]", GetName(targetid), reason, day, month, year, hour, minute, second);
			AdminCommandLog(playerid, acmdlogstring);

			Player[targetid][pWarns]++;

			SaveAccount(targetid);

			if(Player[targetid][pWarns] == 3)
			{
				format(string, sizeof(string), "%s has been banned from the server for 3 days. Reason: 3 Warns", GetName(targetid), GetName(playerid));
				SendClientMessageToAll(COLOR_RED, string);

				format(string, sizeof(string), "You are banned from the server for 3 days. Reason: 3 Warns", GetName(playerid), reason);
				SendClientMessage(targetid, COLOR_RED, string);

				Player[targetid][pWarns] = 0;
				Player[targetid][pIsBanned] = 1;
				Player[targetid][pBanTime] = 259200; // 72 hours
				Player[targetid][pBanExp] = timestamp + Player[targetid][pBanTime];
				SaveAccount(targetid);

				SetTimerEx("DelayedKick", 1000, 0, "i", targetid);

				format(banstring, sizeof(banstring), "Reason: 3 Warns [%d/%d/%d] [%d:%d:%d]", day, month, year, hour, minute, second);
				BanLog(targetid, banstring);
			}
		}
		else
			return SendClientMessage(playerid, COLOR_LIGHTNEUTRALBLUE, "The player is not connected!");
	}
	else
		return SendClientMessage(playerid, COLOR_LIGHTNEUTRALBLUE, "You are not authorized to use this command!");
	return 1;
}

CMD:unwarn(playerid, params[]) // Unwarns a player (Decreases one warn)
{
	new targetid, day, month, year, hour, minute, second, string[128], warnstring[128], acmdlogstring[128];

	if(Player[playerid][pAdminLevel] >= 1 || IsPlayerAdmin(playerid))
	{
		if(sscanf(params, "u", targetid))
			return SendClientMessage(playerid, COLOR_LIGHTCYAN, "Syntax: /unwarn [playerid/PartOfName]");

		if(IsPlayerConnected(targetid))
		{
			if(targetid == playerid)
				return SendClientMessage(playerid, COLOR_NEUTRAL, "You cannot use this command on yourself.");

			if(Player[targetid][pWarns] == 0)
				return SendClientMessage(playerid, COLOR_NEUTRAL, "The player is not warned.");

			gettime(hour, minute, second);
			getdate(year, month, day);

			format(string, sizeof(string), "You have unwarned %s.", GetName(targetid));
			SendClientMessage(playerid, COLOR_LIGHTBLUE, string);

			format(string, sizeof(string), "%s has been unwarned by admin %s.", GetName(targetid), GetName(playerid));
			SendClientMessageToAll(COLOR_RED, string);

			format(string, sizeof(string), "You are unwarned by admin %s.", GetName(playerid));
			SendClientMessage(targetid, COLOR_RED, string);

			format(warnstring, sizeof(warnstring), "Unwarned | By: %s [%d/%d/%d] [%d:%d:%d]", GetName(playerid), day, month, year, hour, minute, second);
			WarnLog(targetid, warnstring);

			format(acmdlogstring, sizeof(acmdlogstring), "Command: /unwarn %s [%d/%d/%d] [%d:%d:%d]", GetName(targetid), day, month, year, hour, minute, second);
			AdminCommandLog(playerid, acmdlogstring);

			Player[targetid][pWarns]--;

			SaveAccount(targetid);
		}
		else
			return SendClientMessage(playerid, COLOR_LIGHTNEUTRALBLUE, "The player is not connected!");
	}
	else
		return SendClientMessage(playerid, COLOR_LIGHTNEUTRALBLUE, "You are not authorized to use this command!");
	return 1;
}

// ------------------------------------------------------------------------------------------------
CMD:goto(playerid, params[]) // Teleports the admin to a player
{
	new targetid, acmdlogstring[128], day, month, year, hour, minute, second, Float:x, Float:y, Float:z;

	if(Player[playerid][pAdminLevel] >= 3 || IsPlayerAdmin(playerid))
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
			gobackstatus[playerid] = 1;
			savedposx[playerid] = x;
			savedposy[playerid] = y;
			savedposz[playerid] = z;
			SetPlayerPos(playerid, x + 1, y + 1, z);

			format(acmdlogstring, sizeof(acmdlogstring), "Command: /goto %s [%d/%d/%d] [%d:%d:%d]", GetName(targetid), day, month, year, hour, minute, second);
			AdminCommandLog(playerid, acmdlogstring);

			SendClientMessage(playerid, COLOR_SEAGREEN, "You have been teleported.");
		}
		else
			return SendClientMessage(playerid, COLOR_LIGHTNEUTRALBLUE, "The player is not connected!");
	}
	else
		return SendClientMessage(playerid, COLOR_LIGHTNEUTRALBLUE, "You are not authorized to use this command!");
	return 1;
}

CMD:gethere(playerid, params[]) // Teleports a player near the admin
{
	new targetid, acmdlogstring[128], day, month, year, hour, minute, second, Float:x, Float:y, Float:z;

	if(Player[playerid][pAdminLevel] >= 3 || IsPlayerAdmin(playerid))
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
			gobackstatus[playerid] = 1;
			savedposx[playerid] = x;
			savedposy[playerid] = y;
			savedposz[playerid] = z;
			SetPlayerPos(targetid, x + 1, y + 1, z);

			format(acmdlogstring, sizeof(acmdlogstring), "Command: /gethere %s [%d/%d/%d] [%d:%d:%d]", GetName(targetid), day, month, year, hour, minute, second);
			AdminCommandLog(playerid, acmdlogstring);

			SendClientMessage(targetid, COLOR_SEAGREEN, "You have been teleported.");
		}
		else
			return SendClientMessage(playerid, COLOR_LIGHTNEUTRALBLUE, "The player is not connected!");
	}
	else
		return SendClientMessage(playerid, COLOR_LIGHTNEUTRALBLUE, "You are not authorized to use this command!");
	return 1;
}

CMD:goback(playerid, params[]) // Teleports the player to the last position (where goto commands were used)
{
	new day, month, year, hour, minute, second, acmdlogstring[128];
	if(Player[playerid][pAdminLevel] >= 3 || IsPlayerAdmin(playerid))
	{
		gettime(hour, minute, second);
		getdate(year, month, day);

		if(gobackstatus[playerid] == 1)
		{
			SetPlayerPos(playerid, savedposx[playerid], savedposy[playerid], savedposz[playerid]);
			gobackstatus[playerid] = 0;
		}
		else
		{
			SendClientMessage(playerid, COLOR_NEUTRAL, "You can go back only once.");
		}
	
		format(acmdlogstring, sizeof(acmdlogstring), "Command: /goback [%d/%d/%d] [%d:%d:%d]", day, month, year, hour, minute, second);
		AdminCommandLog(playerid, acmdlogstring);

		SendClientMessage(playerid, COLOR_SEAGREEN, "You have been teleported.");
	}
	else
		return SendClientMessage(playerid, COLOR_LIGHTNEUTRALBLUE, "You are not authorized to use this command!");
	return 1;
}

// ------------------------------------------------------------------------------------------------
CMD:ban(playerid, params[]) // Bans an account (-1 for permanent, time for temporary)
{
	new targetid, reason[128], time, string[128], acmdlogstring[128], banstring[128], day, month, year, hour, minute, second, timestamp;

	if(Player[playerid][pAdminLevel] >= 2 || IsPlayerAdmin(playerid))
	{
		if(sscanf(params, "us[128]i", targetid, reason, time))
			return SendClientMessage(playerid, COLOR_LIGHTCYAN, "Syntax: /ban [playerid/PartOfName] [reason] [time]"); // -1 for permanent

		if(IsPlayerConnected(targetid))
		{
			if(targetid == playerid)
				return SendClientMessage(playerid, COLOR_NEUTRAL, "You cannot use this command on yourself.");

			timestamp = gettime(hour, minute, second);
			getdate(year, month, day);

			Player[targetid][pIsBanned] = 1;

			if(time == -1)
			{
				format(string, sizeof(string), "You have banned %s from the server. Reason: %s", GetName(targetid), reason);
				SendClientMessage(playerid, COLOR_RED, string);

				format(string, sizeof(string), "%s has been banned from the server by admin %s. Reason: %s", GetName(targetid), GetName(playerid), reason);
				SendClientMessageToAll(COLOR_RED, string);

				format(string, sizeof(string), "You are banned from the server by admin %s. Reason: %s", GetName(playerid), reason);
				SendClientMessage(targetid, COLOR_RED, string);

				Player[targetid][pIsBanned] = 1;
				Player[targetid][pBanExp] = time;
			}
			else
			{
				format(string, sizeof(string), "You have banned %s from the server for %d days. Reason: %s", GetName(targetid), time/24, reason);
				SendClientMessage(playerid, COLOR_RED, string);

				format(string, sizeof(string), "%s has been banned from the server for %d days by admin %s. Reason: %s", GetName(targetid), time/24, GetName(playerid), reason);
				SendClientMessageToAll(COLOR_RED, string);

				format(string, sizeof(string), "You are banned from the server for %d days by admin %s. Reason: %s", time/24, GetName(playerid), reason);
				SendClientMessage(targetid, COLOR_RED, string);

				Player[targetid][pIsBanned] = 1;
				Player[targetid][pBanTime] = time * 3600;
				Player[targetid][pBanExp] = timestamp + Player[targetid][pBanTime];
			}

			SaveAccount(targetid);

			format(acmdlogstring, sizeof(acmdlogstring), "Command: /ban %s %s %d [%d/%d/%d] [%d:%d:%d]", GetName(targetid), reason, time, day, month, year, hour, minute, second);
			AdminCommandLog(playerid, acmdlogstring);

			SetTimerEx("DelayedKick", 1000, 0, "i", targetid);

			format(banstring, sizeof(banstring), "Banned | Reason: %s | By %s [%d/%d/%d] [%d:%d:%d]", reason, GetName(playerid), day, month, year, hour, minute, second);
			BanLog(targetid, banstring);
		}
		else
			return SendClientMessage(playerid, COLOR_LIGHTNEUTRALBLUE, "The player is not connected!");
	}
	else
		return SendClientMessage(playerid, COLOR_LIGHTNEUTRALBLUE, "You are not authorized to use this command!");
	return 1;
}

CMD:banacip(playerid, params[]) // Bans an account and IP address both(-1 for permanent, time for temporary)
{
	new targetid, reason[128], time, string[128], acmdlogstring[128], banstring[128], day, month, year, hour, minute, second, timestamp, pIp[16];

	if(Player[playerid][pAdminLevel] >= 2 || IsPlayerAdmin(playerid))
	{
		if(sscanf(params, "us[128]i", targetid, reason, time))
			return SendClientMessage(playerid, COLOR_LIGHTCYAN, "Syntax: /banacip [playerid/PartOfName] [reason] [time]"); // -1 for permanent

		if(IsPlayerConnected(targetid))
		{
			if(targetid == playerid)
				return SendClientMessage(playerid, COLOR_NEUTRAL, "You cannot use this command on yourself.");

			timestamp = gettime(hour, minute, second);
			getdate(year, month, day);

			Player[targetid][pIsBanned] = 1;

			if(time == -1)
			{
				format(string, sizeof(string), "You have banned %s from the server. Reason: %s", GetName(targetid), reason);
				SendClientMessage(playerid, COLOR_RED, string);

				format(string, sizeof(string), "%s has been banned from the server by admin %s. Reason: %s", GetName(targetid), GetName(playerid), reason);
				SendClientMessageToAll(COLOR_RED, string);

				format(string, sizeof(string), "You are banned from the server by admin %s. Reason: %s", GetName(playerid), reason);
				SendClientMessage(targetid, COLOR_RED, string);

				Player[targetid][pIsBanned] = 1;
				Player[targetid][pBanExp] = time;
			}
			else
			{
				format(string, sizeof(string), "You have banned %s from the server for %d days. Reason: %s", GetName(targetid), time/24, reason);
				SendClientMessage(playerid, COLOR_RED, string);

				format(string, sizeof(string), "%s has been banned from the server for %d days by admin %s. Reason: %s", GetName(targetid), time/24, GetName(playerid), reason);
				SendClientMessageToAll(COLOR_RED, string);

				format(string, sizeof(string), "You are banned from the server for %d days by admin %s. Reason: %s", time/24, GetName(playerid), reason);
				SendClientMessage(targetid, COLOR_RED, string);

				Player[targetid][pIsBanned] = 1;
				Player[targetid][pBanTime] = time * 3600;
				Player[targetid][pBanExp] = timestamp + Player[targetid][pBanTime];
			}

			SaveAccount(targetid);

			format(acmdlogstring, sizeof(acmdlogstring), "Command: /banacip %s %s %d [%d/%d/%d] [%d:%d:%d]", GetName(targetid), reason, time, day, month, year, hour, minute, second);
			AdminCommandLog(playerid, acmdlogstring);

			GetPlayerIp(targetid, pIp, 16);

			SetTimerEx("DelayedKick", 1000, 0, "i", targetid);

			format(banstring, sizeof(banstring), "IP Banned: %s| Reason: %s | By %s [%d/%d/%d] [%d:%d:%d]", pIp, reason, GetName(playerid), day, month, year, hour, minute, second);
			BanLog(targetid, banstring);

			format(string, sizeof(string), "banip %s", pIp); 
        	SendRconCommand(string); 
        	SendRconCommand("reloadbans"); 
		}
		else
			return SendClientMessage(playerid, COLOR_LIGHTNEUTRALBLUE, "The player is not connected!");
	}
	else
		return SendClientMessage(playerid, COLOR_LIGHTNEUTRALBLUE, "You are not authorized to use this command!");
	return 1;
}

CMD:banip(playerid, params[]) // Bans an IP address permanently (until unbanned manually)
{
	new ip[16], string[128], reason[128], ipbanstring[128], acmdlogstring[128], day, month, year, hour, minute, second;
	if(Player[playerid][pAdminLevel] >= 2 || IsPlayerAdmin(playerid))
	{
		if(sscanf(params, "s[16]s[128]", ip, reason))
			return SendClientMessage(playerid, COLOR_LIGHTCYAN, "Syntax: /banip [ip address] [reason]");

		gettime(hour, minute, second);
		getdate(year, month, day);

		format(string, sizeof(string),"banip %s", ip);
		SendRconCommand(string);
		SendRconCommand("reloadbans");

		format(acmdlogstring, sizeof(acmdlogstring), "Command: /banip %s %s [%d/%d/%d] [%d:%d:%d]", ip, reason, day, month, year, hour, minute, second);
		AdminCommandLog(playerid, acmdlogstring);

		format(ipbanstring, sizeof(ipbanstring), "Banned: %s| Reason: %s | By %s [%d/%d/%d] [%d:%d:%d]", ip, reason, GetName(playerid), day, month, year, hour, minute, second);
		IpBanLog(ip, ipbanstring);
	}
	else
		return SendClientMessage(playerid, COLOR_LIGHTNEUTRALBLUE, "You are not authorized to use this command!");
	return 1;
}

CMD:unban(playerid, params[]) // Unbans an account
{
	new targetid, reason[128], string[128], acmdlogstring[128], banstring[128], day, month, year, hour, minute, second;

	if(Player[playerid][pAdminLevel] >= 2 || IsPlayerAdmin(playerid))
	{
		if(sscanf(params, "us[128]", targetid, reason))
			return SendClientMessage(playerid, COLOR_LIGHTCYAN, "Syntax: /unban [playerid/PartOfName] [reason]");

		gettime(hour, minute, second);
		getdate(year, month, day);
	
		format(string, sizeof(string), "You have unbanned %s from the server. Reason: %s", GetName(targetid), reason);
		SendClientMessage(playerid, COLOR_RED, string);

		new filename[64], line[256], s, key[64];
		new File:handle;
		handle = fopen(filename, io_read);

		format(filename, sizeof(filename), ACCOUNT_PATH "%s.ini", GetName(targetid));

		while(fread(handle, line))
		{
			StripNL(line);
			s = strfind(line, "=");

			if(!line[0] || s < 1)
				continue;

			strmid(key, line, 0, s++);
			if(strcmp(key, "IsBanned") == 0)
				Player[targetid][pIsBanned] = strval(line[s]);
			else if(strcmp(key, "BanTime") == 0)
				Player[targetid][pBanTime] = strval(line[s]);
			else if(strcmp(key, "BanExp") == 0)
				Player[targetid][pBanExp] = strval(line[s]);

			Player[targetid][pIsBanned] = 0;
			Player[targetid][pBanTime] = 0;
			Player[targetid][pBanExp] = 0;
		}
		fclose(handle);

		SaveAccount(targetid);

		format(acmdlogstring, sizeof(acmdlogstring), "Command: /unban %s %s [%d/%d/%d] [%d:%d:%d]", GetName(targetid), reason, day, month, year, hour, minute, second);
		AdminCommandLog(playerid, acmdlogstring);

		format(banstring, sizeof(banstring), "Unbanned | Reason: %s | By %s [%d/%d/%d] [%d:%d:%d]", reason, GetName(playerid), day, month, year, hour, minute, second);
		BanLog(targetid, banstring);
	}
	else
		return SendClientMessage(playerid, COLOR_LIGHTNEUTRALBLUE, "You are not authorized to use this command!");
	return 1;
}

CMD:unbanip(playerid, params[]) // Unbans an IP address
{
	new ip[16], string[128], ipbanstring[128], acmdlogstring[128], day, month, year, hour, minute, second, reason[128];
	if(Player[playerid][pAdminLevel] >= 2 || IsPlayerAdmin(playerid))
	{
		if(sscanf(params, "s[16]s[128]", ip, reason))
			return SendClientMessage(playerid, COLOR_LIGHTCYAN, "Syntax: /unbanip [ip address] [reason]");

		gettime(hour, minute, second);
		getdate(year, month, day);

		format(string, sizeof(string),"unbanip %s", ip);
		SendRconCommand(string);
		SendRconCommand("reloadbans");

		format(acmdlogstring, sizeof(acmdlogstring), "Command: /unbanip %s %s [%d/%d/%d] [%d:%d:%d]", ip, reason, day, month, year, hour, minute, second);
		AdminCommandLog(playerid, acmdlogstring);

		format(ipbanstring, sizeof(ipbanstring), "Unbanned: %s| Reason: %s | By %s [%d/%d/%d] [%d:%d:%d]", ip, reason, GetName(playerid), day, month, year, hour, minute, second);
		IpBanLog(ip, ipbanstring);
	}
	else
		return SendClientMessage(playerid, COLOR_LIGHTNEUTRALBLUE, "You are not authorized to use this command!");
	return 1;
}

// ------------------------------------------------------------------------------------------------
CMD:freeze(playerid, params[]) // Freezes a player's position
{
	new targetid, day, month, year, hour, minute, second, acmdlogstring[128], string[MAX_PLAYER_NAME];

	if(Player[playerid][pAdminLevel] >= 2 || IsPlayerAdmin(playerid))
	{
		if(sscanf(params, "u", targetid))
			return SendClientMessage(playerid, COLOR_LIGHTCYAN, "Syntax: /freeze [playerid/PartOfName]");

		if(IsPlayerConnected(targetid))
		{
			gettime(hour, minute, second);
			getdate(year, month, day);

			TogglePlayerControllable(targetid, 0);

			SendClientMessage(targetid, COLOR_YELLOW, "You are freezed!");
			format(string, sizeof(string), "You have freezed %s", GetName(targetid));
			SendClientMessage(playerid, COLOR_LIGHTBLUE, string);

			format(acmdlogstring, sizeof(acmdlogstring), "Command: /freeze %s [%d/%d/%d] [%d:%d:%d]", GetName(targetid), day, month, year, hour, minute, second);
			AdminCommandLog(playerid, acmdlogstring);
		}
		else
			return SendClientMessage(playerid, COLOR_LIGHTNEUTRALBLUE, "The player is not connected!");
	}
	else
		return SendClientMessage(playerid, COLOR_LIGHTNEUTRALBLUE, "You are not authorized to use this command!");
	return 1;
}

CMD:unfreeze(playerid, params[]) // Unfreezes a player's position
{
	new targetid, day, month, year, hour, minute, second, acmdlogstring[128], string[MAX_PLAYER_NAME];

	if(Player[playerid][pAdminLevel] >= 2 || IsPlayerAdmin(playerid))
	{
		if(sscanf(params, "u", targetid))
			return SendClientMessage(playerid, COLOR_LIGHTCYAN, "Syntax: /unfreeze [playerid/PartOfName]");

		if(IsPlayerConnected(targetid))
		{
			gettime(hour, minute, second);
			getdate(year, month, day);

			TogglePlayerControllable(targetid, 1);

			SendClientMessage(targetid, COLOR_YELLOW, "You are unfreezed!");
			format(string, sizeof(string), "You have unfreezed %s", GetName(targetid));
			SendClientMessage(playerid, COLOR_LIGHTBLUE, string);

			format(acmdlogstring, sizeof(acmdlogstring), "Command: /unfreeze %s [%d/%d/%d] [%d:%d:%d]", GetName(targetid), day, month, year, hour, minute, second);
			AdminCommandLog(playerid, acmdlogstring);
		}
		else
			return SendClientMessage(playerid, COLOR_LIGHTNEUTRALBLUE, "The player is not connected!");
	}
	else
		return SendClientMessage(playerid, COLOR_LIGHTNEUTRALBLUE, "You are not authorized to use this command!");
	return 1;
}

// ------------------------------------------------------------------------------------------------
CMD:reports(playerid, params[]) // Checks for pending reports
{
	new string[200], reportReason[126], pendingtime;
	if(Player[playerid][pAdminLevel] >= 1 || IsPlayerAdmin(playerid))
	{
		SendClientMessage(playerid, COLOR_YELLOW, "Reports:");
		for(new i = 0; i < MAX_PLAYERS; i++)
		{
			if(GetPVarInt(i, "ReportPending") == 1)
			{
				GetPVarString(i, "ReportReason", reportReason, sizeof(reportReason));

				pendingtime = (gettime() - GetPVarInt(i, "ReportTime")) / 60;

				format(string, sizeof(string), "%s (%d) | Reason: %s | Pending: %d minutes", GetName(i), i, reportReason, pendingtime);
				SendClientMessage(playerid, COLOR_PINK, string);
			}
		}
	}
	else
		return SendClientMessage(playerid, COLOR_LIGHTNEUTRALBLUE, "You are not authorized to use this command!");
	return 1;
}

CMD:ar(playerid, params[])
	return cmd_acceptreport(playerid, params);

CMD:acceptreport(playerid, params[]) // Accepts a pending report
{
	new targetid, string[128], day, month, year, hour, minute, second, acmdlogstring[128];

	if(Player[playerid][pAdminLevel] >= 1 || IsPlayerAdmin(playerid))
	{
		if(sscanf(params, "u", targetid))
			return SendClientMessage(playerid, COLOR_LIGHTCYAN, "Syntax: /ar [playerid/PartOfName]");

		if(IsPlayerConnected(targetid))
		{
			if(targetid == playerid)
				return SendClientMessage(playerid, COLOR_NEUTRAL, "You cannot use this command on yourself.");

			gettime(hour, minute, second);
			getdate(year, month, day);

			DeletePVar(targetid, "ReportPending");
			DeletePVar(targetid, "ReportReason");
			DeletePVar(targetid, "ReportTime");

			format(string, sizeof(string), "Admin %s has accepted your report", GetName(playerid));
			SendClientMessage(targetid, COLOR_YELLOW, string);

			format(string, sizeof(string), "Admin %s has accepted %s's report", GetName(playerid), GetName(targetid));
			SendToAdmins(COLOR_PINK, string);

			format(acmdlogstring, sizeof(acmdlogstring), "Command: /acceptreport %s [%d/%d/%d] [%d:%d:%d]", GetName(targetid), day, month, year, hour, minute, second);
			AdminCommandLog(playerid, acmdlogstring);
		}
		else
			return SendClientMessage(playerid, COLOR_LIGHTNEUTRALBLUE, "The player is not connected!");
	}
	else
		return SendClientMessage(playerid, COLOR_LIGHTNEUTRALBLUE, "You are not authorized to use this command!");
	return 1;
}

// ------------------------------------------------------------------------------------------------
CMD:a(playerid, params[]) // Sends a message to other admins (admin chat)
{
	new text[256], string[256];

	if(Player[playerid][pAdminLevel] >= 1 || IsPlayerAdmin(playerid))
	{
		if(sscanf(params, "s[256]", text))
			return SendClientMessage(playerid, COLOR_LIGHTCYAN, "Syntax: /a [message]");

		format(string, sizeof(string), "(Admin Level %d) %s: %s", Player[playerid][pAdminLevel], GetName(playerid), text);
		SendToAdmins(COLOR_MEDIUMBLUE, string);
	}
	else
		return SendClientMessage(playerid, COLOR_LIGHTNEUTRALBLUE, "You are not authorized to use this command!");
	return 1;
}

CMD:pm(playerid, params[]) // Sends a message to the player
{
	new targetid, text[128], string[256], day, month, year, hour, minute, second, acmdlogstring[128], pmlogstring[128];
	if(Player[playerid][pAdminLevel] >= 1 || IsPlayerAdmin(playerid))
	{
		if(sscanf(params, "us[128]", targetid, text))
			return SendClientMessage(playerid, COLOR_LIGHTCYAN, "Syntax: /pm [playerid/PartOfName] [message]");

		if(IsPlayerConnected(targetid))
		{
			if(targetid == playerid)
				return SendClientMessage(playerid, COLOR_NEUTRAL, "You cannot use this command on yourself.");

			gettime(hour, minute, second);
			getdate(year, month, day);

			format(string, sizeof(string), "PM to %s: %s", GetName(targetid), text);
			SendClientMessage(playerid, COLOR_YELLOW, string);

			format(string, sizeof(string), "PM from Admin %s: %s", GetName(playerid), text);
			SendClientMessage(targetid, COLOR_YELLOW, string);

			format(pmlogstring, sizeof(pmlogstring), "To: %s | Message: %s [%d/%d/%d] [%d:%d:%d]", GetName(targetid), text, day, month, year, hour, minute, second);
			PMLog(playerid, pmlogstring);

			format(acmdlogstring, sizeof(acmdlogstring), "Command: /pm %s %s [%d/%d/%d] [%d:%d:%d]", GetName(targetid), text, day, month, year, hour, minute, second);
			AdminCommandLog(playerid, acmdlogstring);
		}
		else
			return SendClientMessage(playerid, COLOR_LIGHTNEUTRALBLUE, "The player is not connected!");
	}
	else
		return SendClientMessage(playerid, COLOR_LIGHTNEUTRALBLUE, "You are not authorized to use this command!");
	return 1;
}

// ------------------------------------------------------------------------------------------------
CMD:spawnv(playerid, params[]) // Spawns a vehicle and puts the player in it (auto destroys after)
{
	new model[32], modelid, color1, color2, Float:X, Float:Y, Float:Z, Float:angle, vid, string[128], acmdlogstring[128], day, month, year, hour, minute, second;

	if(Player[playerid][pAdminLevel] >= 3 || IsPlayerAdmin(playerid))
	{
		if(sscanf(params, "s[128]ii", model, color1, color2))
			return SendClientMessage(playerid, COLOR_LIGHTCYAN, "Syntax: /spawnv [model] [color1] [color2]");

		if(IsNumeric(model))
			modelid = strval(model);
		else
			modelid = GetVehicleModelIDFromName(model);

		if(modelid < 400 || modelid > 611)
			return SendClientMessage(playerid, COLOR_LIGHTCYAN, "Invalid vehicle model!");

		if(color1 < 0 || color1 > 255)	
			return SendClientMessage(playerid, COLOR_LIGHTCYAN, "Primary color ID must be from 0 and 255!");

		if(color2 < 0 || color2 > 255)
			return SendClientMessage(playerid, COLOR_LIGHTCYAN, "Secondary color ID must be from 0 and 255!");

		GetPlayerPos(playerid, X, Y, Z);
		GetPlayerFacingAngle(playerid, angle);

		vid = CreateVehicle(modelid, X, Y, Z, angle, color1, color2, -1);

		format(string, sizeof(string), "%s has been spawned.", GetVehicleName(vid));
		SendClientMessage(playerid, COLOR_MEDIUMBLUE, string);

		SetTimerEx("DestroyTempVehicle", 900000, 0, "i", vid);

		PutPlayerInVehicle(playerid, vid, 0);

		gettime(hour, minute, second);
		getdate(year, month, day);

		format(acmdlogstring, sizeof(acmdlogstring), "Command: /spawnv %s %d %d [%d/%d/%d] [%d:%d:%d]", model, color1, color2, day, month, year, hour, minute, second);
		AdminCommandLog(playerid, acmdlogstring);
	}
	else
		return SendClientMessage(playerid, COLOR_LIGHTNEUTRALBLUE, "You are not authorized to use this command!");
	return 1;
}

CMD:gotov(playerid, params[]) // Teleports the player to a vehicle
{
	new Float:X, Float:Y, Float:Z, vid, string[128], gotostring[128], day, month, year, hour, minute, second, acmdlogstring[128];

	if(Player[playerid][pAdminLevel] >= 3 || IsPlayerAdmin(playerid))
	{
		if(sscanf(params, "i", vid))
			return SendClientMessage(playerid, COLOR_LIGHTCYAN, "Syntax: /gotov [vehicleid]");

		GetPlayerPos(playerid, X, Y, Z);
		
		gobackstatus[playerid] = 1;
		savedposx[playerid] = X;
		savedposy[playerid] = Y;
		savedposz[playerid] = Z;

		GetVehiclePos(vid, X, Y, Z);
		SetPlayerPos(playerid, X + 1, Y + 1, Z);

		format(string, sizeof(string), "You have been teleported to vehicle %d.", vid);

		SendClientMessage(playerid, COLOR_MEDIUMBLUE, string);

		gettime(hour, minute, second);
		getdate(year, month, day);

		format(gotostring, sizeof(gotostring), "gotov %d [%d/%d/%d] [%d:%d:%d]", vid, day, month, year, hour, minute, second);
		GotoLog(playerid, gotostring);

		format(acmdlogstring, sizeof(acmdlogstring), "Command: /gotov %d [%d/%d/%d] [%d:%d:%d]", vid, day, month, year, hour, minute, second);
		AdminCommandLog(playerid, acmdlogstring);
	}
	else
		return SendClientMessage(playerid, COLOR_LIGHTNEUTRALBLUE, "You are not authorized to use this command!");
	return 1;	
}

CMD:getv(playerid, params[]) // Teleports the vehicle to the player
{
	new Float:X, Float:Y, Float:Z, vid, string[128], acmdlogstring[128], day, month, year, hour, minute, second;

	if(Player[playerid][pAdminLevel] >= 3 || IsPlayerAdmin(playerid))
	{
		if(sscanf(params, "i", vid))
			return SendClientMessage(playerid, COLOR_LIGHTCYAN, "Syntax: /getv [vehicleid]");

		gobackstatus[playerid] = 1;
		savedposx[playerid] = X;
		savedposy[playerid] = Y;
		savedposz[playerid] = Z;

		GetPlayerPos(playerid, X, Y, Z);
		SetVehiclePos(vid, X + 1, Y + 1, Z);

		gettime(hour, minute, second);
		getdate(year, month, day);

		format(string, sizeof(string), "Vehicle %d has been teleported to you.", vid);
		SendClientMessage(playerid, COLOR_MEDIUMBLUE, string);

		format(acmdlogstring, sizeof(acmdlogstring), "Command: /getv %d [%d/%d/%d] [%d:%d:%d]", vid, day, month, year, hour, minute, second);
		AdminCommandLog(playerid, acmdlogstring);
	}
	else
		return SendClientMessage(playerid, COLOR_LIGHTNEUTRALBLUE, "You are not authorized to use this command!");
	return 1;
}

CMD:arep(playerid, params[]) // Repairs a vehicle
{
	new day, month, year, hour, minute, second, acmdlogstring[128], Float:X, Float:Y, Float:Z;
	if(Player[playerid][pAdminLevel] >= 5 || IsPlayerAdmin(playerid))
	{
		if(!IsPlayerInAnyVehicle(playerid))
			return SendClientMessage(playerid, COLOR_NEUTRAL, "You are not in a vehicle.");

		gettime(hour, minute, second);
		getdate(year, month, day);

		GetPlayerPos(playerid, X, Y, Z);

		RepairVehicle(GetPlayerVehicleID(playerid));
		PlayerPlaySound(playerid, 1133, X, Y, Z);
		SendClientMessage(playerid, COLOR_MEDIUMBLUE, "Vehicle repaired!");

		format(acmdlogstring, sizeof(acmdlogstring), "Command: /arep [%d/%d/%d] [%d:%d:%d]", day, month, year, hour, minute, second);
		AdminCommandLog(playerid, acmdlogstring);
	}
	else
		return SendClientMessage(playerid, COLOR_LIGHTNEUTRALBLUE, "You are not authorized to use this command!");
	return 1;
}

CMD:dv(playerid, params[])
	return cmd_destroyvehicle(playerid, params);

CMD:destroyvehicle(playerid, params[]) // Destroys a vehicle from the server
{
	new day, month, year, hour, minute, second, acmdlogstring[128];
	if(Player[playerid][pAdminLevel] == 6 || IsPlayerAdmin(playerid))
	{
		if(!IsPlayerInAnyVehicle(playerid))
			return SendClientMessage(playerid, COLOR_NEUTRAL, "You are not in a vehicle.");

		DestroyVehicle(GetPlayerVehicleID(playerid));
		SendClientMessage(playerid, COLOR_PINK, "Vehicle destroyed!");

		gettime(hour, minute, second);
		getdate(year, month, day);

		format(acmdlogstring, sizeof(acmdlogstring), "Command: /dv [%d/%d/%d] [%d:%d:%d]", day, month, year, hour, minute, second);
		AdminCommandLog(playerid, acmdlogstring);
	}
	else
		return SendClientMessage(playerid, COLOR_LIGHTNEUTRALBLUE, "You are not authorized to use this command!");
	return 1;
}

CMD:nos(playerid, params[]) // Gives nitros to a vehicle
{
	new day, month, year, hour, minute, second, acmdlogstring[128];
	if(Player[playerid][pAdminLevel] == 6 || IsPlayerAdmin(playerid))
	{
		if(!IsPlayerInAnyVehicle(playerid))
			return SendClientMessage(playerid, COLOR_NEUTRAL, "You are not in a vehicle.");

		AddVehicleComponent(GetPlayerVehicleID(playerid), 1010);
		SendClientMessage(playerid, COLOR_PINK, "Added nitros x10 to the vehicle.");

		gettime(hour, minute, second);
		getdate(year, month, day);

		format(acmdlogstring, sizeof(acmdlogstring), "Command: /nos [%d/%d/%d] [%d:%d:%d]", day, month, year, hour, minute, second);
		AdminCommandLog(playerid, acmdlogstring);
	}
	else
		return SendClientMessage(playerid, COLOR_LIGHTNEUTRALBLUE, "You are not authorized to use this command!");
	return 1;
}

CMD:rtv(playerid, params[])
	return cmd_respawnthisvehicle(playerid, params);

CMD:respawnthisvehicle(playerid, params[]) // Respawns the current vehicle
{
	new day, month, year, hour, minute, second, acmdlogstring[128];

	if(Player[playerid][pAdminLevel] >= 2 || IsPlayerAdmin(playerid))
	{
		if(!IsPlayerInAnyVehicle(playerid))
			return SendClientMessage(playerid, COLOR_NEUTRAL, "You are not in a vehicle.");

		SetVehicleToRespawn(GetPlayerVehicleID(playerid));
		SendClientMessage(playerid, COLOR_PINK, "Vehicle respawned!");

		gettime(hour, minute, second);
		getdate(year, month, day);

		format(acmdlogstring, sizeof(acmdlogstring), "Command: /rtv [%d/%d/%d] [%d:%d:%d]", day, month, year, hour, minute, second);
		AdminCommandLog(playerid, acmdlogstring);
	}
	else
		return SendClientMessage(playerid, COLOR_LIGHTNEUTRALBLUE, "You are not authorized to use this command!");
	return 1;
}

CMD:rav(playerid, params[])
	return cmd_respawnallvehicles(playerid, params);

CMD:respawnallvehicles(playerid, params[]) // Respawns all vehicles
{
	new bool:vehicleused[MAX_VEHICLES], string[128], day, month, year, hour, minute, second, acmdlogstring[128];
	if(Player[playerid][pAdminLevel] >= 5 || IsPlayerAdmin(playerid))
	{
		for(new i = 0; i < MAX_PLAYERS; i++)
			if(IsPlayerInAnyVehicle(i))
				vehicleused[GetPlayerVehicleID(i)] = true;

		for(new i = 0; i < MAX_VEHICLES; i++)
			if(!vehicleused[i])
				SetVehicleToRespawn(i);

		format(string, sizeof(string), "Admin %s has respawned all unused vehicles.", GetName(playerid));
		SendClientMessageToAll(COLOR_LIGHTBLUE, string);

		gettime(hour, minute, second);
		getdate(year, month, day);

		format(acmdlogstring, sizeof(acmdlogstring), "Command: /rav [%d/%d/%d] [%d:%d:%d]", day, month, year, hour, minute, second);
		AdminCommandLog(playerid, acmdlogstring);
	}
	else
		return SendClientMessage(playerid, COLOR_LIGHTNEUTRALBLUE, "You are not authorized to use this command!");
	return 1;
}

// ------------------------------------------------------------------------------------------------
CMD:up(playerid, params[]) // Makes the player jump into the air
{
	new Float:X, Float:Y, Float:Z, day, month, year, hour, minute, second, acmdlogstring[128];

	if(Player[playerid][pAdminLevel] >= 1 || IsPlayerAdmin(playerid))
	{
		GetPlayerPos(playerid, X, Y, Z);
		SetPlayerPos(playerid, X, Y, Z + 5);
		PlayerPlaySound(playerid, 1130, X, Y, Z + 5);

		gettime(hour, minute, second);
		getdate(year, month, day);

		format(acmdlogstring, sizeof(acmdlogstring), "Command: /up [%d/%d/%d] [%d:%d:%d]", day, month, year, hour, minute, second);
		AdminCommandLog(playerid, acmdlogstring);
	}
	else
		return SendClientMessage(playerid, COLOR_LIGHTNEUTRALBLUE, "You are not authorized to use this command!");
	return 1;
}

CMD:slap(playerid, params[]) // Slaps a player (decreases 5 health points)
{
	new targetid, Float:health, Float:X, Float:Y, Float:Z, string[128], day, month, year, hour, minute, second, acmdlogstring[128];

	if(Player[playerid][pAdminLevel] >= 1 || IsPlayerAdmin(playerid))
	{
		if(sscanf(params, "u", targetid))
			return SendClientMessage(playerid, COLOR_LIGHTCYAN, "Syntax: /freeze [playerid/PartOfName]");

		if(IsPlayerConnected(targetid))
		{
			if(targetid == playerid)
				return SendClientMessage(playerid, COLOR_NEUTRAL, "You cannot use this command on yourself.");

			GetPlayerHealth(targetid, health);
			SetPlayerHealth(targetid, health - 5);
			GetPlayerPos(targetid, X, Y, Z);
			SetPlayerPos(targetid, X, Y, Z + 10);

			gettime(hour, minute, second);
			getdate(year, month, day);

			format(string, sizeof(string), "You slapped %s", GetName(targetid));
			SendClientMessage(playerid, COLOR_PINK, string);

			format(string, sizeof(string), "You got slapped by admin %s", GetName(playerid));
			SendClientMessage(targetid, COLOR_LIGHTBLUEGREEN, string);
			
			gettime(hour, minute, second);
			getdate(year, month, day);

			format(acmdlogstring, sizeof(acmdlogstring), "Command: /slap %s [%d/%d/%d] [%d:%d:%d]", GetName(targetid), day, month, year, hour, minute, second);
			AdminCommandLog(playerid, acmdlogstring);
		}
		else
			return SendClientMessage(playerid, COLOR_LIGHTNEUTRALBLUE, "The player is not connected!");
	}
	else
		return SendClientMessage(playerid, COLOR_LIGHTNEUTRALBLUE, "You are not authorized to use this command!");
	return 1;
}

CMD:fly(playerid, params[]) // Makes the player jump in both upward and forward direction
{
	new day, month, year, hour, minute, second, acmdlogstring[128];
	if(Player[playerid][pAdminLevel] >= 1 || IsPlayerAdmin(playerid))
	{
		new Float:px, Float:py, Float:pz, Float:pa;
		GetPlayerFacingAngle(playerid,pa);
		if(pa >= 0.0 && pa <= 22.5) //n1
		{
			GetPlayerPos(playerid, px, py, pz);
			SetPlayerPos(playerid, px, py+30, pz+5);
		}
		if(pa >= 332.5 && pa < 0.0) //n2
		{
			GetPlayerPos(playerid, px, py, pz);
			SetPlayerPos(playerid, px, py+30, pz+5);
		}
		if(pa >= 22.5 && pa <= 67.5) //nw
		{
			GetPlayerPos(playerid, px, py, pz);
			SetPlayerPos(playerid, px-15, py+15, pz+5);
		}
		if(pa >= 67.5 && pa <= 112.5) //w
		{
			GetPlayerPos(playerid, px, py, pz);
			SetPlayerPos(playerid, px-30, py, pz+5);
		}
		if(pa >= 112.5 && pa <= 157.5) //sw
		{
			GetPlayerPos(playerid, px, py, pz);
			SetPlayerPos(playerid, px-15, py-15, pz+5);
		}
		if(pa >= 157.5 && pa <= 202.5) //s
		{
			GetPlayerPos(playerid, px, py, pz);
			SetPlayerPos(playerid, px, py-30, pz+5);
		}
		if(pa >= 202.5 && pa <= 247.5)//se
		{
			GetPlayerPos(playerid, px, py, pz);
			SetPlayerPos(playerid, px+15, py-15, pz+5);
		}
		if(pa >= 247.5 && pa <= 292.5)//e
		{
			GetPlayerPos(playerid, px, py, pz);
			SetPlayerPos(playerid, px+30, py, pz+5);
		}
		if(pa >= 292.5 && pa <= 332.5)//e
		{
			GetPlayerPos(playerid, px, py, pz);
			SetPlayerPos(playerid, px+15, py+15, pz+5);
		}

		gettime(hour, minute, second);
		getdate(year, month, day);

		format(acmdlogstring, sizeof(acmdlogstring), "Command: /fly [%d/%d/%d] [%d:%d:%d]", day, month, year, hour, minute, second);
		AdminCommandLog(playerid, acmdlogstring);
	}
	else
		return SendClientMessage(playerid, COLOR_LIGHTNEUTRALBLUE, "You are not authorized to use this command!");
	return 1;
}

// ------------------------------------------------------------------------------------------------
CMD:givemoney(playerid, params[]) // Gives cash to a player
{
	new targetid, amount, string[128], day, month, year, hour, minute, second, acmdlogstring[128];

	if(Player[playerid][pAdminLevel] >= 5 || IsPlayerAdmin(playerid))
	{
		if(sscanf(params, "ui", targetid, amount))
			return SendClientMessage(playerid, COLOR_LIGHTCYAN, "Syntax: /givemoney [playerid/PartOfName] [amount]");

		if(IsPlayerConnected(targetid))
		{
			if(targetid == playerid)
				return SendClientMessage(playerid, COLOR_NEUTRAL, "You cannot use this command on yourself.");

			SafeGivePlayerMoney(targetid, amount);
			SaveAccount(targetid);

			format(string, sizeof(string), "You have given $%d to %s.", amount, GetName(targetid));
			SendClientMessage(playerid, COLOR_LIGHTBLUE, string);

			format(string, sizeof(string), "Admins %s has given you $%d.", GetName(playerid), amount);
			SendClientMessage(targetid, COLOR_LIGHTBLUE, string);

			gettime(hour, minute, second);
			getdate(year, month, day);

			format(acmdlogstring, sizeof(acmdlogstring), "Command: /givemoney %s %d [%d/%d/%d] [%d:%d:%d]", GetName(targetid), amount, day, month, year, hour, minute, second);
			AdminCommandLog(playerid, acmdlogstring);
		}
		else
			return SendClientMessage(playerid, COLOR_LIGHTNEUTRALBLUE, "The player is not connected!");
	}
	else
		return SendClientMessage(playerid, COLOR_LIGHTNEUTRALBLUE, "You are not authorized to use this command!");
	return 1;
}

CMD:givegun(playerid, params[]) // Gives weapon to a player
{
	new targetid, weapon, ammo, string[128], day, month, year, hour, minute, second, acmdlogstring[128];

	if(Player[playerid][pAdminLevel] >= 5 || IsPlayerAdmin(playerid))
	{
		if(sscanf(params, "uii", targetid, weapon, ammo))
			return SendClientMessage(playerid, COLOR_LIGHTCYAN, "Syntax: /givegun [playerid/PartOfName] [weaponid] [ammo]");

		if(IsPlayerConnected(targetid))
		{
			GivePlayerWeapon(targetid, weapon, ammo);

			format(string, sizeof(string), "You have given weapon ID %d with %d ammo to %s.", weapon, ammo, GetName(targetid));
			SendClientMessage(playerid, COLOR_LIGHTBLUE, string);

			format(string, sizeof(string), "Admins %s has given you weapon ID with %d ammo.", GetName(playerid), weapon, ammo);
			SendClientMessage(targetid, COLOR_LIGHTBLUE, string);

			gettime(hour, minute, second);
			getdate(year, month, day);

			format(acmdlogstring, sizeof(acmdlogstring), "Command: /givegun %s %d %d [%d/%d/%d] [%d:%d:%d]", GetName(targetid), weapon, ammo, day, month, year, hour, minute, second);
			AdminCommandLog(playerid, acmdlogstring);
		}
		else
			return SendClientMessage(playerid, COLOR_LIGHTNEUTRALBLUE, "The player is not connected!");
	}
	else
		return SendClientMessage(playerid, COLOR_LIGHTNEUTRALBLUE, "You are not authorized to use this command!");
	return 1;
}

// ------------------------------------------------------------------------------------------------
CMD:sethp(playerid, params[]) // Sets a player's health to a specific value
{
	new targetid, Float:hp, Float:X, Float:Y, Float:Z, day, month, year, hour, minute, second, acmdlogstring[128], string[128];
	if(Player[playerid][pAdminLevel] >= 4 || IsPlayerAdmin(playerid))
	{
		if(sscanf(params, "ui", targetid, hp))
			return SendClientMessage(playerid, COLOR_LIGHTCYAN, "Syntax: /sethp [playerid/PartOfName] [hp]");

		if(IsPlayerConnected(targetid))
		{
			SetPlayerHealth(targetid, hp);

			GetPlayerPos(targetid, X, Y, Z);
			PlayerPlaySound(targetid, 1133, X, Y, Z);

			gettime(hour, minute, second);
			getdate(year, month, day);

			format(string, sizeof(string), "Admin %s has set your hp to %f", GetName(playerid), hp);
			SendClientMessage(targetid, COLOR_MEDIUMBLUE, string);

			format(string, sizeof(string), "You have set %s's hp to %f", GetName(targetid), hp);
			SendClientMessage(playerid, COLOR_MEDIUMBLUE, string);

			format(acmdlogstring, sizeof(acmdlogstring), "Command: /sethp %s %f [%d/%d/%d] [%d:%d:%d]", GetName(targetid), hp, day, month, year, hour, minute, second);
			AdminCommandLog(playerid, acmdlogstring);
		}
		else
			return SendClientMessage(playerid, COLOR_LIGHTNEUTRALBLUE, "The player is not connected!");
	}
	else
		return SendClientMessage(playerid, COLOR_LIGHTNEUTRALBLUE, "You are not authorized to use this command!");
	return 1;
}

// ------------------------------------------------------------------------------------------------
CMD:cc(playerid, params[])
	return cmd_clearchat(playerid, params);

CMD:clearchat(playerid, params[]) // Clears the chat for every player
{
	new string[128], day, month, year, hour, minute, second, acmdlogstring[128];
	if(Player[playerid][pAdminLevel] >= 4 || IsPlayerAdmin(playerid))
	{
		for(new i = 0; i < 50; i++)
			SendClientMessageToAll(COLOR_WHITE, " ");

		format(string, sizeof(string), "Admin %s cleared the chat.", GetName(playerid));
		SendToAdmins(COLOR_LIGHTBLUE, string);

		gettime(hour, minute, second);
		getdate(year, month, day);

		format(acmdlogstring, sizeof(acmdlogstring), "Command: /cc [%d/%d/%d] [%d:%d:%d]", day, month, year, hour, minute, second);
		AdminCommandLog(playerid, acmdlogstring);
	}
	else
		return SendClientMessage(playerid, COLOR_LIGHTNEUTRALBLUE, "You are not authorized to use this command!");
	return 1;
}

// ------------------------------------------------------------------------------------------------
CMD:jetpack(playerid, params[]) // Gives a jetpack to the player
{
	new day, month, year, hour, minute, second, acmdlogstring[128];

	if(Player[playerid][pAdminLevel] == 6 || IsPlayerAdmin(playerid))
	{
		SetPlayerSpecialAction(playerid, 2);
		SendClientMessage(playerid, COLOR_PINK, "Jetpack added!");

		gettime(hour, minute, second);
		getdate(year, month, day);

		format(acmdlogstring, sizeof(acmdlogstring), "Command: /jetpack [%d/%d/%d] [%d:%d:%d]", day, month, year, hour, minute, second);
		AdminCommandLog(playerid, acmdlogstring);
	}
	else
		return SendClientMessage(playerid, COLOR_LIGHTNEUTRALBLUE, "You are not authorized to use this command!");
	return 1;
}

// ---------------------------------------Player Commands------------------------------------------
CMD:report(playerid, params[]) // Sends a report to admins
{
	new text[256], day, month, year, hour, minute, second, reportstring[128], targetid;
	if(sscanf(params, "s[256]", text))
		return SendClientMessage(playerid, COLOR_LIGHTCYAN, "USAGE: /report [reason]");

	if(GetPVarInt(playerid, "ReportPending") == 1)
		return SendClientMessage(playerid, COLOR_LIGHTCYAN, "You already have a report pending.");

	SetPVarInt(playerid, "ReportPending", 1);
	SetPVarString(playerid, "ReportReason", text);
	SetPVarInt(playerid, "ReportTime", gettime());

	SendClientMessage(playerid, COLOR_YELLOW, "Your report has been sent to admins.");

	format(reportstring, sizeof(reportstring), "%s | %s [%d/%d/%d] [%d:%d:%d]", GetName(targetid), text, day, month, year, hour, minute, second);
	ReportLog(reportstring);
	return 1;
}
