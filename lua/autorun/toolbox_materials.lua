list.Add( "OverrideMaterials", "chroma_key_green" )
list.Add( "OverrideMaterials", "chroma_key_blue" )
list.Add( "OverrideMaterials", "debug/debugempty" )

if IsMounted("tf") then
	list.Add( "OverrideMaterials", "models/effects/invulnfx_red" )
	list.Add( "OverrideMaterials", "models/effects/invulnfx_blue" )
end