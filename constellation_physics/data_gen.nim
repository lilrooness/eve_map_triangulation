import std/os
import std/strutils
import std/sequtils

echo "Reading SDE Data ..."


type
    Sol = object
        # x, y, z: float64
        # nx, ny, nz: float64
        name, id, nameId: string
        links: seq[string]

    SolRef = ref Sol

proc readSolarSystem(fullPath: string): SolRef =
    var
        f: File
        line: string

    f = open(fullPath)
    defer: f.close()

    type
        Mode = enum
            TOP_LEVEL, STARGATES_LEVEL


    var mode = TOP_LEVEL

    var 
        sol: SolRef
        systemId: string
        links: seq[string]

    while f.readLine(line):
        if mode == TOP_LEVEL:
            if line.startsWith("stargates"):
                mode = STARGATES_LEVEL
            elif line.startsWith("solarSystemID"):
                systemId = line.split(":")[1].strip()
        elif mode == STARGATES_LEVEL:
            var lineParts = line.split(":")
            if len(lineParts) > 1:
                if lineParts[0].strip() == "destination":
                    var id = lineParts[1].strip()
                    links.add(id)

    sol = SolRef(id: systemId, links: links)
    return sol

proc writeSols(sols: seq[SolRef], filename: string, placeName: string): void =
    let f = open(filename, fmWrite)
    defer: f.close()

    f.writeLine(placeName)

    for sol in sols:
        var line = @[sol.name, sol.id].concat(sol.links)
        f.writeLine(line.join(","))

if paramCount() < 1:
    echo "please provide path to top of map tree"
    system.quit(1)

var treetop = paramStr(1)

var placeName = treetop.split("/")[^1]

var sols: seq[SolRef]

for path in walkDirRec(treetop):
    var parts = path.split('\\')
    var filename = parts[^1]
    var dirName = parts[^2]

    if filename == "solarsystem.staticdata":
        var newSol = readSolarSystem(path)
        newSol.name = dirName
        sols.add(newSol)

writeSols(sols, "constellation_output", placeName)
    