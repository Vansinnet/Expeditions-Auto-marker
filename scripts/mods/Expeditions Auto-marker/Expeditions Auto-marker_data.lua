local mod = get_mod("Expeditions Auto-marker")

return {
    name        = mod:localize("mod_name"),
    description = mod:localize("mod_description"),
    is_togglable    = true,
    options = {
        widgets = {
            {
                setting_id  = "expedition_group",
                type        = "group",
                title       = "expedition_group",
                sub_widgets = {
                    {
                        setting_id    = "enable_expedition_automark",
                        type          = "checkbox",
                        default_value = true,
                        tooltip       = "enable_expedition_automark_tooltip",
                    },
                    {
                        setting_id    = "expedition_automark_silent",
                        type          = "checkbox",
                        default_value = true,
                        tooltip       = "expedition_automark_silent_tooltip",
                    },
                    {
                        setting_id    = "enable_expedition_automark_vault",
                        type          = "checkbox",
                        default_value = true,
                        tooltip       = "enable_expedition_automark_vault_tooltip",
                    },
                    {
                        setting_id    = "enable_expedition_automark_extraction",
                        type          = "checkbox",
                        default_value = true,
                        tooltip       = "enable_expedition_automark_extraction_tooltip",
                    },
                },
            },
        },
    },
}
