import opengl
import math

type
    Point* = object
        x*, y*, lastX*, lastY*: GLfloat
        id*: int

    PointRef* = ref Point

    Constraint* = object
        a*, b*: int
        length*: GLfloat

    World* = object
        repulsionDist*: float
        size*: float
        elasticity*: float
        points*: seq[PointRef]
        constraints*: seq[Constraint]
    
    WorldRef* = ref World

proc tickWorld*(w: ref World): void =
    for p in w.points:
        var dx = p.x - p.lastX
        var dy = p.y - p.lastY

        if p.x < 0 and dx < 0:
            dx *= -1
        elif p.x > w.size and dx > 0:
            dx *= -1
        
        if p.y < 0 and dy < 0:
            dy *= -1
        elif p.y > w.size and dy > 0:
            dy *= -1
        

        p.lastX = p.x
        p.lastY = p.y
        p.x += dx
        p.y += dy

    # push points away from eachother
    for p in w.points:

        for o in w.points:
            if o.id == p.id:
                continue

            var dist = sqrt(pow(p.x - o.x, 2) + pow(p.y - o.y, 2))
            var maxDist = w.repulsionDist

            if dist < maxDist:
                var
                    nx = (p.x - o.x)/dist
                    ny = (p.y - o.y)/dist
                
                p.x += (nx * ((maxDist - dist)/maxDist))/2
                p.y += (ny * ((maxDist - dist)/maxDist))/2

                o.x -= (nx * ((maxDist - dist)/maxDist))/2
                o.y -= (ny * ((maxDist - dist)/maxDist))/2

    
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
            b.x -= (nx * (diff/2)) * w.elasticity
            b.y -= (ny * (diff/2)) * w.elasticity

            a.x += (nx * (diff/2)) * w.elasticity
            a.y += (ny * (diff/2)) * w.elasticity
        elif length > c.length:
            var diff = length - c.length
            b.x += (nx * (diff/2)) * w.elasticity
            b.y += (ny * (diff/2)) * w.elasticity

            a.x -= (nx * (diff/2)) * w.elasticity
            a.y -= (ny * (diff/2)) * w.elasticity
