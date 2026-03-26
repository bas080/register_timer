# register_timer

**PERSISTENT** timers for Luanti mods.

```lua
local register_timer, get_timer = dofile(core.get_modpath('register_timer')..'/init.lua')

local returns_the_timer = register_timer({
  name = 'grow_tree',
  action = function(job, pos, param2)
    grow_tree(pos)
  end,
})

local grow_tree_timer = get_timer('grow_tree')

assert(grow_tree_timer == returns_the_timer)

local cancel = grow_tree_timer(10, {x,y,z}, math.random(0,3))

cancel()
```

Timers are stored in the mod storage. They are restarted when all mods are loaded.

## Donate

If you enjoy my work, you can support me here: [💖 Donate](https://liberapay.com/bas080)

Thank you for helping me keep modding and sharing fun with everyone!
