global function FFA_Init

#if SERVER
global function SetupLoadouts
global function GetItemToUse
#endif  

const array<string> guns = [
    "",
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
    "",
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
    "",
    "random",
	"melee_pilot_emptyhanded", // 2
	"melee_pilot_arena",
	"melee_pilot_sword",
	"melee_pilot_kunai",
	"melee_titan_punch_vanguard",
	"melee_titan_sword"
]

const array<vector> possspawns1 = [
    <890.238, 3629.25, 4483>, //0 
    <293.426, 3071.25, 4483>
]

const array<vector> possspawns2 = [
    <890.238, 4018.49, 4483>,
    <293.426, 4586.78, 4483>
]

const array<vector> possangles1 = [
    <0, -90, 0>,
    <0, 90, 0>
]

const array<vector> possangles2 = [
    <0, 90, 0>,
    <0, -90, 0>
]

struct {
    int maxplayers
	array<string> playingplayers
    table<string, string> matchups = {}
    bool canstart = false

    string primary
    string secondary
    string weapon3
    string special
    string ordnance
    string melee
} file

void function FFA_Init()
{
    file.maxplayers = GetCurrentPlaylistVarInt( "max_players", 0 );
    if ((file.maxplayers == 4 || file.maxplayers == 8 || file.maxplayers == 16) && GetMapName() == "mp_drydock")
    {
        PrecacheModel($"models/crashsite/crashsite_ship_metal_panel_01.mdl")
        PrecacheModel($"models/IMC_base/outer_gate_imc_closed.mdl")
        PrecacheModel($"models/ola/sewer_staircase_01.mdl")
        PrecacheModel($"models/props/generator_coop/generator_coop_blackbox.mdl")
        PrecacheModel($"models/IMC_base/barrier_low_airport_IMC.mdl")

		AddClientCommandCallback("!matchups", CommandMatchups)
		AddClientCommandCallback("!matchup", CommandMatchups)

        SetLoadoutGracePeriodEnabled( false ) // prevent modifying loadouts with grace period
        SetWeaponDropsEnabled( false )
        ClassicMP_ForceDisableEpilogue( true )
        SetShouldUseRoundWinningKillReplay( true )
        //SetRoundBased( true )
        //SetRespawnsEnabled( true )
        Riff_ForceTitanAvailability( eTitanAvailability.Never )
        Riff_ForceBoostAvailability( eBoostAvailability.Disabled )

	    AddCallback_OnPlayerKilled( OnPlayerKilled )
	    AddCallback_OnPlayerRespawned( OnPlayerRespawned )
	    AddCallback_OnClientDisconnected( OnPlayerDisconnected )
        AddCallback_GameStateEnter(eGameState.Prematch, SetupRound);
		AddCallback_GameStateEnter(eGameState.Playing, DoSpawns);
        SetTimeoutWinnerDecisionFunc( TimeoutCheck )
        thread StartGame()
        thread DoMap()
    }
    else //default ffa
    {
        ClassicMP_ForceDisableEpilogue( true )
	    ScoreEvent_SetupEarnMeterValuesForMixedModes()
    }
}

