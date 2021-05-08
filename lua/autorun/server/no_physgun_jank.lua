hook.Add("PhysgunDrop", "NoPhysgunJank", function( ply, ent )
	if IsValid( ent ) && IsValid( ply ) then
		local phys = ent:GetPhysicsObject()
		if IsValid( phys ) && !ply:KeyDown( IN_ATTACK2 ) then
			local pos = ent:WorldSpaceAABB()
			local tr = util.TraceHull( { start = pos, endpos = pos + Vector( 0, 0, -5 ), mins = ent:OBBMins(), maxs = ent:OBBMaxs(), filter = ent } )
			if tr.Hit then
				phys:EnableMotion( false )
				phys:EnableMotion( true )
			end
		end
	end
end )