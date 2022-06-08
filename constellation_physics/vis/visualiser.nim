import std/strutils

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

WindowInit(SCREEN_W, SCREEN_H, title=name)

var primitiveShader = createShaderProgram("shaders/primative/fragment.glsl", "shaders/primative/vertex.glsl")

var projectionMatrix = genOrthographic(0, 100, 0, 100, -1.0, 1.0)

glUseProgram(primitiveShader)

var quit = false
while not quit:
    var event: sdl2.Event

    while sdl2.pollEvent(event):
        if event.kind == QuitEvent:
            quit = true

        # window.glSwapWindow()