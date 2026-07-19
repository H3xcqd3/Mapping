# Test plan

Record the build identifier, environment, tester, result, and defect link for every run.

- [x] Client loads the map without errors. Verified with the deployed toolchain test package on 2026-07-19.
- [x] Dedicated server loads the map without errors. FDS logged `Level C&C_OnOeS_Test.mix Loaded OK` on 2026-07-19.
- [ ] GDI players spawn correctly.
- [ ] Nod players spawn correctly.
- [ ] Characters can be purchased.
- [ ] Vehicles can be purchased and exit their factories.
- [ ] Both harvesters complete repeated routes.
- [ ] Buildings take damage and can be destroyed.
- [ ] Base power loss has the expected effect.
- [ ] Terrain, building, prop, projectile, and vehicle collision work.
- [ ] Vehicles do not become stuck on normal routes.
- [ ] Infantry cannot reach unintended areas.
- [ ] Players and vehicles do not fall through terrain.
- [ ] No textures are missing.
- [ ] Server logs contain no map-related errors.
- [x] The map is compatible with Scripts 4.8.4 for the current toolchain smoke test (verified 2026-07-19).
- [ ] The map is compatible with Dragonade 1.11.1.
- [ ] A two-player team-balance smoke test passes.
