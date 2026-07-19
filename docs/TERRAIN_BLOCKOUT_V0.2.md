# v0.2 Three-Lane Valley blockout

Status: completed scale-study milestone

## Dimensions and orientation

- Overall playable footprint: 300 by 220 W3D units.
- Base orientation: GDI west, Nod east.
- World origin: centre of the contested middle lane.
- Base-pad centres: approximately X -120 and X 120.

## Route structure

- North vehicle lane centred near Y 70.
- Central infantry/contested lane centred near Y 0.
- South vehicle lane centred near Y -70.
- Low segmented banks separate the lanes without permanently isolating them.
- A shallow central platform and two ramps test elevation and collision.

## Blockout constraints

- Geometry remains modular, untextured, and low-poly.
- Temporary perimeter walls define the test boundary.
- No production art, buildings, harvesters, or balance-sensitive placements are included yet.
- Spawns and later gameplay objects are added only for controlled traversal tests.

## Exit checks

- [x] Terrain exports through RenX without identifier truncation.
- [x] W3D Viewer recognizes the mesh and hierarchy.
- [x] LevelEdit imports the terrain and shows its geometry.
- [x] GDI and Nod startup spawners place players safely on their respective base pads.
- [x] Infantry can traverse all three lanes without falling through the terrain.
- [x] The client and Dragonade FDS load the resulting MIX.

## Scale-study result

- Four nonfunctional building-scale proxies were added, two per base, with heights of 9.5 and 13 W3D units.
- Live screenshots and traversal confirmed that the 300 by 220 footprint works technically but will be compact after real buildings, vehicle factories, defensive clearances, and harvester routes are added.
- The designer approved expansion rather than reduction.
- The designer approved a v0.3 target footprint of 450 by 320 W3D units, with room for four or five buildings per team, vehicle production, defensive clearances, and harvester circulation.
- The expanded footprint remains subject to another live scale and travel-time test before production terrain work.
