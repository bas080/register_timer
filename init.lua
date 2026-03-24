---
-- register_timer and get_timer for Luanti that
-- persists accross server restarts.
--
-- Author:  bas080
-- Date:    2026-03-23
-- Related: https://github.com/luanti-org/luanti/issues/2856
--
-- @usage
--
-- register_timer({
--   name = 'grow_tree',
--   action = function(job, pos, param2)
--     grow_tree(pos)
--   end,
-- })
--
-- grow_tree_timer = get_timer('grow_tree')
--
-- grow_tree_timer(10, {x,y,z}, math.random(0,3))

local storage = core.get_mod_storage()

local id = 0

local timers = {}
local jobs = {}

core.register_on_mods_loaded(function()
    -- Need a tick to because get_worldtime is nil on the first step.
    core.after(0, function()
        local job
        for key in pairs(storage:to_table().fields) do
            job = core.deserialize(storage:get_string(key))
            after(job)
        end
    end)
end)

local function get_timer(name)
    local timer = timers[name]
    assert(timer, "No timer registered with name: " .. name)

    return function(seconds, ...)
        local job = {
            name = name,
            seconds = seconds,
            expires = core.get_gametime() + seconds,
            args = { ... },
        }

        return after(job)
    end
end

local function register_timer(params)
    assert(params, "Must be an table with name")
    assert(params.name, "Define a name for your timer")
    assert(timers[params.name] == nil, 'Timer with name: "' .. params.name .. '" is already defined.')

    timers[params.name] = params

    return get_timer(params.name)
end

function after(job)
    if job.id == nil then
        id = id + 1
        job.id = id

        storage:set_string(tostring(id), core.serialize(job))
    end

    local timer = timers[job.name]

    -- figure out how much time is left
    local left = math.max(0, job.expires - core.get_gametime())
    local after_job = core.after(left, timer.action, unpack(job.args))

    jobs[id] = after_job

    function cancel()
        storage:set_string(job.id, "")
        after_job:cancel()
        jobs[job.id] = nil
    end

    return cancel
end

return register_timer, get_timer
