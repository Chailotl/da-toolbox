AddCSLuaFile()

local orderNums = {
	unbreakable = 1000,
	shadows = 900,
	lock = 800,
	sleep = 850,
	tpose = 1500.5,
	world_collision_off = 1500.1,
	world_collision_on = 1500.1,
	self_collision_off = 1500.2,
	self_collision_on = 1500.2,
	make_friendly = 1900,
	make_hostile = 1900,
	deplete_ammo = 1901,
	restore_ammo = 1901,
	self_destruct = 1902,
	recharge = 1900,
	lock_door = 1900,
	unlock_door = 1900,
	mount_gun = 1900,
	dismount_gun = 1900,
	enable_radar = 1900,
	disable_radar = 1900
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

function registerProperty( name, icon, filter, receive )
	properties.Add( name, {
		MenuLabel = "#" .. name,
		Order = orderNums[name],
		MenuIcon = icon,
		Filter = filter,
		Action = function( self, ent )
			self:MsgStart()
				net.WriteEntity( ent )
			self.MsgEnd()
		end,
		Receive = receive
	} )
end

function registerPropertyToggle( name, checked, filter, receive )
	properties.Add( name, {
		MenuLabel = "#" .. name,
		Order = orderNums[name],
		Type = "toggle",
		Checked = checked,
		Filter = filter,
		Action = function( self, ent )
			self:MsgStart()
				net.WriteEntity( ent )
			self.MsgEnd()
		end,
		Receive = receive
	} )
end

-- unbreakable
registerPropertyToggle( "unbreakable",
	function( self, ent, ply )
		return ent:GetNWBool( "unbreakable" )
	end,
	function( self, ent, ply )
		if !IsValid( ent ) then return false end
		if ent:IsPlayer() then return false end
		if ent:Health() == 0 then return false end

		return true
	end,
	function( self, length, ply )
		local ent = net.ReadEntity()

		if !properties.CanBeTargeted( ent, ply ) then return end
		if !self:Filter( ent, ply ) then return end

		local unbreakable = !ent:GetNWBool( "unbreakable" )
		ent:SetNWBool( "unbreakable", unbreakable )
		duplicator.StoreEntityModifier( ent, "chai.unbreakable", { val = unbreakable } )
	end
)

duplicator.RegisterEntityModifier( "chai.unbreakable", function( ply, ent, data )
	ent:SetNWBool( "unbreakable", data.val )
end )

hook.Add( "EntityTakeDamage", "Unbreakable", function( target, dmginfo )
	if target:GetNWBool( "unbreakable" ) then
		dmginfo:ScaleDamage( 0 )
	end
end )

-- sleep
registerProperty( "sleep", "icon16/anchor.png",
	function( self, ent, ply )
		if !IsValid( ent ) then return false end
		if ent:IsPlayer() then return false end
		-- Always invalid on client
		--if !IsValid( ent:GetPhysicsObject() ) then return false end

		return true
	end,
	function( self, length, ply )
		local ent = net.ReadEntity()

		if !properties.CanBeTargeted( ent, ply ) then return end
		if !self:Filter( ent, ply ) then return end
		if !IsValid( ent:GetPhysicsObject() ) then return end

		for i = 0, ent:GetPhysicsObjectCount() - 1 do
			ent:GetPhysicsObjectNum( i ):Sleep()
			ent:GetPhysicsObjectNum( i ):EnableMotion( true )
		end
	end
)

-- tpose
registerProperty( "tpose", "icon16/status_online.png",
	function( self, ent, ply )
		if !IsValid( ent ) then return false end
		if ent:IsPlayer() then return false end
		if ent:GetClass() != "prop_ragdoll" then return false end

		return true
	end,
	function( self, length, ply )
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
)

-- shadows
registerPropertyToggle( "shadows",
	function( self, ent, ply )
		return ent:GetNWBool( "shadows", true )
	end,
	function( self, ent, ply )
		if !IsValid( ent ) then return false end
		if ent:IsPlayer() then return false end

		return true
	end,
	function( self, length, ply )
		local ent = net.ReadEntity()

		if !properties.CanBeTargeted( ent, ply ) then return end
		if !self:Filter( ent, ply ) then return end

		local shadows = !ent:GetNWBool( "shadows", true )
		ent:SetNWBool( "shadows", shadows )
		ent:DrawShadow( shadows )
		duplicator.StoreEntityModifier( ent, "chai.shadows", { val = shadows } )
	end
)

duplicator.RegisterEntityModifier( "chai.shadows", function( ply, ent, data )
	ent:SetNWBool( "shadows", data.val )
	ent:DrawShadow( data.val )
end )

-- world collisions
registerProperty( "world_collision_off", "icon16/collision_off.png",
	function( self, ent, ply )
		if !IsValid( ent ) then return false end
		if ent:IsPlayer() then return false end
		if ent:GetNWBool( "noCollideWorld" ) then return false end

		return true
	end,
	function( self, length, ply )
		local ent = net.ReadEntity()

		if !properties.CanBeTargeted( ent, ply ) then return end
		if !self:Filter( ent, ply ) then return end

		ent:SetNWBool( "noCollideWorld", true )
		constraint.NoCollideWorld( ent, Entity( 0 ), 0, 0 )
	end
)

registerProperty( "world_collision_on", "icon16/collision_on.png",
	function( self, ent, ply )
		if !IsValid( ent ) then return false end
		if ent:IsPlayer() then return false end
		if !ent:GetNWBool( "noCollideWorld" ) then return false end

		return true
	end,
	function( self, length, ply )
		local ent = net.ReadEntity()

		if !properties.CanBeTargeted( ent, ply ) then return end
		if !self:Filter( ent, ply ) then return end

		ent:SetNWBool( "noCollideWorld", false )
		constraint.FindConstraint( ent, "NoCollideWorld" ).Constraint:Remove()
	end
)

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

-- self collisions
registerProperty( "self_collision_off", "icon16/collision_off.png",
	function( self, ent, ply )
		if !IsValid( ent ) then return false end
		if ent:IsPlayer() then return false end
		if ent:GetClass() != "prop_ragdoll" then return false end
		if ent:GetNWBool( "noCollideSelf" ) then return false end

		return true
	end,
	function( self, length, ply )
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
)

registerProperty( "self_collision_on", "icon16/collision_on.png",
	function( self, ent, ply )
		if !IsValid( ent ) then return false end
		if ent:IsPlayer() then return false end
		if ent:GetClass() != "prop_ragdoll" then return false end
		if !ent:GetNWBool( "noCollideSelf" ) then return false end

		return true
	end,
	function( self, length, ply )
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
)

-- locked
registerPropertyToggle( "locked",
	function( self, ent, ply )
		return ent:GetNWBool( "locked" )
	end,
	function( self, ent, ply )
		if !IsValid( ent ) then return false end
		if ent:IsPlayer() then return false end

		return true
	end,
	function( self, length, ply )
		local ent = net.ReadEntity()

		if !properties.CanBeTargeted( ent, ply ) then return end
		if !self:Filter( ent, ply ) then return end

		local locked = !ent:GetNWBool( "locked" )
		ent:SetNWBool( "locked", locked )
		duplicator.StoreEntityModifier( ent, "chai.locked", { val = locked } )
	end
)

duplicator.RegisterEntityModifier( "chai.locked", function( ply, ent, data )
	ent:SetNWBool( "locked", data.val )
end )

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

-- make friendly/hostile
registerProperty( "make_friendly", "icon16/user_green.png",
	function( self, ent, ply )
		if !IsValid( ent ) then return false end
		if bit.band( ent:GetSpawnFlags(), 512 ) == 512 then return false end
		if ent:GetClass() == "npc_turret_floor" then return true end

		return false
	end,
	function( self, length, ply )
		local ent = net.ReadEntity()

		if !properties.CanBeTargeted( ent, ply ) then return end
		if !self:Filter( ent, ply ) then return end

		ent:SetKeyValue( "spawnflags", bit.bor( ent:GetSpawnFlags(), SF_FLOOR_TURRET_CITIZEN ) )
		ent:SetMaterial( "models/combine_turrets/floor_turret/floor_turret_citizen" )
		duplicator.StoreEntityModifier( ent, "chai.make_friendly", { val = true } )
	end
)

registerProperty( "make_hostile", "icon16/user_red.png",
	function( self, ent, ply )
		if !IsValid( ent ) then return false end
		if bit.band( ent:GetSpawnFlags(), 512 ) == 0 then return false end
		if ent:GetClass() == "npc_turret_floor" then return true end

		return false
	end,
	function( self, length, ply )
		local ent = net.ReadEntity()

		if !properties.CanBeTargeted( ent, ply ) then return end
		if !self:Filter( ent, ply ) then return end

		ent:SetKeyValue( "spawnflags", bit.bxor( ent:GetSpawnFlags(), SF_FLOOR_TURRET_CITIZEN ) )
		ent:SetMaterial( "models/combine_turrets/floor_turret/combine_gun002" )
		duplicator.StoreEntityModifier( ent, "chai.make_friendly", { val = false } )
	end
)

duplicator.RegisterEntityModifier( "chai.make_friendly", function( ply, ent, data )
	if ( data.val ) then
		ent:SetKeyValue( "spawnflags", bit.bor( ent:GetSpawnFlags(), SF_FLOOR_TURRET_CITIZEN ) )
		ent:SetMaterial( "models/combine_turrets/floor_turret/floor_turret_citizen" )
	end
end )

-- self-destruct
registerProperty( "self_destruct", "icon16/bomb.png",
	function( self, ent, ply )
		if !IsValid( ent ) then return false end
		if ent:GetClass() == "npc_turret_floor" then return true end
		if ent:GetClass() == "npc_helicopter" then return true end
		if ent:GetClass() == "npc_rollermine" then return true end

		return false
	end,
	function( self, length, ply )
		local ent = net.ReadEntity()

		if !properties.CanBeTargeted( ent, ply ) then return end
		if !self:Filter( ent, ply ) then return end

		if ent:GetClass() == "npc_rollermine" then
			ent:Fire( "InteractivePowerDown" )
		else
			ent:Fire( "SelfDestruct" )
		end
	end
)

-- deplete/restore ammo
registerProperty( "deplete_ammo", "icon16/delete.png",
	function( self, ent, ply )
		if !IsValid( ent ) then return false end
		if bit.band( ent:GetSpawnFlags(), 256 ) == 256 then return false end
		if ent:GetClass() == "npc_turret_floor" then return true end

		return false
	end,
	function( self, length, ply )
		local ent = net.ReadEntity()

		if !properties.CanBeTargeted( ent, ply ) then return end
		if !self:Filter( ent, ply ) then return end

		ent:SetKeyValue( "spawnflags", bit.bor( ent:GetSpawnFlags(), 256 ) )
		duplicator.StoreEntityModifier( ent, "chai.deplete_ammo", { val = true } )
	end
)

registerProperty( "restore_ammo", "icon16/add.png",
	function( self, ent, ply )
		if !IsValid( ent ) then return false end
		if bit.band( ent:GetSpawnFlags(), 256 ) == 0 then return false end
		if ent:GetClass() == "npc_turret_floor" then return true end

		return false
	end,
	function( self, length, ply )
		local ent = net.ReadEntity()

		if !properties.CanBeTargeted( ent, ply ) then return end
		if !self:Filter( ent, ply ) then return end

		ent:SetKeyValue( "spawnflags", bit.bxor( ent:GetSpawnFlags(), 256 ) )
		duplicator.StoreEntityModifier( ent, "chai.deplete_ammo", { val = false } )
	end
)

duplicator.RegisterEntityModifier( "chai.deplete_ammo", function( ply, ent, data )
	if ( data.val ) then
		ent:SetKeyValue( "spawnflags", bit.bor( ent:GetSpawnFlags(), 256 ) )
	end
end )

-- recharge
registerProperty( "recharge", "icon16/arrow_refresh.png",
	function( self, ent, ply )
		if !IsValid( ent ) then return false end
		if ent:GetClass() == "item_suitcharger" then return true end
		if ent:GetClass() == "item_healthcharger" then return true end

		return false
	end,
	function( self, length, ply )
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
)

-- lock/unlock door
registerProperty( "lock_door", "icon16/lock.png",
	function( self, ent, ply )
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
	function( self, length, ply )
		local ent = net.ReadEntity()

		if !properties.CanBeTargeted( ent, ply ) then return end
		if !self:Filter( ent, ply ) then return end

		ent:SetNWBool( "lockedDoor", true )
		ent:Fire( "Lock" )
	end
)

registerProperty( "unlock_door", "icon16/lock_open.png",
	function( self, ent, ply )
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
	function( self, length, ply )
		local ent = net.ReadEntity()

		if !properties.CanBeTargeted( ent, ply ) then return end
		if !self:Filter( ent, ply ) then return end

		ent:SetNWBool( "lockedDoor", false )
		ent:Fire( "Unlock" )
	end
)

-- mount/dismount gun
registerProperty( "mount_gun", "icon16/car_add.png",
	function( self, ent, ply )
		if !IsValid( ent ) then return false end
		if ent:GetClass() != "prop_vehicle_jeep"
		&& ent:GetClass() != "prop_vehicle_airboat" then return false end
		if ent:GetModel() == "models/vehicle.mdl" then return false end
		if ent:GetNWBool( "EnableGun" ) then return false end

		return true
	end,
	function( self, length, ply )
		local ent = net.ReadEntity()

		if !properties.CanBeTargeted( ent, ply ) then return end
		if !self:Filter( ent, ply ) then return end

		ent:SetKeyValue( "EnableGun", "1" )
		ent:SetBodygroup( 1, 1 )
		ent:SetNWBool( "EnableGun", true )
		duplicator.StoreEntityModifier( ent, "chai.mount_gun", { val = true } )
	end
)

registerProperty( "dismount_gun", "icon16/car_delete.png",
	function( self, ent, ply )
		if !IsValid( ent ) then return false end
		if ent:GetClass() != "prop_vehicle_jeep"
		&& ent:GetClass() != "prop_vehicle_airboat" then return false end
		if !ent:GetNWBool( "EnableGun" ) then return false end

		return true
	end,
	function( self, length, ply )
		local ent = net.ReadEntity()

		if !properties.CanBeTargeted( ent, ply ) then return end
		if !self:Filter( ent, ply ) then return end

		ent:SetKeyValue( "EnableGun", "0" )
		ent:SetBodygroup( 1, 0 )
		ent:SetNWBool( "EnableGun", false )
		duplicator.StoreEntityModifier( ent, "chai.mount_gun", { val = false } )
	end
)

duplicator.RegisterEntityModifier( "chai.mount_gun", function( ply, ent, data )
	if ( data.val ) then
		ent:SetKeyValue( "EnableGun", "1" )
		ent:SetBodygroup( 1, 1 )
		ent:SetNWBool( "EnableGun", true )
	end
end )

-- enable/disable radar
registerProperty( "enable_radar", "icon16/ipod_cast_add.png",
	function( self, ent, ply )
		if !IsValid( ent ) then return false end
		if ent:GetClass() != "prop_vehicle_jeep" then return false end
		if ent:GetModel() != "models/vehicle.mdl" then return false end
		if ent:GetNWBool( "EnableRadar" ) then return false end

		return true
	end,
	function( self, length, ply )
		local ent = net.ReadEntity()

		if !properties.CanBeTargeted( ent, ply ) then return end
		if !self:Filter( ent, ply ) then return end

		ent:Fire( "EnableRadar" )
		ent:SetNWBool( "EnableRadar", true )
		duplicator.StoreEntityModifier( ent, "chai.enable_radar", { val = true } )
	end
)

registerProperty( "disable_radar", "icon16/ipod_cast_delete.png",
	function( self, ent, ply )
		if !IsValid( ent ) then return false end
		if ent:GetClass() != "prop_vehicle_jeep" then return false end
		if ent:GetModel() != "models/vehicle.mdl" then return false end
		if !ent:GetNWBool( "EnableRadar" ) then return false end

		return true
	end,
	function( self, length, ply )
		local ent = net.ReadEntity()

		if !properties.CanBeTargeted( ent, ply ) then return end
		if !self:Filter( ent, ply ) then return end

		ent:Fire( "DisableRadar" )
		ent:SetNWBool( "EnableRadar", false )
		duplicator.StoreEntityModifier( ent, "chai.enable_radar", { val = false } )
	end
)

duplicator.RegisterEntityModifier( "chai.enable_radar", function( ply, ent, data )
	if ( data.val ) then
		ent:Fire( "EnableRadar" )
		ent:SetNWBool( "EnableRadar", true )
	end
end )

--[[properties.Add( "test", {
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
} )]]