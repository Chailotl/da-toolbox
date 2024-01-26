
TOOL.Category = "Poser"
TOOL.Name = "#tool.eyetracker.name"

TOOL.Information = {
	{ name = "left", stage = 0 },
	{ name = "left_1", stage = 1, op = 1 },
	{ name = "right", stage = 0 },
	{ name = "right_1", stage = 1, op = 1 },
	{ name = "reload" }
}

if ( CLIENT ) then
	language.Add( "tool.eyetracker.name", "Eye Tracker" )
	language.Add( "tool.eyetracker.desc", "Change the eye direction of Ragdolls to track you or an object" )
	language.Add( "tool.eyetracker.left", "Make eyes track you" )
	language.Add( "tool.eyetracker.right", "Make eyes track an object" )
	language.Add( "tool.eyetracker.reload", "Clear eye tracking" )
	language.Add( "tool.eyetracker.left_1", "Select an object to eye track" )
	language.Add( "tool.eyetracker.right_1", "Cancel" )
end

function TOOL:LeftClick( trace )
	if !IsValid( trace.Entity ) then return end

	if self:GetOperation() == 0 then
		if trace.Entity:LookupAttachment( "eyes" ) == 0 || trace.Entity:GetClass() != "prop_ragdoll" then return false end

		EyeTracker.Remove( trace.Entity )

		local ent = {}
		ent.index = trace.Entity:EntIndex()
		ent.tracker_index = self:GetOwner():EntIndex()
		ent.is_player = true

		table.insert(EyeTracker.Ents, ent)
		return true
	else
		EyeTracker.Remove( self:GetEnt( 0 ) )

		local ent = {}
		ent.index = self:GetEnt( 0 ):EntIndex()
		ent.tracker_index = trace.Entity:EntIndex()
		ent.is_player = false

		table.insert(EyeTracker.Ents, ent)

		self:SetOperation( 0 )
		self:SetStage( 0 )
		return true
	end
end

function TOOL:RightClick( trace )
	if self:GetOperation() == 1 then
		self:SetOperation( 0 )
		self:SetStage( 0 )
		return true
	end

	if trace.Entity:LookupAttachment( "eyes" ) == 0 then return false end

	if trace.Entity:GetClass() == "prop_ragdoll" then
		self:SetObject( 0, trace.Entity, trace.HitPos, nil, trace.PhysicsBone, trace.HitNormal )
		self:SetOperation( 1 )
		self:SetStage( 1 )
		return true
	end
end

function TOOL:Reload( trace )
	ent = trace.Entity
	return EyeTracker.Remove( ent )
end

function TOOL.BuildCPanel( CPanel )
	CPanel:AddControl( "Header", { Description = "#tool.eyetracker.desc" } )
end