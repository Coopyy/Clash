global function FFA_Init

const array<string> guns = [
    "none",
    "random",
	"mp_weapon_alternator_smg", // 2
	"mp_weapon_arc_launcher", // 3
	"mp_weapon_autopistol", // 4
	"mp_weapon_car",
	"mp_weapon_defender",
	"mp_weapon_dmr",
	"mp_weapon_doubletake",
	"mp_weapon_epg",
	"mp_weapon_esaw",
	"mp_weapon_g2",
	"mp_weapon_hemlok",
	"mp_weapon_hemlok_smg",
	"mp_weapon_lmg",
	"mp_weapon_lstar",
	"mp_weapon_mastiff",
	"mp_weapon_mgl",
	"mp_weapon_pulse_lmg",
	"mp_weapon_r97",
	"mp_weapon_rocket_launcher",
	"mp_weapon_rspn101",
	"mp_weapon_rspn101_og",
	"mp_weapon_semipistol",
	"mp_weapon_shotgun",
	"mp_weapon_shotgun_pistol",
	"mp_weapon_smart_pistol",
	"mp_weapon_smr",
	"mp_weapon_sniper",
	"mp_weapon_softball",
	"mp_weapon_vinson",
	"mp_weapon_wingman",
	"mp_weapon_wingman_n",
	"mp_titanweapon_leadwall",
	"mp_titanweapon_meteor",
	"mp_titanweapon_particle_accelerator",
	"mp_titanweapon_predator_cannon",
	"mp_titanweapon_rocketeer_rocketstream",
	"mp_titanweapon_sniper",
	"mp_titanweapon_sticky_40mm",
	"mp_titanweapon_xo16_shorty",
	"mp_titanweapon_xo16_vanguard"
]

const array<string> offhands = [
    "none",
    "random",
	"mp_ability_cloak", // 2
	"mp_ability_grapple",
	"mp_ability_heal",
	"mp_ability_holopilot",
	"mp_ability_shifter",
	"mp_weapon_deployable_cover",
	"mp_weapon_frag_grenade",
	"mp_weapon_grenade_electric_smoke",
	"mp_weapon_grenade_emp",
	"mp_weapon_grenade_gravity",
	"mp_weapon_grenade_sonar",
	"mp_weapon_satchel",
	"mp_weapon_thermite_grenade",
	"mp_titanability_hover",
	"mp_titanweapon_arc_wave",
	"mp_titanweapon_flame_wall",
	"mp_titanweapon_dumbfire_rockets",
	"mp_titanweapon_salvo_rockets",
	"mp_titanweapon_stun_laser",
	"mp_titanweapon_laser_lite"
]

const array<string> melees = [
    "none",
    "random",
	"melee_pilot_emptyhanded", // 2
	"melee_pilot_arena",
	"melee_pilot_sword",
	"melee_pilot_kunai",
	"melee_titan_punch_vanguard",
	"melee_titan_sword"
]

struct {
    int maxplayers
	array<string> playingplayers
    table<string, string> matchups = {}
    bool canstart = false
} file

void function FFA_Init()
{
    file.maxplayers = GetCurrentPlaylistVarInt( "max_players", 0 );
    if (file.maxplayers == 4 || file.maxplayers == 8 || file.maxplayers == 16) 
    {
        SetLoadoutGracePeriodEnabled( false ) // prevent modifying loadouts with grace period
        SetWeaponDropsEnabled( false )
        ClassicMP_ForceDisableEpilogue( true )
        SetShouldUseRoundWinningKillReplay( true )
        SetRoundBased( true )
        SetRespawnsEnabled( true )
        Riff_ForceTitanAvailability( eTitanAvailability.Never )
        Riff_ForceBoostAvailability( eBoostAvailability.Disabled )

	    AddCallback_OnPlayerKilled( OnPlayerKilled )
	    AddCallback_OnPlayerRespawned( OnPlayerRespawned )
	    AddCallback_OnClientDisconnected( OnPlayerDisconnected )
        AddCallback_GameStateEnter(eGameState.Prematch, SetupRound);
        SetTimeoutWinnerDecisionFunc( TimeoutCheck )
        thread StartGame()
    }
    else //default ffa
    {
        ClassicMP_ForceDisableEpilogue( true )
	    ScoreEvent_SetupEarnMeterValuesForMixedModes()
    }
}

void function OnPlayerDisconnected(entity player)
{   
    thread DisconnectedThread(player)
}

void function DisconnectedThread(entity player) {
    while (IsValid(player)) //wait till disconnected player not exist
		wait 0.25
	CheckWin(false)
}

