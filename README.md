# Orbital Ion Cannon — Space Exploration Edition

A Factorio 2.0 mod: launch ion cannons into orbit with a rocket silo and call down the thunder on enemy nests.

Rewritten from scratch for 2.0 on top of [Supercheese's Orbital Ion Cannon](https://github.com/Suprcheese/Orbital-Ion-Cannon) 1.8.2 (MIT). No code from later ports is used.

## How it plays

- Research **Orbital ion cannon**, craft one and send it to orbit from a rocket silo. Each cannon starts on cooldown.
- Cannons orbit the **planet they were launched from** and only fire there. A Space Exploration orbit counts as its planet or moon; a Space Age platform counts as the planet it is parked at, but cannot be targeted itself.
- Use the **targeting device** on the map, in remote view or on the ground, within its range of you (100 tiles by default). The target is marked, a klaxon sounds and the blast lands after the heat-up (≈7 s by default).
- Build a powered **orbital uplink** (research) and targeting devices reach the whole planet it stands on, orbit included. It also works as a radar.
- **Auto-targeting** (research) lets radars designate enemy nests while they scan and hits new nests in always-visible radar coverage. A configurable number of cannons per planet stays reserved for manual use.
- The **ion cannon window** (top button or `I`) lists cannons per planet with their cooldowns. Admins can switch auto-targeting off, block players from firing, and — with the cheat setting on — add or remove cannons.

Pods sent to a space platform or a landing pad deliver the cannon as an item; only a launch into orbit deploys it. Space Exploration cargo rockets also just deliver it — use a rocket silo on the planet or moon you want covered.

## Compatibility

- Factorio 2.0, with or without Space Age.
- Space Exploration 0.7 (zones resolved through its remote interface).
- Saves from Orbital Ion Cannon 1.x keep their cannons. Saves from the 3.x versions of this mod start with an empty orbit.

## Remote interface

Same name and calls as the original mod:

```lua
-- custom events; also available directly as "on_ion_cannon_targeted" / "on_ion_cannon_fired"
script.on_event(remote.call("orbital_ion_cannon", "on_ion_cannon_targeted"), handler)
script.on_event(remote.call("orbital_ion_cannon", "on_ion_cannon_fired"), handler)
-- event data: force, surface, position, radius, player_index (when a player targeted)

-- returns the cannon number, or false when no cannon over that surface is ready
remote.call("orbital_ion_cannon", "target_ion_cannon", force, position, surface, player)

-- per planet: { location, total, ready, next_ready }
remote.call("orbital_ion_cannon", "get_status", force)
```

## Development

The mod lives in `src/`. `./build.sh` packs `dist/OrbitalIonCannon-SE_<version>.zip` for the mod portal.

## License

MIT, see [LICENSE](LICENSE). Asset credits are in [CREDITS.md](CREDITS.md).