void function DoMap() {
	for (int T = 0; T < 9; T++)
	{
        wait 1
	AddMapProp( $"models/crashsite/crashsite_ship_metal_panel_01.mdl",  <0, 0, 500 * T> + < 127.747, 2956.58, 4479.69 >, < 0, 0, 0 >, true, 6000)
	AddMapProp( $"models/crashsite/crashsite_ship_metal_panel_01.mdl",  <0, 0, 500 * T> + < 127.747, 3082.08, 4479.69 >, < 0, 0, 0 >, true, 6000)
	AddMapProp( $"models/crashsite/crashsite_ship_metal_panel_01.mdl",  <0, 0, 500 * T> + < 127.747, 3207.58, 4479.69 >, < 0, 0, 0 >, true, 6000)
	AddMapProp( $"models/crashsite/crashsite_ship_metal_panel_01.mdl",  <0, 0, 500 * T> + < 127.747, 3333.08, 4479.69 >, < 0, 0, 0 >, true, 6000)
	AddMapProp( $"models/crashsite/crashsite_ship_metal_panel_01.mdl",  <0, 0, 500 * T> + < 127.747, 3458.58, 4479.69 >, < 0, 0, 0 >, true, 6000)
	AddMapProp( $"models/crashsite/crashsite_ship_metal_panel_01.mdl",  <0, 0, 500 * T> + < 127.747, 3584.08, 4479.69 >, < 0, 0, 0 >, true, 6000)
	AddMapProp( $"models/crashsite/crashsite_ship_metal_panel_01.mdl",  <0, 0, 500 * T> + < 127.747, 3709.58, 4479.69 >, < 0, 0, 0 >, true, 6000)
	AddMapProp( $"models/crashsite/crashsite_ship_metal_panel_01.mdl",  <0, 0, 500 * T> + < 127.747, 3835.08, 4479.69 >, < 0, 0, 0 >, true, 6000)
	AddMapProp( $"models/crashsite/crashsite_ship_metal_panel_01.mdl",  <0, 0, 500 * T> + < 127.747, 3960.58, 4479.69 >, < 0, 0, 0 >, true, 6000)
	AddMapProp( $"models/crashsite/crashsite_ship_metal_panel_01.mdl",  <0, 0, 500 * T> + < 127.747, 4086.08, 4479.69 >, < 0, 0, 0 >, true, 6000)
	AddMapProp( $"models/crashsite/crashsite_ship_metal_panel_01.mdl",  <0, 0, 500 * T> + < 127.747, 4211.58, 4479.69 >, < 0, 0, 0 >, true, 6000)
	AddMapProp( $"models/crashsite/crashsite_ship_metal_panel_01.mdl",  <0, 0, 500 * T> + < 127.747, 4337.08, 4479.69 >, < 0, 0, 0 >, true, 6000)
	AddMapProp( $"models/crashsite/crashsite_ship_metal_panel_01.mdl",  <0, 0, 500 * T> + < 127.747, 4462.58, 4479.69 >, < 0, 0, 0 >, true, 6000)
	AddMapProp( $"models/crashsite/crashsite_ship_metal_panel_01.mdl",  <0, 0, 500 * T> + < 127.747, 4588.08, 4479.69 >, < 0, 0, 0 >, true, 6000)
	AddMapProp( $"models/crashsite/crashsite_ship_metal_panel_01.mdl",  <0, 0, 500 * T> + < 127.747, 4713.58, 4479.69 >, < 0, 0, 0 >, true, 6000)
	AddMapProp( $"models/crashsite/crashsite_ship_metal_panel_01.mdl",  <0, 0, 500 * T> + < 297.138, 2956.58, 4479.69 >, < 0, 0, 0 >, true, 6000)
	AddMapProp( $"models/crashsite/crashsite_ship_metal_panel_01.mdl",  <0, 0, 500 * T> + < 466.529, 2956.58, 4479.69 >, < 0, 0, 0 >, true, 6000)
	AddMapProp( $"models/crashsite/crashsite_ship_metal_panel_01.mdl",  <0, 0, 500 * T> + < 635.92, 2956.58, 4479.69 >, < 0, 0, 0 >, true, 6000)
	AddMapProp( $"models/crashsite/crashsite_ship_metal_panel_01.mdl",  <0, 0, 500 * T> + < 805.311, 2956.58, 4479.69 >, < 0, 0, 0 >, true, 6000)
	AddMapProp( $"models/crashsite/crashsite_ship_metal_panel_01.mdl",  <0, 0, 500 * T> + < 974.702, 2956.58, 4479.69 >, < 0, 0, 0 >, true, 6000)
	AddMapProp( $"models/crashsite/crashsite_ship_metal_panel_01.mdl",  <0, 0, 500 * T> + < 1144.09, 2956.58, 4479.69 >, < 0, 0, 0 >, true, 6000)
	AddMapProp( $"models/crashsite/crashsite_ship_metal_panel_01.mdl",  <0, 0, 500 * T> + < 1144.09, 3082.08, 4479.69 >, < 0, 0, 0 >, true, 6000)
	AddMapProp( $"models/crashsite/crashsite_ship_metal_panel_01.mdl",  <0, 0, 500 * T> + < 1144.09, 3207.58, 4479.69 >, < 0, 0, 0 >, true, 6000)
	AddMapProp( $"models/crashsite/crashsite_ship_metal_panel_01.mdl",  <0, 0, 500 * T> + < 1144.09, 3333.08, 4479.69 >, < 0, 0, 0 >, true, 6000)
	AddMapProp( $"models/crashsite/crashsite_ship_metal_panel_01.mdl",  <0, 0, 500 * T> + < 1144.09, 3458.58, 4479.69 >, < 0, 0, 0 >, true, 6000)
	AddMapProp( $"models/crashsite/crashsite_ship_metal_panel_01.mdl",  <0, 0, 500 * T> + < 1144.09, 3584.08, 4479.69 >, < 0, 0, 0 >, true, 6000)
	AddMapProp( $"models/crashsite/crashsite_ship_metal_panel_01.mdl",  <0, 0, 500 * T> + < 1144.09, 3709.58, 4479.69 >, < 0, 0, 0 >, true, 6000)
	AddMapProp( $"models/crashsite/crashsite_ship_metal_panel_01.mdl",  <0, 0, 500 * T> + < 1144.09, 3835.08, 4479.69 >, < 0, 0, 0 >, true, 6000)
	AddMapProp( $"models/crashsite/crashsite_ship_metal_panel_01.mdl",  <0, 0, 500 * T> + < 1144.09, 3960.58, 4479.69 >, < 0, 0, 0 >, true, 6000)
	AddMapProp( $"models/crashsite/crashsite_ship_metal_panel_01.mdl",  <0, 0, 500 * T> + < 1144.09, 4086.08, 4479.69 >, < 0, 0, 0 >, true, 6000)
	AddMapProp( $"models/crashsite/crashsite_ship_metal_panel_01.mdl",  <0, 0, 500 * T> + < 1144.09, 4211.58, 4479.69 >, < 0, 0, 0 >, true, 6000)
	AddMapProp( $"models/crashsite/crashsite_ship_metal_panel_01.mdl",  <0, 0, 500 * T> + < 1144.09, 4337.08, 4479.69 >, < 0, 0, 0 >, true, 6000)
	AddMapProp( $"models/crashsite/crashsite_ship_metal_panel_01.mdl",  <0, 0, 500 * T> + < 1144.09, 4462.58, 4479.69 >, < 0, 0, 0 >, true, 6000)
	AddMapProp( $"models/crashsite/crashsite_ship_metal_panel_01.mdl",  <0, 0, 500 * T> + < 1144.09, 4588.08, 4479.69 >, < 0, 0, 0 >, true, 6000)
	AddMapProp( $"models/crashsite/crashsite_ship_metal_panel_01.mdl",  <0, 0, 500 * T> + < 1144.09, 4713.58, 4479.69 >, < 0, 0, 0 >, true, 6000)
	AddMapProp( $"models/crashsite/crashsite_ship_metal_panel_01.mdl",  <0, 0, 500 * T> + < 297.138, 4713.58, 4479.69 >, < 0, 0, 0 >, true, 6000)
	AddMapProp( $"models/crashsite/crashsite_ship_metal_panel_01.mdl",  <0, 0, 500 * T> + < 466.529, 4713.58, 4479.69 >, < 0, 0, 0 >, true, 6000)
	AddMapProp( $"models/crashsite/crashsite_ship_metal_panel_01.mdl",  <0, 0, 500 * T> + < 635.92, 4713.58, 4479.69 >, < 0, 0, 0 >, true, 6000)
	AddMapProp( $"models/crashsite/crashsite_ship_metal_panel_01.mdl",  <0, 0, 500 * T> + < 805.311, 4713.58, 4479.69 >, < 0, 0, 0 >, true, 6000)
	AddMapProp( $"models/crashsite/crashsite_ship_metal_panel_01.mdl",  <0, 0, 500 * T> + < 974.702, 4713.58, 4479.69 >, < 0, 0, 0 >, true, 6000)
	AddMapProp( $"models/crashsite/crashsite_ship_metal_panel_01.mdl",  <0, 0, 500 * T> + < 1144.09, 4713.58, 4479.69 >, < 0, 0, 0 >, true, 6000)
	AddMapProp( $"models/crashsite/crashsite_ship_metal_panel_01.mdl",  <0, 0, 500 * T> + < 297.138, 3082.08, 4479.69 >, < 0, 0, 0 >, true, 6000)
	AddMapProp( $"models/crashsite/crashsite_ship_metal_panel_01.mdl",  <0, 0, 500 * T> + < 297.138, 3207.58, 4479.69 >, < 0, 0, 0 >, true, 6000)
	AddMapProp( $"models/crashsite/crashsite_ship_metal_panel_01.mdl",  <0, 0, 500 * T> + < 297.138, 3333.08, 4479.69 >, < 0, 0, 0 >, true, 6000)
	AddMapProp( $"models/crashsite/crashsite_ship_metal_panel_01.mdl",  <0, 0, 500 * T> + < 297.138, 3458.58, 4479.69 >, < 0, 0, 0 >, true, 6000)
	AddMapProp( $"models/crashsite/crashsite_ship_metal_panel_01.mdl",  <0, 0, 500 * T> + < 297.138, 3584.08, 4479.69 >, < 0, 0, 0 >, true, 6000)
	AddMapProp( $"models/crashsite/crashsite_ship_metal_panel_01.mdl",  <0, 0, 500 * T> + < 297.138, 3709.58, 4479.69 >, < 0, 0, 0 >, true, 6000)
	AddMapProp( $"models/crashsite/crashsite_ship_metal_panel_01.mdl",  <0, 0, 500 * T> + < 297.138, 3835.08, 4479.69 >, < 0, 0, 0 >, true, 6000)
	AddMapProp( $"models/crashsite/crashsite_ship_metal_panel_01.mdl",  <0, 0, 500 * T> + < 297.138, 3960.58, 4479.69 >, < 0, 0, 0 >, true, 6000)
	AddMapProp( $"models/crashsite/crashsite_ship_metal_panel_01.mdl",  <0, 0, 500 * T> + < 297.138, 4086.08, 4479.69 >, < 0, 0, 0 >, true, 6000)
	AddMapProp( $"models/crashsite/crashsite_ship_metal_panel_01.mdl",  <0, 0, 500 * T> + < 297.138, 4211.58, 4479.69 >, < 0, 0, 0 >, true, 6000)
	AddMapProp( $"models/crashsite/crashsite_ship_metal_panel_01.mdl",  <0, 0, 500 * T> + < 297.138, 4337.08, 4479.69 >, < 0, 0, 0 >, true, 6000)
	AddMapProp( $"models/crashsite/crashsite_ship_metal_panel_01.mdl",  <0, 0, 500 * T> + < 297.138, 4462.58, 4479.69 >, < 0, 0, 0 >, true, 6000)
	AddMapProp( $"models/crashsite/crashsite_ship_metal_panel_01.mdl",  <0, 0, 500 * T> + < 297.138, 4588.08, 4479.69 >, < 0, 0, 0 >, true, 6000)
	AddMapProp( $"models/crashsite/crashsite_ship_metal_panel_01.mdl",  <0, 0, 500 * T> + < 297.138, 4713.58, 4479.69 >, < 0, 0, 0 >, true, 6000)
	AddMapProp( $"models/crashsite/crashsite_ship_metal_panel_01.mdl",  <0, 0, 500 * T> + < 466.529, 4588.08, 4479.69 >, < 0, 0, 0 >, true, 6000)
	AddMapProp( $"models/crashsite/crashsite_ship_metal_panel_01.mdl",  <0, 0, 500 * T> + < 466.529, 4462.58, 4479.69 >, < 0, 0, 0 >, true, 6000)
	AddMapProp( $"models/crashsite/crashsite_ship_metal_panel_01.mdl",  <0, 0, 500 * T> + < 466.529, 4337.08, 4479.69 >, < 0, 0, 0 >, true, 6000)
	AddMapProp( $"models/crashsite/crashsite_ship_metal_panel_01.mdl",  <0, 0, 500 * T> + < 466.529, 4211.58, 4479.69 >, < 0, 0, 0 >, true, 6000)
	AddMapProp( $"models/crashsite/crashsite_ship_metal_panel_01.mdl",  <0, 0, 500 * T> + < 466.529, 4086.08, 4479.69 >, < 0, 0, 0 >, true, 6000)
	AddMapProp( $"models/crashsite/crashsite_ship_metal_panel_01.mdl",  <0, 0, 500 * T> + < 466.529, 3960.58, 4479.69 >, < 0, 0, 0 >, true, 6000)
	AddMapProp( $"models/crashsite/crashsite_ship_metal_panel_01.mdl",  <0, 0, 500 * T> + < 466.529, 3835.08, 4479.69 >, < 0, 0, 0 >, true, 6000)
	AddMapProp( $"models/crashsite/crashsite_ship_metal_panel_01.mdl",  <0, 0, 500 * T> + < 466.529, 3709.58, 4479.69 >, < 0, 0, 0 >, true, 6000)
	AddMapProp( $"models/crashsite/crashsite_ship_metal_panel_01.mdl",  <0, 0, 500 * T> + < 466.529, 3584.08, 4479.69 >, < 0, 0, 0 >, true, 6000)
	AddMapProp( $"models/crashsite/crashsite_ship_metal_panel_01.mdl",  <0, 0, 500 * T> + < 466.529, 3458.58, 4479.69 >, < 0, 0, 0 >, true, 6000)
	AddMapProp( $"models/crashsite/crashsite_ship_metal_panel_01.mdl",  <0, 0, 500 * T> + < 466.529, 3333.08, 4479.69 >, < 0, 0, 0 >, true, 6000)
	AddMapProp( $"models/crashsite/crashsite_ship_metal_panel_01.mdl",  <0, 0, 500 * T> + < 466.529, 3207.58, 4479.69 >, < 0, 0, 0 >, true, 6000)
	AddMapProp( $"models/crashsite/crashsite_ship_metal_panel_01.mdl",  <0, 0, 500 * T> + < 466.529, 3082.08, 4479.69 >, < 0, 0, 0 >, true, 6000)
	AddMapProp( $"models/crashsite/crashsite_ship_metal_panel_01.mdl",  <0, 0, 500 * T> + < 635.92, 3082.08, 4479.69 >, < 0, 0, 0 >, true, 6000)
	AddMapProp( $"models/crashsite/crashsite_ship_metal_panel_01.mdl",  <0, 0, 500 * T> + < 635.92, 3207.58, 4479.69 >, < 0, 0, 0 >, true, 6000)
	AddMapProp( $"models/crashsite/crashsite_ship_metal_panel_01.mdl",  <0, 0, 500 * T> + < 635.92, 3333.08, 4479.69 >, < 0, 0, 0 >, true, 6000)
	AddMapProp( $"models/crashsite/crashsite_ship_metal_panel_01.mdl",  <0, 0, 500 * T> + < 635.92, 3458.58, 4479.69 >, < 0, 0, 0 >, true, 6000)
	AddMapProp( $"models/crashsite/crashsite_ship_metal_panel_01.mdl",  <0, 0, 500 * T> + < 635.92, 3584.08, 4479.69 >, < 0, 0, 0 >, true, 6000)
	AddMapProp( $"models/crashsite/crashsite_ship_metal_panel_01.mdl",  <0, 0, 500 * T> + < 635.92, 3709.58, 4479.69 >, < 0, 0, 0 >, true, 6000)
	AddMapProp( $"models/crashsite/crashsite_ship_metal_panel_01.mdl",  <0, 0, 500 * T> + < 635.92, 3835.08, 4479.69 >, < 0, 0, 0 >, true, 6000)
	AddMapProp( $"models/crashsite/crashsite_ship_metal_panel_01.mdl",  <0, 0, 500 * T> + < 635.92, 3960.58, 4479.69 >, < 0, 0, 0 >, true, 6000)
	AddMapProp( $"models/crashsite/crashsite_ship_metal_panel_01.mdl",  <0, 0, 500 * T> + < 635.92, 4086.08, 4479.69 >, < 0, 0, 0 >, true, 6000)
	AddMapProp( $"models/crashsite/crashsite_ship_metal_panel_01.mdl",  <0, 0, 500 * T> + < 635.92, 4211.58, 4479.69 >, < 0, 0, 0 >, true, 6000)
	AddMapProp( $"models/crashsite/crashsite_ship_metal_panel_01.mdl",  <0, 0, 500 * T> + < 635.92, 4337.08, 4479.69 >, < 0, 0, 0 >, true, 6000)
	AddMapProp( $"models/crashsite/crashsite_ship_metal_panel_01.mdl",  <0, 0, 500 * T> + < 635.92, 4462.58, 4479.69 >, < 0, 0, 0 >, true, 6000)
	AddMapProp( $"models/crashsite/crashsite_ship_metal_panel_01.mdl",  <0, 0, 500 * T> + < 635.92, 4588.08, 4479.69 >, < 0, 0, 0 >, true, 6000)
	AddMapProp( $"models/crashsite/crashsite_ship_metal_panel_01.mdl",  <0, 0, 500 * T> + < 805.311, 4588.08, 4479.69 >, < 0, 0, 0 >, true, 6000)
	AddMapProp( $"models/crashsite/crashsite_ship_metal_panel_01.mdl",  <0, 0, 500 * T> + < 805.311, 4462.58, 4479.69 >, < 0, 0, 0 >, true, 6000)
	AddMapProp( $"models/crashsite/crashsite_ship_metal_panel_01.mdl",  <0, 0, 500 * T> + < 805.311, 4337.08, 4479.69 >, < 0, 0, 0 >, true, 6000)
	AddMapProp( $"models/crashsite/crashsite_ship_metal_panel_01.mdl",  <0, 0, 500 * T> + < 805.311, 4211.58, 4479.69 >, < 0, 0, 0 >, true, 6000)
	AddMapProp( $"models/crashsite/crashsite_ship_metal_panel_01.mdl",  <0, 0, 500 * T> + < 805.311, 4086.08, 4479.69 >, < 0, 0, 0 >, true, 6000)
	AddMapProp( $"models/crashsite/crashsite_ship_metal_panel_01.mdl",  <0, 0, 500 * T> + < 805.311, 3960.58, 4479.69 >, < 0, 0, 0 >, true, 6000)
	AddMapProp( $"models/crashsite/crashsite_ship_metal_panel_01.mdl",  <0, 0, 500 * T> + < 805.311, 3835.08, 4479.69 >, < 0, 0, 0 >, true, 6000)
	AddMapProp( $"models/crashsite/crashsite_ship_metal_panel_01.mdl",  <0, 0, 500 * T> + < 805.311, 3709.58, 4479.69 >, < 0, 0, 0 >, true, 6000)
	AddMapProp( $"models/crashsite/crashsite_ship_metal_panel_01.mdl",  <0, 0, 500 * T> + < 805.311, 3584.08, 4479.69 >, < 0, 0, 0 >, true, 6000)
	AddMapProp( $"models/crashsite/crashsite_ship_metal_panel_01.mdl",  <0, 0, 500 * T> + < 805.311, 3458.58, 4479.69 >, < 0, 0, 0 >, true, 6000)
	AddMapProp( $"models/crashsite/crashsite_ship_metal_panel_01.mdl",  <0, 0, 500 * T> + < 805.311, 3333.08, 4479.69 >, < 0, 0, 0 >, true, 6000)
	AddMapProp( $"models/crashsite/crashsite_ship_metal_panel_01.mdl",  <0, 0, 500 * T> + < 805.311, 3207.58, 4479.69 >, < 0, 0, 0 >, true, 6000)
	AddMapProp( $"models/crashsite/crashsite_ship_metal_panel_01.mdl",  <0, 0, 500 * T> + < 805.311, 3082.08, 4479.69 >, < 0, 0, 0 >, true, 6000)
	AddMapProp( $"models/crashsite/crashsite_ship_metal_panel_01.mdl",  <0, 0, 500 * T> + < 974.702, 3082.08, 4479.69 >, < 0, 0, 0 >, true, 6000)
	AddMapProp( $"models/crashsite/crashsite_ship_metal_panel_01.mdl",  <0, 0, 500 * T> + < 974.702, 3207.58, 4479.69 >, < 0, 0, 0 >, true, 6000)
	AddMapProp( $"models/crashsite/crashsite_ship_metal_panel_01.mdl",  <0, 0, 500 * T> + < 974.702, 3333.08, 4479.69 >, < 0, 0, 0 >, true, 6000)
	AddMapProp( $"models/crashsite/crashsite_ship_metal_panel_01.mdl",  <0, 0, 500 * T> + < 974.702, 3458.58, 4479.69 >, < 0, 0, 0 >, true, 6000)
	AddMapProp( $"models/crashsite/crashsite_ship_metal_panel_01.mdl",  <0, 0, 500 * T> + < 974.702, 3584.08, 4479.69 >, < 0, 0, 0 >, true, 6000)
	AddMapProp( $"models/crashsite/crashsite_ship_metal_panel_01.mdl",  <0, 0, 500 * T> + < 974.702, 3709.58, 4479.69 >, < 0, 0, 0 >, true, 6000)
	AddMapProp( $"models/crashsite/crashsite_ship_metal_panel_01.mdl",  <0, 0, 500 * T> + < 974.702, 3835.08, 4479.69 >, < 0, 0, 0 >, true, 6000)
	AddMapProp( $"models/crashsite/crashsite_ship_metal_panel_01.mdl",  <0, 0, 500 * T> + < 974.702, 3960.58, 4479.69 >, < 0, 0, 0 >, true, 6000)
	AddMapProp( $"models/crashsite/crashsite_ship_metal_panel_01.mdl",  <0, 0, 500 * T> + < 974.702, 4086.08, 4479.69 >, < 0, 0, 0 >, true, 6000)
	AddMapProp( $"models/crashsite/crashsite_ship_metal_panel_01.mdl",  <0, 0, 500 * T> + < 974.702, 4211.58, 4479.69 >, < 0, 0, 0 >, true, 6000)
	AddMapProp( $"models/crashsite/crashsite_ship_metal_panel_01.mdl",  <0, 0, 500 * T> + < 974.702, 4337.08, 4479.69 >, < 0, 0, 0 >, true, 6000)
	AddMapProp( $"models/crashsite/crashsite_ship_metal_panel_01.mdl",  <0, 0, 500 * T> + < 974.702, 4462.58, 4479.69 >, < 0, 0, 0 >, true, 6000)
	AddMapProp( $"models/crashsite/crashsite_ship_metal_panel_01.mdl",  <0, 0, 500 * T> + < 974.702, 4588.08, 4479.69 >, < 0, 0, 0 >, true, 6000)
	if (T < 8)
	{
	AddMapProp( $"models/IMC_base/outer_gate_imc_closed.mdl",  <0, 0, 500 * T> + < 63.3655, 3183.24, 4479.89 >, < 0, 0, 0 >, true, 6000)
	AddMapProp( $"models/IMC_base/outer_gate_imc_closed.mdl",  <0, 0, 500 * T> + < 63.3655, 3822.84, 4479.89 >, < 0, 0, 0 >, true, 6000)
	AddMapProp( $"models/IMC_base/outer_gate_imc_closed.mdl",  <0, 0, 500 * T> + < 63.3655, 4462.44, 4479.89 >, < 0, 0, 0 >, true, 6000)
	AddMapProp( $"models/IMC_base/outer_gate_imc_closed.mdl",  <0, 0, 500 * T> + < 1258.29, 3854.67, 4463.87 >, < 0, 0, 0 >, true, 6000)
	AddMapProp( $"models/IMC_base/outer_gate_imc_closed.mdl",  <0, 0, 500 * T> + < 1258.29, 3215.06, 4463.87 >, < 0, 0, 0 >, true, 6000)
	AddMapProp( $"models/IMC_base/outer_gate_imc_closed.mdl",  <0, 0, 500 * T> + < 1258.29, 4494.27, 4463.87 >, < 0, 0, 0 >, true, 6000)
	AddMapProp( $"models/IMC_base/outer_gate_imc_closed.mdl",  <0, 0, 500 * T> + < 927.343, 4783.45, 4479.48 >, < 0, 90, 0 >, true, 6000)
	AddMapProp( $"models/IMC_base/outer_gate_imc_closed.mdl",  <0, 0, 500 * T> + < 287.742, 4783.45, 4479.48 >, < 0, 90, 0 >, true, 6000)
	AddMapProp( $"models/IMC_base/outer_gate_imc_closed.mdl",  <0, 0, 500 * T> + < 319.27, 2880.65, 4463.8 >, < 0, 90, 0 >, true, 6000)
	AddMapProp( $"models/IMC_base/outer_gate_imc_closed.mdl",  <0, 0, 500 * T> + < 958.871, 2880.65, 4463.8 >, < 0, 90, 0 >, true, 6000)
	AddMapProp( $"models/IMC_base/outer_gate_imc_closed.mdl",  <0, 0, 500 * T> + < 319.27, 2880.65, 4700.79 >, < 0, 90, 0 >, true, 6000)
	AddMapProp( $"models/IMC_base/outer_gate_imc_closed.mdl",  <0, 0, 500 * T> + < 958.871, 2880.65, 4700.79 >, < 0, 90, 0 >, true, 6000)
	AddMapProp( $"models/IMC_base/outer_gate_imc_closed.mdl",  <0, 0, 500 * T> + < 1258.29, 3215.06, 4700.86 >, < 0, 0, 0 >, true, 6000)
	AddMapProp( $"models/IMC_base/outer_gate_imc_closed.mdl",  <0, 0, 500 * T> + < 1258.29, 3854.67, 4700.86 >, < 0, 0, 0 >, true, 6000)
	AddMapProp( $"models/IMC_base/outer_gate_imc_closed.mdl",  <0, 0, 500 * T> + < 1258.29, 4494.27, 4700.86 >, < 0, 0, 0 >, true, 6000)
	AddMapProp( $"models/IMC_base/outer_gate_imc_closed.mdl",  <0, 0, 500 * T> + < 927.343, 4783.45, 4700.47 >, < 0, 90, 0 >, true, 6000)
	AddMapProp( $"models/IMC_base/outer_gate_imc_closed.mdl",  <0, 0, 500 * T> + < 287.742, 4783.45, 4700.47 >, < 0, 90, 0 >, true, 6000)
	AddMapProp( $"models/IMC_base/outer_gate_imc_closed.mdl",  <0, 0, 500 * T> + < 63.3655, 4462.44, 4700.87 >, < 0, 0, 0 >, true, 6000)
	AddMapProp( $"models/IMC_base/outer_gate_imc_closed.mdl",  <0, 0, 500 * T> + < 63.3655, 3822.84, 4700.87 >, < 0, 0, 0 >, true, 6000)
	AddMapProp( $"models/IMC_base/outer_gate_imc_closed.mdl",  <0, 0, 500 * T> + < 63.3655, 3183.24, 4700.87 >, < 0, 0, 0 >, true, 6000)
	AddMapProp( $"models/ola/sewer_staircase_01.mdl",  <0, 0, 500 * T> + < 143.052, 4255.96, 4495.68 >, < 0, 90, 0 >, true, 6000)
	AddMapProp( $"models/ola/sewer_staircase_01.mdl",  <0, 0, 500 * T> + < 271.552, 4255.96, 4495.68 >, < 0, 90, 0 >, true, 6000)
	AddMapProp( $"models/ola/sewer_staircase_01.mdl",  <0, 0, 500 * T> + < 160.15, 3392.12, 4495.02 >, < 0, -90, 0 >, true, 6000)
	AddMapProp( $"models/ola/sewer_staircase_01.mdl",  <0, 0, 500 * T> + < 288.649, 3392.12, 4495.02 >, < 0, -90, 0 >, true, 6000)
	AddMapProp( $"models/ola/sewer_staircase_01.mdl",  <0, 0, 500 * T> + < 160.105, 3568.05, 4607.01 >, < 0, -90, 0 >, true, 6000)
	AddMapProp( $"models/ola/sewer_staircase_01.mdl",  <0, 0, 500 * T> + < 288.605, 3568.05, 4607.01 >, < 0, -90, 0 >, true, 6000)
	AddMapProp( $"models/ola/sewer_staircase_01.mdl",  <0, 0, 500 * T> + < 143.916, 4079.96, 4607 >, < 0, 90, 0 >, true, 6000)
	AddMapProp( $"models/ola/sewer_staircase_01.mdl",  <0, 0, 500 * T> + < 272.416, 4079.96, 4607 >, < 0, 90, 0 >, true, 6000)
	AddMapProp( $"models/IMC_base/outer_gate_imc_closed.mdl",  <0, 0, 500 * T> + < 271.076, 3871.95, 4431.62 >, < 0, 90, 0 >, true, 6000)
	AddMapProp( $"models/IMC_base/outer_gate_imc_closed.mdl",  <0, 0, 500 * T> + < 271.666, 3775.85, 4431.07 >, < 0, 90, 0 >, true, 6000)
	AddMapProp( $"models/IMC_base/outer_gate_imc_closed.mdl",  <0, 0, 500 * T> + < 271.382, 3824.01, 4431.21 >, < 0, 90, 0 >, true, 6000)
	AddMapProp( $"models/ola/sewer_staircase_01.mdl",  <0, 0, 500 * T> + < 400.916, 4079.96, 4607 >, < 0, 90, 0 >, true, 6000)
	AddMapProp( $"models/ola/sewer_staircase_01.mdl",  <0, 0, 500 * T> + < 400.052, 4255.96, 4495.68 >, < 0, 90, 0 >, true, 6000)
	AddMapProp( $"models/ola/sewer_staircase_01.mdl",  <0, 0, 500 * T> + < 417.105, 3568.05, 4607.01 >, < 0, -90, 0 >, true, 6000)
	AddMapProp( $"models/ola/sewer_staircase_01.mdl",  <0, 0, 500 * T> + < 417.149, 3392.12, 4495.02 >, < 0, -90, 0 >, true, 6000)
	AddMapProp( $"models/props/generator_coop/generator_coop_blackbox.mdl",  <0, 0, 500 * T> + < 976.991, 3824.06, 4480.12 >, < 0, -90, 0 >, true, 6000)
	AddMapProp( $"models/props/generator_coop/generator_coop_blackbox.mdl",  <0, 0, 500 * T> + < 880.925, 3823.86, 4479.65 >, < 0, -90, 0 >, true, 6000)
	AddMapProp( $"models/props/generator_coop/generator_coop_blackbox.mdl",  <0, 0, 500 * T> + < 1225.99, 3824.06, 4480.12 >, < 0, -90, 0 >, true, 6000)
	AddMapProp( $"models/crashsite/crashsite_ship_metal_panel_01.mdl",  <0, 0, 500 * T> + < 592.478, 3824.04, 4718.62 >, < 0, -90, 0 >, true, 6000)
	AddMapProp( $"models/crashsite/crashsite_ship_metal_panel_01.mdl",  <0, 0, 500 * T> + < 717.977, 3824.04, 4718.62 >, < 0, -90, 0 >, true, 6000)
	AddMapProp( $"models/crashsite/crashsite_ship_metal_panel_01.mdl",  <0, 0, 500 * T> + < 717.977, 3654.65, 4718.62 >, < 0, -90, 0 >, true, 6000)
	AddMapProp( $"models/crashsite/crashsite_ship_metal_panel_01.mdl",  <0, 0, 500 * T> + < 592.478, 3654.65, 4718.62 >, < 0, -90, 0 >, true, 6000)
	AddMapProp( $"models/crashsite/crashsite_ship_metal_panel_01.mdl",  <0, 0, 500 * T> + < 843.477, 3654.65, 4718.62 >, < 0, -90, 0 >, true, 6000)
	AddMapProp( $"models/crashsite/crashsite_ship_metal_panel_01.mdl",  <0, 0, 500 * T> + < 968.977, 3654.65, 4718.62 >, < 0, -90, 0 >, true, 6000)
	AddMapProp( $"models/crashsite/crashsite_ship_metal_panel_01.mdl",  <0, 0, 500 * T> + < 1094.48, 3654.65, 4718.62 >, < 0, -90, 0 >, true, 6000)
	AddMapProp( $"models/crashsite/crashsite_ship_metal_panel_01.mdl",  <0, 0, 500 * T> + < 592.478, 3993.43, 4718.62 >, < 0, -90, 0 >, true, 6000)
	AddMapProp( $"models/crashsite/crashsite_ship_metal_panel_01.mdl",  <0, 0, 500 * T> + < 717.977, 3993.43, 4718.62 >, < 0, -90, 0 >, true, 6000)
	AddMapProp( $"models/crashsite/crashsite_ship_metal_panel_01.mdl",  <0, 0, 500 * T> + < 843.477, 3993.43, 4718.62 >, < 0, -90, 0 >, true, 6000)
	AddMapProp( $"models/crashsite/crashsite_ship_metal_panel_01.mdl",  <0, 0, 500 * T> + < 968.977, 3993.43, 4718.62 >, < 0, -90, 0 >, true, 6000)
	AddMapProp( $"models/crashsite/crashsite_ship_metal_panel_01.mdl",  <0, 0, 500 * T> + < 1094.48, 3993.43, 4718.62 >, < 0, -90, 0 >, true, 6000)
	AddMapProp( $"models/IMC_base/outer_gate_imc_closed.mdl",  <0, 0, 500 * T> + < 800.546, 4111.44, 4431.38 >, < 0, -0, 0 >, true, 6000)
	AddMapProp( $"models/IMC_base/outer_gate_imc_closed.mdl",  <0, 0, 500 * T> + < 800.007, 3536.34, 4431.06 >, < 0, -180, 0 >, true, 6000)
	AddMapProp( $"models/IMC_base/barrier_low_airport_IMC.mdl",  <0, 0, 500 * T> + < 623.553, 4063.62, 4719.19 >, < 0, 90, 0 >, true, 6000)
	AddMapProp( $"models/IMC_base/barrier_low_airport_IMC.mdl",  <0, 0, 500 * T> + < 623.203, 3567.62, 4719.53 >, < 0, 90, 0 >, true, 6000)
	AddMapProp( $"models/IMC_base/barrier_low_airport_IMC.mdl",  <0, 0, 500 * T> + < 539.848, 4064.76, 4719.73 >, < 0, -180, 0 >, true, 6000)
	AddMapProp( $"models/IMC_base/barrier_low_airport_IMC.mdl",  <0, 0, 500 * T> + < 527.809, 3567.55, 4719.13 >, < 0, -0, 0 >, true, 6000)
	}
	}
}

