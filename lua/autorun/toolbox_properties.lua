AddCSLuaFile()

local orderNums = {
	unbreakable = 1000,
	shadows = 900,
	lock = 800,
	sleep = 850,
	tpose = 1500.5,
	worldCollision = 1500.1,
	selfCollision = 1500.2,
	makeFriendly = 1900,
	depleteAmmo = 1901,
	selfDestruct = 1902,
	recharge = 1900,
	lockDoor = 1900,
	mountGun = 1900,
	enableRadar = 1900
}

if CLIENT then
	language.Add( "unbreakable", "Unbreakable" )
	language.Add( "shadows", "Shadows" )
	language.Add( "locked", "Locked" )
	language.Add( "sleep", "Sleep" )
	language.Add( "tpose", "T-Pose" )
	language.Add( "world_collision_off", "Disable World Collision" )
	language.Add( "world_collision_on", "Enable World Collision" )
	language.Add( "self_collision_off", "Disable Self Collision" )
	language.Add( "self_collision_on", "Enable Self Collision" )
	language.Add( "make_friendly", "Make Friendly" )
	language.Add( "make_hostile", "Make Hostile" )
	language.Add( "deplete_ammo", "Deplete Ammo" )
	language.Add( "restore_ammo", "Restore Ammo" )
	language.Add( "self_destruct", "Self Destruct" )
	language.Add( "recharge", "Recharge" )
	language.Add( "lock_door", "Lock Door" )
	language.Add( "unlock_door", "Unlock Door" )
	language.Add( "mount_gun", "Mount Gun" )
	language.Add( "dismount_gun", "Dismount Gun" )
	language.Add( "enable_radar", "Enable Radar" )
	language.Add( "disable_radar", "Disable Radar" )
end

properties.Add( "unbreakable", {
	MenuLabel = "#unbreakable",
	Order = orderNums.unbreakable,
	Type = "toggle",

	Filter = function( self, ent, ply )
		if !IsValid( ent ) then return false end
		if ent:IsPlayer() then return false end
		if ent:Health() == 0 then return false end

		return true
	end,

	Checked = function( self, ent, ply )
		return ent:GetNWBool( "unbreakable" )
	end,

	Action = function( self, ent )
		self:MsgStart()
			net.WriteEntity( ent )
		self:MsgEnd()
	end,

	Receive = function( self, length, ply )
		local ent = net.ReadEntity()

		if !properties.CanBeTargeted( ent, ply ) then return end
		if !self:Filter( ent, ply ) then return end

		ent:SetNWBool( "unbreakable", !ent:GetNWBool( "unbreakable" ) )
	end
} )

hook.Add( "EntityTakeDamage", "Unbreakable", function( target, dmginfo )
	if target:GetNWBool( "unbreakable" ) then
		dmginfo:ScaleDamage( 0 )
	end
end )

properties.Add( "sleep", {
	MenuLabel = "#sleep",
	Order = orderNums.sleep,
	MenuIcon = "icon16/anchor.png",

	Filter = function( self, ent, ply )
		if !IsValid( ent ) then return false end
		if ent:IsPlayer() then return false end
		-- Always invalid on client
		--if !IsValid( ent:GetPhysicsObject() ) then return false end

		return true
	end,

	Action = function( self, ent )
		self:MsgStart()
			net.WriteEntity( ent )
		self:MsgEnd()
	end,

	Receive = function( self, length, ply )
		local ent = net.ReadEntity()

		if !properties.CanBeTargeted( ent, ply ) then return end
		if !self:Filter( ent, ply ) then return end
		if !IsValid( ent:GetPhysicsObject() ) then return end

		for i = 0, ent:GetPhysicsObjectCount() - 1 do
			ent:GetPhysicsObjectNum( i ):Sleep()
			ent:GetPhysicsObjectNum( i ):EnableMotion( true )
		end
	end
} )

