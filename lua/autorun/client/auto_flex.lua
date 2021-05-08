FlexEntities = {}

local function GetFlexFromName( ent, name )
	for i = 0, ent:GetFlexNum() - 1 do
		if string.lower( ent:GetFlexName( i ) ) == string.lower( name ) then return i end
	end
end

hook.Add( "Think", "Flex_Think", function()
	for parent, tab in pairs( FlexEntities ) do
		if IsValid( parent ) && parent:GetFlexNum() > 0 then
			local children = parent:GetChildren()
			
			if IsValid( parent:GetParent() ) && parent:GetParent().AttachedEntity == parent then
				table.Add( children, parent:GetParent():GetChildren() )
			end
			
			for _, ent in pairs( children ) do
				if IsValid( ent ) && ent != parent && ent:GetFlexNum() > 0 then
					if !tab[ ent ] then
						tab[ ent ] = {}
						for i = 0, ent:GetFlexNum() - 1 do
							local flex = GetFlexFromName( parent, ent:GetFlexName( i ) )
							if flex then tab[ ent ][ i ] = flex end
						end
					end
					
					for i, flex in pairs( tab[ ent ] ) do
						ent:SetFlexWeight( i, parent:GetFlexWeight( flex ) )
					end
					
					ent:SetFlexScale( parent:GetFlexScale() )
				end
			end
		else
			FlexEntities[ parent ] = nil
		end
	end
end )

hook.Add( "OnEntityCreated", "Flex_Add", function( ent )
	if !IsValid( ent ) then return end
	FlexEntities[ ent ] = {}
end )