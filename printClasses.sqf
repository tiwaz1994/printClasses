modTag = ["NORTH"];
//base filter function
TWZ_filter = {
params ["_item"];
	private _filter = false;
	private _scope = [_x,"scope"] call BIS_fnc_returnConfigEntry;
	if (typeName _scope == "SCALAR" && {_scope >= 2}) then
	{
		if (count modTag != 0) then 
		{
			{
				private _className = configName (_item);
				if (_x in (_className splitString "_")) then 
				{
					_filter = true;
				};
			} forEach modTag;
		};
	};
	_filter //return bool
};

//extract data from CfgVehicles
allCfgVehiclesData = [];
{
	private _filter = [_x] call TWZ_filter;
	if (_filter) then {
		private _vehClass = [_x,"vehicleClass"] call BIS_fnc_returnConfigEntry;
		private "_vehicleClassIndex";
		{
			if (_vehClass in _x) then {
				_vehicleClassIndex = _forEachIndex;
			};
		} forEach allCfgVehiclesData;
		if (isNil "_vehicleClassIndex") then {
			allCfgVehiclesData pushBack [_vehClass,[]];
			_vehicleClassIndex = allCfgVehiclesData find [_vehClass,[]];
		};
		private _className = configName _x;
		((allCfgVehiclesData select _vehicleClassIndex) select 1) pushBack _className;
	};
} forEach ("true" configClasses (configFile >> "CfgVehicles"));

//extract data from CfgWeapons
allCfgWeaponsData = [];
{
	private _filter = [_x] call TWZ_filter;
	if (_filter) then {
		private _className = configName _x;
		_className call BIS_fnc_itemType params ["_weapCat","_weapType"];
		private ["_weapCatIndex","_weapTypeIndex"];
		{
			if (_weapCat in _x) then {
				_weapCatIndex = _forEachIndex;
			};
		} forEach allCfgWeaponsData;
		if (isNil "_weapCatIndex") then {
			allCfgWeaponsData pushBack [_weapCat];
			_weapCatIndex = allCfgWeaponsData find [_weapCat];
		};
		{
			if (_weapType in _x) then {
				_weapTypeIndex = _forEachIndex;
			};
		} forEach (allCfgWeaponsData select _weapCatIndex);
		if (isNil "_weapTypeIndex") then {
			(allCfgWeaponsData select _weapCatIndex) pushBack [_weapType,[]];
			_weapTypeIndex = (allCfgWeaponsData select _weapCatIndex) find [_weapType,[]];
		};
		(((allCfgWeaponsData select _weapCatIndex) select _weapTypeIndex) select 1) pushBack _className;
	};
} forEach ("true" configClasses (configFile >> "CfgWeapons"));


//extract data from CfgMagazines
_allAmmoTypes = ["Grenades","Explosives","Launcher","Magazines","Vehicles","Other"];
{
	missionNameSpace setVariable [format ["CfgMagazines%1",_x],[]];
} forEach _allAmmoTypes;
{
	private _filter = [_x] call TWZ_filter;
	if (_filter) then {
		private _magType = [_x,"nameSound"] call BIS_fnc_returnConfigEntry;
		private _className = configName _x;
		private _parents = [_x,true] call BIS_fnc_returnParents;
		switch (true) do {
			case ("VehicleMagazine" in _parents): {CfgMagazinesVehicles pushBack _className};
			case ("HandGrenade" in _parents): {CfgMagazinesGrenades pushBack _className};
			case ("CA_LauncherMagazine" in _parents): {CfgMagazinesLauncher pushBack _className};
			default {
				private _magType = toLower ( [_x,"nameSound"] call BIS_fnc_returnConfigEntry);
				switch (_magType) do
				{
					case "satchelcharge";
					case "mine": {CfgMagazinesExplosives pushBack _className};
					case "magazine";
					case "mgun": {CfgMagazinesMagazines pushBack _className};
					default {CfgMagazinesOther pushBack _className};
				};
			};
		};
	};
} forEach ("true" configClasses (configFile >> "CfgMagazines"));
allCfgAmmodata = [];
allCfgAmmoData = [["Magazines",CfgMagazinesMagazines],["Launcher",CfgMagazinesLauncher],["Grenades",CfgMagazinesGrenades],["Explosives",CfgMagazinesExplosives],["Vehicles",CfgMagazinesVehicles],["Other",CfgMagazinesOther]];