bool function CommandMatchups(entity player, array<string> args) 
{
	string s = "Current Matchups\n------------------\n"
	foreach (key, value in file.matchups)
		s += key + " vs " + value + "\n"
	SendHudMessage(player, s, -1, 0.2, 200, 200, 255, 255, 0.15, 15, 0.15 )
	return true
}

void function AddMapProp( asset a, vector pos, vector ang, bool mantle, int fade)
{
    entity e = CreatePropDynamicLightweight(a, pos, ang, SOLID_VPHYSICS, 6000.0)
    
    if(mantle) e.AllowMantle()
    e.SetScriptName( "editor_placed_prop" )
}

void function OnPlayerDisconnected(entity player)
{   
    WipeScore(player)
    thread DisconnectedThread(player)
}

void function DisconnectedThread(entity player) {
    while (IsValid(player)) //wait till disconnected player not exist
		wait 0.25
	CheckWin(false)
}

void function StartGame()
{
    file.canstart = false
    while (GetPlayerArray().len() < file.maxplayers) 
    {
        wait 10.0
        foreach (entity player in GetPlayerArray())
            SendHudMessage( player, "Waiting For Players (" + GetPlayerArray().len() + "/" + file.maxplayers + ")" , -1, 0.2, 200, 200, 255, 255, 0.15, 999, 0 )
        SetTimeLeft(Time() + 60.0)
    }

    InitPlayers()
}

