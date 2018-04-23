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
#include <streamer>
#include "colors.pwn"
#include <zcmd>

// ------------------------------------------Defines-----------------------------------------
#define GameMode "NSRP v1.0"

#define ACCOUNT_PATH "accounts/"
#define DEALERSHIP_PATH "dealerships/"
#define VEHICLE_PATH "vehicles/"
#define JOB_FILE_PATH "jobs/"

#define COL_WHITE "{FFFFFF}"
#define COL_RED "{AA3333}"

#define Spawn_X 1685.6904 // Default spawn coordinates (LS International)
#define Spawn_Y -2240.9397
#define Spawn_Z 13.5469

#define MAX_DEALERSHIPS 10
#define MAX_JOB_LIMIT 15

#define MAX_PLAYER_VEHICLES 4
#define MAX_PLAYER_VIP_VEHICLES 8

// ---------------------------------Global Variable Declarations------------------------------
new accountstimer[MAX_PLAYERS];
new mutetimer[MAX_PLAYERS];
new fueltimer[MAX_PLAYERS];
new speedotimer[MAX_PLAYERS];
new healthtimer[MAX_PLAYERS];
new hoursplayedtimer[MAX_PLAYERS];
new paydaytimer[MAX_PLAYERS];

new gobackstatus[MAX_PLAYERS];
new Float:savedposx[MAX_PLAYERS];
new Float:savedposy[MAX_PLAYERS];
new Float:savedposz[MAX_PLAYERS];

new DealershipStatus[MAX_DEALERSHIPS];
new Float:DealershipPosition[MAX_DEALERSHIPS][3];
new DealershipPickup[MAX_DEALERSHIPS];
new Text3D:VehicleLabel[MAX_VEHICLES];

new PlayerText:VehicleMeter[MAX_PLAYERS];
new PlayerText:Speedometer[MAX_PLAYERS];

new Text:Time, Text:Date;

new vehicles;

new IsLoggedIn[MAX_PLAYERS];
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

//Trucker Job System Variables
new Float:checkPositions[][3] = {
	{2206.4895, -2173.9502, 12.9224},
	{2030.8846, -2110.1584, 12.9200},
	{1888.1641, -2102.9700, 13.1015},
	{1779.8054, -2166.1008, 12.9224},
	{1530.3160, -1885.8534, 13.0589}
};

new bool:working[MAX_PLAYERS];
new TrailerID[] = {435, 450, 591};
new r_trailer, r_checkzone = 0, count_work[MAX_PLAYERS] = 0;

//Mechanic Job System Variables
new bool:MechanicServiceRequest[MAX_PLAYERS] = false;
new bool:MechanicRequestGenerated[MAX_PLAYERS] = false;
new RefillPrice[MAX_PLAYERS] = -1;
new MechanicOnService[MAX_PLAYERS] = -1;

//Farmer Job Sytem Variables
new Float:Farm[][3] = {
	{-244.5337, -1374.0824, 10.3107},
	{-270.0924, -1519.5729, 4.6385},
	{-473.8837, -1354.5908, 26.9494}
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
	pBanExp,
	Float:pHoursPlayed,
	pRespectPoints,
	pLevel,
	pJobStatus,
	pJobID,
	pTruckerSkill,
	pMechanicSkill,
	pFarmerSkill,
	pVehicle1,
	pVehicle2,
	pVehicle3,
	pVehicle4,
	pVehicle5,
	pVehicle6,
	pVehicle7,
	pVehicle8
}
new Player[MAX_PLAYERS][PlayerData];

enum VehicleData
{
	vStatus,
	vModel,
	Float:vPosition[3],
	Float:vAngle,
	vColor1,
	vColor2,
	vPrice,
	vOwner[MAX_PLAYER_NAME],
	vInterior,
	vVirtualWorld,
	vCarPlate,
	vMods[14],
	vPaintjob,
	Float:vFuel
}
new Vehicle[MAX_VEHICLES][VehicleData];

enum JobData
{
	JobID,
	JobStatus,
	JobName[128],
	JobLevel,
	Float:JobX,
	Float:JobY,
	Float:JobZ,
	Text3D:JobText,
	JobPickup
}
new Job[MAX_JOB_LIMIT][JobData];

enum TruckData
{
	T_vehicle,
	Trailer,
}
new Truck[MAX_PLAYERS][TruckData];

enum dialogs
{
	DIALOG_LOGIN,
	DIALOG_REGISTER_1,
	DIALOG_REGISTER_2,
	DIALOG_REGISTER_3,

	DIALOG_AHELP,

	DIALOG_BUY_LEVEL,

	DIALOG_BUY_VEHICLE
}

new Float:lowdealershipspawnsX[] = {2161.0, 2161.0, 2161.0, 2161.0, 2161.0, 2161.0, 2147.0, 2147.0, 2147.0, 2147.0, 2147.0, 2147.0};
new Float:lowdealershipspawnsY[] = {-1197.0, -1187.0, -1177.0, -1167.0, -1157.0, -1147.0, -1203.0, -1193.0, -1183.0, -1173.0, -1163.0, -1153.0};
new Float:lowdealershipspawnsZ[] = {23.8801, 23.8203, 23.8203, 23.8203, 23.8203, 24.4088, 23.8463, 23.8341, 23.8341, 23.8341, 23.8341, 23.8341};
new Float:lowdealershipsrots[] = {90.0, 90.0, 90.0, 90.0, 90.0, 90.0, 270.0, 270.0, 270.0, 270.0, 270.0, 270.0};

new lspos = 0;

new Float:vipdealershipspawnsX[] = {-1921.7722, -1921.7722, -1921.7722, -1921.7722, -1921.7722, -1921.7722, -1921.7722};
new Float:vipdealershipspawnsY[] = {279.0, 284.0, 289.0, 294.0, 299.0, 304.0};
new Float:vipdealershipspawnsZ[] = {41.0469, 41.0469, 41.0469, 41.0469, 41.0469, 41.0469};
new Float:vipdealershiprots[] = {240.0, 240.0, 240.0, 240.0, 240.0, 240.0};

new vspos = 0;

native WP_Hash(buffer[], len, const str[]);

// ------------------------------------------Forwards-----------------------------------------
forward LoadAccount(playerid);
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
forward BanLog2(playername[], banstring2[]);
forward IpBanLog(ip[], ipbanstring[]);
forward GotoLog(playerid, gotostring[]);
forward ReportLog(reportstring[]);
forward PMLog(playerid, pmlogstring[]);

forward IsBicycle(vehicleid);
forward IsAirplane(vehicleid);
forward RangeSend(Float:range, playerid, text[], color);

forward UpdateDealership(dealershipid, removeold);
forward SaveDealership(dealershipid);
forward LoadDealerships();
forward IsValidDealership(dealershipid);
forward UpdateVehicle(vehicleid, removeold);
forward IsValidDealershipVehicle(vehicleid);
forward SaveVehicle(vehicleid);
forward LoadVehicles();
forward IsValidCivilianVehicle(vehicleid);
forward LoadJob();
forward IsValidPlayerVehicle(vehicleid);

forward DecreaseFuel(playerid);
forward ToggleEngine(vehicleid, toggle);

forward GetPlayerVehicles(playerid);
forward GetFreeVehicleID();
forward CheckFreePlayerSlot(playerid);

forward DecreaseHealth(playerid);
forward IncreaseHoursPlayed(playerid);
forward Payday(playerid);
forward BuyLevel(playerid);

forward LoadObjects();
forward RemoveObjects(playerid);

forward UpdatePlayerVehicle(vehicleid, removeold);

forward Speedo(playerid, vehicleid);

forward settime(playerid);

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

	LoadDealerships();
	LoadVehicles();
	LoadObjects();
	LoadJob();

	for(new i = 0; i < MAX_JOB_LIMIT; i++)
	{
		UpdateJob(i,0);
	}

	for(new i = 0; i < MAX_DEALERSHIPS; i++)
	{
		UpdateDealership(i, 0);
	}

	for(new i = 1; i < MAX_VEHICLES; i++)
	{
		UpdateVehicle(i, 0);
	}

	SetTimer("settime", 1000, true);
 
	Date = TextDrawCreate(547.000000, 11.000000, "--");
	TextDrawFont(Date, 3);
	TextDrawLetterSize(Date, 0.399999, 1.600000);
	TextDrawColor(Date, 0xffffffff);

	Time = TextDrawCreate(547.000000, 28.000000, "--");
	TextDrawFont(Time, 3);
	TextDrawLetterSize(Time, 0.399999, 1.600000);
	TextDrawColor(Time, 0xffffffff);

	return 1;
}

public OnPlayerConnect(playerid)
{
	TextDrawShowForPlayer(playerid, Time), TextDrawShowForPlayer(playerid, Date);

	TogglePlayerSpectating(playerid, 1);
	CheckAccountExist(playerid);

	hoursplayedtimer[playerid] = SetTimerEx("IncreaseHoursPlayed", 6000, 1, "i", playerid);
	healthtimer[playerid] = SetTimerEx("DecreaseHealth", 30000, 1, "i", playerid);
	paydaytimer[playerid] = SetTimerEx("Payday", 1000, 1, "i", playerid);
	accountstimer[playerid] = SetTimerEx("SaveAccount", 60000, 1, "i", playerid);

	VehicleMeter[playerid] = CreatePlayerTextDraw(playerid, 498.000000, 140.000000, " ");
	PlayerTextDrawBackgroundColor(playerid, VehicleMeter[playerid], 255);
	PlayerTextDrawFont(playerid, VehicleMeter[playerid], 1);
	PlayerTextDrawLetterSize(playerid, VehicleMeter[playerid], 0.389999, 1.299999);
	PlayerTextDrawColor(playerid, VehicleMeter[playerid], 0xFFFFFFFF);
	PlayerTextDrawSetOutline(playerid, VehicleMeter[playerid], 1);
	PlayerTextDrawSetProportional(playerid, VehicleMeter[playerid], 1);


	Speedometer[playerid] = CreatePlayerTextDraw(playerid, 498.000000, 123.000000, " ");
	PlayerTextDrawBackgroundColor(playerid, Speedometer[playerid], 255);
	PlayerTextDrawFont(playerid, Speedometer[playerid], 1);
	PlayerTextDrawLetterSize(playerid, Speedometer[playerid], 0.389999, 1.299999);
	PlayerTextDrawColor(playerid, Speedometer[playerid], 0xFFFFFFFF);
	PlayerTextDrawSetOutline(playerid, Speedometer[playerid], 1);
	PlayerTextDrawSetProportional(playerid, Speedometer[playerid], 1);

	RemoveObjects(playerid);

	for(new i = 1; i < MAX_VEHICLES; i++)
	{
		if(strcmp(Vehicle[i][vOwner], GetName(playerid)) == 0)
			UpdatePlayerVehicle(i, 0);	
	}
	
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
				Player[playerid][pSex] = 1; // Female
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

		case DIALOG_BUY_LEVEL:
		{
			if(response)
			{
				BuyLevel(playerid);
			}
		}

		case DIALOG_BUY_VEHICLE:
		{
			new string[256];

			if(response)
			{
				new vehicleid = GetPlayerVehicleID(playerid);

				new slot = CheckFreePlayerSlot(playerid);

				if(slot == 1)
					Player[playerid][pVehicle1] = GetVehicleModel(vehicleid);
				else if(slot == 2)
					Player[playerid][pVehicle2] = GetVehicleModel(vehicleid);
				else if(slot == 3)
					Player[playerid][pVehicle3] = GetVehicleModel(vehicleid);
				else if(slot == 4)
					Player[playerid][pVehicle4] = GetVehicleModel(vehicleid);
				else if(slot == 5)
					Player[playerid][pVehicle5] = GetVehicleModel(vehicleid);
				else if(slot == 6)
					Player[playerid][pVehicle6] = GetVehicleModel(vehicleid);
				else if(slot == 7)
					Player[playerid][pVehicle7] = GetVehicleModel(vehicleid);
				else if(slot == 8)
					Player[playerid][pVehicle8] = GetVehicleModel(vehicleid);

				SaveAccount(playerid);

				new freeid = GetFreeVehicleID();
				if(!freeid)
				{
					ClearAnimations(playerid, 0);
					RemovePlayerFromVehicle(playerid);
					return SendClientMessage(playerid, COLOR_NEUTRAL, "Vehicle dealership is out of stock.");
				}

				Vehicle[freeid][vStatus] = 1;
				Vehicle[freeid][vOwner] = GetName(playerid);
				Vehicle[freeid][vModel] = GetVehicleModel(vehicleid);
				// Vehicle[freeid][vPosition][0] = vipdealershipspawnsX[vspos];
				// Vehicle[freeid][vPosition][1] = vipdealershipspawnsY[vspos];
				// Vehicle[freeid][vPosition][2] = vipdealershipspawnsZ[vspos];
				// Vehicle[freeid][vAngle] = vipdealershiprots[vspos];

				switch(GetVehicleModel(vehicleid))
				{
					case 412, 534, 535, 536, 566, 567, 575, 576:
					{
						Vehicle[freeid][vPosition][0] = lowdealershipspawnsX[lspos];
						Vehicle[freeid][vPosition][1] = lowdealershipspawnsY[lspos];
						Vehicle[freeid][vPosition][2] = lowdealershipspawnsZ[lspos];
						Vehicle[freeid][vAngle] = lowdealershipsrots[lspos];

						lspos++;
						if(lspos > 11)
							lspos = 0;
					}
				}

				Vehicle[freeid][vColor1] = 1;
				Vehicle[freeid][vColor2] = 1;
				Vehicle[freeid][vPrice] = 0;
				sscanf(Vehicle[freeid][vOwner], "s[128]", GetName(playerid));
				Vehicle[freeid][vInterior] = 0;
				Vehicle[freeid][vVirtualWorld] = 0;
				sscanf(Vehicle[freeid][vCarPlate], "s[128]", "NewCar");
				Vehicle[freeid][vPaintjob] = 3;
				Vehicle[freeid][vFuel] = 100.0;

				UpdatePlayerVehicle(freeid, 0);
				SaveVehicle(freeid);

				format(string, sizeof(string), "Congratulations, you have bought %s for $%d. For more info, use /vhelp.", GetVehicleName(vehicleid), Vehicle[vehicleid][vPrice]);
				SendClientMessage(playerid, COLOR_LIGHTBLUE, string);

				// vspos++;
				// if(vspos > 5)
				// 	vspos = 0;
			}
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

	TextDrawHideForPlayer(playerid, Time), TextDrawHideForPlayer(playerid, Date);
	KillTimer(healthtimer[playerid]);
	KillTimer(mutetimer[playerid]);

	PlayerTextDrawDestroy(playerid, VehicleMeter[playerid]);
	PlayerTextDrawDestroy(playerid, Speedometer[playerid]);

	SaveAccount(playerid);

	for(new i = 1; i < MAX_VEHICLES; i++)
	{
		if(IsValidPlayerVehicle(i) && strcmp(Vehicle[i][vOwner], GetName(playerid)))
			DestroyVehicle(i);
	}
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
		SendClientMessage(playerid, COLOR_LIGHTNEUTRALBLUE, "You cannot say anything because you are muted by the admins.");
		return 0;
	}

	format(string, sizeof(string), "%s says: %s", GetName(playerid), text);
	RangeSend(30.0, playerid, string, COLOR_WHITE);
	return 0;
}

public OnPlayerPickUpPickup(playerid, pickupid)
{
	for(new i = 0; i < MAX_DEALERSHIPS; i++)
		if(pickupid == DealershipPickup[i])
		{
			if(i == 0)
				GameTextForPlayer(playerid, "Lowrider Dealership", 1000, 1);
			else if(i == 1)
				GameTextForPlayer(playerid, "Luxury Dealership", 1000, 1);
			else if(i == 2)
				GameTextForPlayer(playerid, "Airplane Dealership", 1000, 1);
			else if(i == 3)
				GameTextForPlayer(playerid, "Sea Dealership", 1000, 1);
			else if(i == 4)
				GameTextForPlayer(playerid, "Offroad Dealership", 1000, 1);
			else if(i == 5)
				GameTextForPlayer(playerid, "Bikes Dealership", 1000, 1);
			else if(i == 6)
				GameTextForPlayer(playerid, "Standard Dealership", 1000, 1);
			else if(i == 7)
				GameTextForPlayer(playerid, "Special Dealership", 1000, 1);
		}
	return 1;
}

public OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
	new engine, lights, alarm, doors, bonnet, boot, objective, string[128];
	new vid = GetPlayerVehicleID(playerid);

	if(newkeys & KEY_SUBMISSION)
	{
		if(IsBicycle(vid) == 1)
			return 1;

		if(GetPlayerVehicleSeat(playerid) == 0 && IsAirplane(vid) == 0)
		{
			GetVehicleParamsEx(vid, engine, lights, alarm, doors, bonnet, boot, objective);

			if(engine == 1)
			{
				engine = 0;
				format(string, sizeof(string), "%s stops the engine of a %s.", GetName(playerid), GetVehicleName(vid));
				RangeSend(30.0, playerid, string, COLOR_PINK);
			}
			else
			{
				if(Vehicle[vid][vFuel] > 0)
				{
					engine = 1;
					format(string, sizeof(string), "%s starts the engine of a %s.", GetName(playerid), GetVehicleName(vid));
					RangeSend(30.0, playerid, string, COLOR_PINK);
				}
				else
					SendClientMessage(playerid, COLOR_LIGHTCYAN, "Your vehicle is out of fuel.");
			}

			SetVehicleParamsEx(vid, engine, lights, alarm, doors, bonnet, boot, objective);
		}
	}

	if(newkeys & KEY_ACTION)
	{
		if(IsBicycle(vid) == 1)
			return 1;

		if(GetPlayerVehicleSeat(playerid) == 0 && IsAirplane(vid) == 0)
		{
			GetVehicleParamsEx(vid, engine, lights, alarm, doors, bonnet, boot, objective);

			if(lights == 1)
				lights = 0;
			else
				lights = 1;

			SetVehicleParamsEx(vid, engine, lights, alarm, doors, bonnet, boot, objective);
		}
	}
	return 1;
}

