-- Builds the approved v0.2 Three-Lane Valley as one low-poly terrain mesh.
-- Run this while ONO_TestBox.gmax is open. The script replaces its geometry
-- with the approved valley blockout and saves the result to a new file.

outputPath = "E:\\Mapping\\C&C_OnOeS_Test\\source\\renx\\ONO_ValleyB.gmax"

fn appendQuadFaces faceArray baseIndex =
(
    append faceArray [baseIndex + 0, baseIndex + 2, baseIndex + 1]
    append faceArray [baseIndex + 0, baseIndex + 3, baseIndex + 2]
    append faceArray [baseIndex + 4, baseIndex + 5, baseIndex + 6]
    append faceArray [baseIndex + 4, baseIndex + 6, baseIndex + 7]
    append faceArray [baseIndex + 0, baseIndex + 1, baseIndex + 5]
    append faceArray [baseIndex + 0, baseIndex + 5, baseIndex + 4]
    append faceArray [baseIndex + 1, baseIndex + 2, baseIndex + 6]
    append faceArray [baseIndex + 1, baseIndex + 6, baseIndex + 5]
    append faceArray [baseIndex + 2, baseIndex + 3, baseIndex + 7]
    append faceArray [baseIndex + 2, baseIndex + 7, baseIndex + 6]
    append faceArray [baseIndex + 3, baseIndex + 0, baseIndex + 4]
    append faceArray [baseIndex + 3, baseIndex + 4, baseIndex + 7]
)

fn appendBox vertexArray faceArray x0 x1 y0 y1 z0 z1 =
(
    local baseIndex = vertexArray.count + 1
    append vertexArray [x0, y0, z0]
    append vertexArray [x1, y0, z0]
    append vertexArray [x1, y1, z0]
    append vertexArray [x0, y1, z0]
    append vertexArray [x0, y0, z1]
    append vertexArray [x1, y0, z1]
    append vertexArray [x1, y1, z1]
    append vertexArray [x0, y1, z1]
    appendQuadFaces faceArray baseIndex
)

fn appendRampX vertexArray faceArray x0 x1 y0 y1 bottomZ leftTopZ rightTopZ =
(
    local baseIndex = vertexArray.count + 1
    append vertexArray [x0, y0, bottomZ]
    append vertexArray [x1, y0, bottomZ]
    append vertexArray [x1, y1, bottomZ]
    append vertexArray [x0, y1, bottomZ]
    append vertexArray [x0, y0, leftTopZ]
    append vertexArray [x1, y0, rightTopZ]
    append vertexArray [x1, y1, rightTopZ]
    append vertexArray [x0, y1, leftTopZ]
    appendQuadFaces faceArray baseIndex
)

fn buildValleyBlockout =
(
    try
    (
        local vertices = #()
        local faces = #()

    -- Main ground slab.
    appendBox vertices faces -150 150 -110 110 -2 0

    -- West and east base pads.
    appendBox vertices faces -148 -92 -40 40 0 1
    appendBox vertices faces 92 148 -40 40 0 1

    -- Nonfunctional building-scale proxies. Two masses per base provide
    -- recognizable height and footprint references while leaving Y -7..8
    -- clear for temporary team spawns and movement into the central lane.
    -- West/GDI base: taller north utility and lower south infantry structure.
    appendBox vertices faces -142 -118 10 34 1 11
    appendBox vertices faces -144 -116 8 36 11 13
    appendBox vertices faces -142 -112 -34 -10 1 8
    appendBox vertices faces -145 -109 -37 -7 8 9.5

    -- East/Nod base: mirrored scale proxies.
    appendBox vertices faces 118 142 10 34 1 11
    appendBox vertices faces 116 144 8 36 11 13
    appendBox vertices faces 112 142 -34 -10 1 8
    appendBox vertices faces 109 145 -37 -7 8 9.5

    -- Central contested platform and accessible ramps.
    appendBox vertices faces -35 35 -25 25 0 3
    appendRampX vertices faces -60 -35 -25 25 0 0 3
    appendRampX vertices faces 35 60 -25 25 0 3 0

    -- Low segmented banks separate central and vehicle lanes while leaving crossings.
    appendBox vertices faces -90 -25 36 44 0 1.2
    appendBox vertices faces 25 90 36 44 0 1.2
    appendBox vertices faces -90 -25 -44 -36 0 1.2
    appendBox vertices faces 25 90 -44 -36 0 1.2

    -- Temporary perimeter boundaries.
    appendBox vertices faces -152 -150 -112 112 0 5
    appendBox vertices faces 150 152 -112 112 0 5
    appendBox vertices faces -150 150 -112 -110 0 5
    appendBox vertices faces -150 150 110 112 0 5

        local geometryNodes = for node in objects where superclassof node == GeometryClass collect node
        for node in geometryNodes do delete node

        -- Construct the scene node from the arrays. A node's .mesh property is
        -- only a copy in this GMax/MAXScript version, so setMesh on terrain.mesh
        -- does not change the geometry that the W3D exporter sees.
        local terrain = mesh vertices:vertices faces:faces
        terrain.name = "ONO_ValleyB"
        terrain.transform = matrix3 1
        update terrain
        terrain.wirecolor = color 150 165 125
        select terrain

        saveMaxFile outputPath

        messageBox ("ONO_ValleyB.gmax created with " + (vertices.count as string) + " vertices and " + (faces.count as string) + " faces.\nSet W3D Object Export Name to ONO_ValleyB. Enable Physical, Projectile and Camera collision, then export as Renegade Terrain.") title:"OnOeS blockout complete"
    )
    catch
    (
        messageBox ("Blockout build failed:\n" + (getCurrentException())) title:"OnOeS blockout error"
    )
)

buildValleyBlockout()