void function InitPlayers()
{
	if (file.canstart == true)
		return
	SetTimeLeft(Time() + 60.0)
	//SetRespawnsEnabled( false )

	array<entity> players = GetPlayerArray()
	foreach ( entity plr in players ) {
        file.playingplayers.append(plr.GetPlayerName()) //should(tm) always be 4 8 or 16
    }
    file.canstart = true
    SetTimeLeft(Time())
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

        file.matchups[plr1] <- plr2
    }
}

void function DoSpawns() 
{
	SetTimeLeft(Time() + 60.0)
	if (!file.canstart)
        return
	int x = 0
    int index = RandomInt(possspawns1.len())
    foreach (key, value in file.matchups) 
    {
        entity player = GetPlayerFromName(key)
        if (IsValid(player)) 
        {
            SendHudMessage(player, "Your Opponent: " + key, -1, 0.2, 255, 200, 200, 255, 0.15, 5, 0.15 )
            player.SetOrigin(possspawns1[index] + <0, 0, 500 * x>)
            player.SetAngles(possangles1[index])
        }

        entity player1 = GetPlayerFromName(value)
        if (IsValid(player1)) 
        {
            SendHudMessage(player1, "Your Opponent: " + value, -1, 0.2, 255, 200, 200, 255, 0.15, 5, 0.15 )
            player1.SetOrigin(possspawns2[index] + <0, 0, 500 * x>)
            player1.SetAngles(possangles2[index])
        }
        x++
    }
	CheckWin(false)
}