properties.Add( "tpose", {
	MenuLabel = "#tpose",
	Order = orderNums.tpose,
	MenuIcon = "icon16/status_online.png",

	Filter = function( self, ent, ply )
		if !IsValid( ent ) then return false end
		if ent:IsPlayer() then return false end
		if ent:GetClass() != "prop_ragdoll" then return false end

		return true
	end,

	Action = function( self, ent )
		self:MsgStart()
			net.WriteEntity( ent )
		self:MsgEnd()
	end,

	Receive = function( self, length, ply )
		local ent = net.ReadEntity()

		if !properties.CanBeTargeted( ent, ply ) then return end
		if !self:Filter( ent, ply ) then return end

		local tr = util.TraceLine( { start = ent:GetPos(), endpos = ent:GetPos() - Vector( 0, 0, 3000 ), filter = ent } )

		local temp = ents.Create( "prop_dynamic" )
		temp:SetModel( ent:GetModel() )
		temp:SetPos( tr.HitPos )
		local angle = ( tr.HitPos - ply:GetPos() ):Angle()
		temp:SetAngles( Angle( 0, angle.y - 180, 0 ) )
		temp:Spawn()
		for i = 0, ent:GetPhysicsObjectCount() - 1 do
			local phys = ent:GetPhysicsObjectNum( i )
			local bone = ent:TranslatePhysBoneToBone( i )
			local pos, ang = temp:GetBonePosition( bone )
			phys:SetPos( pos )
			phys:SetAngles( ang )
			phys:EnableMotion( string.sub( ent:GetBoneName( bone ), 1, 4 ) == "prp_" )
			phys:Wake()
		end
		temp:Remove()
	end
} )

properties.Add( "shadows", {
	MenuLabel = "#shadows",
	Order = orderNums.shadows,
	Type = "toggle",

	Filter = function( self, ent, ply )
		if !IsValid( ent ) then return false end
		if ent:IsPlayer() then return false end

		return true
	end,

	Checked = function( self, ent, ply )
		return ent:GetNWBool( "shadows", true )
	end,

	Action = function( self, ent )
		self:MsgStart()
			net.WriteEntity( ent )
		self:MsgEnd()
	end,

	Receive = function( self, length, ply )
		local ent = net.ReadEntity()

		if !properties.CanBeTargeted( ent, ply ) then return end
		if !self:Filter( ent, ply ) then return end

		local shadows = !ent:GetNWBool( "shadows", true )
		ent:SetNWBool( "shadows", shadows )
		ent:DrawShadow( shadows )
	end
} )

properties.Add( "world_collision_off", {
	MenuLabel = "#world_collision_off",
	Order = orderNums.worldCollision,
	MenuIcon = "icon16/collision_off.png",

	Filter = function( self, ent, ply )
		if !IsValid( ent ) then return false end
		if ent:IsPlayer() then return false end
		if ent:GetNWBool( "noCollideWorld" ) then return false end

		return true
	end,

	Action = function( self, ent )
		self:MsgStart()
			net.WriteEntity( ent )
		self:MsgEnd()
	end,

	Receive = function( self, length, ply )
		local ent = net.ReadEntity()

		if !properties.CanBeTargeted( ent, ply ) then return end
		if !self:Filter( ent, ply ) then return end

		ent:SetNWBool( "noCollideWorld", true )
		constraint.NoCollideWorld( ent, Entity( 0 ), 0, 0 )
	end
} )

properties.Add( "world_collision_on", {
	MenuLabel = "#world_collision_on",
	Order = orderNums.worldCollision,
	MenuIcon = "icon16/collision_on.png",

	Filter = function( self, ent, ply )
		if !IsValid( ent ) then return false end
		if ent:IsPlayer() then return false end
		if !ent:GetNWBool( "noCollideWorld" ) then return false end

		return true
	end,

	Action = function( self, ent )
		self:MsgStart()
			net.WriteEntity( ent )
		self:MsgEnd()
	end,

	Receive = function( self, length, ply )
		local ent = net.ReadEntity()

		if !properties.CanBeTargeted( ent, ply ) then return end
		if !self:Filter( ent, ply ) then return end

		ent:SetNWBool( "noCollideWorld", false )
		constraint.FindConstraint( ent, "NoCollideWorld" ).Constraint:Remove()
	end
} )

