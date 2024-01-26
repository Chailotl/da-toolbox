EyeTracker = {}
EyeTracker.Ents = {}

function EyeTracker.Remove( ent )
	for k, v in pairs( EyeTracker.Ents ) do
		if v.index == ent:EntIndex() then
			EyeTracker.Ents[ k ] = nil
			return true
		end
	end

	return false
end

local function ConvertRelativeToEyesAttachment( ent, pos )
	// Convert relative to eye attachment
	local eyeattachment = ent:LookupAttachment( "eyes" )
	if eyeattachment == 0 then return end
	local attachment = ent:GetAttachment( eyeattachment )
	if !attachment then return end

	local LocalPos, LocalAng = WorldToLocal( pos, Angle( 0, 0, 0 ), attachment.Pos, attachment.Ang )

	return LocalPos
end

hook.Add( "Think", "EyeTracker_Think", function()
	for k, v in pairs( EyeTracker.Ents ) do
		local ent = ents.GetByIndex( v.index )
		local pos = nil

		if v.is_player then
			local ply = player.GetByID( v.tracker_index )
			if !IsValid( ply ) then
				EyeTracker.Ents[ k ] = nil
				return
			end
			pos = ply:GetBonePosition( ply:LookupBone( "ValveBiped.Bip01_Head1" ) )
		else
			local OtherEnt = ents.GetByIndex( v.tracker_index )
			if !IsValid( OtherEnt ) then
				EyeTracker.Ents[ k ] = nil
				return
			end
			pos = OtherEnt:GetPos()
		end

		ent:SetEyeTarget( ConvertRelativeToEyesAttachment( ent, pos ) )
	end
end )