void function SetupRound() 
{
    file.primary = GetItemToUse(guns, "clash_primary") 
    file.secondary = GetItemToUse(guns, "clash_secondary") 
    file.weapon3 = GetItemToUse(guns, "clash_at") 
    file.special = GetItemToUse(offhands, "clash_tactical") 
    file.ordnance = GetItemToUse(offhands, "clash_ordnance") 
    file.melee = GetItemToUse(melees, "clash_melee") 

    if (!file.canstart)
        return

    PlayMusicToAll( eMusicPieceID.GAMEMODE_1 )

    thread SetupMatches() 
}

void function SetupLoadouts(entity player) {

    PilotLoadoutDef loadout = GetPilotLoadoutFromPersistentData(player, GetPersistentSpawnLoadoutIndex(player, "pilot"))
    loadout.name = "???"

    loadout.primary = file.primary
    loadout.primaryAttachments = []
    loadout.primaryMods = []

    loadout.secondary = file.secondary
    loadout.secondaryMods = []

    loadout.weapon3 = file.weapon3
    loadout.weapon3Mods = []

    loadout.special = file.special

    loadout.ordnance = file.ordnance

    loadout.melee = file.melee
    loadout.meleeMods = []

    GivePilotLoadout(player, loadout)
}

void function CheckWin(bool roundend) 
{
    if (file.matchups.len() == 0)
        return

	if (!file.canstart)
        return

    foreach (key, value in file.matchups) 
    {
        entity player1 = GetPlayerFromName(key)
        entity player2 = GetPlayerFromName(value)

        if (player1 == null || !IsValid(player1)) // if both players for some reason disconnect, the 2nd one "moves on" to make sure playingplayer count doesnt explode
        {   
            thread HandleWin(player2)
            if (IsValid(player2)) 
                SendHudMessage(player2, "Opponent Disconnected. You Win This Round!", -1, 0.2, 200, 255, 200, 255, 0.15, 5, 0.15 )
            file.playingplayers.remove(file.playingplayers.find(key))
            delete file.matchups[key]
        } 
        else if (!IsAlive(player1))
        {   
            thread HandleWin(player2)
            SendHudMessage(player1, "You Have Been Eliminated", -1, 0.2, 255, 200, 200, 255, 0.15, 5, 0.15 )
            file.playingplayers.remove(file.playingplayers.find(key))
            delete file.matchups[key]
        }
        else if (player2 == null || !IsValid(player2))
        {   
            thread HandleWin(player1)
            if (IsValid(player1)) 
                SendHudMessage(player1, "Opponent Disconnected. You Win This Round!", -1, 0.2, 200, 255, 200, 255, 0.15, 5, 0.15 )
            file.playingplayers.remove(file.playingplayers.find(value))
            delete file.matchups[key]
        } 
        else if (!IsAlive(player2) || roundend)
        {   
            thread HandleWin(player1)
            SendHudMessage(player2, "You Have Been Eliminated", -1, 0.2, 255, 200, 200, 255, 0.15, 5, 0.15 )
            file.playingplayers.remove(file.playingplayers.find(value))
            delete file.matchups[key]
        }
    }

    if (!roundend && file.matchups.len() == 0)
        SetTimeLeft(Time()) //ghetto way to end round but w/e
}

