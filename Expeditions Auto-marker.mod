return {
	version = "1.0.0",
	run = function()
		fassert(rawget(_G, "new_mod"), "`Expeditions Auto-marker` encountered an error loading the Darktide Mod Framework.")
		new_mod("Expeditions Auto-marker", {
			mod_script       = "Expeditions Auto-marker/scripts/mods/Expeditions Auto-marker/Expeditions Auto-marker",
			mod_data         = "Expeditions Auto-marker/scripts/mods/Expeditions Auto-marker/Expeditions Auto-marker_data",
			mod_localization = "Expeditions Auto-marker/scripts/mods/Expeditions Auto-marker/Expeditions Auto-marker_localization",
		})
	end,
	packages = {},
}
