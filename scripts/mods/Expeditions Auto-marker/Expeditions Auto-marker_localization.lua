local mod = get_mod("Expeditions Auto-marker")

local localizations = {
    mod_name = {
        en = "Expeditions Auto-marker",
        ["zh-tw"] = "遠征自動標記",
    },
    mod_description = {
        en = "Automatically marks the nearest opportunity on the expedition map without needing to pull out the auspex.",
        ["zh-tw"] = "自動標記遠征地圖上最近的機會點，不需要拿出占卜儀。",
    },

    expedition_group = {
        en = "Expedition Auto-Mark",
        ["zh-tw"] = "遠征自動標記",
    },
    enable_expedition_automark = {
        en = "Automatically mark points of interest (POI)",
        ["zh-tw"] = "自動標記興趣點（POI）",
    },
    enable_expedition_automark_tooltip = {
        en = "Automatically marks the nearest opportunity on the expedition map without needing to pull out the auspex. Manual marking overrides auto-marking.",
        ["zh-tw"] = "自動標記遠征地圖上最近的機會點，不需要拿出占卜儀。手動標記會覆蓋自動標記。",
    },
    expedition_automark_silent = {
        en = "Disable notifications",
        ["zh-tw"] = "停用通知",
    },
    expedition_automark_silent_tooltip = {
        en = "Suppress chat messages when a POI is auto-marked.",
        ["zh-tw"] = "自動標記 POI 時隱藏聊天訊息。",
    },
    enable_expedition_automark_vault = {
        en = "Always mark the Vault automatically when all POI are finished",
        ["zh-tw"] = "所有 POI 完成後一律自動標記寶庫",
    },
    enable_expedition_automark_vault_tooltip = {
        en = "When all opportunities are completed, automatically mark the nearest exit/vault.",
        ["zh-tw"] = "所有機會點完成後，自動標記最近的出口/寶庫。",
    },
    enable_expedition_automark_extraction = {
        en = "Mark extraction when no Vault exists",
        ["zh-tw"] = "沒有寶庫時標記撤離點",
    },
    enable_expedition_automark_extraction_tooltip = {
        en = "When all opportunities are completed and there is no exit/vault to mark, automatically mark the extraction point instead.",
        ["zh-tw"] = "所有機會點完成且沒有可標記的出口/寶庫時，改為自動標記撤離點。",
    },
    auto_mark_notification = {
        en = "Expeditions Auto-marker: auto-marked nearest expedition %s",
        ["zh-tw"] = "Expeditions Auto-marker：已自動標記最近的遠征%s",
    },
    mark_reason_nearest_poi = {
        en = "POI",
        ["zh-tw"] = "機會點",
    },
    mark_reason_vault = {
        en = "vault",
        ["zh-tw"] = "寶庫",
    },
    mark_reason_extraction = {
        en = "extraction",
        ["zh-tw"] = "撤離點",
    },
}

return localizations