local function CreateConstraintSystem()
	local System = ents.Create( "phys_constraintsystem" )
	if !IsValid( System ) then return end
	System:SetKeyValue( "additionaliterations", GetConVarNumber( "gmod_physiterations" ) )
	System:Spawn()
	System:Activate()
	return System
end

local function FindOrCreateConstraintSystem( Ent1, Ent2 )
	local System
	if !Ent1:IsWorld() && Ent1:GetTable().ConstraintSystem && Ent1:GetTable().ConstraintSystem:IsValid() then System = Ent1:GetTable().ConstraintSystem end
	if System && System:IsValid() && System:GetVar( "constraints", 0 ) > 100 then System = nil end
	if !System && !Ent2:IsWorld() && Ent2:GetTable().ConstraintSystem && Ent2:GetTable().ConstraintSystem:IsValid() then System = Ent2:GetTable().ConstraintSystem end
	if System && System:IsValid() && System:GetVar( "constraints", 0 ) > 100 then System = nil end
	if !System || !System:IsValid() then System = CreateConstraintSystem() end
	if !System then return end
	Ent1.ConstraintSystem = System
	Ent2.ConstraintSystem = System
	System.UsedEntities = System.UsedEntities || {}
	table.insert( System.UsedEntities, Ent1 )
	table.insert( System.UsedEntities, Ent2 )
	System:SetVar( "constraints", System:GetVar( "constraints", 0 ) + 1 )
	return System
end

function constraint.NoCollideWorld( Ent1, Ent2, Bone1, Bone2 )
	if !Ent1 || !Ent2 then return false end

	if Ent1 == game.GetWorld() then
		Ent1 = Ent2
		Ent2 = game.GetWorld()
		Bone1 = Bone2
		Bone2 = 0
	end

	if !Ent1:IsValid() || ( !Ent2:IsWorld() && !Ent2:IsValid() ) then return false end

	Bone1 = Bone1 || 0
	Bone2 = Bone2 || 0

	local Phys1 = Ent1:GetPhysicsObjectNum( Bone1 )
	local Phys2 = Ent2:GetPhysicsObjectNum( Bone2 )

	if !Phys1 || !Phys1:IsValid() || !Phys2 || !Phys2:IsValid() then return false end

	if Phys1 == Phys2 then return false end

	if Ent1:GetTable().Constraints then
		for _, v in pairs( Ent1:GetTable().Constraints ) do
			if v:IsValid() then
				local CTab = v:GetTable()
				if ( CTab.Type == "NoCollideWorld" || CTab.Type == "NoCollide" )
				&& ( ( CTab.Ent1 == Ent1 && CTab.Ent2 == Ent2 )
				|| ( CTab.Ent2 == Ent1 && CTab.Ent1 == Ent2 ) ) then return false end
			end
		end
	end

	local System = FindOrCreateConstraintSystem( Ent1, Ent2 )

	if !IsValid( System ) then return false end

	SetPhysConstraintSystem( System )

	local Constraint = ents.Create( "phys_ragdollconstraint" )

	if !IsValid( Constraint ) then
		SetPhysConstraintSystem( NULL )
		return false
	end
	Constraint:SetKeyValue( "xmin", -180 )
	Constraint:SetKeyValue( "xmax", 180 )
	Constraint:SetKeyValue( "ymin", -180 )
	Constraint:SetKeyValue( "ymax", 180 )
	Constraint:SetKeyValue( "zmin", -180 )
	Constraint:SetKeyValue( "zmax", 180 )
	Constraint:SetKeyValue( "spawnflags", 3 )
	Constraint:SetPhysConstraintObjects( Phys1, Phys2 )
	Constraint:Spawn()
	Constraint:Activate()

	SetPhysConstraintSystem( NULL )
	constraint.AddConstraintTable( Ent1, Constraint, Ent2 )

	local ctable = {
		Type	= "NoCollideWorld",
		Ent1	= Ent1,
		Ent2	= Ent2,
		Bone1	= Bone1,
		Bone2	= Bone2
	}

	Constraint:SetTable( ctable )

	return Constraint
end
duplicator.RegisterConstraint( "NoCollideWorld", constraint.NoCollideWorld, "Ent1", "Ent2", "Bone1", "Bone2" )

