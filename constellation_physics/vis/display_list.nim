import opengl

const
    VERTEX_DATA_ATTRIB_POINTER: GLuint = 1
    TINTS_DATA_ATTRIB_POINTER: GLuint = 2
    # UV_DATA_ATTRIB_POINTER: GLuint = 2
    # ROTATION_DATA_ATTRIB_POINTER: GLuint = 3
    # PIVOT_DATA_ATTRIB_POINTER: Gluint = 4

type
    DisplayList* = object
        vao*: GLuint
        vertexBuffer*: GLuint
        tintBuffer*: GLuint
        verteces*: seq[GLfloat]
        tints*: seq[GLfloat]

proc GetDisplayList*(): DisplayList =
    var list: DisplayList

    glGenVertexArrays(1, list.vao.addr)
    glBindVertexArray(list.vao)

    glGenBuffers(1, list.vertexBuffer.addr)
    glBindBuffer(GL_ARRAY_BUFFER, list.vertexBuffer)
    glVertexAttribPointer(VERTEX_DATA_ATTRIB_POINTER, 3, cGL_FLOAT, GL_FALSE, 0, nil)
    glEnableVertexAttribArray(VERTEX_DATA_ATTRIB_POINTER)

    glGenBuffers(1, list.tintBuffer.addr)
    glBindBuffer(GL_ARRAY_BUFFER, list.tintBuffer)
    glVertexAttribPointer(TINTS_DATA_ATTRIB_POINTER, 3, cGL_FLOAT, GL_FALSE, 0, nil)
    glEnableVertexAttribArray(TINTS_DATA_ATTRIB_POINTER)

    glBindVertexArray(0)

    return list

proc PushBuffers*(list: DisplayList): void =
    if list.verteces.len > 0:
        glBindBuffer(GL_ARRAY_BUFFER, list.vertexBuffer)
        glBufferData(GL_ARRAY_BUFFER, list.verteces.len * sizeof(GLfloat), list.verteces[0].unsafeAddr, GL_STATIC_DRAW)
        glBindBuffer(GL_ARRAY_BUFFER, 0)

    if list.tints.len > 0:
        glBindBuffer(GL_ARRAY_BUFFER, list.tintBuffer)
        glBufferData(GL_ARRAY_BUFFER, list.tints.len * sizeof(GLfloat), list.tints[0].unsafeAddr, GL_STATIC_DRAW)
        glBindBuffer(GL_ARRAY_BUFFER, 0)
    
proc ClearBuffers*(list: var DisplayList): void =
    list.verteces = @[]
    list.tints = @[]

proc AddVertex*(list: var DisplayList, x, y, z, r, g, b: GLfloat): void =
    list.verteces.add(x)
    list.verteces.add(y)
    list.verteces.add(z)

    list.tints.add(r)
    list.tints.add(g)
    list.tints.add(b)
