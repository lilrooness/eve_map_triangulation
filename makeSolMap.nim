import std/os
import std/strutils
import std/sequtils
import std/math

type
    Sol = object
        x, y, z: float64
        nx, ny, nz: float64
        name, id, nameId: string

    SolRef = ref Sol

proc readSolarSystem(fullPath: string): SolRef =
    var
        f: File
        line: string

    f = open(fullPath)
    defer: f.close()

    while f.readLine(line):
        if line == "center:":
            var
                sol: SolRef
                x, y, z: float64
                xLine, yLine, zLine: string

            discard f.readLine(xLine)
            discard f.readLine(yLine)
            discard f.readLine(zLine)

            x = parseFloat(xLine.split(" ")[1])
            y = parseFloat(yLine.split(" ")[1])
            z = parseFloat(zLine.split(" ")[1])

            sol = SolRef(x: x, y: y, z: z)
            return sol

proc getMinMaxCoords(sols: seq[SolRef], maxX, maxY, maxZ, minX, minY, minZ: var float64): void =
    
    var
        xs, ys, zs: seq[float64]
        maxXIndex, maxYIndex, maxZIndex: int
        minXIndex, minYIndex, minZIndex: int

    for sol in sols:
        xs.add(sol.x)
        ys.add(sol.y)
        zs.add(sol.z)

    maxXIndex = xs.maxIndex()
    maxYIndex = ys.maxIndex()
    maxZIndex = zs.maxIndex()

    minXIndex = xs.minIndex()
    minYIndex = ys.minIndex()
    minZIndex = zs.minIndex()

    maxX = xs[maxXIndex]
    maxY = ys[maxYIndex]
    maxZ = zs[maxZIndex]

    minX = xs[minXIndex]
    minY = ys[minYIndex]
    minZ = zs[minZIndex]

proc writeSols(sols: seq[SolRef], filename: string, placeName: string): void =
    let filename = "normalisedmap"
    let f = open(filename, fmWrite)
    defer: f.close()

    f.writeLine(placeName)

    for sol in sols:
        var line = $sol.name & " " & $sol.nx & " " & $sol.ny & " " & $sol.nz
        f.writeLine(line)


var sols: seq[SolRef]

echo "Reading SDE Data ..."

if paramCount() < 1:
    echo "please provide path to top of map tree"
    system.quit(1)

var treetop = paramStr(1)

var placeName = treetop.split("/")[^1]

for path in walkDirRec(treetop):
    var parts = path.split('\\')
    var filename = parts[^1]
    var dirName = parts[^2]

    # echo dirName, " : ",  filename
    if filename == "solarsystem.staticdata":
        var newSol = readSolarSystem(path)
        newSol.name = dirName
        sols.add(newSol)

var
    maxX, maxY, maxZ: float64
    minX, minY, minZ: float64

echo "Calculating min/max data .."
getMinMaxCoords(sols, maxX, maxY, maxZ, minX, minY, minZ)

var nmax: float64 = 1000
echo "Calculating normalised sol positions between 0 and ", $nmax, " ..."

var
    xshift, yshift, zshift: float64 = 0
    xdist: float64 = maxX - minX
    ydist: float64 = maxY - minY
    zdist: float64 = maxZ - minZ

if minX < 0:
    xshift = minX * -1

if minY < 0:
    yshift = minY * -1

if minZ < 0:
    zshift = minZ * -1

# var scale = pow(10, 11.7)
for sol in sols:

    # sol.nx = sol.x * scale
    # sol.ny = sol.y * scale
    # sol.nz = sol.z * scale
    sol.nx = ((sol.x + xshift) / xdist) * nmax
    sol.ny = ((sol.y + yshift) / ydist) * nmax
    sol.nz = ((sol.z + zshift) / zdist) * nmax


echo "Saving normalised sol data ..."
writeSols(sols, "normalisedmap", placeName)


# echo "max x: ", $maxX, " y: ", $maxY, " z: ", maxZ
# echo "min x: ", $minX, " y: ", $minY, " z: ", minZ

# echo "xrange: ", $(xdist * nmax)
# echo "yrange: ", $(ydist * nmax)
# echo "zrange: ", $(zdist * nmax)
