import os
import std/strutils

type
    Point* = tuple
        x, y: float64
    Cell* = object
        name*: string
        indices*: seq[int]
        point*: Point

    CellRef* = ref Cell

proc readSystemNames*(filename: string): seq[string] =
    var
        f: File
        line: string
        names: seq[string]

    f = open(filename)
    defer: f.close()

    while f.readLine(line):
        if line.len() > 1:
            names.add(line)

    return names

proc readVertices*(filename: string): seq[Point] =
    var
        f: File
        line: string
        verts: seq[Point]

    f = open(filename)
    defer: f.close()

    while f.readLine(line):
        var parts = line.split(",")
        if parts.len() > 1:
            var x, y: float64
            x = parseFloat(parts[0])
            y = parseFloat(parts[1])
            verts.add((x: x, y: y))

    return verts


proc readIndices*(filename: string): seq[CellRef] =
    var
        f: File
        line: string
        cells: seq[CellRef]

    f = open(filename)
    defer: f.close()

    while f.readLine(line):
        var parts = line.split(" ")
        var cell = CellRef()
        var string_indices = parts[1].split(",")
        
        if string_indices.len() > 1:
            cell.name = parts[0]
            for string_index in string_indices:
                cell.indices.add(string_index.parseInt())

        cells.add(cell)

    return cells


proc readPoints*(filename: string, cellData: var seq[CellRef]): void =
    var
        f: File
        line: string

    f = open(filename)
    defer: f.close()

    var lineNumber = 0
    while f.readLine(line):

        var parts = line.split(",")

        if parts.len() == 1:
            continue
        
        var x, y: float64

        x = parts[0].parseFloat()
        y = parts[1].parseFloat()

        cellData[lineNumber].point = (x: x, y: y)

        lineNumber += 1
