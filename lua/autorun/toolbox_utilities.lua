AddCSLuaFile()

if CLIENT then
	language.Add( "menubar.drawing.viewmodel", "Draw Viewmodel" )
end

local function SandboxClientSettings( pnl )
	pnl:AddControl( "Header", { Description = "#utilities.sandboxsettings_cl" } )

	local ConVarsDefault = {
		sbox_search_maxresults = "1024",
		cl_drawhud = "1",
		r_drawviewmodel = "1",
		gmod_drawhelp = "1",
		gmod_drawtooleffects = "1",
		cl_drawworldtooltips = "1",
		cl_drawspawneffect = "1",
		cl_draweffectrings = "1",
		cl_drawcameras = "1",
		cl_drawthrusterseffects = "1",
		cl_showhints = "1",
	}

	pnl:AddControl( "ComboBox", { MenuButton = 1, Folder = "util_sandbox_cl", Options = { [ "#preset.default" ] = ConVarsDefault }, CVars = table.GetKeys( ConVarsDefault ) } )

	pnl:AddControl( "Slider", { Label = "#utilities.max_results", Type = "Integer", Command = "sbox_search_maxresults", Min = "1024", Max = "8192", Help = true } )

	local function AddCheckbox( title, cvar )
		pnl:AddControl( "CheckBox", { Label = title, Command = cvar } )
	end

	AddCheckbox( "#menubar.drawing.hud", "cl_drawhud" )
	AddCheckbox( "#menubar.drawing.viewmodel", "r_drawviewmodel" )
	AddCheckbox( "#menubar.drawing.toolhelp", "gmod_drawhelp" )
	AddCheckbox( "#menubar.drawing.toolui", "gmod_drawtooleffects" )
	AddCheckbox( "#menubar.drawing.world_tooltips", "cl_drawworldtooltips" )
	AddCheckbox( "#menubar.drawing.spawn_effect", "cl_drawspawneffect" )
	AddCheckbox( "#menubar.drawing.effect_rings", "cl_draweffectrings" )
	AddCheckbox( "#menubar.drawing.cameras", "cl_drawcameras" )
	AddCheckbox( "#menubar.drawing.thrusters", "cl_drawthrusterseffects" )
	AddCheckbox( "#menubar.drawing.hints", "cl_showhints" )
end

-- Tool Menu
hook.Add( "PopulateToolMenu", "PopulateUtilityMenus_2", function()
	spawnmenu.AddToolMenuOption( "Utilities", "User", "SandboxClientSettings", "#spawnmenu.utilities.sandbox_settings", "", "", SandboxClientSettings )
end )