void function StartGame()
{
    while (GetPlayerArray().len() < file.maxplayers) 
    {
        wait 10.0
        foreach (entity player in GetPlayerArray())
            SendHudMessage( player, "Waiting For Players (" + GetPlayerArray().len() + "/" + file.maxplayers + ")" , -1, 0.2, 200, 200, 255, 255, 0.15, 999, 0 )
        SetServerVar( "roundEndTime", Time() + 60.0 ) // reset this shit
        
    }

    InitPlayers()
}

void function InitPlayers()
{
	SetServerVar( "roundEndTime", Time() + 60.0 )
	SetRespawnsEnabled( false ) // lol owned

	array<entity> players = GetPlayerArray()
	foreach ( entity plr in players ) {
        file.playingplayers.append(plr.GetPlayerName()) //should(tm) always be 4 8 or 16
    }
    file.canstart = true
    SetServerVar( "roundEndTime", Time())
}

void function SetupMatches() 
{
    file.matchups.clear()
    foreach (string plrname in file.playingplayers)  // in theory there will always be correct amount of "playing players" (4, 8, 16)
    {
        if (MatchupContainsString(plrname))
            continue

        string plr1 = file.playingplayers[RandomInt(file.playingplayers.len())]
		while (MatchupContainsString(plr1))
			plr1 = file.playingplayers[RandomInt(file.playingplayers.len())]

        string plr2 = file.playingplayers[RandomInt(file.playingplayers.len())]
		while (plr1 == plr2 || MatchupContainsString(plr2))
			plr2 = file.playingplayers[RandomInt(file.playingplayers.len())]

        file.playingplayers[plr1] <- plr2

        entity ent1 = GetPlayerFromName(plr1)
        entity ent2 = GetPlayerFromName(plr2)

        if (IsValid(ent1)) 
            SendHudMessage(ent1, "Your Opponent: " + plr2, -1, 0.2, 255, 200, 200, 255, 0.15, 5, 0.15 )
        if (IsValid(ent2)) 
            SendHudMessage(ent1, "Your Opponent: " + plr1, -1, 0.2, 255, 200, 200, 255, 0.15, 5, 0.15 )
    }

    wait 5
    CheckWin(false) 
}

void function SetupRound() 
{
    /*if (file.maxplayers == 4)
        SetPlaylistVarOverride( "roundscorelimit", "2" )
    else if (file.maxplayers == 8)
        SetPlaylistVarOverride( "roundscorelimit", "3" )
    else if (file.maxplayers == 16)
        SetPlaylistVarOverride( "roundscorelimit", "4" )*/

    if (!file.canstart)
        return

    PlayMusicToAll( eMusicPieceID.GAMEMODE_1 )
    SetupMatches() 

    // do spawns

    SetupLoadouts()
}

void function SetupLoadouts() {

    PilotLoadoutDef loadout = GetPilotLoadoutFromPersistentData(player, GetPersistentSpawnLoadoutIndex(player, "pilot"))
    array<string> offhandExclusions = []

    loadout.name = "???"

    loadout.primary = RandomiserGetRandomPilotWeapon()
    loadout.primaryAttachments = []
    loadout.primaryMods = []

    string primary = GetItemToUse(guns, "clash_primary");
    if (primary != "none")
    {
        loadout.primary = primary
        loadout.primaryAttachments = []
        loadout.primaryMods = []
    }

    string secondary = GetItemToUse(guns, "clash_secondary");
    if (secondary != "none")
    {
        loadout.secondary = secondary
        loadout.secondaryMods = []
    }

    string weapon3 = GetItemToUse(guns, "clash_at");
    if (weapon3 != "none")
    {
        loadout.weapon3 = weapon3
        loadout.weapon3Mods = []
    }

    string tac = GetItemToUse(offhands, "clash_tactical")
    if (tac != "none")
        loadout.special = tac;

    string ord = GetItemToUse(offhands, "clash_ordnance")
    if (ord != "none")
        loadout.ordnance = ord;

    string melee = GetItemToUse(melees, "clash_melee");
    if (melee != "none")
    {
        loadout.melee = 
        loadout.meleeMods = []
    }

    foreach (entity player in GetPlayerArray())
        if (IsValid(player))
            GivePilotLoadout(player, loadout)
}

