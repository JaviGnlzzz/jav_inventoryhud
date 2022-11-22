Config = {}
Config.Locale = "es"
Config.IncludeWeapons = true -- Incluir armas en el inventario
Config.IncludeAccounts = true -- Incluir cuentas (banco, dinero negro...)
Config.ExcludeAccountsList = {"bank"}-- Cuentas a excluir del inventario
Config.OpenControl = 289 -- Tecla abrir inventario. Editar html/js/config.js para cambiar la tecla de cierre
Config.HotBar = 37 -- Tecla para activar la barra de acceso rápido.

-- Lista de objetos usables (Para cerrar el inventario una vez usados)

--Peso maleteros

Config.localWeight = {
    bread = 20,
    water = 20,
	raisin = 20,
	vine = 40,
    WEAPON_SMG = 15000,
	WEAPON_PISTOL = 30,
	WEAPON_SNSPISTOL = 10000,
	WEAPON_SPECIALCARBINE = 15000,
	WEAPON_COMPACTRIFLE = 15000,
	WEAPON_MINIGUN = 45000,
	WEAPON_HEAVYSHOTGUN = 15000,
	WEAPON_COMBATMG = 25000,
	WEAPON_SMOKEGRENADE = 1000,
	WEAPON_BZGAS = 1000,
	WEAPON_STUNGUN = 15000,
	WEAPON_MARKSMANPISTOL = 15000,
	WEAPON_CARBINERIFLE = 15000,
	WEAPON_COMBATPDW = 15000,
	WEAPON_DBSHOTGUN = 15000,
	WEAPON_APPISTOL = 15000,
	WEAPON_HEAVYSNIPER = 20000,
	WEAPON_MUSKET = 15000,
	WEAPON_ADVANCEDRIFLE = 15000,
	WEAPON_MARKSMANRIFLE = 15000,
	WEAPON_STICKYBOMB = 5000,
	WEAPON_ASSAULTSHOTGUN = 15000,
	WEAPON_COMBATPISTOL = 15000,
	WEAPON_DOUBLEACTION = 15000,
	WEAPON_VINTAGEPISTOL = 15000,
	WEAPON_MACHINEPISTOL = 15000,
	WEAPON_SNIPERRIFLE = 20000,
	WEAPON_ASSAULTRIFLE = 20000,
	WEAPON_MOLOTOV = 5000,
	WEAPON_GUSENBERG = 15000
}

--Almacenes

Config.Job_Policia = 'police'

Config.Alamacenes_Pol = {
	vector3(485.4204, -995.637, 30.689),
	vector3(487.3417, -998.072, 30.689)
}

Config.Job_Ems = 'ambulance'

Config.Alamacenes_Ems = {
	vector3(235.1952, -679.159, 37.248),
}

Config.Mecanico = 'mechanic'

Config.Alamacenes_Meca = {
	vector3(246.5966, -667.339, 38.211),
}
