AddCSLuaFile()

if CLIENT then
	language.Add( "unbreakable", "Unbreakable" )
	language.Add( "shadows", "Shadows" )
	language.Add( "sleep", "Sleep" )
	language.Add( "tpose", "T-Pose" )
	language.Add( "world_collision_off", "Disable World Collision" )
	language.Add( "world_collision_on", "Enable World Collision" )
	language.Add( "self_collision_off", "Disable Self Collision" )
	language.Add( "self_collision_on", "Enable Self Collision" )
end

properties.Add( "unbreakable", {
	MenuLabel = "#unbreakable",
	Order = 1000,
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
	Order = 800,
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
	Order = 850,
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
	Order = 900,
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
	Order = 1501,
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
	Order = 1501,
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
	Order = 1501,
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
	Order = 1501,
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