void function CheckWin(bool roundend) 
{
    if (file.matchups.len() == 0)
        return

    foreach (key, value in file.matchups) 
    {
        entity player1 = GetPlayerFromName(key)
        entity player2 = GetPlayerFromName(value)

        if (player1 == null || !IsValid(player1)) // if both players for some reason disconnect, the 2nd one "moves on" to make sure playingplayer count doesnt explode
        {   
            HandleWin(player2)
            if (IsValid(player2)) 
                SendHudMessage(player2, "Opponent Disconnected. You Win This Round!", -1, 0.2, 200, 255, 200, 255, 0.15, 5, 0.15 )
            file.playingplayers.remove(file.playingplayers.find(key))
            delete file.matchups[key]
        } 
        else if (!IsAlive(player1))
        {   
            HandleWin(player2)
            SendHudMessage(player1, "You Have Been Eliminated", -1, 0.2, 255, 200, 200, 255, 0.15, 5, 0.15 )
            file.playingplayers.remove(file.playingplayers.find(key))
            delete file.matchups[key]
        }
        else if (player2 == null || !IsValid(player2))
        {   
            HandleWin(player1)
            if (IsValid(player1)) 
                SendHudMessage(player1, "Opponent Disconnected. You Win This Round!", -1, 0.2, 200, 255, 200, 255, 0.15, 5, 0.15 )
            file.playingplayers.remove(file.playingplayers.find(value))
            delete file.matchups[key]
        } 
        else if (!IsAlive(player2) || roundend)
        {   
            HandleWin(player1)
            SendHudMessage(player2, "You Have Been Eliminated", -1, 0.2, 255, 200, 200, 255, 0.15, 5, 0.15 )
            file.playingplayers.remove(file.playingplayers.find(value))
            delete file.matchups[key]
        }
    }

    if (!roundend && file.matchups.len() == 0)
        SetServerVar( "roundEndTime", Time()) //ghetto way to end round but w/e
}

void function HandleWin(entity player) 
{
    if (IsValid(player)) {
        AddTeamScore( player.GetTeam(), 1 )
        SendHudMessage(player, "You Win This Round!", -1, 0.2, 200, 255, 200, 255, 0.15, 5, 0.15 )
        player.FreezeControlsOnServer()
    }

    wait 5
    if (IsValid(player)) {
        if (IsAlive(player))
            player.Die()
        player.UnfreezeControlsOnServer()
        SendHudMessage(player, "Wait Until This Round is Finished", -1, 0.2, 255, 255, 255, 255, 0.15, 15, 0.15 )
    }
}

void function OnPlayerKilled( entity victim, entity attacker, var damageInfo )
{
	if ( victim != attacker && victim.IsPlayer() && attacker.IsPlayer() && GetGameState() == eGameState.Playing )
	{
        SetRoundWinningKillReplayAttacker(attacker)
		attacker.AddToPlayerGameStat( PGS_ASSAULT_SCORE, 1 )
	}
    CheckWin(false)
}

void function OnPlayerRespawned(entity player) 
{
    thread OnPlayerRespawned_Threaded(player)
}

void function OnPlayerRespawned_Threaded( entity player )
{
	// bit of a hack, need to rework earnmeter code to have better support for completely disabling it
	// rn though this just waits for earnmeter code to set the mode before we set it back
	WaitFrame()
	if ( IsValid( player ) ) 
    {
		PlayerEarnMeter_SetMode( player, eEarnMeterMode.DISABLED )
        if (!file.playingplayers.contains(player.GetPlayerName()))
            player.Die()
        else 
        {
            foreach ( entity weapon in player.GetMainWeapons() )
		        player.TakeWeaponNow( weapon.GetWeaponClassName() )
	        foreach ( entity weapon in player.GetOffhandWeapons() )
		        player.TakeWeaponNow( weapon.GetWeaponClassName() )
        }
    }
}

int function TimeoutCheck()
{
    CheckWin(true)
	return TEAM_UNASSIGNED
}

bool function MatchupContains(entity player)
{
	foreach (key, value in file.matchups) {
		if (player.GetPlayerName() == key || player.GetPlayerName() == value)
			return true
	}
	return false
}

bool function MatchupContainsString(string player)
{
	foreach (key, value in file.matchups) {
		if (player == key || player == value)
			return true
	}
	return false
}

entity function GetPlayerFromName(string name)
{
	foreach (entity player in GetPlayerArray())
        if (player.GetPlayerName() == name)
            return player
    return null
}

entity function GetOpponent(entity player) {
    foreach (key, value in file.matchups) {
		if (player.GetPlayerName() == key)
		{
            entity opponent = GetPlayerFromName(value)
            if (IsValid(opponent))
                return opponent
        }
        else if (player.GetPlayerName() == value)
		{
            entity opponent = GetPlayerFromName(key)
            if (IsValid(opponent))
                return opponent
        }
	}

    return null
}


string function GetItemToUse(array<string> list, string pvarslot) 
[
    int weaponindex = GetCurrentPlaylistVarInt(pvarslot, 0)
    string weap = list[weaponindex]

    if (weap == "random")
        return list[2 + RandomInt(list.len() - 2)]

    return weap
]