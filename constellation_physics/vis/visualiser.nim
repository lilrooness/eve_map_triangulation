import std/strutils
import std/tables

import sdl2
import opengl
import display_list
import shader_utils
import mat
import window
import verlet

const 
    SCREEN_W: int = 640*2
    SCREEN_H: int = 480*2

type
    Sol = object
        region, name, id: string
        links: seq[string]

proc ReadData(filename: string): (string, seq[Sol]) =
    var 
        file = open(filename)
        line: string
        readHeader = false
        header: string
        sols: seq[Sol]

    defer: file.close()

    while file.readLine(line):
        if not readHeader:
            header = line
            readHeader = true
            continue

        var
            sol: Sol
            name, id: string
            links: seq[string]
            parts = line.split(",")

        name = parts[0]
        id = parts[1]
        links = parts[2..^1]
        var regionNameAndName = name.split(":")
        sol = Sol(region: regionNameAndName[0], name: regionNameAndName[1], id: id, links: links)
        sols.add(sol)

    return (header, sols)


var (name, sols) = ReadData("../constellation_output")

var worlds = new(OrderedTable[string, WorldRef])
var constellationIds = new(OrderedTable[string, seq[string]])


var worldSize = 100.0
var constraintLen = 10.0

# generate points
var id = 0
for sol in sols:
    if not (sol.region in worlds):
        worlds[sol.region] = WorldRef(
            repulsionDist: 50,
            size: worldSize,
            elasticity: 1,
            points: @[],
            constraints: @[]
        )
        constellationIds[sol.region] = @[]
    
    var counter = worlds[sol.region].points.len.float64
    worlds[sol.region].points.add(PointRef(id: id, x: counter, y: counter, lastX: counter+0.1, lastY: counter-0.1))
    constellationIds[sol.region].add(sol.id)
    id += 1

# generate constraints using sol links
for sol in sols:
    for link in sol.links:
        let linkedIdx = constellationIds[sol.region].find(link)
        let thisId = constellationIds[sol.region].find(sol.id)
        if linkedIdx != -1:
            worlds[sol.region].constraints.add(Constraint(a: thisId, b: linkedIdx, length: constraintLen))

var win = WindowInit(SCREEN_W, SCREEN_H, title=name, debug=false)

var primitiveShader = createShaderProgram("shaders/primative/fragment.glsl", "shaders/primative/vertex.glsl")

var projectionMatrix = genOrthographic(0, 1000, 0, 1000, -1.0, 1.0)

var uiViewMatrix = genId4D()

glPointSize(4)
glUseProgram(primitiveShader)
glUniformMatrix4fv(GLint(1), GLsizei(1), GL_TRUE, projectionMatrix.data[0].unsafeAddr)
glUniformMatrix4fv(GLint(2), GLsizei(1), GL_TRUE, uiViewMatrix.data[0].unsafeAddr)

var list = GetDisplayList()
var linesList = GetDisplayList()

# frame rate control
var
    now, interval, lastTick: uint32

lastTick = 0
# set the framerate at 60 frames a second (this is the tick rate too for now)
interval = uint32(1000/60)

var quit = false
while not quit:

    list.ClearBuffers()
    linesList.ClearBuffers()

    # add gridlines
    for i in 1 ..< 10:
        # verticle line
        linesList.AddVertex(i.GLfloat * 100, 0, 1.0, 1.0.GLfloat, 1.0.GLfloat, 1.0.GLfloat)
        linesList.AddVertex(i.GLfloat * 100, 1000, 1.0, 1.0.GLfloat, 1.0.GLfloat, 1.0.GLfloat)

        # horizontal line
        linesList.AddVertex(0, i.GLfloat * 100, 1.0, 1.0.GLfloat, 1.0.GLfloat, 1.0.GLfloat)
        linesList.AddVertex(1000, i.GLfloat * 100, 1.0, 1.0.GLfloat, 1.0.GLfloat, 1.0.GLfloat)

    var regionNum = 0
    for region in worlds.keys:
        var
            xmod, ymod: float64
        
        xmod = ((regionNum mod 10).float64 * worldSize)
        ymod = worldSize * (int(regionNum/10)).float64
        for p in worlds[region].points:
            list.AddVertex(p.x.GLfloat + xmod, p.y.GLfloat + ymod, 1.0.GLfloat, 1.0.GLfloat, 1.0.GLfloat, 1.0.GLfloat)

        for c in worlds[region].constraints:
            var
                a = worlds[region].points[c.a]
                b = worlds[region].points[c.b]
            linesList.AddVertex(a.x + xmod, a.y + ymod, 1.0, 1.0, 1.0, 1.0)
            linesList.AddVertex(b.x + xmod, b.y + ymod, 1.0, 1.0, 1.0, 1.0)
        
        regionNum += 1
    list.PushBuffers()
    linesList.PushBuffers()

    glClear(GL_COLOR_BUFFER_BIT)
    glBindVertexArray(list.vao)
    glDrawArrays(GL_POINTS, 0, GLint(list.verteces.len()/3))

    glBindVertexArray(linesList.vao)
    glDrawArrays(GL_LINES, 0, GLint(linesList.verteces.len()/3))

    var event: sdl2.Event
    while sdl2.pollEvent(event):
        if event.kind == QuitEvent:
            quit = true


    win.glSwapWindow()

    now = sdl2.getTicks()
    if now - lastTick < interval:
        continue

    lastTick = now
    for region in worlds.keys:
        verlet.tickWorld(worlds[region])
