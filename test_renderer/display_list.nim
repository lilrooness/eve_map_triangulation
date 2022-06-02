import opengl

const
    VERTEX_DATA_ATTRIB_POINTER: GLuint = 1
    UV_DATA_ATTRIB_POINTER: GLuint = 2
    ROTATION_DATA_ATTRIB_POINTER: GLuint = 3
    PIVOT_DATA_ATTRIB_POINTER: Gluint = 4

type
    DisplayList* = object
        vao*: GLuint
        vertexBuffer*: GLuint
        verteces*: seq[GLfloat]

proc GetDisplayList*(): DisplayList =
    var list: DisplayList

    glGenVertexArrays(1, list.vao.addr)
    glBindVertexArray(list.vao)

    glGenBuffers(1, list.vertexBuffer.addr)
    glBindBuffer(GL_ARRAY_BUFFER, list.vertexBuffer)
    glVertexAttribPointer(VERTEX_DATA_ATTRIB_POINTER, 3, cGL_FLOAT, GL_FALSE, 0, nil)
    glEnableVertexAttribArray(VERTEX_DATA_ATTRIB_POINTER)

    glBindVertexArray(0)

    return list

proc PushBuffers*(list: DisplayList): void =
    if list.verteces.len > 0:
        glBindBuffer(GL_ARRAY_BUFFER, list.vertexBuffer)
        glBufferData(GL_ARRAY_BUFFER, list.verteces.len * sizeof(GLfloat), list.verteces[0].unsafeAddr, GL_STATIC_DRAW)
        glBindBuffer(GL_ARRAY_BUFFER, 0)
    
proc ClearBuffers*(list: var DisplayList): void =
    list.verteces = @[]

# proc AddRect*(list: var DisplayList,  x, y, width, height, pivotx, pivoty, rotation: GLfloat): void =
#     var verts: seq[GLfloat] = @[
#         x, y+height, 1.0,
#         x+width, y, 1.0,
#         x, y, 1.0,

#         x, y+height, 1.0,
#         x+width, y+height, 1.0,
#         x+width, y, 1.0
#     ]
    
#     list.verteces.add(verts)

# proc AddRect*(list: var DisplayList, x, y, width, height: GLfloat, rotation: GLfloat = 0.0): void =
#     list.AddRect(x, y, width, height, x + width/2, height+width/2, rotation)