properties.Add( "self_collision_off", {
	MenuLabel = "#self_collision_off",
	Order = orderNums.selfCollision,
	MenuIcon = "icon16/collision_off.png",

	Filter = function( self, ent, ply )
		if !IsValid( ent ) then return false end
		if ent:IsPlayer() then return false end
		if ent:GetClass() != "prop_ragdoll" then return false end
		if ent:GetNWBool( "noCollideSelf" ) then return false end

		return true
	end,

	Action = function( self, ent )
		self:MsgStart()
			net.WriteEntity( ent )
		self:MsgEnd()
	end,

	Receive = function( self, length, ply )
		local ent = net.ReadEntity()

		if !properties.CanBeTargeted( ent, ply ) then return end
		if !self:Filter( ent, ply ) then return end

		ent:SetNWBool( "noCollideSelf", true )
		for num = 0, ent:GetPhysicsObjectCount() - 1 do
			phys = ent:GetPhysicsObjectNum( num )
			if phys:IsValid() then
				phys:AddGameFlag( FVPHYSICS_NO_SELF_COLLISIONS )
			end
		end
	end
} )

properties.Add( "self_collision_on", {
	MenuLabel = "#self_collision_on",
	Order = orderNums.selfCollision,
	MenuIcon = "icon16/collision_on.png",

	Filter = function( self, ent, ply )
		if !IsValid( ent ) then return false end
		if ent:IsPlayer() then return false end
		if ent:GetClass() != "prop_ragdoll" then return false end
		if !ent:GetNWBool( "noCollideSelf" ) then return false end

		return true
	end,

	Action = function( self, ent )
		self:MsgStart()
			net.WriteEntity( ent )
		self:MsgEnd()
	end,

	Receive = function( self, length, ply )
		local ent = net.ReadEntity()

		if !properties.CanBeTargeted( ent, ply ) then return end
		if !self:Filter( ent, ply ) then return end

		ent:SetNWBool( "noCollideSelf", false )
		for num = 0, ent:GetPhysicsObjectCount() - 1 do
			phys = ent:GetPhysicsObjectNum( num )
			if phys:IsValid() then
				phys:ClearGameFlag( FVPHYSICS_NO_SELF_COLLISIONS )
			end
		end
	end
} )

properties.Add( "locked", {
	MenuLabel = "#locked",
	Order = orderNums.locked,
	Type = "toggle",

	Filter = function( self, ent, ply )
		if !IsValid( ent ) then return false end
		if ent:IsPlayer() then return false end

		return true
	end,

	Checked = function( self, ent, ply )
		return ent:GetNWBool( "locked" )
	end,

	Action = function( self, ent )
		self:MsgStart()
			net.WriteEntity( ent )
		self:MsgEnd()
	end,

	Receive = function( self, length, ply )
		local ent = net.ReadEntity()

		if !properties.CanBeTargeted( ent, ply ) then return end
		if !self:Filter( ent, ply ) then return end

		ent:SetNWBool( "locked", !ent:GetNWBool( "locked" ) )
	end
} )

hook.Add( "PhysgunPickup", "Locked_Pickup", function( ply, ent )
	if IsValid( ent ) && ent:GetNWBool( "locked" ) then
		return false
	end
end)

hook.Add( "CanTool", "Locked_Tool", function( ply, trace, mode )
	if IsValid( trace.Entity ) && trace.Entity:GetNWBool( "locked" ) then
		return false
	end
end)

hook.Add( "OnPhysgunReload", "Locked_Reload", function( _, ply )
	if IsValid( ply ) && IsValid( ply:GetEyeTrace().Entity ) && ply:GetEyeTrace().Entity:GetNWBool( "locked" ) then
		return false
	end
end)