void function HandleWin(entity player) 
{
    if (IsValid(player)) {
        AddTeamScore( player.GetTeam(), 1 )
        player.AddToPlayerGameStat( PGS_ASSAULT_SCORE, 1 )
        SendHudMessage(player, "You Win This Round!", -1, 0.2, 200, 255, 200, 255, 0.15, 5, 0.15 )
        player.FreezeControlsOnServer()
    }

    wait 5
    if (IsValid(player)) {
        if (IsAlive(player))
            player.SetOrigin(<257.016, 142.381, 1446.95>)
        player.UnfreezeControlsOnServer()
        SendHudMessage(player, "Wait Until This Round is Finished", -1, 0.2, 255, 255, 255, 255, 0.15, 15, 0.15 )
    }
}

void function OnPlayerKilled( entity victim, entity attacker, var damageInfo )
{
	if ( victim != attacker && victim.IsPlayer() && attacker.IsPlayer() && GetGameState() == eGameState.Playing )
	{
        SetRoundWinningKillReplayAttacker(attacker)
	}
    if (file.canstart && file.playingplayers.len() > 0)
        CheckWin(false)
}

void function WipeScore(entity player) {
	while (GameRules_GetTeamScore(player.GetTeam()) > 0) {
		AddTeamScore( player.GetTeam(), -1 )
	}
	player.SetPlayerGameStat( PGS_ASSAULT_SCORE, 0)
}


void function OnPlayerRespawned(entity player) 
{
    SetupLoadouts(player)
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
        if (file.canstart && file.playingplayers.len() > 0 && !file.playingplayers.contains(player.GetPlayerName()))
            SendHudMessage(player, "You Are Eliminated, Now Playing FFA\nUse !matchups in console to view current status", -1, 0.2, 255, 255, 255, 255, 0.15, 15, 0.15 )
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

entity function GetOpponent(entity player) 
{
    foreach (key, value in file.matchups) 
    {
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
{
    int weaponindex
    if (pvarslot == "clash_primary")
        weaponindex = GetCurrentPlaylistVarInt(pvarslot, 2) //weird thing
    else
        weaponindex = GetCurrentPlaylistVarInt(pvarslot, 0)
    string weap = list[weaponindex]

    if (weap == "random")
        return list[2 + RandomInt(list.len() - 2)]

    return weap
}

void function SetTimeLeft(float seconds) 
{
    SetServerVar( "roundEndTime", seconds)
    SetServerVar( "gameEndTime", seconds) // client only sees this
}