//extract data from CfgFaces
allCfgFaces = [];
{
	private _filter = [_x] call TWZ_filter;
	if (_filter) then {
		private _className = configName _x;
		allCfgFaces pushBack _className;
	};
} forEach ("true" configClasses (configFile >> "CfgFaces" >> "Man_A3"));

//extract data from cfgGlasses
allCfgGlasses = [];
{
	private _filter = [_x] call TWZ_filter;
	if (_filter) then {
		private _className = configName _x;
		allCfgGlasses pushBack _className;
	};
} forEach ("true" configClasses (configFile >> "CfgGlasses"));


//get factions,groups and the units in them
allFactions = [];
private _allSides = (configFile >> "CfgGroups") call BIS_fnc_getCfgSubClasses;
{
	private _side = _x;
	private _factions = (configFile >> "CfgGroups" >> _side) call BIS_fnc_getCfgSubClasses;
	{
		private _faction = _x;
		private _tagFilter = false;
		{
			if (_x in (_faction splitString "_")) then {
				_tagFilter = true;
			};
		} forEach modTag;
		if (_tagFilter) then {
			private _factionIndex = count allFactions;
			allFactions pushBack [_faction];
			private _groupTypes = (configFile >> "CfgGroups" >> _side >> _faction) call BIS_fnc_getCfgSubClasses;
			{
				private _groupType = _x;
				private _groupTypeIndex = count (allFactions select _factionIndex);
				(allFactions select _factionIndex) pushBack [_groupType];
				private _groups = (configFile >> "CfgGroups" >> _side >> _faction >> _groupType) call BIS_fnc_getCfgSubClasses;
				{
					private _group = _x;
					private _groupIndex = count ((allFactions select _factionIndex) select _groupTypeIndex);
					((allFactions select _factionIndex) select _groupTypeIndex) pushBack [_group,[]];
					private _units = (configFile >> "CfgGroups" >> _side >> _faction >> _groupType >> _group) call BIS_fnc_getCfgSubClasses;
					{
						private _unit = _x;
						private _unitClass = getText (configFile >> "CfgGroups" >> _side >> _faction >> _groupType >> _group >> _unit >> "vehicle");
						((((allFactions select _factionIndex) select _groupTypeIndex) select _groupIndex) select 1) pushBack _unitClass;
					} forEach _units;
				} forEach _groups;
			} forEach _groupTypes;
		};
	} forEach _factions;
} forEach _allSides;




alldata = [["CfgWeapons",allCfgWeaponsData],["CfgAmmo",allCfgAmmoData],["CfgFaces",allCfgFaces],["CfgGlasses",allCfgGlasses],["CfgVehicles",allCfgVehiclesData],["CfgGroups",allFactions]];
//ASCII control characters
_br = toString [13,10]; //carriage return, line feed
_tab = toString [9];	//horizontal tab
//print _output
outPut = [];
{
	{
		if (typeName _x == "STRING") then
		{
			outPut pushBack _x;
			outPut PushBack _br;
		}
		else
		{
			{
				if (typeName _x == "STRING") then
				{
					outPut pushBack _tab;
					outPut pushBack _x;
					outPut PushBack _br;
				}
				else
				{
					{
						if (typeName _x == "STRING") then
						{
							outPut pushBack _tab;
							outPut pushBack _tab;
							outPut pushBack _x;
							outPut PushBack _br;
						}
						else
						{
							{
								if (typeName _x == "STRING") then
								{
									outPut pushBack _tab;
									outPut pushBack _tab;
									outPut pushBack _tab;
									outPut pushBack _x;
									outPut PushBack _br;
								}
								else
								{
									{
										if (typeName _x == "STRING") then
										{
											outPut pushBack _tab;
											outPut pushBack _tab;
											outPut pushBack _tab;
											outPut pushBack _tab;
											outPut pushBack _x;
											outPut PushBack _br;
										}
										else
										{
											{
												if (typeName _x == "STRING") then
												{
													outPut pushBack _tab;
													outPut pushBack _tab;
													outPut pushBack _tab;
													outPut pushBack _tab;
													outPut pushBack _tab;
													outPut pushBack _x;
													outPut PushBack _br;
												}
												else
												{
													systemChat "something probably went wrong";
												};
											} forEach _x;
										};
									} forEach _x;
								};
							} forEach _x;
						};
					} forEach _x;
				};
			} forEach _x;
		};
	} forEach _x;
} forEach allData;