properties.Add( "make_friendly", {
	MenuLabel = "#make_friendly",
	Order = orderNums.makeFriendly,
	MenuIcon = "icon16/user_green.png",

	Filter = function( self, ent, ply )
		if !IsValid( ent ) then return false end
		if bit.band( ent:GetSpawnFlags(), 512 ) == 512 then return false end
		if ent:GetClass() == "npc_turret_floor" then return true end

		return false
	end,

	Action = function( self, ent )
		self:MsgStart()
			net.WriteEntity( ent )
		self:MsgEnd()
	end,

	Receive = function( self, length, ply )
		local ent = net.ReadEntity()

		if !properties.CanBeTargeted( ent, ply ) then return end
		if !self:Filter( ent, ply ) then return end

		ent:SetKeyValue( "spawnflags", bit.bor( ent:GetSpawnFlags(), SF_FLOOR_TURRET_CITIZEN ) )
		ent:SetMaterial( "models/combine_turrets/floor_turret/floor_turret_citizen" )
	end
} )

properties.Add( "make_hostile", {
	MenuLabel = "#make_hostile",
	Order = orderNums.makeFriendly,
	MenuIcon = "icon16/user_red.png",

	Filter = function( self, ent, ply )
		if !IsValid( ent ) then return false end
		if bit.band( ent:GetSpawnFlags(), 512 ) == 0 then return false end
		if ent:GetClass() == "npc_turret_floor" then return true end

		return false
	end,

	Action = function( self, ent )
		self:MsgStart()
			net.WriteEntity( ent )
		self:MsgEnd()
	end,

	Receive = function( self, length, ply )
		local ent = net.ReadEntity()

		if !properties.CanBeTargeted( ent, ply ) then return end
		if !self:Filter( ent, ply ) then return end

		ent:SetKeyValue( "spawnflags", bit.bxor( ent:GetSpawnFlags(), SF_FLOOR_TURRET_CITIZEN ) )
		ent:SetMaterial( "models/combine_turrets/floor_turret/combine_gun002" )
	end
} )

properties.Add( "self_destruct", {
	MenuLabel = "#self_destruct",
	Order = orderNums.selfDestruct,
	MenuIcon = "icon16/bomb.png",

	Filter = function( self, ent, ply )
		if !IsValid( ent ) then return false end
		if ent:GetClass() == "npc_turret_floor" then return true end
		if ent:GetClass() == "npc_helicopter" then return true end
		if ent:GetClass() == "npc_rollermine" then return true end

		return false
	end,

	Action = function( self, ent )
		self:MsgStart()
			net.WriteEntity( ent )
		self:MsgEnd()
	end,

	Receive = function( self, length, ply )
		local ent = net.ReadEntity()

		if !properties.CanBeTargeted( ent, ply ) then return end
		if !self:Filter( ent, ply ) then return end

		if ent:GetClass() == "npc_rollermine" then
			ent:Fire( "InteractivePowerDown" )
		else
			ent:Fire( "SelfDestruct" )
		end
	end
} )

properties.Add( "deplete_ammo", {
	MenuLabel = "#deplete_ammo",
	Order = orderNums.depleteAmmo,
	MenuIcon = "icon16/delete.png",

	Filter = function( self, ent, ply )
		if !IsValid( ent ) then return false end
		if bit.band( ent:GetSpawnFlags(), 256 ) == 256 then return false end
		if ent:GetClass() == "npc_turret_floor" then return true end

		return false
	end,

	Action = function( self, ent )
		self:MsgStart()
			net.WriteEntity( ent )
		self:MsgEnd()
	end,

	Receive = function( self, length, ply )
		local ent = net.ReadEntity()

		if !properties.CanBeTargeted( ent, ply ) then return end
		if !self:Filter( ent, ply ) then return end

		ent:SetKeyValue( "spawnflags", bit.bor( ent:GetSpawnFlags(), 256 ) )
	end
} )

properties.Add( "restore_ammo", {
	MenuLabel = "#restore_ammo",
	Order = orderNums.depleteAmmo,
	MenuIcon = "icon16/add.png",

	Filter = function( self, ent, ply )
		if !IsValid( ent ) then return false end
		if bit.band( ent:GetSpawnFlags(), 256 ) == 0 then return false end
		if ent:GetClass() == "npc_turret_floor" then return true end

		return false
	end,

	Action = function( self, ent )
		self:MsgStart()
			net.WriteEntity( ent )
		self:MsgEnd()
	end,

	Receive = function( self, length, ply )
		local ent = net.ReadEntity()

		if !properties.CanBeTargeted( ent, ply ) then return end
		if !self:Filter( ent, ply ) then return end

		ent:SetKeyValue( "spawnflags", bit.bxor( ent:GetSpawnFlags(), 256 ) )
	end
} )

