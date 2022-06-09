import opengl
import math

type
    Point* = object
        x*, y*, lastX*, lastY*: GLfloat

    PointRef* = ref Point

    GravBody* = object
        x*, y*: GLfloat
        mass: float

    Constraint* = object
        a*, b*: int
        length*: GLfloat

    World* = object
        elasticity*: float
        points*: seq[PointRef]
        constraints*: seq[Constraint]
        gravBodies*: seq[GravBody]
    
    WorldRef* = ref World


# proc dist(ax, ay, bx, by: float): float =
#     return sqrt(pow(ax - bx, 2) + pow(ay - by, 2))

proc tickWorld*(w: ref World): void =
    for p in w.points:
        var dx = p.x - p.lastX
        var dy = p.y - p.lastY

        if p.x < 0 and dx < 0:
            dx *= -1
        elif p.x > 100 and dx > 0:
            dx *= -1
        
        if p.y < 0 and dy < 0:
            dy *= -1
        elif p.y > 100 and dy > 0:
            dy *= -1
        

        p.lastX = p.x
        p.lastY = p.y
        p.x += dx
        p.y += dy
    
    for c in w.constraints:
        var
            a = w.points[c.a]
            b = w.points[c.b]

        var
            dx = a.x - b.x
            dy = a.y - b.y

        var length = sqrt(pow(a.x - b.x, 2) + pow(a.y - b.y, 2))
        var
            nx = dx/length
            ny = dy/length

        if length < c.length:
            var diff = c.length - length
            b.x -= (nx * (diff/2))
            b.y -= (ny * (diff/2))

            a.x += (nx * (diff/2))
            a.y += (ny * (diff/2))
        elif length > c.length:
            var diff = length - c.length
            b.x += (nx * (diff/2))
            b.y += (ny * (diff/2))

            a.x -= (nx * (diff/2))
            a.y -= (ny * (diff/2))
