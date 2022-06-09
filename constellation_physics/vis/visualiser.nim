import std/strutils
import std/sequtils

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
        name, id: string
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
        sol = Sol(name: name, id: id, links: links)
        sols.add(sol)

    return (header, sols)


var (name, sols) = ReadData("../constellation_output")

var world: verlet.WorldRef = WorldRef(
    elasticity: 0.1,
    points: @[],
    constraints: @[],
    gravBodies: @[]
)

var counter = 0.0

var ids: seq[string]

# generate points
for sol in sols:
    world.points.add(PointRef(x: counter, y: counter, lastX: counter+0.1, lastY: counter-0.1))
    ids.add(sol.id)
    counter += 5.0

# generate constraints using sol links
var i = 0
for sol in sols:
    echo  sol
    for link in sol.links:
        let linkedIdx = ids.find(link)
        # echo "Link:", link.repr
        # echo sol.id.repr
        if linkedIdx != -1:
            echo "adding  constraint"
            world.constraints.add(Constraint(a: i, b: linkedIdx, length: 4))
    i += 1

var win = WindowInit(SCREEN_W, SCREEN_H, title=name, debug=false)

var primitiveShader = createShaderProgram("shaders/primative/fragment.glsl", "shaders/primative/vertex.glsl")

var projectionMatrix = genOrthographic(0, 100, 0, 100, -1.0, 1.0)

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
    for p in world.points:
        list.AddVertex(p.x.GLfloat, p.y.GLfloat, 1.0.GLfloat, 1.0.GLfloat, 1.0.GLfloat, 1.0.GLfloat)
    list.PushBuffers()

    linesList.ClearBuffers()
    for c in world.constraints:
        var
            a = world.points[c.a]
            b = world.points[c.b]
        linesList.AddVertex(a.x, a.y, 1.0, 1.0, 1.0, 1.0)
        linesList.AddVertex(b.x, b.y, 1.0, 1.0, 1.0, 1.0)
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
    verlet.tickWorld(world)