public OnPlayerStateChange(playerid, newstate, oldstate)
{
	new string[128];
	new vid = GetPlayerVehicleID(playerid);
	new engine, lights, alarm, doors, bonnet, boot, objective;

	GetVehicleParamsEx(vid, engine, lights, alarm, doors, bonnet, boot, objective);

	if(newstate == PLAYER_STATE_DRIVER)
	{
		KillTimer(fueltimer[playerid]);
		KillTimer(speedotimer[playerid]);

		PlayerTextDrawShow(playerid, VehicleMeter[playerid]);
		PlayerTextDrawShow(playerid, Speedometer[playerid]);

		fueltimer[playerid] = SetTimerEx("DecreaseFuel", 1000, 1, "ii", playerid, vid);
		speedotimer[playerid] = SetTimerEx("Speedo", 500, 1, "ii", playerid, vid);

		if(IsBicycle(vid))
			ToggleEngine(vid, VEHICLE_PARAMS_ON);

		if(Vehicle[vid][vPrice] == 0 && engine == 0 && IsBicycle(vid) == 0 && IsAirplane(vid) == 0)
			SendClientMessage(playerid, COLOR_WHITE, "To turn the engine on, press 2 or type /engine.");

		if(Vehicle[vid][vPrice] > 0)
		{
			if(Player[playerid][pCash] >= Vehicle[vid][vPrice])
			{
				if(Player[playerid][pVipLevel] > 0)
				{
					if(GetPlayerVehicles(playerid) >= MAX_PLAYER_VIP_VEHICLES)
					{
						ClearAnimations(playerid, 0);
						RemovePlayerFromVehicle(playerid);
						return SendClientMessage(playerid, COLOR_NEUTRAL, "You cannot buy more vehicles.");
					}
				}
				else
				{
					if(GetPlayerVehicles(playerid) >= MAX_PLAYER_VEHICLES)
					{
						ClearAnimations(playerid, 0);
						RemovePlayerFromVehicle(playerid);
						return SendClientMessage(playerid, COLOR_NEUTRAL, "You cannot buy more vehicles. Upgrade to a VIP account to buy more vehicles.");
					}
				}

				ShowPlayerDialog(playerid, DIALOG_BUY_VEHICLE, DIALOG_STYLE_MSGBOX, "Buy Vehicle", "Do you want to buy this vehicle?\nPress escape to cancel.", "Buy Vehicle", "Test Drive");
			}
			else
			{
				ClearAnimations(playerid, 0);
				RemovePlayerFromVehicle(playerid);
				format(string, sizeof(string), "You need at least $%d to buy %s.", Vehicle[vid][vPrice], GetVehicleName(vid));
				return SendClientMessage(playerid, COLOR_NEUTRAL, string);
			}
		}
	}
	else
	{
		PlayerTextDrawHide(playerid, VehicleMeter[playerid]);
		PlayerTextDrawHide(playerid, Speedometer[playerid]);
		KillTimer(fueltimer[playerid]);
		KillTimer(speedotimer[playerid]);
	}
	return 1;
}

public OnPlayerEnterVehicle(playerid, vehicleid, ispassenger)
{
	GameTextForPlayer(playerid, GetVehicleName(vehicleid), 750, 1);
	KillTimer(fueltimer[playerid]);
	return 1;
}

public OnPlayerEnterCheckpoint(playerid)
{
	if(working[playerid] && Player[playerid][pJobID] == 0)
	{
		if(IsTrailerAttachedToVehicle(Truck[playerid][T_vehicle]))
		{
			new Float:j1, Float:j2, Float:j3, Float:rotation;

			if(count_work[playerid] > 1)
			{
				SafeGivePlayerMoney(playerid, 1000);
			}
				
			count_work[playerid]++;
				
			r_trailer = random(3);
			GetVehiclePos(Truck[playerid][Trailer], j1, j2, j3);
			DestroyVehicle(Truck[playerid][Trailer]);
			rotation = GetVehicleRotation(Truck[playerid][T_vehicle]);
			DetachTrailerFromVehicle(Truck[playerid][T_vehicle]);

			DisablePlayerCheckpoint(playerid);

			Truck[playerid][Trailer] = CreateVehicle(TrailerID[r_trailer], j1, j2, j3, rotation - 20 , random(256), random(256), -1);
				
			AttachTrailerToVehicle(Truck[playerid][Trailer], Truck[playerid][T_vehicle]);

			SetPlayerCheckpoint(playerid, checkPositions[r_checkzone][0], checkPositions[r_checkzone][1], checkPositions[r_checkzone][2], 10.0);
			r_checkzone++;

			SendClientMessage(playerid, COLOR_NEUTRAL, "Attach the trailer and move on to next checkpoint.");
		
		}
		else
		{
			SendClientMessage(playerid, COLOR_YELLOW, "Where's your Trailer dude?");
		}
	}

	if(Player[playerid][pJobID] == 2)
	{
		Float:ang, Float:x, Float:y, Float:z;
		GetPlayerFacingAngle(playerid, &ang);
		GetPlayerPos(playerid, x, y, z);
		CreateVehicle(531 + random(1), x, y, z, ang, random(256), random(256), -1);
	}
	return 1;
}

public OnPlayerExitVehicle(playerid, vehicleid)
{
	KillTimer(fueltimer[playerid]);
	if(working[playerid] && Player[playerid][pJobID] == 0)
	{
		new string[128];
		working[playerid] = false;
		DisablePlayerCheckpoint(playerid);
		DestroyVehicle(Truck[playerid][T_vehicle]);
		DestroyVehicle(Truck[playerid][Trailer]);

		format(string, sizeof(string), "You have done %d trucking jobs.", count_work[playerid]);
		SendClientMessage(playerid, COLOR_YELLOW, string);

		count_work[playerid] = 0;
		r_checkzone = 0;
	}
	return 1;
}

stock FarmerWork(playerid)
{
	MoneyTimer = SetTimer("SafeGivePlayerMoney", 2000, true, playerid, 1000);
public OnVehicleSpawn(vehicleid)
{
	if(Vehicle[vehicleid][vPrice] == 0 && strcmp(Vehicle[vehicleid][vOwner], "0") == 0)
		Vehicle[vehicleid][vFuel] = 100.0;
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

stock GetVehicleModelIDFromName(const vname[]) // Returns vehicle's model id from vehicle name
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
	SetPlayerScore(playerid, 1);
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
	Player[playerid][pHoursPlayed] = 0;
	Player[playerid][pLevel] = 1;
	Player[playerid][pVehicle1] = 0;
	Player[playerid][pVehicle2] = 0;
	Player[playerid][pVehicle3] = 0;
	Player[playerid][pVehicle4] = 0;
	Player[playerid][pVehicle5] = 0;
	Player[playerid][pVehicle6] = 0;
	Player[playerid][pVehicle7] = 0;
	Player[playerid][pVehicle8] = 0;

	new hour, minute, second;
	new year, month, day;

	gettime(hour, minute, second);
	getdate(year, month, day);

	format(registerstring, sizeof(registerstring), "%s has registered. [%d/%d/%d] [%d:%d:%d]", GetName(playerid), day, month, year, hour, minute, second);
	RegisterLog(registerstring);

	TogglePlayerSpectating(playerid, 0);

	SetSpawnInfo(playerid, 0, Player[playerid][pSkin], Spawn_X, Spawn_Y, Spawn_Z, 180, -1, -1, -1, -1, -1, -1);
	SpawnPlayer(playerid);

	IsLoggedIn[playerid] = 1;

	SaveAccount(playerid);
	SendClientMessage(playerid, COLOR_GREEN, "You have successfully registered!");
	return 1;
}

public SaveAccount(playerid) // Saves the information to the .ini file
{
	if(IsPlayerConnected(playerid) && IsLoggedIn[playerid] == 1)
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

		format(line, sizeof(line), "HoursPlayed=%.1f\r\n", Player[playerid][pHoursPlayed]);
		fwrite(handle, line);

		format(line, sizeof(line), "Level=%d\r\n", Player[playerid][pLevel]);
		fwrite(handle, line);

		format(line, sizeof(line), "RespectPoints=%d\r\n", Player[playerid][pRespectPoints]);
		fwrite(handle, line);
	
		format(line, sizeof(line), "JobStatus=%d\r\n", Player[playerid][pJobStatus]);
	  	fwrite(handle, line);

	  	format(line, sizeof(line), "JobID=%d\r\n", Player[playerid][pJobID]);
	  	fwrite(handle, line);

	  	format(line, sizeof(line), "TruckerSkill=%d\r\n", Player[playerid][pTruckerSkill]);
	  	fwrite(handle, line);

	  	format(line, sizeof(line), "MechanicSkill=%d\r\n", Player[playerid][pMechanicSkill]);
	  	fwrite(handle, line);

		format(line, sizeof(line), "Vehicle1=%d\r\n", Player[playerid][pVehicle1]);
		fwrite(handle, line);

		format(line, sizeof(line), "Vehicle2=%d\r\n", Player[playerid][pVehicle2]);
		fwrite(handle, line);

		format(line, sizeof(line), "Vehicle3=%d\r\n", Player[playerid][pVehicle3]);
		fwrite(handle, line);

		format(line, sizeof(line), "Vehicle4=%d\r\n", Player[playerid][pVehicle4]);
		fwrite(handle, line);

		format(line, sizeof(line), "Vehicle5=%d\r\n", Player[playerid][pVehicle5]);
		fwrite(handle, line);

		format(line, sizeof(line), "Vehicle6=%d\r\n", Player[playerid][pVehicle6]);
		fwrite(handle, line);

		format(line, sizeof(line), "Vehicle7=%d\r\n", Player[playerid][pVehicle7]);
		fwrite(handle, line);

		format(line, sizeof(line), "Vehicle8=%d\r\n", Player[playerid][pVehicle8]);
		fwrite(handle, line);

		fclose(handle);
	}
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
		else if(strcmp(key, "HoursPlayed") == 0)
			sscanf(line[s], "f", Player[playerid][pHoursPlayed]);
		else if(strcmp(key, "Level") == 0)
			Player[playerid][pLevel] = strval(line[s]);
		else if(strcmp(key, "RespectPoints") == 0)
			Player[playerid][pRespectPoints] = strval(line[s]);
		else if(strcmp(key, "JobStatus") == 0)
			Player[playerid][pJobStatus] = strval(line[s]);
		else if(strcmp(key, "JobID") == 0)
			Player[playerid][pJobID] = strval(line[s]);
		else if(strcmp(key, "TruckerSkill") == 0)
			Player[playerid][pTruckerSkill] = strval(line[s]);
		else if(strcmp(key, "MechanicSkill") == 0)
			Player[playerid][pMechanicSkill] = strval(line[s]);
      else if(strcmp(key, "FarmingSkill") == 0)
			Player[playerid][pFarmingSkill] = strval(line[s]);
		else if(strcmp(key, "Vehicle1") == 0)
			Player[playerid][pVehicle1] = strval(line[s]);
		else if(strcmp(key, "Vehicle2") == 0)
			Player[playerid][pVehicle2] = strval(line[s]);
		else if(strcmp(key, "Vehicle3") == 0)
			Player[playerid][pVehicle3] = strval(line[s]);
		else if(strcmp(key, "Vehicle4") == 0)
			Player[playerid][pVehicle4] = strval(line[s]);
		else if(strcmp(key, "Vehicle5") == 0)
			Player[playerid][pVehicle5] = strval(line[s]);
		else if(strcmp(key, "Vehicle6") == 0)
			Player[playerid][pVehicle6] = strval(line[s]);
		else if(strcmp(key, "Vehicle7") == 0)
			Player[playerid][pVehicle7] = strval(line[s]);
		else if(strcmp(key, "Vehicle8") == 0)
			Player[playerid][pVehicle8] = strval(line[s]);
	}
	fclose(handle);

	BanCheck(playerid);

	SafeSetPlayerMoney(playerid, Player[playerid][pCash]);
	SetPlayerScore(playerid, Player[playerid][pLevel]);

	TogglePlayerSpectating(playerid, 0);

	SetSpawnInfo(playerid, 0, Player[playerid][pSkin], Spawn_X, Spawn_Y, Spawn_Z, 180, -1, -1, -1, -1, -1, -1);
	SpawnPlayer(playerid);

	SendClientMessage(playerid, COLOR_GREEN, "You have successfully logged in.");

	IsLoggedIn[playerid] = 1;

	if(Player[playerid][pIsMuted] == 1)
		mutetimer[playerid] = SetTimerEx("DecMuteTime", 1000, 1, "i", playerid);

	return 1;
}

