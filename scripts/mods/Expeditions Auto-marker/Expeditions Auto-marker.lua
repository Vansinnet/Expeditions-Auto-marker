local mod = get_mod("Expeditions Auto-marker")

local POLL_INTERVAL = 1.0
local ACTIVE_GRACE = 5.0
local REGISTRY_GRACE = 2.0
local MARK_COOLDOWN = 3.0

local poll_timer = 0
local active_since = nil
local registry_signature = nil
local registry_changed_at = nil
local next_mark_at = 0
local last_handler = nil
local auto_mark = nil

local settings_cache = {}

local function S(k)
    if settings_cache[k] == nil then
        settings_cache[k] = mod:get(k)
    end

    return settings_cache[k]
end

local function clear_settings_cache()
    for k in pairs(settings_cache) do
        settings_cache[k] = nil
    end
end

local function _call(obj, method, ...)
    local fn = obj and obj[method]
    if not fn then return nil end

    local ok, a, b = pcall(fn, obj, ...)
    if ok then
        return a, b
    end

    return nil
end

---@return ExpeditionNavigationHandler?
local function _get_handler()
    local gm = Managers.state and Managers.state.game_mode
    if not gm then return nil end
    local mode = gm:game_mode()
    if not mode or not mode.get_navigation_handler then return nil end

    local ok, handler = pcall(mode.get_navigation_handler, mode)
    if not ok or not handler then return nil end
    ---@type ExpeditionNavigationHandler
    return handler
end

local function _game_time()
    local time_manager = Managers.time
    if not time_manager then return 0 end

    local ok, value = pcall(time_manager.time, time_manager, "gameplay")
    if ok and value then
        return value
    end

    local ok2, value2 = pcall(time_manager.time, time_manager, "main")
    return ok2 and value2 or 0
end

