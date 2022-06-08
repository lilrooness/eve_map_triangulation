import opengl
import math

type
    Point* = object
        x*, y*, lastX*, lastY*: GLfloat

    GravBody* = object
        x*, y*: GLfloat
        mass: float

    Constraint* = object
        a*, b*: int

    PointRef = ref Constraint

    World = object
        elasticity*: float
        points*: seq[PointRef]
        constraints*: seq[Constraint]
        gravBodies*: seq[GravBody]


proc dist(ax, ay, bx, by: float): float =
    return sqrt(pow(ax - bx, 2) + pow(ay - by, 2))

proc tickWorld*(w: ref World): void =
    for p in w.points:
        var dx = p.x - p.lastX
        var dy = p.y - p.lastY

        var length = sqrt(pow(dx, 2) + pow(dy, 2))

        var ndx = dx / length
        var ndy = dy / length