public DecMuteTime(playerid) // Decreases mute time of player by 1 second
{
	new day, month, year, hour, minute, second, mutestring[128];
	Player[playerid][pMuteTime]--;

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

public IsBicycle(vehicleid) // Checks if the vehicle is a bicyle
{
	switch(GetVehicleModel(vehicleid))
	{
		case 481,509,510:
			return 1;
	}
	return 0;
}

public IsAirplane(vehicleid) // Checks if the vehicle is an airplane
{
	switch(GetVehicleModel(vehicleid))
	{
		case 417,425,447,460,469,476,487,488,497,511,512,513,519,520,548,553,563,577,592,593:
			return 1;
	}
	return 0;
}

public RangeSend(Float:range, playerid, text[], color) // Sends a message to a specific range
{
	new Float:px, Float:py, Float:pz;

	GetPlayerPos(playerid, px, py, pz);

	for(new i = 0; i < MAX_PLAYERS; i++)
	{
		if(IsPlayerConnected(i))
		{
			if(GetPlayerVirtualWorld(playerid) == GetPlayerVirtualWorld(i))
			{
				if(IsPlayerInRangeOfPoint(i, range, px, py, pz))
					SendClientMessage(i, color, text);
			}
		}
	}
	return 1;
}

public UpdateDealership(dealershipid, removeold) // Updates dealership data and creates pickup and icon
{
	if(DealershipStatus[dealershipid] == 1)
	{
		if(removeold == 1)
			DestroyPickup(DealershipPickup[dealershipid]);
		DealershipPickup[dealershipid] = CreatePickup(1239, 1, DealershipPosition[dealershipid][0], DealershipPosition[dealershipid][1], DealershipPosition[dealershipid][2]);
	}
	return 1;
}

public SaveDealership(dealershipid) // Saves dealership data to .ini file
{
	new filename[64], line[256];

	format(filename, sizeof(filename), DEALERSHIP_PATH "d%d.ini", dealershipid);

	new File:handle = fopen(filename, io_write);

	format(line, sizeof(line), "Status=%d\r\n", DealershipStatus[dealershipid]);
	fwrite(handle, line);

	format(line, sizeof(line), "Position=%f, %f, %f\r\n", DealershipPosition[dealershipid][0], DealershipPosition[dealershipid][1], DealershipPosition[dealershipid][2]);
	fwrite(handle, line);

	fclose(handle);
}

public LoadDealerships() // Loads dealership data from .ini file
{
	new File:handle, count;
	new filename[64], line[256], s, key[64];
	for(new i = 0; i < MAX_DEALERSHIPS; i++)
	{
		format(filename, sizeof(filename), DEALERSHIP_PATH "d%d.ini", i);

		if(!fexist(filename))
			continue;

		handle = fopen(filename, io_read);
		while(fread(handle, line))
		{
			StripNL(line);
			s = strfind(line, "=");

			if(!line[0] || s < 1)
				continue;

			strmid(key, line, 0, s++);
			if(strcmp(key, "Status") == 0)
				DealershipStatus[i] = strval(line[s]);
			else if(strcmp(key, "Position") == 0)
				sscanf(line[s], "p<,>fff", DealershipPosition[i][0], DealershipPosition[i][1], DealershipPosition[i][2]);
		}
		fclose(handle);
		if(DealershipStatus[i])
			count++;
	}
	printf("  Loaded %d dealerships", count);
}

public IsValidDealership(dealershipid) // Checks if a dealership exists and returns 1
{
	if(DealershipStatus[dealershipid] == 1)
		return 1;
	return 0;
}

public IsValidDealershipVehicle(vehicleid) // Checks if a dealership exists and returns 1
{
	if(Vehicle[vehicleid][vStatus] == 1 && Vehicle[vehicleid][vPrice] > 0)
		return 1;
	return 0;
}

public IsValidCivilianVehicle(vehicleid) // Checks if a dealership exists and returns 1
{
	if(Vehicle[vehicleid][vStatus] == 1 && Vehicle[vehicleid][vPrice] == 0 && strcmp(Vehicle[vehicleid][vOwner], "0") == 0)
		return 1;
	return 0;
}

public UpdateVehicle(vehicleid, removeold) // Updates vehicle data and creates label
{
	new vid, string[256];

	if(Vehicle[vehicleid][vStatus] == 1)
	{
		if(removeold == 1)
		{
			DestroyVehicle(vehicleid);
			DestroyDynamic3DTextLabel(VehicleLabel[vehicleid]);
		}

		if(IsValidCivilianVehicle(vehicleid) == 1)
		{
			vid = CreateVehicle(Vehicle[vehicleid][vModel], Vehicle[vehicleid][vPosition][0], Vehicle[vehicleid][vPosition][1], Vehicle[vehicleid][vPosition][2], Vehicle[vehicleid][vAngle], random(128), random(128), 900);

			LinkVehicleToInterior(vid, Vehicle[vehicleid][vInterior]);
			SetVehicleVirtualWorld(vid, Vehicle[vehicleid][vVirtualWorld]);

			for(new i = 0; i < 14; i++)
			{
				AddVehicleComponent(vid, Vehicle[vehicleid][vMods][i]);
			}

			ChangeVehiclePaintjob(vid, Vehicle[vehicleid][vPaintjob]);
			return 1;
		}
		else if(IsValidDealershipVehicle(vehicleid) == 1)
		{
			vid = CreateVehicle(Vehicle[vehicleid][vModel], Vehicle[vehicleid][vPosition][0], Vehicle[vehicleid][vPosition][1], Vehicle[vehicleid][vPosition][2], Vehicle[vehicleid][vAngle], 128 + random(128), 128 + random(128), 60);

			LinkVehicleToInterior(vid, Vehicle[vehicleid][vInterior]);
			SetVehicleVirtualWorld(vid, Vehicle[vehicleid][vVirtualWorld]);

			for(new i = 0; i < 14; i++)
			{
				AddVehicleComponent(vid, Vehicle[vehicleid][vMods][i]);
			}

			ChangeVehiclePaintjob(vid, Vehicle[vehicleid][vPaintjob]);

			format(string, sizeof(string), "%s\nPrice: $%d", GetVehicleName(vid), Vehicle[vehicleid][vPrice]);
			VehicleLabel[vid] = CreateDynamic3DTextLabel(string, COLOR_PINK, Vehicle[vehicleid][vPosition][0], Vehicle[vehicleid][vPosition][1], Vehicle[vehicleid][vPosition][2], 20.0, INVALID_PLAYER_ID, vid, 0, Vehicle[vehicleid][vVirtualWorld], Vehicle[vehicleid][vInterior], -1, 20.0);
		}
	}
	return 1;
}

public SaveVehicle(vehicleid) // Saves vehicle data to .ini file
{
	new filename[64], line[256];

	format(filename, sizeof(filename), VEHICLE_PATH "v%d.ini", vehicleid);

	new File:handle = fopen(filename, io_write);

	format(line, sizeof(line), "Status=%d\r\n", Vehicle[vehicleid][vStatus]);
	fwrite(handle, line);

	format(line, sizeof(line), "Model=%d\r\n", Vehicle[vehicleid][vModel]);
	fwrite(handle, line);

	format(line, sizeof(line), "Position=%f, %f, %f\r\n", Vehicle[vehicleid][vPosition][0], Vehicle[vehicleid][vPosition][1], Vehicle[vehicleid][vPosition][2]);
	fwrite(handle, line);

	format(line, sizeof(line), "Angle=%f\r\n", Vehicle[vehicleid][vAngle]);
	fwrite(handle, line);

	format(line, sizeof(line), "Color1=%d\r\n", Vehicle[vehicleid][vColor1]);
	fwrite(handle, line);

	format(line, sizeof(line), "Color2=%d\r\n", Vehicle[vehicleid][vColor2]);
	fwrite(handle, line);

	format(line, sizeof(line), "Price=%d\r\n", Vehicle[vehicleid][vPrice]);
	fwrite(handle, line);

	format(line, sizeof(line), "Owner=%s\r\n", Vehicle[vehicleid][vOwner]);
	fwrite(handle, line);

	format(line, sizeof(line), "Interior=%d\r\n", Vehicle[vehicleid][vInterior]);
	fwrite(handle, line);

	format(line, sizeof(line), "VW=%d\r\n", Vehicle[vehicleid][vVirtualWorld]);
	fwrite(handle, line);

	format(line, sizeof(line), "CarPlate=%s\r\n", Vehicle[vehicleid][vCarPlate]);
	fwrite(handle, line);

	format(line, sizeof(line), "Paintjob=%d\r\n", Vehicle[vehicleid][vPaintjob]);
	fwrite(handle, line);

	format(line, sizeof(line), "Fuel=%f\r\n", Vehicle[vehicleid][vFuel]);
	fwrite(handle, line);

	for(new m = 0; m < 14; m++)
	{
		format(line, sizeof(line), "Mod%d=%d\r\n", Vehicle[vehicleid][vMods][m]);
		fwrite(handle, line);
	}

	fclose(handle);
}

public LoadVehicles() // Loads vehicle data from .ini file
{
	new File:handle, count;
	new filename[64], line[256], s, key[64];
	for(new i = 1; i < MAX_VEHICLES; i++)
	{
		format(filename, sizeof(filename), VEHICLE_PATH "v%d.ini", i);

		if(!fexist(filename))
			continue;

		handle = fopen(filename, io_read);
		while(fread(handle, line))
		{
			StripNL(line);
			s = strfind(line, "=");

			if(!line[0] || s < 1)
				continue;

			strmid(key, line, 0, s++);
			if(strcmp(key, "Status") == 0)
				Vehicle[i][vStatus] = strval(line[s]);
			else if(strcmp(key, "Model") == 0)
				Vehicle[i][vModel] = strval(line[s]);
			else if(strcmp(key, "Position") == 0)
				sscanf(line[s], "p<,>fff", Vehicle[i][vPosition][0], Vehicle[i][vPosition][1], Vehicle[i][vPosition][2]);
			else if(strcmp(key, "Angle") == 0)
				sscanf(line[s], "f", Vehicle[i][vAngle]);
			else if(strcmp(key, "Color1") == 0)
				sscanf(line[s], "i", Vehicle[i][vColor1]);
			else if(strcmp(key, "Color2") == 0)
				sscanf(line[s], "i", Vehicle[i][vColor2]);
			else if(strcmp(key, "Interior") == 0)
				Vehicle[i][vInterior] = strval(line[s]);
			else if(strcmp(key, "VW") == 0)
				Vehicle[i][vVirtualWorld] = strval(line[s]);
			else if(strcmp(key, "Price") == 0)
				Vehicle[i][vPrice] = strval(line[s]);
			else if(strcmp(key, "Owner") == 0)
				sscanf(line[s], "s[128]", Vehicle[i][vOwner]);
			else if(strcmp(key, "vCarPlate") == 0)
				sscanf(line[s], "s[128]", Vehicle[i][vCarPlate]);
			else if(strcmp(key, "Fuel") == 0)
				sscanf(line[s], "f", Vehicle[i][vFuel]);
		}
		fclose(handle);
		if(Vehicle[i][vStatus] == 1)
			count++;
	}
	printf("  Loaded %d vehicles", count);
	vehicles = count;
}

public DecreaseFuel(playerid) // Decreases fuel by 0.035
{
	new engine, lights, alarm, doors, bonnet, boot, objective, string[128];

	if(GetPlayerState(playerid) == PLAYER_STATE_DRIVER || GetPlayerState(playerid) == PLAYER_STATE_PASSENGER)
	{
		new vehicleid = GetPlayerVehicleID(playerid);

		GetVehicleParamsEx(vehicleid, engine, lights, alarm, doors, bonnet, boot, objective);

		if(IsBicycle(vehicleid) == 0 && IsValidDealershipVehicle(vehicleid) == 0 && engine == 1)
		{
			if(Vehicle[vehicleid][vFuel] <= 0)
			{
				ToggleEngine(vehicleid, VEHICLE_PARAMS_OFF);
				SendClientMessage(playerid, COLOR_INDIGO, "Your vehicle is out of fuel.");
				KillTimer(fueltimer[playerid]);
			}

			format(string, sizeof(string), "Fuel: %d%%", floatround(Vehicle[vehicleid][vFuel]));
			PlayerTextDrawSetString(playerid, VehicleMeter[playerid], string);
			// Vehicle[vehicleid][vFuel] -= 0.035;
			Vehicle[vehicleid][vFuel] -= GetPlayerSpeed(playerid, true)/1000.0;
		}
	}
	return 1;
}

public ToggleEngine(vehicleid, toggle) // Toggles engine on or off
{
	new engine, lights, alarm, doors, bonnet, boot, objective;
	GetVehicleParamsEx(vehicleid, engine, lights, alarm, doors, bonnet, boot, objective);
	SetVehicleParamsEx(vehicleid, toggle, lights, alarm, doors, bonnet, boot, objective);
	return 1;
}

public DecreaseHealth(playerid) // Decreases player health by 1
{
	new Float:health;
	
	if(IsPlayerConnected(playerid) && IsLoggedIn[playerid] == 1)
	{
		GetPlayerHealth(playerid, health);
		SetPlayerHealth(playerid, health - 1);
	}
	return 1;
}

public IncreaseHoursPlayed(playerid) // Increases total hours played by 0.1
{
	Player[playerid][pHoursPlayed] += 0.1;
	SaveAccount(playerid);
	return 1;
}

public Payday(playerid) // Gives payday at every 00 minutes and 00 seconds
{
	new hour, minute, second, paycheck, string[256], bonus, tax;
	gettime(hour, minute, second);

	if(minute == 0 && second == 0)
	{
		paycheck = GetPlayerScore(playerid) * 25;
		bonus = Player[playerid][pVipLevel] * 5;
		tax = GetPlayerScore(playerid) * 1;

		GameTextForPlayer(playerid, "PayDay", 1500, 1);

		SendClientMessage(playerid, COLOR_WHITE, "__________PAYDAY PAYCHECK__________");
		format(string, sizeof(string), "Paycheck: $%d Bonus: $%d Tax: -$%d", paycheck, bonus, tax);
		SendClientMessage(playerid, COLOR_WHITE, string);

		SafeGivePlayerMoney(playerid, (paycheck + bonus) - tax);

		Player[playerid][pRespectPoints]++;
		SaveAccount(playerid);

		if(Player[playerid][pRespectPoints] == (GetPlayerScore(playerid) * 4) - 2)
		{
			SendClientMessage(playerid, COLOR_KHAKI, "You have obtained enough respect points to buy the next level.");
			SendClientMessage(playerid, COLOR_KHAKI, "Use /buylevel to buy the next level.");
		}
	}
}

public BuyLevel(playerid) // Gives next level to the player
{
	new string[128];
	new totalneeded = (GetPlayerScore(playerid) * 4) - 2;
	new nextlevel = GetPlayerScore(playerid) * 250;

	if(Player[playerid][pVipLevel] > 0)
		Player[playerid][pRespectPoints] = Player[playerid][pRespectPoints] - totalneeded;
	else
		Player[playerid][pRespectPoints] = 0;

	Player[playerid][pLevel]++;
	SafeGivePlayerMoney(playerid, -nextlevel);
	SaveAccount(playerid);

	SetPlayerScore(playerid, Player[playerid][pLevel]);
	format(string, sizeof(string), "Congratulations, you are now level %d.", Player[playerid][pLevel]);
	SendClientMessage(playerid, COLOR_PINK, string);
	return 1;
}

public LoadObjects() // Loads objects in the server
{
	CreateObject(984, 1106.66589, -1757.76599, 13.19675,   0.00000, 0.00000, 0.00000);
	CreateObject(984, 1106.68506, -1775.36682, 13.18836,   0.00000, 0.00000, 0.00000);
	CreateObject(984, 1054.06287, -1797.92993, 13.41897,   0.00000, 0.00000, 0.30301);
	CreateObject(984, 1060.48767, -1804.33850, 13.31967,   0.24000, -0.66000, 90.29993);
	CreateObject(984, 1078.02820, -1804.26099, 13.26337,   0.24000, -0.66000, 90.29993);
	CreateObject(984, 1100.40820, -1730.86157, 13.44559,   0.00000, 0.00000, 90.06003);
	CreateObject(984, 1060.42139, -1730.97778, 13.44559,   0.00000, 0.00000, 90.46606);
	CreateObject(984, 1074.81982, -1730.88879, 13.44559,   0.00000, 0.00000, 90.06003);
	CreateObject(984, 1087.63110, -1730.87769, 13.44559,   0.00000, 0.00000, 90.06003);
	CreateObject(984, 1087.63110, -1730.87769, 13.44559,   0.00000, 0.00000, 90.06003);
	CreateObject(647, 1115.87085, -1776.95850, 13.97656,   356.85840, 0.00000, -0.10463);
	CreateObject(647, 1109.56116, -1777.57495, 13.97656,   356.85840, 0.00000, -0.10463);
	CreateObject(984, 1106.66150, -1762.56409, 13.18836,   0.00000, 0.00000, 0.00000);
	CreateObject(984, 1062.01306, -1730.97021, 13.44559,   0.00000, 0.00000, 90.46606);
	CreateObject(984, 1054.02734, -1737.43018, 13.41897,   0.00000, 0.00000, 0.00000);
	CreateObject(984, 1054.01306, -1750.22668, 13.41897,   0.00000, 0.00000, 0.00000);
	CreateObject(984, 1054.00940, -1763.02649, 13.41897,   0.00000, 0.00000, 0.00000);
	CreateObject(984, 1054.00061, -1775.81543, 13.41897,   0.00000, 0.00000, 0.00000);
	CreateObject(984, 1054.01770, -1788.60730, 13.41897,   0.00000, 0.00000, 0.30301);
	CreateObject(984, 1065.23022, -1804.32007, 13.31967,   0.24000, -0.66000, 90.29993);
	CreateObject(1290, 1101.95923, -1777.39624, 18.57813,   356.85840, 0.00000, 3.14159);
	CreateObject(1290, 1058.68689, -1756.64636, 18.57813,   356.85840, 0.00000, 3.14159);
	CreateObject(1290, 1101.93628, -1735.52417, 18.57813,   356.85840, 0.00000, 3.14159);
	CreateObject(1290, 1059.03528, -1735.62463, 18.57813,   356.85840, 0.00000, 3.14159);
	CreateObject(1290, 1081.92871, -1735.70447, 18.57813,   356.85840, 0.00000, 3.14159);
	CreateObject(1290, 1059.07947, -1777.46460, 18.57813,   356.85840, 0.00000, 3.14159);

	CreateObject(8168, 1615.58301, 644.86877, 11.65614,   0.00000, 0.00000, 106.55999);
	CreateObject(1232, -2929.48022, 435.22589, 6.59930,   356.85840, 0.00000, 3.14159);
	CreateObject(1232, -2864.85498, 417.76968, 6.59930,   356.85840, 0.00000, 3.14159);
	CreateObject(1232, -2864.63818, 435.35443, 6.59930,   356.85840, 0.00000, 3.14159);
	CreateObject(1232, -2926.80737, 418.13971, 6.59930,   356.85840, 0.00000, 3.14159);
	CreateObject(8168, -2864.22925, 505.14557, 5.74485,   0.00000, 0.00000, 16.56001);
	CreateObject(19313, -2868.21436, 486.94171, 3.87600,   0.00000, -180.00000, 0.00000);
	CreateObject(19313, -2924.18335, 486.89532, 3.87600,   0.00000, -180.00000, 0.00000);
	CreateObject(19313, -2910.19775, 486.90952, 3.87600,   0.00000, -180.00000, 0.00000);
	CreateObject(19313, -2896.21655, 486.91205, 3.87600,   0.00000, -180.00000, 0.00000);
	CreateObject(19313, -2882.19824, 486.92218, 3.87600,   0.00000, -180.00000, 0.00000);

	CreateObject(3465, 603.48438, 1707.23438, 7.50950,   0.00000, 0.00000, -54.12000);
	CreateObject(3465, 620.53131, 1682.46094, 7.50950,   0.00000, 0.00000, -54.12000);
	CreateObject(3465, 606.90430, 1702.22705, 7.50955,   0.00000, 0.00000, -54.12000);
	CreateObject(3465, 610.25000, 1697.26563, 7.50950,   0.00000, 0.00000, -54.12000);
	CreateObject(3465, 613.71881, 1692.26563, 7.50950,   0.00000, 0.00000, -54.12000);
	CreateObject(3465, 617.10425, 1687.41895, 7.50950,   0.00000, 0.00000, -54.12000);
	CreateObject(3465, 624.04688, 1677.60156, 7.50950,   0.00000, 0.00000, -54.12000);
	CreateObject(3465, 1378.96094, 461.03909, 20.67780,   0.00000, 0.00000, 64.92000);
	CreateObject(3465, 1385.10864, 458.28751, 20.67780,   0.00000, 0.00000, 64.92000);
	CreateObject(3465, 1383.39844, 459.07031, 20.67780,   0.00000, 0.00000, 64.92000);
	CreateObject(3465, 1380.63281, 460.27341, 20.67780,   0.00000, 0.00000, 64.92000);
	CreateObject(3465, 1007.48083, -936.35480, 42.52997,   0.00000, 0.00000, 98.10004);
	CreateObject(3465, 1000.31641, -937.37799, 42.52997,   0.00000, 0.00000, 98.10004);
	CreateObject(3465, -1611.35706, -2720.47974, 49.26486,   0.00000, 0.00000, 52.20002);
	CreateObject(3465, -1601.36035, -2707.26489, 49.26486,   0.00000, 0.00000, 52.20002);
	CreateObject(3465, -1607.95105, -2716.11792, 49.26486,   0.00000, 0.00000, 52.20002);
	CreateObject(3465, -1604.58057, -2711.73999, 49.26486,   0.00000, 0.00000, 52.20002);
	CreateObject(3465, -2241.71875, -2562.28906, 32.38170,   0.00000, 0.00000, -26.94000);
	CreateObject(3465, -2246.71143, -2559.71191, 32.38172,   0.00000, 0.00000, -26.94002);
	CreateObject(3465, -2026.59338, 156.74089, 29.34369,   0.00000, 0.00000, 0.00000);
	CreateObject(3465, -1679.36633, 403.05774, 7.72122,   0.00000, 0.00000, -46.85999);
	CreateObject(3465, -1685.96875, 409.64059, 7.72120,   0.00000, 0.00000, -46.86000);
	CreateObject(3465, -1681.82813, 413.78131, 7.72120,   0.00000, 0.00000, -46.86000);
	CreateObject(3465, -1676.51563, 419.11719, 7.72120,   0.00000, 0.00000, -46.86000);
	CreateObject(3465, -1665.52344, 416.91409, 7.72120,   0.00000, 0.00000, -46.86000);
	CreateObject(3465, -1672.13281, 423.50000, 7.72120,   0.00000, 0.00000, -46.86000);
	CreateObject(3465, -1669.90625, 412.53131, 7.72120,   0.00000, 0.00000, -46.86000);
	CreateObject(3465, -1675.21875, 407.19531, 7.72120,   0.00000, 0.00000, -46.86000);
	CreateObject(3465, -2410.69946, 975.90387, 45.81320,   0.00000, 0.00000, 0.00000);
	CreateObject(3465, -1464.94653, 1860.56299, 33.14404,   0.00000, 0.00000, -85.97997);
	CreateObject(3465, -1477.65625, 1859.73438, 33.14400,   0.00000, 0.00000, -85.98000);
	CreateObject(3465, -1465.47656, 1868.27344, 33.14400,   0.00000, 0.00000, -85.98000);
	CreateObject(3465, -1477.85156, 1867.31250, 33.14400,   0.00000, 0.00000, -85.98000);
	CreateObject(3465, -1329.22839, 2669.29956, 50.81291,   0.00000, 0.00000, -98.58000);
	CreateObject(3465, -1328.58594, 2674.71094, 50.81290,   0.00000, 0.00000, -98.58000);
	CreateObject(3465, -1327.51611, 2685.63940, 50.81290,   0.00000, 0.00000, -98.58000);
	CreateObject(3465, -1327.79688, 2680.12500, 50.81290,   0.00000, 0.00000, -98.58000);
	CreateObject(3465, 1941.65625, -1778.45313, 13.90000,   0.00000, 0.00000, 0.00000);
	CreateObject(3465, 1941.65625, -1767.28906, 13.90000,   0.00000, 0.00000, 0.00000);
	CreateObject(3465, 1941.65625, -1774.31250, 13.90000,   0.00000, 0.00000, 0.00000);
	CreateObject(3465, 1941.65625, -1771.34375, 13.90000,   0.00000, 0.00000, 0.00000);
	CreateObject(3465, -93.74920, -1169.17798, 2.70380,   0.00000, 0.00000, -24.78000);
	CreateObject(3465, -92.12737, -1161.92224, 2.70383,   0.00000, 0.00000, -24.78000);
	CreateObject(3465, -85.24220, -1165.03125, 2.70380,   0.00000, 0.00000, -24.78000);
	CreateObject(3465, -97.07030, -1173.75000, 2.70380,   0.00000, 0.00000, -24.78000);
	CreateObject(3465, 655.66412, -558.92969, 16.75410,   0.00000, 0.00000, 0.00000);
	CreateObject(3465, 655.66412, -571.21088, 16.75412,   0.00000, 0.00000, 0.00000);
	CreateObject(3465, 655.66412, -569.60162, 16.75410,   0.00000, 0.00000, 0.00000);
	CreateObject(3465, 655.66412, -560.54688, 16.75410,   0.00000, 0.00000, 0.00000);
	CreateObject(3465, -2410.80469, 981.52338, 45.81320,   0.00000, 0.00000, 0.00000);
	CreateObject(3465, -2410.66602, 970.67859, 45.81320,   0.00000, 0.00000, 0.00000);

	CreateObject(971, -99.83736, 1111.65613, 21.03730,   0.00000, 0.00000, 0.00000);
	CreateObject(971, -1420.85474, 2591.07373, 57.13861,   0.00000, 0.00000, 0.00000);
	CreateObject(971, -1903.98999, 277.76801, 43.33656,   0.00000, 0.00000, 0.00000);
	CreateObject(971, -2425.03955, 1028.24268, 52.65782,   0.00000, 0.00000, 0.00000);
	CreateObject(971, 487.72806, -1735.20532, 11.93346,   -0.42000, -0.12000, -7.97999);
	CreateObject(971, 2071.54688, -1830.11218, 14.20679,   0.00000, 0.00000, 90.54002);
	CreateObject(971, 1023.57233, -1029.14722, 32.46410,   0.00000, 0.00000, 0.00000);
	CreateObject(971, 720.14825, -462.39355, 16.90990,   0.00000, 0.00000, 0.00000);
	CreateObject(971, 2394.56641, 1483.60730, 13.18009,   0.00000, 0.00000, 0.00000);

	CreateObject(8373, 1581.69617, 447.78674, -21.37116,   356.85840, 0.00000, -190.47838);

	// DS
	CreateObject(8168, 1615.58301, 644.86877, 11.65614,   0.00000, 0.00000, 106.55999);
	CreateObject(1232, -2929.48022, 435.22589, 6.59930,   356.85840, 0.00000, 3.14159);
	CreateObject(1232, -2864.85498, 417.76968, 6.59930,   356.85840, 0.00000, 3.14159);
	CreateObject(1232, -2864.63818, 435.35443, 6.59930,   356.85840, 0.00000, 3.14159);
	CreateObject(1232, -2926.80737, 418.13971, 6.59930,   356.85840, 0.00000, 3.14159);
	CreateObject(8168, -2864.22925, 505.14557, 5.74485,   0.00000, 0.00000, 16.56001);
	CreateObject(19865, -2853.53027, 503.76834, 3.38780,   0.00000, 0.00000, 159.96007);
	CreateObject(19865, -2929.05566, 486.84256, 3.38776,   0.00000, 0.00000, 90.36002);
	CreateObject(19865, -2924.13696, 486.86908, 3.38776,   0.00000, 0.00000, 90.36002);
	CreateObject(19865, -2919.29199, 486.90680, 3.38776,   0.00000, 0.00000, 90.36002);
	CreateObject(19865, -2914.35986, 486.95187, 3.38776,   0.00000, 0.00000, 90.36002);
	CreateObject(19865, -2909.47070, 486.98074, 3.38776,   0.00000, 0.00000, 90.36002);
	CreateObject(19865, -2904.51709, 487.02966, 3.38776,   0.00000, 0.00000, 90.36002);
	CreateObject(19865, -2889.95557, 487.15530, 3.38776,   0.00000, 0.00000, 90.36002);
	CreateObject(19865, -2899.68286, 487.07187, 3.38776,   0.00000, 0.00000, 90.36002);
	CreateObject(19865, -2894.82104, 487.11038, 3.38776,   0.00000, 0.00000, 90.36002);
	CreateObject(19865, -2885.03271, 487.21152, 3.38776,   0.00000, 0.00000, 90.36002);
	CreateObject(19865, -2880.19043, 487.23599, 3.38776,   0.00000, 0.00000, 90.36002);
	CreateObject(19865, -2875.28979, 487.26886, 3.38776,   0.00000, 0.00000, 90.36002);
	CreateObject(19865, -2870.39819, 487.26132, 3.38776,   0.00000, 0.00000, 90.36002);
	CreateObject(19865, -2865.52051, 487.30865, 3.38776,   0.00000, 0.00000, 90.36002);
	CreateObject(19865, -2853.52588, 510.55466, 3.38780,   0.00000, 0.00000, 90.36000);
	CreateObject(19865, -2856.69214, 494.49680, 3.38780,   0.00000, 0.00000, 164.87997);
	CreateObject(19865, -2851.85522, 508.33173, 3.38780,   0.00000, 0.00000, 159.96007);
	CreateObject(19865, -2861.11011, 487.32739, 3.38780,   0.00000, 0.00000, 90.36000);
	CreateObject(8168, 402.80249, 2536.93579, 17.38592,   0.00000, 0.00000, 16.67999);
	CreateObject(16375, 406.45187, 2525.23315, 15.66406,   356.85840, 0.00000, 3.14159);
	CreateObject(5837, -2213.85596, 312.70898, 35.50178,   0.00000, 0.00000, 0.00000);
	CreateObject(718, 2117.78296, 1440.26392, 9.75000,   356.85840, 0.00000, 3.14159);
	CreateObject(1341, 2111.21338, 1439.93652, 10.70313,   3.14159, 0.00000, 1.57080);
	CreateObject(1340, 2160.67627, 1439.74658, 10.85156,   356.85840, 0.00000, -85.93080);
	CreateObject(718, 2167.79272, 1439.83032, 9.75000,   356.85840, 0.00000, 2.12159);
	CreateObject(8856, 2163.91016, 1444.00684, 10.06250,   0.00000, 0.00000, 89.96002);
	CreateObject(718, 2154.01611, 1439.41650, 9.75000,   356.85840, 0.00000, 3.14159);
	CreateObject(8852, 2219.27417, 1483.11316, 8.54077,   356.85840, 0.00000, -0.09841);
	CreateObject(19865, -2857.97485, 489.77106, 3.38780,   0.00000, 0.00000, 164.87997);

	// VIP
	CreateObject(19313, 1137.58789, 1008.53778, 13.16424,   0.00000, 0.00000, 43.62006);
	CreateObject(19313, 1147.81030, 1018.32257, 13.10644,   0.00000, 0.00000, 43.56006);
	CreateObject(19313, 1156.50134, 1029.94104, 13.14450,   0.00000, 0.00000, 63.06008);
	CreateObject(19313, 1162.81335, 1042.49097, 13.12332,   0.00000, 0.00000, 63.23996);
	CreateObject(19313, 1166.83313, 1055.95508, 13.17605,   0.00000, 0.00000, 83.46001);
	CreateObject(1278, 990.28485, 1063.85815, 23.93750,   3.14159, 0.00000, 0.03491);
	CreateObject(19313, 1168.40894, 1069.92554, 13.17605,   0.00000, 0.00000, 83.46001);
	CreateObject(19313, 1167.59497, 1083.80481, 13.17605,   0.00000, 0.00000, 103.32008);
	CreateObject(19313, 1164.26685, 1097.47632, 13.13443,   0.00000, 0.00000, 103.44007);
	CreateObject(19313, 1158.61584, 1110.50757, 13.13443,   0.00000, 0.00000, 123.54007);
	CreateObject(19313, 1150.83203, 1122.27527, 13.13443,   0.00000, 0.00000, 123.54007);
	CreateObject(19313, 1140.89319, 1132.66907, 13.13443,   0.00000, 0.00000, 143.51962);
	CreateObject(19313, 1129.61304, 1140.97144, 13.13443,   0.00000, 0.00000, 143.51962);
	CreateObject(19313, 1117.22961, 1147.05432, 13.12437,   0.00000, 0.00000, 163.49927);
	CreateObject(19313, 1103.76489, 1151.03528, 13.12437,   0.00000, 0.00000, 163.49927);
	CreateObject(19313, 1090.05432, 1152.53491, 13.12437,   0.00000, 0.00000, 183.59895);
	CreateObject(19313, 1076.02612, 1151.72473, 13.12437,   0.00000, 0.00000, 183.59895);
	CreateObject(19313, 1062.55518, 1148.52283, 13.12437,   0.00000, 0.00000, 203.63881);
	CreateObject(19313, 1049.60754, 1142.85889, 13.12437,   0.00000, 0.00000, 203.63881);
	CreateObject(19313, 1044.42603, 1146.93445, 13.12437,   0.00000, 0.00000, 259.01855);
	CreateObject(19313, 1014.86237, 1161.68311, 13.12437,   0.00000, 0.00000, 361.31760);
	CreateObject(19313, 1040.41895, 1162.80249, 13.12437,   0.00000, 0.00000, 360.23764);
	CreateObject(8006, 1071.71362, 1176.13708, 7.85156,   0.00000, 0.00000, 0.00000);
	CreateObject(19313, 983.53223, 1161.44019, 13.12437,   0.00000, 0.00000, 360.23764);
	CreateObject(19313, 976.43231, 1154.53027, 13.12437,   0.00000, 0.00000, 449.75772);
	CreateObject(19313, 976.41351, 1140.49231, 13.12437,   0.00000, 0.00000, 449.81772);
	CreateObject(19313, 976.40344, 1126.50085, 13.12437,   0.00000, 0.00000, 449.81772);
	CreateObject(19313, 976.35663, 1112.52087, 13.12437,   0.00000, 0.00000, 449.81772);
	CreateObject(19313, 976.37598, 1112.52600, 13.12437,   0.00000, 0.00000, 449.81772);
	CreateObject(19313, 976.37042, 1098.44702, 13.12437,   0.00000, 0.00000, 450.11771);
	CreateObject(19313, 976.42358, 1084.39722, 13.12437,   0.00000, 0.00000, 450.11771);
	CreateObject(19313, 976.43854, 1070.28271, 13.12437,   0.00000, 0.00000, 450.11771);
	CreateObject(1278, 1152.95654, 1023.55420, 23.93750,   0.00000, 0.00000, 223.65450);
	CreateObject(1278, 1043.22644, 1139.98645, 23.93750,   0.00000, 0.00000, 311.19315);
	CreateObject(1278, 1146.71716, 1128.23547, 23.69580,   0.00000, 0.00000, 316.65259);
	CreateObject(13749, 1125.22607, 1021.95782, 17.36907,   0.00000, 0.00000, 169.73981);
	CreateObject(13749, 1005.34625, 1114.37317, 12.26993,   0.00000, 0.00000, -135.60016);
	CreateObject(13749, 1032.11426, 980.28992, 40.35970,   0.00000, 0.00000, 23.51998);
	CreateObject(13749, 1090.67712, 997.19324, 32.31939,   0.00000, 0.00000, 127.73998);
	CreateObject(13749, 1021.49500, 1012.74072, 49.53580,   0.00000, 0.00000, -95.46001);
	CreateObject(13749, 989.77258, 1073.13538, 40.31702,   0.00000, 0.00000, -212.64018);
	CreateObject(13749, 1004.69556, 1091.04517, 26.27953,   0.00000, 0.00000, -174.18018);
	CreateObject(4003, 1069.53052, 1009.17017, 27.00395,   0.00000, 0.00000, -17.16002);
	CreateObject(4003, 1032.71973, 1035.72900, 26.72060,   0.00000, 0.00000, -56.76001);
	CreateObject(1697, 1020.13916, 1045.76428, 27.55951,   0.00000, 0.00000, -18.24000);
	CreateObject(1697, 1030.27075, 1029.44617, 27.55951,   0.00000, 0.00000, -18.24000);
	CreateObject(1697, 1024.72498, 1037.17383, 27.55951,   0.00000, 0.00000, -18.24000);
	CreateObject(1697, 1092.57739, 999.49420, 27.55951,   0.00000, 0.00000, -50.82000);
	CreateObject(1697, 1017.64136, 1055.32031, 27.55951,   0.00000, 0.00000, -18.24000);
	CreateObject(1697, 1015.68896, 1064.04138, 27.55951,   0.00000, 0.00000, -18.24000);
	CreateObject(1697, 1064.89465, 1004.27557, 27.55951,   0.00000, 0.00000, -50.82000);
	CreateObject(1697, 1074.26196, 1001.38190, 27.55951,   0.00000, 0.00000, -50.82000);
	CreateObject(1697, 1083.52344, 999.84900, 27.55951,   0.00000, 0.00000, -50.82000);
	CreateObject(1359, 1080.25000, 1004.45313, 10.67766,   356.85840, 0.00000, 3.14160);
	CreateObject(1359, 1141.90625, 1031.32031, 10.67400,   356.85840, 0.00000, 3.14160);
	CreateObject(1359, 1025.53906, 1045.00781, 10.67287,   356.85840, 0.00000, 3.14160);
	CreateObject(1556, 980.69427, 1066.74695, 12.28423,   0.00000, 180.00000, 181.61993);
	CreateObject(1556, 980.74072, 1066.78687, 9.80000,   0.00000, 0.00000, 180.00000);
	CreateObject(1278, 1162.47192, 1104.37854, 23.93750,   0.00000, 0.00000, 303.03369);
	CreateObject(1278, 1097.00171, 1152.87231, 23.93750,   0.00000, 0.00000, 350.07376);
	CreateObject(1278, 1165.91296, 1048.93384, 23.93750,   0.00000, 0.00000, 257.79401);
	CreateObject(1278, 1123.93860, 1144.95984, 23.93750,   0.00000, 0.00000, 331.35312);
	CreateObject(1278, 1169.06323, 1076.93604, 23.93750,   0.00000, 0.00000, 266.67380);
	CreateObject(1278, 977.19507, 1072.55383, 23.93750,   0.00000, 0.00000, 128.23068);
	CreateObject(1278, 1035.41504, 1160.81812, 23.76633,   0.00000, 0.00000, -176.66508);
	CreateObject(19912, 1021.82141, 1161.85144, 12.60217,   0.00000, 0.00000, -175.44020);
	CreateObject(19313, 986.81732, 1161.42944, 13.12437,   0.00000, 0.00000, 360.23764);
	CreateObject(19313, 1000.82953, 1161.52625, 13.12437,   0.00000, 0.00000, 360.23764);
	CreateObject(19313, 1046.19910, 1155.95569, 13.12437,   0.00000, 0.00000, 259.31854);
	CreateObject(3438, 1017.53296, 1171.00183, 9.65099,   0.00000, 0.00000, -0.18000);
	CreateObject(8168, 1041.14624, 1185.63940, 11.66478,   0.00000, 0.00000, -163.19995);
	CreateObject(3438, 1017.41779, 1167.66113, 9.65099,   0.00000, 0.00000, -0.48000);
	CreateObject(3438, 1037.54736, 1168.48718, 9.65099,   0.00000, 0.00000, -0.48000);
	CreateObject(3438, 1037.43347, 1177.24207, 9.65099,   0.00000, 0.00000, -0.48000);
	CreateObject(3438, 1017.39130, 1176.89148, 9.65099,   0.00000, 0.00000, -0.48000);
	CreateObject(3438, 1037.26416, 1171.20203, 9.65099,   0.00000, 0.00000, -0.48000);
	CreateObject(1278, 1019.52966, 1160.04626, 23.76633,   0.00000, 0.00000, -176.66508);
	CreateObject(1278, 1069.05811, 1151.17798, 23.93750,   0.00000, 0.00000, 380.37320);
	CreateObject(7388, 1045.68835, 1161.20862, 10.05782,   0.00000, 0.00000, -48.24001);
	CreateObject(13011, 1036.81799, 1007.22369, 52.88374,   0.00000, 0.00000, 122.33997);
	CreateObject(1278, 978.08588, 1160.74219, 23.93750,   0.00000, 0.00000, 41.19490);
	CreateObject(1278, 977.11316, 1133.56848, 23.93750,   0.00000, 0.00000, 80.41065);
	CreateObject(1278, 977.17139, 1105.44897, 23.93750,   0.00000, 0.00000, 80.41065);
	CreateObject(7392, 1052.17749, 1023.49469, 42.96974,   0.00000, 0.00000, -114.84020);
	CreateObject(3267, 1040.80469, 1185.51147, 12.81562,   0.00000, 0.00000, -56.04000);
	CreateObject(19313, 1040.42371, 1162.78308, 17.97308,   0.00000, 0.00000, 360.23764);
	CreateObject(19313, 1014.86243, 1161.68311, 17.97310,   0.00000, 0.00000, 361.31760);
	CreateObject(3438, 1037.44788, 1174.23926, 9.65099,   0.00000, 0.00000, -0.48000);
	CreateObject(3438, 1017.62128, 1174.05994, 9.65099,   0.00000, 0.00000, -0.18000);
	CreateObject(16375, 1066.51538, 1000.76605, 54.37277,   0.00000, 0.00000, 0.00000);
	CreateObject(16375, 1142.10229, 981.11664, 25.97521,   0.00000, 0.00000, 0.00000);
	CreateObject(16375, 1084.59985, 970.56201, 39.14843,   0.00000, 0.00000, 0.00000);

	return 1;
}

public RemoveObjects(playerid) // Removes objects from the server
{
	RemoveBuildingForPlayer(playerid, 647, 1074.9766, -1800.6875, 14.3125, 0.25);
	RemoveBuildingForPlayer(playerid, 620, 1075.3750, -1797.3594, 12.3516, 0.25);
	RemoveBuildingForPlayer(playerid, 647, 1074.9766, -1794.5781, 14.3125, 0.25);
	RemoveBuildingForPlayer(playerid, 647, 1107.6250, -1779.8359, 13.9766, 0.25);
	RemoveBuildingForPlayer(playerid, 647, 1077.3672, -1750.3984, 14.3125, 0.25);
	RemoveBuildingForPlayer(playerid, 1290, 1080.8438, -1750.1797, 18.5781, 0.25);
	RemoveBuildingForPlayer(playerid, 647, 1083.5156, -1750.3984, 14.3125, 0.25);

	RemoveBuildingForPlayer(playerid, 1232, -2916.6172, 419.7344, 6.5000, 0.25);
	RemoveBuildingForPlayer(playerid, 1232, -2880.3828, 419.7344, 6.5000, 0.25);
	RemoveBuildingForPlayer(playerid, 1280, -2911.4219, 422.3516, 4.2891, 0.25);
	RemoveBuildingForPlayer(playerid, 1280, -2886.5859, 422.3516, 4.2891, 0.25);
	RemoveBuildingForPlayer(playerid, 1232, -2916.8984, 506.8203, 6.5000, 0.25);
	RemoveBuildingForPlayer(playerid, 1232, -2863.3438, 506.8203, 6.5000, 0.25);

	RemoveBuildingForPlayer(playerid, 1676, 1941.6563, -1778.4531, 14.1406, 0.25);
	RemoveBuildingForPlayer(playerid, 1676, 1941.6563, -1774.3125, 14.1406, 0.25);
	RemoveBuildingForPlayer(playerid, 1676, 1941.6563, -1771.3438, 14.1406, 0.25);
	RemoveBuildingForPlayer(playerid, 1676, 1941.6563, -1767.2891, 14.1406, 0.25);
	RemoveBuildingForPlayer(playerid, 1686, -1685.9688, 409.6406, 6.3828, 0.25);
	RemoveBuildingForPlayer(playerid, 1686, -1679.3594, 403.0547, 6.3828, 0.25);
	RemoveBuildingForPlayer(playerid, 1686, -1681.8281, 413.7813, 6.3828, 0.25);
	RemoveBuildingForPlayer(playerid, 1686, -1675.2188, 407.1953, 6.3828, 0.25);
	RemoveBuildingForPlayer(playerid, 1686, -1676.5156, 419.1172, 6.3828, 0.25);
	RemoveBuildingForPlayer(playerid, 1686, -1669.9063, 412.5313, 6.3828, 0.25);
	RemoveBuildingForPlayer(playerid, 1686, -1672.1328, 423.5000, 6.3828, 0.25);
	RemoveBuildingForPlayer(playerid, 1686, -1665.5234, 416.9141, 6.3828, 0.25);
	RemoveBuildingForPlayer(playerid, 1686, -2410.8047, 970.8516, 44.4844, 0.25);
	RemoveBuildingForPlayer(playerid, 1686, -2410.8047, 976.1875, 44.4844, 0.25);
	RemoveBuildingForPlayer(playerid, 1686, -2410.8047, 981.5234, 44.4844, 0.25);
	RemoveBuildingForPlayer(playerid, 1686, -1477.6563, 1859.7344, 31.8203, 0.25);
	RemoveBuildingForPlayer(playerid, 1686, -1464.9375, 1860.5625, 31.8203, 0.25);
	RemoveBuildingForPlayer(playerid, 1686, -1477.8516, 1867.3125, 31.8203, 0.25);
	RemoveBuildingForPlayer(playerid, 1686, -1465.4766, 1868.2734, 31.8203, 0.25);
	RemoveBuildingForPlayer(playerid, 1686, -1329.2031, 2669.2813, 49.4531, 0.25);
	RemoveBuildingForPlayer(playerid, 1686, -1328.5859, 2674.7109, 49.4531, 0.25);
	RemoveBuildingForPlayer(playerid, 1686, -1327.7969, 2680.1250, 49.4531, 0.25);
	RemoveBuildingForPlayer(playerid, 1686, -1327.0313, 2685.5938, 49.4531, 0.25);
	RemoveBuildingForPlayer(playerid, 1686, 624.0469, 1677.6016, 6.1797, 0.25);
	RemoveBuildingForPlayer(playerid, 1686, 603.4844, 1707.2344, 6.1797, 0.25);
	RemoveBuildingForPlayer(playerid, 1686, 606.8984, 1702.2188, 6.1797, 0.25);
	RemoveBuildingForPlayer(playerid, 1686, 610.2500, 1697.2656, 6.1797, 0.25);
	RemoveBuildingForPlayer(playerid, 1686, 613.7188, 1692.2656, 6.1797, 0.25);
	RemoveBuildingForPlayer(playerid, 1686, 617.1250, 1687.4531, 6.1797, 0.25);
	RemoveBuildingForPlayer(playerid, 1686, 620.5313, 1682.4609, 6.1797, 0.25);
	RemoveBuildingForPlayer(playerid, 1686, -1610.6172, -2721.0000, 47.9297, 0.25);
	RemoveBuildingForPlayer(playerid, 1686, -1607.3047, -2716.6016, 47.9297, 0.25);
	RemoveBuildingForPlayer(playerid, 1686, -1603.9922, -2712.2031, 47.9297, 0.25);
	RemoveBuildingForPlayer(playerid, 1686, -1600.6719, -2707.8047, 47.9297, 0.25);
	RemoveBuildingForPlayer(playerid, 1686, -2246.7031, -2559.7109, 31.0625, 0.25);
	RemoveBuildingForPlayer(playerid, 1686, -2241.7188, -2562.2891, 31.0625, 0.25);
	RemoveBuildingForPlayer(playerid, 1686, 655.6641, -571.2109, 15.3594, 0.25);
	RemoveBuildingForPlayer(playerid, 1686, 655.6641, -569.6016, 15.3594, 0.25);
	RemoveBuildingForPlayer(playerid, 1686, 655.6641, -558.9297, 15.3594, 0.25);
	RemoveBuildingForPlayer(playerid, 1686, 655.6641, -560.5469, 15.3594, 0.25);
	RemoveBuildingForPlayer(playerid, 1686, 1378.9609, 461.0391, 19.3281, 0.25);
	RemoveBuildingForPlayer(playerid, 1686, 1380.6328, 460.2734, 19.3281, 0.25);
	RemoveBuildingForPlayer(playerid, 1686, 1385.0781, 458.2969, 19.3281, 0.25);
	RemoveBuildingForPlayer(playerid, 1686, 1383.3984, 459.0703, 19.3281, 0.25);
	RemoveBuildingForPlayer(playerid, 1676, -92.1016, -1161.7891, 2.9609, 0.25);
	RemoveBuildingForPlayer(playerid, 1676, -97.0703, -1173.7500, 3.0313, 0.25);
	RemoveBuildingForPlayer(playerid, 1676, -85.2422, -1165.0313, 2.6328, 0.25);
	RemoveBuildingForPlayer(playerid, 1676, -90.1406, -1176.6250, 2.6328, 0.25);

	RemoveBuildingForPlayer(playerid, 5422, 2071.4766, -1831.4219, 14.5625, 0.25);
	RemoveBuildingForPlayer(playerid, 5856, 1024.9844, -1029.3516, 33.1953, 0.25);
	RemoveBuildingForPlayer(playerid, 6400, 488.2813, -1734.6953, 12.3906, 0.25);
	RemoveBuildingForPlayer(playerid, 11319, -1904.5313, 277.8984, 42.9531, 0.25);
	RemoveBuildingForPlayer(playerid, 9625, -2425.7266, 1027.9922, 52.2813, 0.25);
	RemoveBuildingForPlayer(playerid, 8957, 2393.7656, 1483.6875, 12.7109, 0.25);
	RemoveBuildingForPlayer(playerid, 3294, -1420.5469, 2591.1563, 57.7422, 0.25);
	RemoveBuildingForPlayer(playerid, 3294, -100.0000, 1111.4141, 21.6406, 0.25);
	RemoveBuildingForPlayer(playerid, 13028, 720.0156, -462.5234, 16.8594, 0.25);

	RemoveBuildingForPlayer(playerid, 956, -76.03, 1227.99, 19.1250, 0.25);
	RemoveBuildingForPlayer(playerid, 956, 2271.73, -76.46, 25.9609, 0.25);
	RemoveBuildingForPlayer(playerid, 956, 662.43, -552.16, 15.7109, 0.25);
	RemoveBuildingForPlayer(playerid, 956, -1455.12, 2591.66, 55.2344, 0.25);
	RemoveBuildingForPlayer(playerid, 956, 2139.52, -1161.48, 23.3594, 0.25);
	RemoveBuildingForPlayer(playerid, 956, 2153.23, -1016.15, 62.2344, 0.25);
	RemoveBuildingForPlayer(playerid, 956, 2480.86, -1959.27, 12.9609, 0.25);
	RemoveBuildingForPlayer(playerid, 956, 1634.11, -2237.53, 12.8906, 0.25);
	RemoveBuildingForPlayer(playerid, 956, -1350.12, 493.86, 10.5859, 0.25);
	RemoveBuildingForPlayer(playerid, 956, -2229.19, 286.41, 34.7031, 0.25);
	RemoveBuildingForPlayer(playerid, 956, 2845.73, 1295.05, 10.7891, 0.25);
	RemoveBuildingForPlayer(playerid, 956, 2647.70, 1129.66, 10.2188, 0.25);
	RemoveBuildingForPlayer(playerid, 956, 1659.46, 1722.86, 10.2188, 0.25);
	RemoveBuildingForPlayer(playerid, 956, 1398.84, 2222.61, 10.4219, 0.25);
	RemoveBuildingForPlayer(playerid, 956, -253.74, 2599.76, 62.2422, 0.25);

	RemoveBuildingForPlayer(playerid, 955, 1928.7344, -1772.4453, 12.9453, 0.25);
	RemoveBuildingForPlayer(playerid, 955, -14.70, 1175.36, 18.9531, 0.25);
	RemoveBuildingForPlayer(playerid, 955, -253.74, 2597.95, 62.2422, 0.25);
	RemoveBuildingForPlayer(playerid, 955, 201.02, -107.62, 0.8984, 0.25);
	RemoveBuildingForPlayer(playerid, 955, -862.83, 1536.61, 21.9844, 0.25);
	RemoveBuildingForPlayer(playerid, 955, 1277.84, 372.52, 18.9531, 0.25);
	RemoveBuildingForPlayer(playerid, 955, 2325.98, -1645.13, 14.2109, 0.25);
	RemoveBuildingForPlayer(playerid, 955, 2352.18, -1357.16, 23.7734, 0.25);
	RemoveBuildingForPlayer(playerid, 955, 1928.73, -1772.45, 12.9453, 0.25);
	RemoveBuildingForPlayer(playerid, 955, 1789.21, -1369.27, 15.1641, 0.25);
	RemoveBuildingForPlayer(playerid, 955, 2060.12, -1897.64, 12.9297, 0.25);
	RemoveBuildingForPlayer(playerid, 955, 1729.79, -1943.05, 12.9453, 0.25);
	RemoveBuildingForPlayer(playerid, 955, 1154.73, -1460.89, 15.1562, 0.25);
	RemoveBuildingForPlayer(playerid, 955, -1350.12, 492.29, 10.5859, 0.25);
	RemoveBuildingForPlayer(playerid, 955, -2118.97, -423.65, 34.7266, 0.25);
	RemoveBuildingForPlayer(playerid, 955, -2118.62, -422.41, 34.7266, 0.25);
	RemoveBuildingForPlayer(playerid, 955, -2097.27, -398.34, 34.7266, 0.25);
	RemoveBuildingForPlayer(playerid, 955, -2092.09, -490.06, 34.7266, 0.25);
	RemoveBuildingForPlayer(playerid, 955, -2063.27, -490.06, 34.7266, 0.25);
	RemoveBuildingForPlayer(playerid, 955, -2005.65, -490.06, 34.7266, 0.25);
	RemoveBuildingForPlayer(playerid, 955, -2034.46, -490.06, 34.7266, 0.25);
	RemoveBuildingForPlayer(playerid, 955, -2068.56, -398.34, 34.7266, 0.25);
	RemoveBuildingForPlayer(playerid, 955, -2039.85, -398.34, 34.7266, 0.25);
	RemoveBuildingForPlayer(playerid, 955, -2011.14, -398.34, 34.7266, 0.25);
	RemoveBuildingForPlayer(playerid, 955, -1980.79, 142.66, 27.0703, 0.25);
	RemoveBuildingForPlayer(playerid, 955, 2503.14, 1243.70, 10.2188, 0.25);
	RemoveBuildingForPlayer(playerid, 955, 2319.99, 2532.85, 10.2188, 0.25);
	RemoveBuildingForPlayer(playerid, 955, 1520.15, 1055.27, 10.0000, 0.25);
	RemoveBuildingForPlayer(playerid, 955, 2085.77, 2071.36, 10.4531, 0.25);

	RemoveBuildingForPlayer(playerid, 1209, -2420.2188, 984.5781, 44.2969, 0.25);
	RemoveBuildingForPlayer(playerid, 1302, -2420.1797, 985.9453, 44.2969, 0.25);

	RemoveBuildingForPlayer(playerid, 6400, 488.2813, -1734.6953, 12.3906, 0.25);

	// DS
	RemoveBuildingForPlayer(playerid, 1280, 1074.9609, -1783.0781, 13.0000, 0.25);
	RemoveBuildingForPlayer(playerid, 1280, 1065.3125, -1783.0781, 13.0000, 0.25);
	RemoveBuildingForPlayer(playerid, 1280, 1084.6094, -1783.0781, 13.0000, 0.25);
	RemoveBuildingForPlayer(playerid, 1290, 1080.8438, -1777.4922, 18.5781, 0.25);
	RemoveBuildingForPlayer(playerid, 1280, 1094.2656, -1783.0781, 13.0000, 0.25);
	RemoveBuildingForPlayer(playerid, 1232, -2916.6172, 419.7344, 6.5000, 0.25);
	RemoveBuildingForPlayer(playerid, 1232, -2880.3828, 419.7344, 6.5000, 0.25);
	RemoveBuildingForPlayer(playerid, 1280, -2911.4219, 422.3516, 4.2891, 0.25);
	RemoveBuildingForPlayer(playerid, 1280, -2886.5859, 422.3516, 4.2891, 0.25);
	RemoveBuildingForPlayer(playerid, 1232, -2916.8984, 506.8203, 6.5000, 0.25);
	RemoveBuildingForPlayer(playerid, 1232, -2863.3438, 506.8203, 6.5000, 0.25);
	RemoveBuildingForPlayer(playerid, 1231, 2121.7266, 1447.9766, 12.4609, 0.25);
	RemoveBuildingForPlayer(playerid, 718, 2121.8359, 1443.2344, 9.7500, 0.25);
	RemoveBuildingForPlayer(playerid, 1341, 2125.1328, 1442.0781, 10.7031, 0.25);
	RemoveBuildingForPlayer(playerid, 718, 2147.6641, 1443.2344, 9.7500, 0.25);
	RemoveBuildingForPlayer(playerid, 1340, 2144.6406, 1441.9297, 10.8516, 0.25);
	RemoveBuildingForPlayer(playerid, 3345, 400.1172, 2543.5703, 15.4844, 0.25);
	RemoveBuildingForPlayer(playerid, 1224, 410.8281, 2528.5703, 16.1563, 0.25);
	RemoveBuildingForPlayer(playerid, 1224, 409.8047, 2529.6328, 16.1563, 0.25);
	RemoveBuildingForPlayer(playerid, 1224, 408.7188, 2530.7656, 16.1563, 0.25);
	RemoveBuildingForPlayer(playerid, 1224, 407.1563, 2530.4688, 16.1563, 0.25);
	RemoveBuildingForPlayer(playerid, 3172, 400.1172, 2543.5703, 15.4844, 0.25);
	RemoveBuildingForPlayer(playerid, 1224, 407.8828, 2532.0078, 16.1563, 0.25);

	// VIP
	RemoveBuildingForPlayer(playerid, 1359, 1080.2500, 1004.4531, 10.9609, 0.25);
	RemoveBuildingForPlayer(playerid, 1359, 1141.9063, 1031.3203, 10.9609, 0.25);
	RemoveBuildingForPlayer(playerid, 1359, 1025.5391, 1045.0078, 10.9609, 0.25);
	RemoveBuildingForPlayer(playerid, 673, 1172.0000, 1038.4063, 9.7188, 0.25);
	RemoveBuildingForPlayer(playerid, 1278, 978.0859, 1068.0000, 23.9375, 0.25);
	RemoveBuildingForPlayer(playerid, 1411, 976.2891, 1069.2734, 11.4063, 0.25);
	RemoveBuildingForPlayer(playerid, 1411, 976.2891, 1074.5391, 11.4063, 0.25);
	RemoveBuildingForPlayer(playerid, 1411, 976.2891, 1079.8047, 11.4063, 0.25);
	RemoveBuildingForPlayer(playerid, 1411, 976.2891, 1085.0703, 11.4063, 0.25);
	RemoveBuildingForPlayer(playerid, 1411, 976.2891, 1090.3359, 11.4063, 0.25);
	RemoveBuildingForPlayer(playerid, 1411, 976.2891, 1095.6016, 11.4063, 0.25);
	RemoveBuildingForPlayer(playerid, 1411, 976.2891, 1100.8672, 11.4063, 0.25);
	RemoveBuildingForPlayer(playerid, 763, 967.7266, 1101.7734, 9.4766, 0.25);
	RemoveBuildingForPlayer(playerid, 1411, 976.2891, 1106.1328, 11.4063, 0.25);
	RemoveBuildingForPlayer(playerid, 1411, 976.2891, 1111.3984, 11.4063, 0.25);
	RemoveBuildingForPlayer(playerid, 1411, 976.2891, 1116.6641, 11.4063, 0.25);
	RemoveBuildingForPlayer(playerid, 1411, 976.2891, 1121.9297, 11.4063, 0.25);
	RemoveBuildingForPlayer(playerid, 1411, 976.2891, 1127.2031, 11.4063, 0.25);
	RemoveBuildingForPlayer(playerid, 1411, 976.2891, 1132.4688, 11.4063, 0.25);
	RemoveBuildingForPlayer(playerid, 1411, 976.2891, 1137.7344, 11.4063, 0.25);
	RemoveBuildingForPlayer(playerid, 1411, 976.2891, 1143.0000, 11.4063, 0.25);
	RemoveBuildingForPlayer(playerid, 1411, 976.2891, 1148.2656, 11.4063, 0.25);
	RemoveBuildingForPlayer(playerid, 1411, 976.2891, 1158.7969, 11.4063, 0.25);
	RemoveBuildingForPlayer(playerid, 1411, 976.2891, 1153.5313, 11.4063, 0.25);
	RemoveBuildingForPlayer(playerid, 1278, 978.0859, 1160.7422, 23.9375, 0.25);
	RemoveBuildingForPlayer(playerid, 1278, 1011.7422, 1160.7422, 23.9375, 0.25);
	RemoveBuildingForPlayer(playerid, 1411, 979.1250, 1161.6875, 11.4063, 0.25);
	RemoveBuildingForPlayer(playerid, 1411, 984.3906, 1161.6875, 11.4063, 0.25);
	RemoveBuildingForPlayer(playerid, 1411, 994.9219, 1161.6875, 11.4063, 0.25);
	RemoveBuildingForPlayer(playerid, 1411, 989.6563, 1161.6875, 11.4063, 0.25);
	RemoveBuildingForPlayer(playerid, 1411, 1005.4531, 1161.6875, 11.4063, 0.25);
	RemoveBuildingForPlayer(playerid, 1411, 1000.1875, 1161.6875, 11.4063, 0.25);
	RemoveBuildingForPlayer(playerid, 1411, 1010.7188, 1161.6875, 11.4063, 0.25);
	RemoveBuildingForPlayer(playerid, 673, 1016.2578, 1164.8203, 9.3203, 0.25);
	RemoveBuildingForPlayer(playerid, 647, 1015.3359, 1168.9219, 11.1250, 0.25);
	RemoveBuildingForPlayer(playerid, 680, 1012.5938, 1181.8438, 9.7031, 0.25);
	RemoveBuildingForPlayer(playerid, 673, 1016.6719, 1172.8047, 8.5156, 0.25);
	RemoveBuildingForPlayer(playerid, 673, 1016.6719, 1181.5859, 9.7344, 0.25);
	RemoveBuildingForPlayer(playerid, 647, 1015.5938, 1176.3750, 11.1250, 0.25);
	RemoveBuildingForPlayer(playerid, 673, 1037.7734, 1164.8203, 8.8125, 0.25);
	RemoveBuildingForPlayer(playerid, 673, 1037.7734, 1172.8047, 8.8125, 0.25);
	RemoveBuildingForPlayer(playerid, 647, 1038.4844, 1168.3594, 11.1250, 0.25);
	RemoveBuildingForPlayer(playerid, 673, 1037.5313, 1181.5859, 9.7344, 0.25);
	RemoveBuildingForPlayer(playerid, 680, 1042.1328, 1181.8438, 9.7031, 0.25);
	RemoveBuildingForPlayer(playerid, 647, 1038.2656, 1177.1641, 11.1250, 0.25);

	return 1;
}

public GetPlayerVehicles(playerid) // Returns the number of vehicle the player owns
{
	new count;

	for(new i = 1; i < MAX_VEHICLES; i++)
	{
		if(Vehicle[i][vStatus] == 1 && strcmp(Vehicle[i][vOwner], GetName(playerid)) == 0)
			count++;
	}
	return count;
}

public GetFreeVehicleID() // Returns the free id from the total vehicles to replace the deleted vehicle
{
	for(new i = 1; i < MAX_VEHICLES; i++)
	{
		if(Vehicle[i][vStatus] == 0)
		{
			printf("%d", i);
			return i;
		}
	}
	return 0;
}

public CheckFreePlayerSlot(playerid) // Returns the free vehicle slot of player
{
	if(Player[playerid][pVehicle1] == 0)
		return 1;
	else if(Player[playerid][pVehicle2] == 0)
		return 2;
	else if(Player[playerid][pVehicle3] == 0)
		return 3;
	else if(Player[playerid][pVehicle4] == 0)
		return 4;
	else if(Player[playerid][pVehicle5] == 0 && Player[playerid][pVipLevel] > 0)
		return 5;
	else if(Player[playerid][pVehicle6] == 0 && Player[playerid][pVipLevel] > 0)
		return 6;
	else if(Player[playerid][pVehicle7] == 0 && Player[playerid][pVipLevel] > 0)
		return 7;
	else if(Player[playerid][pVehicle8] == 0 && Player[playerid][pVipLevel] > 0)
		return 8;
	return 0;
}

public IsValidPlayerVehicle(vehicleid) // Checks if the vehicle is owner by a player
{
	if(Vehicle[vehicleid][vStatus] == 1 && strcmp(Vehicle[vehicleid][vOwner], "0") == 1)
		return 1;
	return 0;
}

public UpdatePlayerVehicle(vehicleid, removeold) // Spawns the vehicle owbed by the player only if the player is connected
{
	if(IsValidPlayerVehicle(vehicleid) == 1)
	{
		if(removeold == 1)
			DestroyVehicle(vehicleid);

		new vid = CreateVehicle(Vehicle[vehicleid][vModel], Vehicle[vehicleid][vPosition][0], Vehicle[vehicleid][vPosition][1], Vehicle[vehicleid][vPosition][2], Vehicle[vehicleid][vAngle], Vehicle[vehicleid][vColor1], Vehicle[vehicleid][vColor2], 900);

		LinkVehicleToInterior(vid, Vehicle[vehicleid][vInterior]);
		SetVehicleVirtualWorld(vid, Vehicle[vehicleid][vVirtualWorld]);

		ChangeVehiclePaintjob(vid, Vehicle[vehicleid][vPaintjob]);

		SetVehicleNumberPlate(vehicleid, Vehicle[vehicleid][vCarPlate]);
	}
	return 1;
}

public Speedo(playerid, vehicleid)
{
	new engine, lights, alarm, doors, bonnet, boot, objective, string[128];

	if(GetPlayerState(playerid) == PLAYER_STATE_DRIVER || GetPlayerState(playerid) == PLAYER_STATE_PASSENGER)
	{
		new vid = GetPlayerVehicleID(playerid);

		GetVehicleParamsEx(vid, engine, lights, alarm, doors, bonnet, boot, objective);

		if(IsValidDealershipVehicle(vid) == 0 && engine == 1)
		{
			if(Vehicle[vid][vFuel] <= 0)
			{
				ToggleEngine(vid, VEHICLE_PARAMS_OFF);
				SendClientMessage(playerid, COLOR_INDIGO, "Your vehicle is out of fuel.");
				KillTimer(fueltimer[playerid]);
			}

			format(string, sizeof(string), "Speed: %d Km/h", GetPlayerSpeed(playerid, true));			
			PlayerTextDrawSetString(playerid, Speedometer[playerid], string);
		}
	}
	return 1;
}

stock GetVehicleRotation(vehicleid) // Returns the rotation of a vehicle
{
	new Float:qw,Float:qx,Float:qy,Float:qz, Float:rx, Float:ry, Float:rz, Float:rot;

	GetVehicleRotationQuat(vehicleid,qw,qx,qy,qz);
	
	rx = asin(2*qy*qz-2*qx*qw);
	ry = -atan2(qx*qz+qy*qw,0.5-qx*qx-qy*qy);
	rz = -atan2(qx*qy+qz*qw,0.5-qx*qx-qz*qz);
	rot = rx + ry + rz;
	return _:rot;
stock GetPlayerSpeed(playerid, bool:distance)
{
    new Float:X, Float:Y, Float:Z, Float:rotation;

    if(IsPlayerInAnyVehicle(playerid))
    	GetVehicleVelocity(GetPlayerVehicleID(playerid), X, Y, Z);
    else
    	GetPlayerVelocity(playerid, X, Y, Z);

    // rotation = floatsqroot(floatabs(floatpower(X + Y + Z, 2)));

    // return distance?floatround(rotation * 100 * 1.61):floatround(rotation * 100);

    new Float:vX = floatpower(X, 2);
    new Float:vY = floatpower(Y, 2);
    new Float:vZ = floatpower(Z, 2);

    new Float:sq = floatsqroot(vX + vY + vZ);

    new Float:total = sq * 180.0;
    return floatround(total);
}

public settime(playerid)
{
	new string[256], year, month, day, hours, minutes, seconds;

	getdate(year, month, day), gettime(hours, minutes, seconds);

	format(string, sizeof string, "%d/%s%d/%s%d", day, ((month < 10) ? ("0") : ("")), month, (year < 10) ? ("0") : (""), year);
	TextDrawSetString(Date, string);

	format(string, sizeof string, "%s%d:%s%d:%s%d", (hours < 10) ? ("0") : (""), hours, (minutes < 10) ? ("0") : (""), minutes, (seconds < 10) ? ("0") : (""), seconds);
	TextDrawSetString(Time, string);
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

public BanLog(playerid, banstring[]) // Makes log of player bans (takes playerid as parameter)
{
	new entry[256], string[128];
	format(entry, sizeof(entry), "%s\r\n", banstring);

	new File:hFile;
	format(string, sizeof(string), "logs/bans/%s.log", GetName(playerid));
	hFile = fopen(string, io_append);
	fwrite(hFile, entry);

	fclose(hFile);
}

public BanLog2(playername[], banstring2[]) // Makes log of player bans (takes name as parameter)
{
	new entry[256], string[128];
	format(entry, sizeof(entry), "%s\r\n", banstring2);

	new File:hFile;
	format(string, sizeof(string), "logs/bans/%s.log", playername);
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

// -------------------------------------Job Functions---------------------------------------------

stock UpdateJob(jobid, removeold) // Updates job data and labels
{
	new string2[1024];
	if(Job[jobid][JobStatus])
	{
		if(removeold)
		{
			DestroyDynamic3DTextLabel(Job[jobid][JobText]);
			DestroyPickup(Job[jobid][JobPickup]);
		}
		
		format(string2, sizeof(string2), "{0000BB}JobID: %d\n{ffffff}\n{0000BB}Name: {ffffff}%s\n{0000BB}Level: {ffffff}%d\n{0000BB}Type /getjob to get this job", jobid, Job[jobid][JobName], Job[jobid][JobLevel]);

		Job[jobid][JobText] = CreateDynamic3DTextLabel(string2, 0xFFFFFF, Job[jobid][JobX], Job[jobid][JobY], Job[jobid][JobZ], 20.0, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 0, -1, -1, -1, 20.0);
		Job[jobid][JobPickup] = CreatePickup(1239, 1, Job[jobid][JobX], Job[jobid][JobY], Job[jobid][JobZ], 0);
	}
}

stock SaveJob(jobid) // Saves job data into .ini file
{
	new filename[64], line[256];

	format(filename, sizeof(filename), JOB_FILE_PATH "j%d.ini", jobid);

	new File:handle = fopen(filename, io_write);

	format(line, sizeof(line), "ID=%d\r\n", Job[jobid][JobID]);
	fwrite(handle, line);

	format(line, sizeof(line), "Status=%d\r\n", Job[jobid][JobStatus]);
	fwrite(handle, line);

	format(line, sizeof(line), "Name=%s\r\n", Job[jobid][JobName]);
	fwrite(handle, line);
	
	format(line, sizeof(line), "Level=%d\r\n", Job[jobid][JobLevel]);
	fwrite(handle, line);

	format(line, sizeof(line), "EntranceX=%f\r\n", Job[jobid][JobX]);
	fwrite(handle, line);

	format(line, sizeof(line), "EntranceY=%f\r\n", Job[jobid][JobY]);
	fwrite(handle, line);

	format(line, sizeof(line), "EntranceZ=%f\r\n", Job[jobid][JobZ]);
	fwrite(handle, line);

	fclose(handle);
}

stock LoadJob() // Loads Job data from .ini file
{
	new File:handle, count;
	new filename[64], line[256], s, key[64];

	for(new i = 0; i < MAX_JOB_LIMIT; i++)
	{
		format(filename, sizeof(filename), JOB_FILE_PATH"j%d.ini", i);

		if(!fexist(filename))
			continue;

		handle = fopen(filename, io_read);
		while(fread(handle, line))
		{
			StripNL(line);
			s = strfind(line, "=");

			if(!line[0] || s < 1)
				continue;

			strmid(key, line, 0, s++);
			if(strcmp(key, "Status") == 0)
				Job[i][JobStatus] = strval(line[s]);
			else if(strcmp(key, "ID") == 0)
				Job[i][JobID] = strval(line[s]);
			else if(strcmp(key, "Name") == 0)
				sscanf(line[s], "s[128]", Job[i][JobName]);
			else if(strcmp(key, "Level") == 0)
				Job[i][JobLevel] = strval(line[s]);
			else if(strcmp(key, "EntranceX") == 0)
				sscanf(line[s], "f", Job[i][JobX]);
			else if(strcmp(key, "EntranceY") == 0)
				sscanf(line[s], "f", Job[i][JobY]);
			else if(strcmp(key, "EntranceZ") == 0)
				sscanf(line[s], "f", Job[i][JobZ]);
		}
		fclose(handle);
		if(Job[i][JobStatus])
			count++;
	}
	printf("  Loaded %d Jobs", count);
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
			SendClientMessage(targetid, COLOR_RED, string);

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
			if(Player[targetid][pIsMuted] == 0)
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
			SendClientMessage(playerid, COLOR_SEAGREEN, "You have been teleported.");
		}
		else
		{
			SendClientMessage(playerid, COLOR_NEUTRAL, "You can go back only once.");
		}
	
		format(acmdlogstring, sizeof(acmdlogstring), "Command: /goback [%d/%d/%d] [%d:%d:%d]", day, month, year, hour, minute, second);
		AdminCommandLog(playerid, acmdlogstring);

		
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
	new reason[128], string[128], acmdlogstring[128], banstring2[128], day, month, year, hour, minute, second, playername[MAX_PLAYER_NAME];

	new tEmail[128], tPassword[129], tSex, tSkin, tCash, tAdminLevel, tVipLevel, tHelperLevel, tIsBanned, tIsMuted, tMuteTime, tWarns, tRegCheck, Float:tHoursPlayed, tLevel, tRespectPoints;

	new filename2[64], line2[256];
	
	if(Player[playerid][pAdminLevel] >= 2 || IsPlayerAdmin(playerid))
	{
		if(sscanf(params, "s[128]s[128]", playername, reason))
			return SendClientMessage(playerid, COLOR_LIGHTCYAN, "Syntax: /unban [playername] [reason]");

		gettime(hour, minute, second);
		getdate(year, month, day);
	
		new filename[64], line[256], s, key[64];
		new File:handle;

		format(filename, sizeof(filename), ACCOUNT_PATH "%s.ini", playername);

		if(fexist(filename))
		{
			handle = fopen(filename, io_read);
			while(fread(handle, line))
			{
				StripNL(line);
				s = strfind(line, "=");

				if(!line[0] || s < 1)
					continue;

				strmid(key, line, 0, s++);
				if(strcmp(key, "Email") == 0)
					sscanf(line[s], "s[128]", tEmail);
				else if(strcmp(key, "Password") == 0)
					sscanf(line[s], "s[129]", tPassword);
				else if(strcmp(key, "Sex") == 0)
					tSex = strval(line[s]);
				else if(strcmp(key, "Skin") == 0)
					tSkin = strval(line[s]);
				else if(strcmp(key, "Cash") == 0)
					tCash = strval(line[s]);
				else if(strcmp(key, "AdminLevel") == 0)
					tAdminLevel = strval(line[s]);
				else if(strcmp(key, "VipLevel") == 0)
					tVipLevel = strval(line[s]);
				else if(strcmp(key, "HelperLevel") == 0)
					tHelperLevel = strval(line[s]);
				else if(strcmp(key, "IsBanned") == 0)
					tIsBanned = strval(line[s]);
				else if(strcmp(key, "IsMuted") == 0)
					tIsMuted = strval(line[s]);
				else if(strcmp(key, "MuteTime") == 0)
					tMuteTime = strval(line[s]);
				else if(strcmp(key, "Warns") == 0)
					tWarns = strval(line[s]);
				else if(strcmp(key, "RegCheck") == 0)
					tRegCheck = strval(line[s]);
				else if(strcmp(key, "HoursPlayed") == 0)
					sscanf(line[s], "f", tHoursPlayed);
				else if(strcmp(key, "Level") == 0)
					tLevel = strval(line[s]);
				else if(strcmp(key, "RespectPoints") == 0)
					tRespectPoints = strval(line[s]);
			}
			fclose(handle);
		}
		else
			return SendClientMessage(playerid, COLOR_NEUTRAL, "Player does not exist.");

		if(tIsBanned == 0)
		{
			new string2[128];
			format(string2, sizeof(string2), "%s is not banned", playername);
			return SendClientMessage(playerid, COLOR_NEUTRAL, string2);
		}

		format(filename2, sizeof(filename2), ACCOUNT_PATH "%s.ini", playername);

		new File:handle2 = fopen(filename2, io_write);

		format(line2, sizeof(line2), "Email=%s\r\n", tEmail);
		fwrite(handle2, line2);

		format(line2, sizeof(line2), "Password=%s\r\n", tPassword);
		fwrite(handle2, line2);

		format(line2, sizeof(line2), "Sex=%d\r\n", tSex);
		fwrite(handle2, line2);

		format(line2, sizeof(line2), "Skin=%d\r\n", tSkin);
		fwrite(handle2, line2);

		format(line2, sizeof(line2), "Cash=%d\r\n", tCash);
		fwrite(handle2, line2);

		format(line2, sizeof(line2), "AdminLevel=%d\r\n", tAdminLevel);
		fwrite(handle2, line2);

		format(line2, sizeof(line2), "VipLevel=%d\r\n", tVipLevel);
		fwrite(handle2, line2);

		format(line2, sizeof(line2), "HelperLevel=%d\r\n", tHelperLevel);
		fwrite(handle2, line2);
			
		format(line2, sizeof(line2), "IsBanned=%d\r\n", 0);
		fwrite(handle2, line2);

		format(line2, sizeof(line2), "IsMuted=%d\r\n", tIsMuted);
		fwrite(handle2, line2);

		format(line2, sizeof(line2), "MuteTime=%d\r\n", tMuteTime);
		fwrite(handle2, line2);

		format(line2, sizeof(line2), "Warns=%d\r\n", tWarns);
		fwrite(handle2, line2);

		format(line2, sizeof(line2), "RegCheck=%d\r\n", tRegCheck);
		fwrite(handle2, line2);

		format(line2, sizeof(line2), "BanTime=0\r\n");
		fwrite(handle2, line2);

		format(line2, sizeof(line2), "BanExp=0\r\n");
		fwrite(handle2, line2);

		format(line, sizeof(line), "HoursPlayed=%.1f\r\n", tHoursPlayed);
		fwrite(handle, line);

		format(line, sizeof(line), "Level=%d\r\n", tLevel);
		fwrite(handle, line);

		format(line, sizeof(line), "RespectPoints=%d\r\n", tRespectPoints);
		fwrite(handle, line);

		format(string, sizeof(string), "You have unbanned %s from the server. Reason: %s", playername, reason);
		SendClientMessage(playerid, COLOR_RED, string);

		fclose(handle2);

		format(acmdlogstring, sizeof(acmdlogstring), "Command: /unban %s %s [%d/%d/%d] [%d:%d:%d]", playername, reason, day, month, year, hour, minute, second);
		AdminCommandLog(playerid, acmdlogstring);

		format(banstring2, sizeof(banstring2), "Unbanned | Reason: %s | By %s [%d/%d/%d] [%d:%d:%d]", reason, GetName(playerid), day, month, year, hour, minute, second);
		BanLog2(playername, banstring2);
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
	new targetid, day, month, year, hour, minute, second, acmdlogstring[128], string[256];

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

		Vehicle[vid][vFuel] = 100.0;

		if(IsBicycle(vid))
			ToggleEngine(vid, VEHICLE_PARAMS_ON);

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

		for(new i = 1; i < MAX_VEHICLES; i++)
			if(!vehicleused[i])
				SetVehicleToRespawn(i);

		format(string, sizeof(string), "Admin %s has respawned all unused vehicles.", GetName(playerid));
		SendToAdmins(COLOR_LIGHTBLUE, string);

		gettime(hour, minute, second);
		getdate(year, month, day);

		format(acmdlogstring, sizeof(acmdlogstring), "Command: /rav [%d/%d/%d] [%d:%d:%d]", day, month, year, hour, minute, second);
		AdminCommandLog(playerid, acmdlogstring);
	}
	else
		return SendClientMessage(playerid, COLOR_LIGHTNEUTRALBLUE, "You are not authorized to use this command!");
	return 1;
}

CMD:createdealership(playerid, params[]) // Creates a new dealership
{
	new string[128], day, month, year, hour, minute, second, acmdlogstring[128];

	if(Player[playerid][pAdminLevel] == 6 || IsPlayerAdmin(playerid))
	{
		for(new i = 0; i < MAX_DEALERSHIPS; i++)
		{
			if(DealershipStatus[i] == 0)
			{
				DealershipStatus[i] = 1;
				GetPlayerPos(playerid, DealershipPosition[i][0], DealershipPosition[i][1], DealershipPosition[i][2]);

				UpdateDealership(i, 0);
				SaveDealership(i);

				gettime(hour, minute, second);
				getdate(year, month, day);

				format(acmdlogstring, sizeof(acmdlogstring), "Command: /createdealership [%d/%d/%d] [%d:%d:%d]", day, month, year, hour, minute, second);
				AdminCommandLog(playerid, acmdlogstring);

				format(string, sizeof(string), "Dealership %d created.", i);
				return SendClientMessage(playerid, COLOR_LIGHTBLUE, string);
			}
		}
		SendClientMessage(playerid, COLOR_NEUTRAL, "Maximum dealership limit reached.");
	}
	else
		return SendClientMessage(playerid, COLOR_LIGHTNEUTRALBLUE, "You are not authorized to use this command!");
	return 1;
}

CMD:gotods(playerid, params[])
	return cmd_gotodealership(playerid, params);

CMD:gotodealership(playerid, params[]) // Teleports the player to the specified dealership
{
	new dealershipid, Float:X, Float:Y, Float:Z, string[128], day, month, year, hour, minute, second, acmdlogstring[128], gotostring[128];

	if(Player[playerid][pAdminLevel] >= 3 || IsPlayerAdmin(playerid))
	{
		if(sscanf(params, "i", dealershipid))
			return SendClientMessage(playerid, COLOR_LIGHTCYAN, "Syntax: /gotodealership [dealershipid]");

		if(IsValidDealership(dealershipid) == 0)
			return SendClientMessage(playerid, COLOR_NEUTRAL, "Invalid dealership ID!");

		GetPlayerPos(playerid, X, Y, Z);
		gobackstatus[playerid] = 1;
		savedposx[playerid] = X;
		savedposy[playerid] = Y;
		savedposz[playerid] = Z;

		SetPlayerPos(playerid, DealershipPosition[dealershipid][0], DealershipPosition[dealershipid][1], DealershipPosition[dealershipid][2]);

		format(string, sizeof(string), "Teleported to dealership %d", dealershipid);
		SendClientMessage(playerid, COLOR_PINK, string);

		gettime(hour, minute, second);
		getdate(year, month, day);

		format(gotostring, sizeof(gotostring), "gotod %d [%d/%d/%d] [%d:%d:%d]", dealershipid, day, month, year, hour, minute, second);
		GotoLog(playerid, gotostring);

		format(acmdlogstring, sizeof(acmdlogstring), "Command: /gotodealership %d [%d/%d/%d] [%d:%d:%d]", dealershipid, day, month, year, hour, minute, second);
		AdminCommandLog(playerid, acmdlogstring);
	}
	else
		return SendClientMessage(playerid, COLOR_LIGHTNEUTRALBLUE, "You are not authorized to use this command!");
	return 1;
}

CMD:cdv(playerid, params[])
	return cmd_createdvehicle(playerid, params);

CMD:createdvehicle(playerid, params[]) // Creates a dealership vehicle
{
	new dealershipid, Float:X, Float:Y, Float:Z, Float:angle, price, modelid, model[64], string[128], day, month, year, hour, minute, second, acmdlogstring[128];

	if(Player[playerid][pAdminLevel] == 6 || IsPlayerAdmin(playerid))
	{
		if(sscanf(params, "is[128]i", dealershipid, model, price))
			return SendClientMessage(playerid, COLOR_LIGHTCYAN, "Syntax: /createdvehicle [dealershipid] [modelid] [price]");

		if(IsValidDealership(dealershipid) == 0)
			return SendClientMessage(playerid, COLOR_NEUTRAL, "Invalid dealership ID!");

		if(IsNumeric(model))
			modelid = strval(model);
		else
			modelid = GetVehicleModelIDFromName(model);

		if(modelid < 400 || modelid > 611)
			return SendClientMessage(playerid, COLOR_LIGHTCYAN, "Invalid vehicle model!");

		GetPlayerPos(playerid, X, Y, Z);
		GetPlayerFacingAngle(playerid, angle);

		for(new i = 1; i < MAX_VEHICLES; i++)
		{
			if(Vehicle[i][vStatus] == 0)
			{
				Vehicle[i][vStatus] = 1;
				Vehicle[i][vModel] = modelid;
				Vehicle[i][vPosition][0] = X;
				Vehicle[i][vPosition][1] = Y;
				Vehicle[i][vPosition][2] = Z;
				Vehicle[i][vAngle] = angle;
				Vehicle[i][vPrice] = price;
				valstr(Vehicle[i][vOwner], 0);
				Vehicle[i][vInterior] = GetPlayerInterior(playerid);
				Vehicle[i][vVirtualWorld] = GetPlayerVirtualWorld(playerid);
				valstr(Vehicle[i][vCarPlate], 0);

				UpdateVehicle(i, 0);
				SaveVehicle(i);

				format(string, sizeof(string), "Created vehicle %d for dealership %d", i, dealershipid);
				SendClientMessage(playerid, COLOR_PINK, string);

				vehicles++;

				gettime(hour, minute, second);
				getdate(year, month, day);

				format(acmdlogstring, sizeof(acmdlogstring), "Command: /addvehicle %d %s %d [%d/%d/%d] [%d:%d:%d]", dealershipid, model, price, day, month, year, hour, minute, second);
				AdminCommandLog(playerid, acmdlogstring);
				return 1;
			}
		}
	}
	else
		return SendClientMessage(playerid, COLOR_LIGHTNEUTRALBLUE, "You are not authorized to use this command!");
	return 1;
}

CMD:ddv(playerid, params[])
	return cmd_deletedvehicle(playerid, params);

CMD:deletedvehicle(playerid, params[]) // Deletes a delership vehicle
{
	new vid, string[128], day, month, year, hour, minute, second, acmdlogstring[128];

	if(Player[playerid][pAdminLevel] == 6 || IsPlayerAdmin(playerid))
	{
		if(sscanf(params, "i", vid))
			return SendClientMessage(playerid, COLOR_LIGHTCYAN, "Syntax: /deletedvehicle [vehicleid]");

		if(IsValidDealershipVehicle(vid) == 1)
		{
			DestroyVehicle(vid);
			Delete3DTextLabel(VehicleLabel[vid]);
			Vehicle[vid][vStatus] = 0;  
		}
		else
			return SendClientMessage(playerid, COLOR_NEUTRAL, "Vehicle does not exist.");

		SaveVehicle(vid);
		
		format(string, sizeof(string), "Deleted dealership vehicle %d", vid);
		SendClientMessage(playerid, COLOR_PINK, string);

		gettime(hour, minute, second);
		getdate(year, month, day);

		format(acmdlogstring, sizeof(acmdlogstring), "Command: /deletedvehicle %d [%d/%d/%d] [%d:%d:%d]", vid, day, month, year, hour, minute, second);
		AdminCommandLog(playerid, acmdlogstring);
	}
	else
		return SendClientMessage(playerid, COLOR_LIGHTNEUTRALBLUE, "You are not authorized to use this command!");
	return 1;
}

CMD:ccv(playerid, params[])
	return cmd_createcvehicle(playerid, params);

CMD:createcvehicle(playerid, params[]) // Creates a civilian vehicle
{
	new model[64], modelid, Float:X, Float:Y, Float:Z, Float:angle, string[128], day, month, year, hour, minute, second, acmdlogstring[128];

	if(Player[playerid][pAdminLevel] == 6 || IsPlayerAdmin(playerid))
	{
		if(sscanf(params, "s[64]", model))
			return SendClientMessage(playerid, COLOR_LIGHTCYAN, "Syntax: /createcvehicle [modelid/name]");

		if(IsNumeric(model))
			modelid = strval(model);
		else
			modelid = GetVehicleModelIDFromName(model);

		if(modelid < 400 || modelid > 611)
			return SendClientMessage(playerid, COLOR_LIGHTCYAN, "Invalid vehicle model!");

		GetPlayerPos(playerid, X, Y, Z);
		GetPlayerFacingAngle(playerid, angle);

		for(new i = 1; i < MAX_VEHICLES; i++)
		{
			if(Vehicle[i][vStatus] == 0)
			{
				Vehicle[i][vStatus] = 1;
				Vehicle[i][vModel] = modelid;
				Vehicle[i][vPosition][0] = X;
				Vehicle[i][vPosition][1] = Y;
				Vehicle[i][vPosition][2] = Z;
				Vehicle[i][vAngle] = angle;
				Vehicle[i][vPrice] = 0;
				valstr(Vehicle[i][vOwner], 0);
				Vehicle[i][vInterior] = GetPlayerInterior(playerid);
				Vehicle[i][vVirtualWorld] = GetPlayerVirtualWorld(playerid);
				valstr(Vehicle[i][vCarPlate], 0);

				UpdateVehicle(i, 0);
				SaveVehicle(i);

				format(string, sizeof(string), "Created civilian vehicle %d", i);
				SendClientMessage(playerid, COLOR_PINK, string);

				vehicles++;

				gettime(hour, minute, second);
				getdate(year, month, day);

				format(acmdlogstring, sizeof(acmdlogstring), "Command: /createcvehicle %d %s %d [%d/%d/%d] [%d:%d:%d]", i, model, day, month, year, hour, minute, second);
				AdminCommandLog(playerid, acmdlogstring);
				return 1;
			}
		}
	}
	else
		return SendClientMessage(playerid, COLOR_LIGHTNEUTRALBLUE, "You are not authorized to use this command!");
	return 1;
}

CMD:dcv(playerid, params[])
	return cmd_deletecvehicle(playerid, params);

CMD:deletecvehicle(playerid, params[]) // Deletes a civilian vehicle
{
	new vid, day, month, year, hour, minute, second, acmdlogstring[128], string[128];

	if(Player[playerid][pAdminLevel] == 6 || IsPlayerAdmin(playerid))
	{
		if(sscanf(params, "i", vid))
			return SendClientMessage(playerid, COLOR_LIGHTCYAN, "Syntax: /deletecvehicle [vehicleid]");

		if(Vehicle[vid][vStatus] == 1 && IsValidCivilianVehicle(vid) == 1)
		{
			DestroyVehicle(vid);
			Vehicle[vid][vStatus] = 0;  
		}
		else
			return SendClientMessage(playerid, COLOR_NEUTRAL, "Vehicle does not exist.");

		SaveVehicle(vid);
		
		format(string, sizeof(string), "Deleted civilian vehicle %d", vid);
		SendClientMessage(playerid, COLOR_PINK, string);

		gettime(hour, minute, second);
		getdate(year, month, day);

		format(acmdlogstring, sizeof(acmdlogstring), "Command: /deletecvehicle %d [%d/%d/%d] [%d:%d:%d]", vid, day, month, year, hour, minute, second);
		AdminCommandLog(playerid, acmdlogstring);
	}
	else
		return SendClientMessage(playerid, COLOR_LIGHTNEUTRALBLUE, "You are not authorized to use this command!");
	return 1;
}

CMD:moveds(playerid, params[])
	return cmd_movedealership(playerid, params);

CMD:movedealership(playerid, params[])
{
	new dealershipid, day, month, year, hour, minute, second, acmdlogstring[128], Float:X, Float:Y, Float:Z;

	if(Player[playerid][pAdminLevel] == 6 || IsPlayerAdmin(playerid))
	{
		if(sscanf(params, "i", dealershipid))
			return SendClientMessage(playerid, COLOR_LIGHTCYAN, "Syntax: /movedealership [dealershipid]");

		if(IsValidDealership(dealershipid) == 0)
			return SendClientMessage(playerid, COLOR_NEUTRAL, "Invalid dealership ID!");

		GetPlayerPos(playerid, X, Y, Z);
		DealershipPosition[dealershipid][0] = X;
		DealershipPosition[dealershipid][1] = Y;
		DealershipPosition[dealershipid][2] = Z;

		UpdateDealership(dealershipid, 1);
		SaveDealership(dealershipid);

		gettime(hour, minute, second);
		getdate(year, month, day);

		format(acmdlogstring, sizeof(acmdlogstring), "Command: /movedealership %d [%d/%d/%d] [%d:%d:%d]", dealershipid, day, month, year, hour, minute, second);
		AdminCommandLog(playerid, acmdlogstring);
	}
	else
		return SendClientMessage(playerid, COLOR_LIGHTNEUTRALBLUE, "You are not authorized to use this command!");
	return 1;
}

CMD:mdv(playerid, params[])
	return cmd_movedvehicle(playerid, params);

CMD:movedvehicle(playerid, params[])
{
	new vid, Float:X, Float:Y, Float:Z, day, month, year, hour, minute, second, acmdlogstring[128], Float:angle;

	if(Player[playerid][pAdminLevel] == 6 || IsPlayerAdmin(playerid))
	{
		if(sscanf(params, "i", vid))
			return SendClientMessage(playerid, COLOR_LIGHTCYAN, "Syntax: /movedvehicle [vehicleid]");

		if(IsValidDealershipVehicle(vid) == 1)
		{
			GetPlayerPos(playerid, X, Y, Z);
			GetPlayerFacingAngle(playerid, angle);
			Vehicle[vid][vPosition][0] = X;
			Vehicle[vid][vPosition][1] = Y;
			Vehicle[vid][vPosition][2] = Z;
			Vehicle[vid][vAngle] = angle;

			gettime(hour, minute, second);
			getdate(year, month, day);

			UpdateVehicle(vid, 1);
			SaveVehicle(vid);

			format(acmdlogstring, sizeof(acmdlogstring), "Command: /movedvehicle %d [%d/%d/%d] [%d:%d:%d]", vid, day, month, year, hour, minute, second);
			AdminCommandLog(playerid, acmdlogstring);
		}
		else
			SendClientMessage(playerid, COLOR_LIGHTCYAN, "Not a valid dealership vehicle.");
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

CMD:respawn(playerid)
{
	if(Player[playerid][pAdminLevel] == 6 || IsPlayerAdmin(playerid))
		SpawnPlayer(playerid);
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
			// if(targetid == playerid)
			// 	return SendClientMessage(playerid, COLOR_NEUTRAL, "You cannot use this command on yourself.");

			SafeGivePlayerMoney(targetid, amount);
			SaveAccount(targetid);

			format(string, sizeof(string), "You have given $%d to %s.", amount, GetName(targetid));
			SendClientMessage(playerid, COLOR_LIGHTBLUE, string);

			format(string, sizeof(string), "Admin %s has given you $%d.", GetName(playerid), amount);
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

			format(string, sizeof(string), "Admins %s has given you weapon ID %d with %d ammo.", GetName(playerid), weapon, ammo);
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
	new targetid, hp, Float:X, Float:Y, Float:Z, day, month, year, hour, minute, second, acmdlogstring[128], string[128];
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

			format(string, sizeof(string), "Admin %s has set your HP to %d.", GetName(playerid), hp);
			SendClientMessage(targetid, COLOR_MEDIUMBLUE, string);

			format(string, sizeof(string), "You have set %s's HP to %d.", GetName(targetid), hp);
			SendClientMessage(playerid, COLOR_MEDIUMBLUE, string);

			format(acmdlogstring, sizeof(acmdlogstring), "Command: /sethp %s %d [%d/%d/%d] [%d:%d:%d]", GetName(targetid), hp, day, month, year, hour, minute, second);
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
CMD:createjob(playerid, params[])
{
	new jobname[128], joblevel, Float:jobx, Float:joby, Float:jobz, string[512];

	if(Player[playerid][pAdminLevel] == 6 || IsPlayerAdmin(playerid))
	{
		if(sscanf(params, "s[128]i", jobname, joblevel))
			return SendClientMessage(playerid, COLOR_LIGHTCYAN, "Syntax:/createjob [jobname] [joblevel]");

		for(new i = 0; i < MAX_JOB_LIMIT; i++)
		{
			if(!Job[i][JobStatus])
			{
				GetPlayerPos(playerid, jobx, joby, jobz);

				Job[i][JobID] = i;
				Job[i][JobStatus] = 1;
				Job[i][JobName] = jobname;
				Job[i][JobLevel] = joblevel;
				Job[i][JobX] = jobx;
				Job[i][JobY] = joby;
				Job[i][JobZ] = jobz;

				format(string, sizeof(string), "Created Job %s", Job[i][JobName]);
				SendClientMessage(playerid, COLOR_LIGHTBLUE, string);

				UpdateJob(i, 0);
				SaveJob(i);
				
				return 1;
			}
		}
		SendClientMessage(playerid, 0xE74C3CFF, "Maximum job limit reached!");
		return 1;
	}

	SendClientMessage(playerid, COLOR_RED, "Unautorized Command");
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

// ------------------------------------------------------------------------------------------------
CMD:ahelp(playerid, params[]) // Displays a list of commands with levels that can be used by the admins 
{
	if(Player[playerid][pAdminLevel] >= 1 || IsPlayerAdmin(playerid))
	{
		ShowPlayerDialog(playerid, DIALOG_AHELP, DIALOG_STYLE_MSGBOX, "Admin Commands", "Level 1\n\n/mute    /unmute    /kick    /warn    /unwarn    /reports    /ar (/acceptreport)    /a    /up    /slap    /fly    /pm    /ahelp\n\nLevel2\n\n/ban    /banacip    /banip    /unban    /unbanip    /freeze    /unfreeze    /rtv (/respawnthisvehicle)    /rav (/respawnallvehicles)", "Okay", "");
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

// ------------------------------------------------------------------------------------------------
CMD:admins(playerid, params[]) // Displays a list of online admins with levels
{
	new string[128];

	SendClientMessage(playerid, COLOR_YELLOW, "Online Admins:");
	for(new i = 0; i < MAX_PLAYERS; i++)
	{
		if(IsPlayerConnected(i))
		{
			if(Player[i][pAdminLevel] > 0)
			{
				format(string, sizeof(string), "%s | Level %d", GetName(i), Player[i][pAdminLevel]);
				SendClientMessage(playerid, COLOR_MEDIUMBLUE, string);
			}
		}
	}
	return 1;
}

// ------------------------------------------------------------------------------------------------
CMD:engine(playerid, params[]) // Starts and stops the engine of a vehicle
{
	new engine, lights, alarm, doors, bonnet, boot, objective, string[256];
	new vid = GetPlayerVehicleID(playerid);

	if(IsBicycle(vid))
		return SendClientMessage(playerid, COLOR_NEUTRAL, "Your vehicle does not have an engine.");

	if(GetPlayerState(playerid) != PLAYER_STATE_DRIVER)
		return SendClientMessage(playerid, COLOR_NEUTRAL, "You are not driving a vehicle.");

	GetVehicleParamsEx(vid, engine, lights, alarm, doors, bonnet, boot, objective);

	if(engine == 1)
	{
		engine = 0;
		format(string, sizeof(string), "%s stops the engine of a %s.", GetName(playerid), GetVehicleName(vid));
		RangeSend(30.0, playerid, string, COLOR_PINK);
	}
	else
	{
		if(Vehicle[vid][vFuel] > 0)
		{
			engine = 1;
			format(string, sizeof(string), "%s starts the engine of a %s.", GetName(playerid), GetVehicleName(vid));
			RangeSend(30.0, playerid, string, COLOR_PINK);
		}
		else
			SendClientMessage(playerid, COLOR_LIGHTCYAN, "Your vehicle is out of fuel.");
	}

	SetVehicleParamsEx(vid, engine, lights, alarm, doors, bonnet, boot, objective);
	return 1;
}

CMD:eject(playerid, params[]) // Ejects a player out of the vehicle
{
	new targetid, string[128];

	if(sscanf(params, "u", targetid))
		return SendClientMessage(playerid, COLOR_LIGHTCYAN, "USAGE: /eject [playerid]");

	new vid = GetPlayerVehicleID(playerid);

	if(IsBicycle(vid))
		return SendClientMessage(playerid, COLOR_NEUTRAL, "Your vehicle does not have any passengers.");

	if(GetPlayerState(playerid) != PLAYER_STATE_DRIVER)
		return SendClientMessage(playerid, COLOR_NEUTRAL, "You are not driving a vehicle.");

	if(IsPlayerConnected(targetid))
	{
		if(!IsPlayerInVehicle(playerid, vid))
			return SendClientMessage(playerid, COLOR_NEUTRAL, "The player is not in your vehicle.");

		RemovePlayerFromVehicle(targetid);
		format(string, sizeof(string), "Vehicle driver %s has thrown %s out of the vehicle.", GetName(playerid), GetName(targetid));

		for(new i = 0; i < MAX_PLAYERS; i++)
		{
			if((IsPlayerInVehicle(i, vid)) && (GetPlayerState(i) != PLAYER_STATE_DRIVER))
			{
				SendClientMessage(i, COLOR_SEAGREEN, string);
			}
		}

		format(string, sizeof(string), "Vehicle driver %s has thrown you out of the vehicle.", GetName(playerid));
		SendClientMessage(targetid, COLOR_SEAGREEN, string);

		format(string, sizeof(string), "You have thrown %s out of the vehicle.", GetName(targetid));
		SendClientMessage(playerid, COLOR_SEAGREEN, string);
	}
	return 1;
}

CMD:ejectall(playerid, params[]) // Ejects all players out of the vehicle
{
	new string[128];
	new vid = GetPlayerVehicleID(playerid);

	if(IsBicycle(vid))
		return SendClientMessage(playerid, COLOR_NEUTRAL, "Your vehicle does not have any passengers.");

	if(GetPlayerState(playerid) != PLAYER_STATE_DRIVER)
		return SendClientMessage(playerid, COLOR_NEUTRAL, "You are not driving a vehicle.");

	for(new i = 0; i < MAX_PLAYERS; i++)
	{
		if(IsPlayerInVehicle(i, vid) && i != playerid)
		{
			RemovePlayerFromVehicle(i);
			format(string, sizeof(string), "Vehicle driver %s has thrown you out of the vehicle.", GetName(playerid));
			SendClientMessage(i, COLOR_SEAGREEN, string);
		}
	}
	return 1;
}

CMD:lights(playerid, params[]) // Turns the lights of a vehicle on or off
{
	new engine, lights, alarm, doors, bonnet, boot, objective;
	new vid = GetPlayerVehicleID(playerid);

	if(IsBicycle(vid))
		return SendClientMessage(playerid, COLOR_NEUTRAL, "Your vehicle does not have any passengers.");

	if(GetPlayerState(playerid) != PLAYER_STATE_DRIVER)
		return SendClientMessage(playerid, COLOR_NEUTRAL, "You are not driving a vehicle.");

	GetVehicleParamsEx(vid, engine, lights, alarm, doors, bonnet, boot, objective);

	if(lights == 1)
		lights = 0;
	else
		lights = 1;

	SetVehicleParamsEx(vid, engine, lights, alarm, doors, bonnet, boot, objective);
	return 1;
}

CMD:park(playerid, params[]) // Saves the player's vehicle's position
{
	new Float:X, Float:Y, Float:Z, Float:angle;
	if(GetPlayerState(playerid) == PLAYER_STATE_DRIVER)
	{
		new vid = GetPlayerVehicleID(playerid);
	
		if(strcmp(Vehicle[vid][vOwner], GetName(playerid)) == 0 && IsValidPlayerVehicle(vid))
		{
			GetPlayerPos(playerid, X, Y, Z);
			GetPlayerFacingAngle(playerid, angle);

			Vehicle[vid][vPosition][0] = X;
			Vehicle[vid][vPosition][1] = Y;
			Vehicle[vid][vPosition][2] = Z;
			Vehicle[vid][vAngle] = angle;

			UpdatePlayerVehicle(vid, 1);
			SaveVehicle(vid);

			SetVehicleToRespawn(vid);

			SendClientMessage(playerid, COLOR_PINK, "You have parked your vehicle.");
		}
		else
			return SendClientMessage(playerid, COLOR_NEUTRAL, "You do not own this vehicle.");
	}
	else
		return SendClientMessage(playerid, COLOR_NEUTRAL, "You are not driving a vehicle.");
	return 1;
}

// ------------------------------------------------------------------------------------------------
CMD:stats(playerid, params[]) // Shows the stats of the player
{
	new string[256], sex[64], vipstring[128];

	if(Player[playerid][pSex] == 0)
		sex = "Male";
	else
		sex = "Female";

	if(Player[playerid][pVipLevel] > 0)
		format(vipstring, sizeof(vipstring), "Yes, Level %d", Player[playerid][pVipLevel]);
	else
		vipstring = "No";

	format(string, sizeof(string), "*** %s (%d) ***", GetName(playerid), playerid);
	SendClientMessage(playerid, COLOR_WHITE, string);

	format(string, sizeof(string), "Level:[%d]  Sex:[%s]  Cash:[$%d]  Bank:[$%d]  Phone:[%d]  Hours Played:[%.1f]", GetPlayerScore(playerid), sex, Player[playerid][pCash], 0, 0, Player[playerid][pHoursPlayed]);
	SendClientMessage(playerid, COLOR_WHITE, string);

	format(string, sizeof(string), "Times Arrested:[%d]  Respect:[%d/%d]  Next Level:[$%d]  VIP:[%s]", 0, Player[playerid][pRespectPoints], (GetPlayerScore(playerid) * 4) - 2, GetPlayerScore(playerid) * 250, vipstring);
	SendClientMessage(playerid, COLOR_WHITE, string);

	format(string, sizeof(string), "Drugs:[%d] Materials:[%d] WantedLevel:[%d] Crimes:[%d] Deaths:[%d] Kills:[%d] Jailed:[%s]", 0, 0, 0, 0, 0, 0, "No");
	SendClientMessage(playerid, COLOR_WHITE, string);

	format(string, sizeof(string), "Lotto Number:[%d] MarriedTo:[%s] Job:[%s] Faction:[%s] Rank:[%s] FactionWarns:[%d/5] FPunish[%d/60] ", 0, "None", "None", "None", "None", 0, 0);
	SendClientMessage(playerid, COLOR_WHITE, string);
	return 1;
}

CMD:buylevel(playerid, params[]) // Buys next level
{
	new string[512];
	new totalneeded = (GetPlayerScore(playerid) * 4) - 2;
	new nextlevel = GetPlayerScore(playerid) * 250;
	if(Player[playerid][pRespectPoints] >= totalneeded)
	{
		if(Player[playerid][pCash] >= GetPlayerScore(playerid) * 250)
		{
			if(Player[playerid][pVipLevel] == 0)
			{
				if(Player[playerid][pRespectPoints] > totalneeded)
				{
					format(string, sizeof(string), "Warning: You are not a VIP. So %d respect points will be lost. Are you sure you want to buy next level?", -(totalneeded - Player[playerid][pRespectPoints]));
					ShowPlayerDialog(playerid, DIALOG_BUY_LEVEL, DIALOG_STYLE_MSGBOX, "Buy Level", string, "Yes", "No");
					return 1;
				}
			}
			BuyLevel(playerid);
		}
		else
			format(string, sizeof(string), "You need at least $%d to buy next level", nextlevel);   
		SendClientMessage(playerid, COLOR_NEUTRAL, string);
	}
	return 1;
}

// ------------------------------------------------------------------------------------------------

CMD:gotoj(playerid, params[])
	return cmd_gotojob(playerid, params);

CMD:gotojob(playerid, params[])
{
	new targetplace[30], targetid;

	if(sscanf(params, "s[30]", targetplace))
		return SendClientMessage(playerid, COLOR_ORANGE, "Syntax: /gotojob [jobid/jobname]");

	if(IsNumeric(targetplace))
	{
		targetid = strval(targetplace);
		SetPlayerPos(playerid, Job[targetid][JobX], Job[targetid][JobY], Job[targetid][JobZ]);
		return 1;
	}
	else
	{
		for(new i = 0; i < MAX_JOB_LIMIT; i++)
		{
			if(strcmp(targetplace, Job[i][JobName]) == 0)
			{
				SetPlayerPos(playerid, Job[i][JobX], Job[i][JobY], Job[i][JobZ]);
				return 1;
			}
		}
	}
	return SendClientMessage(playerid, COLOR_RED, "No job like that dude!");
}


CMD:getjob(playerid)
{
	for(new i = 0; i < MAX_JOB_LIMIT; i++)
	{
		if(IsPlayerInRangeOfPoint(playerid, 3.0,Job[i][JobX], Job[i][JobY], Job[i][JobZ]))
		{
			Player[playerid][pJobStatus] = 1;

			Player[playerid][pJobID] = Job[i][JobID];

			SaveAccount(playerid); //Change the status of player's profile.

			new string[128];
			format(string, sizeof(string), "You got the job of %s.", Job[i][JobName]);
			return SendClientMessage(playerid, COLOR_LIGHTBLUE, string);
		}
	}

	return SendClientMessage(playerid, COLOR_RED, "You are not in range of the any headquarters.");
}

CMD:work(playerid)
{
	if(Player[playerid][pJobStatus] == 1)
	{
		if(Player[playerid][pJobID] == 0)
		{
			if(IsPlayerInRangeOfPoint(playerid, 3.0,Job[0][JobX], Job[0][JobY], Job[0][JobZ]))
			{
				new Trucks[] = {403, 514, 515};
				working[playerid] = true;

				Truck[playerid][T_vehicle] = CreateVehicle(Trucks[random(3)], 2192.4851, -2264.9810, 13.5469, 319.9930, random(256), random(256), -1);
				Truck[playerid][Trailer] = CreateVehicle( 450, 2181.2285, -2280.8203, 13.5469, 318.6438, Truck[playerid][r_color2], 5, -1);
				PutPlayerInVehicle(playerid, Truck[playerid][T_vehicle], 0);
				AttachTrailerToVehicle(Truck[playerid][Trailer], Truck[playerid][T_vehicle]);

				SetPlayerCheckpoint(playerid, checkPositions[r_checkzone][0], checkPositions[r_checkzone][1], checkPositions[r_checkzone][2], 15.0);
				r_checkzone++;
				return SendClientMessage(playerid, COLOR_BRIGHTRED, "Move to new red markers shown on the map. To quit your work anytime just leave the vehice.");
			}
		}
		else if(Player[playerid][pJobID] == 2)
		{
			if(IsPlayerInRangeOfPoint(playerid, 3.0, Job[2][JobX], Job[2][JobY], Job[2][JobZ]))
			{
				new r_farm = random(3);
				SetPlayerCheckpoint(playerid, FarmX[r_farm], FarmY[r_farm], FarmZ[r_farm], 5.0);
				SendClientMessage(playerid, COLOR_GREEN, "Goto Checkpoint...");
			}
			
		}
		else
			return SendClientMessage(playerid, COLOR_RED, "You are not in range of your job.");
	}
	return SendClientMessage(playerid, COLOR_RED, "You don't have a job."); 
}

// ------------------------------------------------------------------------------------------------

CMD:service(playerid, params[])
{
	new ser[128];

	if(sscanf(params, "s[128]", ser))
		return SendClientMessage(playerid, COLOR_LIGHTCYAN, "Syntax:/service [taxi/medical/mechanic]");

	if(strcmp(ser, "mechanic") == 0)
	{
		new flag = 0;
		for(new i = 0; i < MAX_PLAYERS; i++)
		{
			if(IsPlayerConnected(i) && Player[i][pJobID] == 1)
			{
				new string[128];
				format(string, sizeof(string), "%s requested for a mechanic. To accept the job, type: /accept", GetName(playerid));
				SendClientMessage( i, COLOR_NEUTRALGREEN, string);
				MechanicServiceRequest[playerid] = true;
				flag = 1;
			}
		}
		if(flag == 0)
			return SendClientMessage(playerid, COLOR_WHITE, "No Mechanic online.");
	}
	else        
		return SendClientMessage(playerid, COLOR_WHITE, "Please choose between the given options. [taxi/medical/mechanic]");
	return 1;
}

CMD:accept(playerid)
{
	if(Player[playerid][pJobID] == 1)
	{
		for(new i = 0; i < MAX_PLAYERS; i++)
		{
			if(MechanicServiceRequest[i] == true)
			{
				new Float:x, Float:y, Float:z;
				GetPlayerPos(i, x, y, z);
				SetPlayerMapIcon(playerid, playerid, x, y, z, 0, 3, MAPICON_GLOBAL_CHECKPOINT);
				MechanicServiceRequest[i] = false;
				MechanicRequestGenerated[playerid] = true;
				MechanicOnService[i] = playerid;
				return SendClientMessage(playerid, COLOR_LIGHTNEUTRALBLUE, "Goto red marker shown on Map.");
			}
		}
		return SendClientMessage(playerid, COLOR_LIGHTBLUE, "No job available or already taken");
	}
	return 1;
}

CMD:refill(playerid, params[])
{
	new targetid, price;
	if(sscanf(params, "ui", targetid, price))
		return SendClientMessage(playerid, COLOR_LIGHTCYAN, "Syntax:/refill [targetid] [price offer to refill the fuel]");
	if(price < 0)
		return SendClientMessage(playerid, COLOR_RED, "Price cannot be negative");

	if(Player[playerid][pJobID] == 1 || Player[playerid][pAdminLevel] >= 4)
	{
		if(GetPlayerState(targetid) == PLAYER_STATE_DRIVER)
		{
			new vid, engine, lights, alarm, doors, bonnet, boot, objective, Float:x, Float:y, Float:z;
			vid = GetPlayerVehicleID(targetid);
			GetVehiclePos(vid, x, y, z);
			GetVehicleParamsEx(vid, engine, lights, alarm, doors, bonnet, boot, objective);
			if(playerid == targetid)
			{
				if(Player[playerid][pMechanicSkill] > 3)
				{
					Vehicle[vid][vFuel] = 100.0;
				}
				else
					return SendClientMessage(playerid, COLOR_RED, "You need to be a mechanic of level 4 or more to use this command on yourself.");
			}
			else
			{
				if(IsPlayerInRangeOfPoint(playerid, 4.0, x, y, z))
				{
					if(engine == 0)
					{
						new string[512];
						format(string, sizeof(string), "Mechanic %s of skill level %d offered you refill for price %d.\nTo accept the offer type:/acceptrefill or to bargain just chat with the mechanic.", GetName(playerid), Player[playerid][pMechanicSkill], price);
						MechanicOnService[targetid] = playerid;
						MechanicRequestGenerated[playerid] = true;
						RefillPrice[targetid] = price;
						return SendClientMessage(targetid, COLOR_SEAGREEN, string);
					}
					else
					{
						SendClientMessage(playerid, COLOR_WHITE, "Car engine must be turned off to give a refill.");
						return SendClientMessage(targetid, COLOR_RED, "Plaese turn off your car's engine to have a refill.");
					}
				}
				else
					return SendClientMessage(playerid, COLOR_ORANGE, "You need to be closer to the vehicle to refill it.");
			}       
		}
		else
		{
			SendClientMessage(playerid, COLOR_WHITE, "Your customer is not in driver seat.");
			return SendClientMessage(targetid, COLOR_WHITE, "You need to be in driver seat to have a refill of your car.");
		}
	}
	else
		return SendClientMessage(playerid, COLOR_RED, "You need to be a mechanic to use this command.");
	return 1;
}

CMD:repair(playerid, params[])
{
	new vid, engine, lights, alarm, doors, bonnet, boot, objective;

	if(Player[playerid][pJobID] == 1)
	{
		if(GetPlayerState(playerid) == PLAYER_STATE_DRIVER && Player[playerid][pMechanicSkill] > 3)
		{
			vid = GetPlayerVehicleID(playerid);
			GetVehicleParamsEx(vid, engine, lights, alarm, doors, bonnet, boot, objective);
			RepairVehicle(vid);
			SendClientMessage(playerid, COLOR_GREEN, "Vehicle repaired");
		}
		else if(MechanicRequestGenerated[playerid] == true)
		{
			new targetid, price, Float:x, Float:y, Float:z;

			if(sscanf(params, "ui", targetid, price))
				return SendClientMessage(playerid, COLOR_LIGHTCYAN, "Syntax:/repair [targetid] [price offer to repair the car]");
			if(price < 0)
				return SendClientMessage(playerid, COLOR_RED, "Price cannot be negative");

			vid = GetPlayerVehicleID(targetid);
			GetVehiclePos(vid, x, y, z);
			GetVehicleParamsEx(vid, engine, lights, alarm, doors, bonnet, boot, objective);
			
			if(GetPlayerState(targetid) == PLAYER_STATE_DRIVER)
			{
				if(IsPlayerInRangeOfPoint(playerid, 4.0, x, y, z))
				{
					if(engine == 0)
					{
						new string[512];
						format(string, sizeof(string), "Mechanic %s of skill level %d offered you repair for price %d.\nTo accept the offer type:/acceptrepair or to bargain just chat with the mechanic.", GetName(playerid), Player[playerid][pMechanicSkill], price);
						MechanicOnService[targetid] = playerid;
						
						RefillPrice[targetid] = price;
						return SendClientMessage(targetid, COLOR_SEAGREEN, string);
					}
					else
					{
						SendClientMessage(playerid, COLOR_WHITE, "Car engine must be turned off to give a repair.");
						return SendClientMessage(targetid, COLOR_RED, "Plaese turn off your car's engine to have a repair.");
					}
				}
				else
					return SendClientMessage(playerid, COLOR_ORANGE, "You need to be closer to the vehicle to repair it.");
			}
			else
			{
				SendClientMessage(playerid, COLOR_WHITE, "Your customer is not in driver seat.");
				return SendClientMessage(targetid, COLOR_WHITE, "You need to be in driver seat to have a repair for your car.");
			}

		}
		else
			return SendClientMessage(playerid, COLOR_RED, "Currently there is no request for mechanic.");
	}
	else
		return SendClientMessage(playerid, COLOR_RED, "You need to be a mechanic to use this command.");
	return 1;
}

CMD:acceptrefill(playerid)
{
	if(MechanicRequestGenerated[playerid] == true)
	{
		new targetid, string[128];
		targetid = MechanicOnService[playerid];
		new vid = GetPlayerVehicleID(playerid);
		new Float:remainingFuel = 100 - Vehicle[vid][vFuel];
		if(Player[targetid][pMechanicSkill] < 2)
		{
			if(remainingFuel > 20.0)
			{
				Vehicle[vid][vFuel] += 20.0;
				format(string, sizeof(string), "Vehicle fuel refilled upto 20%%");
				SendClientMessage(playerid, COLOR_GREEN, string);
			}
			else
			{
				Vehicle[vid][vFuel] += remainingFuel;
				SendClientMessage(playerid, COLOR_GREEN, "Fuel refilled");
			}
		}
		else if(Player[targetid][pMechanicSkill] == 2)
		{
			if(remainingFuel > 40.0)
			{
				Vehicle[vid][vFuel] += 40.0;
				format(string, sizeof(string), "Vehicle fuel refilled upto 40%%");
				SendClientMessage(playerid, COLOR_GREEN, string);
			}
			else
			{
				Vehicle[vid][vFuel] += remainingFuel;
				SendClientMessage(playerid, COLOR_GREEN, "Fuel refilled");
			}
		}
		else if(Player[targetid][pMechanicSkill] == 3)
		{
			if(remainingFuel > 60.0)
			{
				Vehicle[vid][vFuel] += 60.0;
				format(string, sizeof(string), "Vehicle fuel refilled upto 60%%");
				SendClientMessage(playerid, COLOR_GREEN, string);
			}
			else
			{
				Vehicle[vid][vFuel] += remainingFuel;
				SendClientMessage(playerid, COLOR_GREEN, "Fuel refilled");
			}
		}
		else if(Player[targetid][pMechanicSkill] == 4)
		{
			if(remainingFuel > 80.0)
			{
				Vehicle[vid][vFuel] += 80.0;
				format(string, sizeof(string), "Vehicle fuel refilled upto 80%%");
				SendClientMessage(playerid, COLOR_GREEN, string);
			}
			else
			{
				Vehicle[vid][vFuel] += remainingFuel;
				SendClientMessage(playerid, COLOR_GREEN, "Fuel refilled");
			}
		}
		else
		{
			if(remainingFuel == 100.0)
			{
				Vehicle[vid][vFuel] += 100.0;
				format(string, sizeof(string), "Vehicle fuel refilled upto 100%%");
				SendClientMessage(playerid, COLOR_GREEN, string);
			}
			else
			{
				Vehicle[vid][vFuel] += remainingFuel;
				SendClientMessage(playerid, COLOR_GREEN, "Fuel refilled");
			}
		}
		RemovePlayerMapIcon(targetid, playerid);
		MechanicOnService[playerid] = -1;
		MechanicRequestGenerated[targetid] = false;
	}
	else if(MechanicOnService[playerid] == -1)
	{
		return SendClientMessage(playerid, COLOR_RED, "No mechanic has accepted your request yet.");
	}
	else
		return SendClientMessage(playerid, COLOR_RED, "You need to request a mechanic first. To request for a mechanic. Type:/service mechanic");
	return 1;
}

CMD:acceptrepair(playerid)
{
	if(MechanicRequestGenerated[playerid] == true)
	{
		new targetid = MechanicOnService[playerid];
		new vid = GetPlayerVehicleID(playerid);
		RepairVehicle(vid);
		SendClientMessage(playerid, COLOR_GREEN, "Vehicle repaired");
		RemovePlayerMapIcon(targetid, playerid);
		MechanicOnService[playerid] = -1;
		MechanicRequestGenerated[targetid] = false;
	}
	else if(MechanicOnService[playerid] == -1)
	{
		return SendClientMessage(playerid, COLOR_RED, "No mechanic has accepted your request yet.");
	}
	else
		return SendClientMessage(playerid, COLOR_RED, "You need to request a mechanic first. To request for a mechanic. Type:/service mechanic");
	return 1;
}