local function _registry_part(list, prefix)
    local keys = {}

    for idx in pairs(list or {}) do
        keys[#keys + 1] = idx
    end

    table.sort(keys)

    for i = 1, #keys do
        keys[i] = prefix .. tostring(keys[i])
    end

    return table.concat(keys, ",")
end

local function _registry_signature(handler)
    return _registry_part(_call(handler, "get_registered_opportunities"), "o")
        .. "|" .. _registry_part(_call(handler, "get_registered_exits"), "e")
        .. "|" .. _registry_part(_call(handler, "get_registered_extractions"), "x")
end

local function _reset_readiness()
    active_since = nil
    registry_signature = nil
    registry_changed_at = nil
    next_mark_at = 0
end

local function _target_exists(handler, level_index)
    local opportunities = _call(handler, "get_registered_opportunities") or {}
    local exits = _call(handler, "get_registered_exits") or {}
    local extractions = _call(handler, "get_registered_extractions") or {}

    return opportunities[level_index] ~= nil or exits[level_index] ~= nil or extractions[level_index] ~= nil
end

local function _find_best(list, handler, player_pos)
    local best, best_d2
    for idx, box in pairs(list or {}) do
        local _, marked = _call(handler, "player_slots_by_level_marked", idx)
        if not _call(handler, "is_level_completed", idx) and marked == 0 then
            local p = box and box:unbox()
            if p then
                local dx = p.x - player_pos.x
                local dy = p.y - player_pos.y
                local dz = p.z - player_pos.z
                local d2 = dx * dx + dy * dy + dz * dz
                if not best_d2 or d2 < best_d2 then
                    best, best_d2 = idx, d2
                end
            end
        end
    end
    return best
end

local function _all_opps_done(handler)
    local opportunities = _call(handler, "get_registered_opportunities") or {}
    if not next(opportunities) then return false end
    for idx in pairs(opportunities) do
        if not _call(handler, "is_level_completed", idx) then
            return false
        end
    end
    return true
end

local function _clear_auto_mark()
    poll_timer = 0
    auto_mark = nil
    last_handler = nil
    _reset_readiness()
end

local function _my_marked_level(handler, slot)
    local marked = _call(handler, "get_marked_player_slots")
    return marked and marked[slot]
end

local function _tick()
    local now = _game_time()
    local handler = _get_handler()
    if not handler then
        auto_mark = nil
        if last_handler then
            last_handler = nil
            _reset_readiness()
        end
        return
    end

    if handler ~= last_handler then
        last_handler = handler
        _reset_readiness()
    end

    local active = _call(handler, "is_active")
    if active ~= true then
        auto_mark = nil
        _reset_readiness()
        return
    end

    if not active_since then
        active_since = now
        return
    end

    if now - active_since < ACTIVE_GRACE then
        return
    end

    local signature = _registry_signature(handler)
    if signature ~= registry_signature or not registry_changed_at then
        registry_signature = signature
        registry_changed_at = now
        auto_mark = nil
        return
    end

    if now - registry_changed_at < REGISTRY_GRACE then
        return
    end

    if now < next_mark_at then
        return
    end

    local player_manager = Managers.player
    local player = player_manager and player_manager:local_player_safe(1)
    local slot = player and player:slot()
    local unit = player and player.player_unit
    local pos = unit and Unit.alive(unit) and Unit.world_position(unit, 1)
    if not slot or not pos then
        return
    end
    if not Managers.state or not Managers.state.game_session then
        return
    end

    local my_mark = _my_marked_level(handler, slot)
    if my_mark and my_mark ~= auto_mark then
        auto_mark = nil
        return
    end

    local last = auto_mark
    if last then
        local slots = _call(handler, "player_slots_by_level_marked", last)
        if slots and slots[slot] then
            if not _call(handler, "is_level_completed", last) then
                return
            end
        elseif not _call(handler, "is_level_completed", last) then
            auto_mark = nil
            return
        end
    end

    local nearest = _find_best(_call(handler, "get_registered_opportunities"), handler, pos)
    local mark_reason = "nearest_poi"
    if not nearest and _all_opps_done(handler) then
        local exit = _find_best(_call(handler, "get_registered_exits"), handler, pos)

        if exit and S("enable_expedition_automark_vault") then
            nearest = exit
            mark_reason = "vault"
        elseif not exit and S("enable_expedition_automark_extraction") then
            nearest = _find_best(_call(handler, "get_registered_extractions"), handler, pos)
            mark_reason = "extraction"
        end
    end
    if nearest then
        if not _target_exists(handler, nearest) then
            next_mark_at = now + MARK_COOLDOWN
            return
        end

        if _call(handler, "is_level_completed", nearest) then
            next_mark_at = now + MARK_COOLDOWN
            return
        end

        local marked_slots = _call(handler, "player_slots_by_level_marked", nearest)
        if marked_slots and marked_slots[slot] then
            auto_mark = nearest
            next_mark_at = now + MARK_COOLDOWN
            return
        end

        next_mark_at = now + MARK_COOLDOWN
        local impacted, assigned = _call(handler, "mark_level_by_player", nearest, player)
        if impacted and assigned then
            auto_mark = nearest
            if not S("expedition_automark_silent") then
                mod:echo_localized("auto_mark_notification", mod:localize("mark_reason_" .. mark_reason))
            end
        end
    end
end

mod.update = function(dt)
    if not mod:is_enabled() then return end
    if not S("enable_expedition_automark") then return end
    poll_timer = poll_timer + dt
    if poll_timer < POLL_INTERVAL then return end
    poll_timer = 0
    _tick()
end

mod.on_setting_changed = function(id)
    clear_settings_cache()

    if id == "enable_expedition_automark" then
        _clear_auto_mark()
    end
end

mod.on_game_state_changed = function(status, name)
    if status == "exit" and name == "StateGameplay" then
        _clear_auto_mark()
    end
end

mod.on_disabled = function()
    _clear_auto_mark()
end

mod.on_unload = function()
    _clear_auto_mark()
end