properties.Add( "recharge", {
	MenuLabel = "#recharge",
	Order = orderNums.recharge,
	MenuIcon = "icon16/arrow_refresh.png",

	Filter = function( self, ent, ply )
		if !IsValid( ent ) then return false end
		if ent:GetClass() == "item_suitcharger" then return true end
		if ent:GetClass() == "item_healthcharger" then return true end

		return false
	end,

	Action = function( self, ent )
		self:MsgStart()
			net.WriteEntity( ent )
		self:MsgEnd()
	end,

	Receive = function( self, length, ply )
		local ent = net.ReadEntity()

		if !properties.CanBeTargeted( ent, ply ) then return end
		if !self:Filter( ent, ply ) then return end

		if ent:GetClass() == "item_suitcharger" then
			ent:Fire( "Recharge" )
		else
			local e = ents.Create( "item_healthcharger" )
			e:SetPos( ent:GetPos() )
			e:SetAngles( ent:GetAngles() )
			e:Spawn()
			e:Activate()
			e:EmitSound( "items/suitchargeok1.wav" )

			undo.ReplaceEntity( ent, e )
			cleanup.ReplaceEntity( ent, e )

			ent:Remove()
		end
	end
} )

properties.Add( "lock_door", {
	MenuLabel = "#lock_door",
	Order = orderNums.lockDoor,
	MenuIcon = "icon16/lock.png",

	Filter = function( self, ent, ply )
		if !IsValid( ent ) then return false end
		if ent:GetClass() != "prop_door_rotating" then return false end

		-- Check if door starts locked
		if ent:GetNWBool( "lockedDoor", 420 ) == 420 then
			if bit.band( ent:GetSpawnFlags(), 2048 ) == 2048 then
				ent:SetNWBool( "lockedDoor", true )
			end
		end

		if ent:GetNWBool( "lockedDoor" ) then return false end

		return true
	end,

	Action = function( self, ent )
		self:MsgStart()
			net.WriteEntity( ent )
		self:MsgEnd()
	end,

	Receive = function( self, length, ply )
		local ent = net.ReadEntity()

		if !properties.CanBeTargeted( ent, ply ) then return end
		if !self:Filter( ent, ply ) then return end

		ent:SetNWBool( "lockedDoor", true )
		ent:Fire( "Lock" )
	end
} )

properties.Add( "unlock_door", {
	MenuLabel = "#unlock_door",
	Order = orderNums.lockDoor,
	MenuIcon = "icon16/lock_open.png",

	Filter = function( self, ent, ply )
		if !IsValid( ent ) then return false end
		if ent:GetClass() != "prop_door_rotating" then return false end

		-- Check if door starts locked
		if ent:GetNWBool( "lockedDoor", 420 ) == 420 then
			if bit.band( ent:GetSpawnFlags(), 2048 ) == 2048 then
				ent:SetNWBool( "lockedDoor", true )
			end
		end

		if !ent:GetNWBool( "lockedDoor" ) then return false end

		return true
	end,

	Action = function( self, ent )
		self:MsgStart()
			net.WriteEntity( ent )
		self:MsgEnd()
	end,

	Receive = function( self, length, ply )
		local ent = net.ReadEntity()

		if !properties.CanBeTargeted( ent, ply ) then return end
		if !self:Filter( ent, ply ) then return end

		ent:SetNWBool( "lockedDoor", false )
		ent:Fire( "Unlock" )
	end
} )

properties.Add( "mount_gun", {
	MenuLabel = "#mount_gun",
	Order = orderNums.mountGun,
	MenuIcon = "icon16/gun.png",

	Filter = function( self, ent, ply )
		if !IsValid( ent ) then return false end
		if ent:GetClass() != "prop_vehicle_jeep"
		&& ent:GetClass() != "prop_vehicle_airboat" then return false end
		if ent:GetModel() == "models/vehicle.mdl" then return false end
		if ent:GetNWBool( "EnableGun" ) then return false end

		return true
	end,

	Action = function( self, ent )
		self:MsgStart()
			net.WriteEntity( ent )
		self:MsgEnd()
	end,

	Receive = function( self, length, ply )
		local ent = net.ReadEntity()

		if !properties.CanBeTargeted( ent, ply ) then return end
		if !self:Filter( ent, ply ) then return end

		ent:SetKeyValue( "EnableGun", "1" )
		ent:SetBodygroup( 1, 1 )
		ent:SetNWBool( "EnableGun", true )
	end
} )

properties.Add( "dismount_gun", {
	MenuLabel = "#dismount_gun",
	Order = orderNums.mountGun,
	MenuIcon = "icon16/gun.png",

	Filter = function( self, ent, ply )
		if !IsValid( ent ) then return false end
		if ent:GetClass() != "prop_vehicle_jeep"
		&& ent:GetClass() != "prop_vehicle_airboat" then return false end
		if !ent:GetNWBool( "EnableGun" ) then return false end

		return true
	end,

	Action = function( self, ent )
		self:MsgStart()
			net.WriteEntity( ent )
		self:MsgEnd()
	end,

	Receive = function( self, length, ply )
		local ent = net.ReadEntity()

		if !properties.CanBeTargeted( ent, ply ) then return end
		if !self:Filter( ent, ply ) then return end

		ent:SetKeyValue( "EnableGun", "0" )
		ent:SetBodygroup( 1, 0 )
		ent:SetNWBool( "EnableGun", false )
	end
} )

properties.Add( "enable_radar", {
	MenuLabel = "#enable_radar",
	Order = orderNums.enableRadar,
	MenuIcon = "icon16/application_add.png",

	Filter = function( self, ent, ply )
		if !IsValid( ent ) then return false end
		if ent:GetClass() != "prop_vehicle_jeep" then return false end
		if ent:GetModel() != "models/vehicle.mdl" then return false end
		if ent:GetNWBool( "EnableRadar" ) then return false end

		return true
	end,

	Action = function( self, ent )
		self:MsgStart()
			net.WriteEntity( ent )
		self:MsgEnd()
	end,

	Receive = function( self, length, ply )
		local ent = net.ReadEntity()

		if !properties.CanBeTargeted( ent, ply ) then return end
		if !self:Filter( ent, ply ) then return end

		ent:Fire( "EnableRadar" )
		ent:SetNWBool( "EnableRadar", true )
	end
} )

properties.Add( "disable_radar", {
	MenuLabel = "#disable_radar",
	Order = orderNums.enableRadar,
	MenuIcon = "icon16/application_delete.png",

	Filter = function( self, ent, ply )
		if !IsValid( ent ) then return false end
		if ent:GetClass() != "prop_vehicle_jeep" then return false end
		if ent:GetModel() != "models/vehicle.mdl" then return false end
		if !ent:GetNWBool( "EnableRadar" ) then return false end

		return true
	end,

	Action = function( self, ent )
		self:MsgStart()
			net.WriteEntity( ent )
		self:MsgEnd()
	end,

	Receive = function( self, length, ply )
		local ent = net.ReadEntity()

		if !properties.CanBeTargeted( ent, ply ) then return end
		if !self:Filter( ent, ply ) then return end

		ent:Fire( "DisableRadar" )
		ent:SetNWBool( "EnableRadar", false )
	end
} )

properties.Add( "test", {
	MenuLabel = "#test",
	Order = 0,
	MenuIcon = "icon16/bomb.png",

	Filter = function( self, ent, ply )
		if !IsValid( ent ) then return false end

		return true
	end,

	Action = function( self, ent )
		self:MsgStart()
			net.WriteEntity( ent )
		self:MsgEnd()
	end,

	Receive = function( self, length, ply )
		local ent = net.ReadEntity()

		if !properties.CanBeTargeted( ent, ply ) then return end
		if !self:Filter( ent, ply ) then return end

		ent:Fire( "EnableRadar" )
		--ent:SetKeyValue( "EnableGun", "1" )
		--ent:SetKeyValue( "spawnflags", bit.bor( ent:GetSpawnFlags(), 8192 ) )
	end
} )