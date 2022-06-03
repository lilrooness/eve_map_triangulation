import sdl2
import opengl
import display_list
import shader_utils
import mat
import data_reader

const 
    SCREEN_W = 640*2
    SCREEN_H = 480*2

proc driverDebugCallback(source: GLenum, typ: GLenum, id: GLuint, severity: GLenum, length: GLsizei, message: ptr GLchar, userParam: pointer) {.stdcall.} = 
    var printable: string = ""
    var recvBuff: array[2096, GLchar]

    copyMem(recvBuff.addr, message, length)

    for i in countup(0, length):
        add(printable, $char(recvBuff[i]))

    echo $printable


discard sdl2.init(INIT_EVERYTHING)

var
    window: WindowPtr

window = createWindow("New Voronoi-den", SDL_WINDOWPOS_UNDEFINED, SDL_WINDOWPOS_UNDEFINED, SCREEN_W, SCREEN_H, SDL_WINDOW_OPENGL)

discard window.glCreateContext()

loadExtensions()

var
    primitiveShader: GLuint
    err: GLenum

discard glSetAttribute(SDL_GL_CONTEXT_FLAGS, SDL_GL_CONTEXT_DEBUG_FLAG)
glEnable(GL_DEBUG_OUTPUT)
glDebugMessageCallback(driverDebugCallback, nil)
glDebugMessageControl(GL_DONT_CARE, GL_DONT_CARE, GL_DONT_CARE, 0, nil, GL_TRUE)


primitiveShader = createShaderProgram("shaders/primative/fragment.glsl", "shaders/primative/vertex.glsl")
err = glGetError()
echo err.repr

var dim: GLfloat = 20.129476603142384e+28
# var projectionMatrix = genOrthographic(0, 1000, 0, 1000, -1.0, 1.0);
var projectionMatrix = genOrthographic(0, 1000, 0, 1000, -1.0, 1.0);

glDisable(GL_DEPTH_TEST)
glClearColor(0.0, 0.0, 0.0, 1.0)
glEnable(GL_BLEND);
glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
glClear(GL_COLOR_BUFFER_BIT)

glUseProgram(primitiveShader)

var cellData = readIndices("../output_data/indices")
readPoints("../output_data/points", cellData)
var vertices = readVertices("../output_data/vertices")
var (systemNames, systemRegions) = readSystemNames("../output_data/lonetrek_names")

var linesList = GetDisplayList()
var pointsList = GetDisplayList()

type
    TintColor = (GLfloat, GLfloat, GLfloat)

var color_1: TintColor = (0.0.GLfloat, 1.0.GLfloat, 0.0.GLfloat)
var color_2: TintColor = (1.0.GLfloat, 1.0.GLfloat, 0.0.GLfloat)

# fill vertex buffer with only one region's data
for cell in cellData:
    if cell.indices.len() > 1 and systemNames.find(cell.name) > -1 and cell.indices.find(-1) == -1:
    # if cell.indices.len() > 1 and cell.indices.find(-1) == -1:

        var regionNameIndex = systemNames.find(cell.name)

        var color: TintColor = (1.0.GLfloat, 1.0.GLfloat, 1.0.GLfloat)

        if regionNameIndex > -1:
            var regionName = systemRegions[regionNameIndex]
            if regionName == "Lonetrek":
                color = color_1
            elif regionName == "TheCitadel":
                color = color_2

        pointsList.AddVertex(cell.point.x, cell.point.y, 1.0, 0.0, 1.0, 0.0)

        for i in 0 .. cell.indices.len()-2:
            var ax: float64 = vertices[cell.indices[i]].x
            var ay: float64 = vertices[cell.indices[i]].y

            var bx: float64 = vertices[cell.indices[i+1]].x
            var by: float64 = vertices[cell.indices[i+1]].y

            linesList.AddVertex(ax, ay, 1.0, color[0], color[1], color[2])
            linesList.AddVertex(bx, by, 1.0, color[0], color[1], color[2])


            if i == cell.indices.len()-2:
                linesList.AddVertex(ax, ay, 1.0, color[0], color[1], color[2])
                var firstx: float64 = vertices[cell.indices[0]].x
                var firsty: float64 = vertices[cell.indices[0]].y
                linesList.AddVertex(firstx, firsty, 1.0, color[0], color[1], color[2])


linesList.PushBuffers()
pointsList.PushBuffers()

var uiViewMatrix = genId4D()
glUniformMatrix4fv(GLint(1), GLsizei(1), GL_TRUE, projectionMatrix.data[0].unsafeAddr)
glUniformMatrix4fv(GLint(2), GLsizei(1), GL_TRUE, uiViewMatrix.data[0].unsafeAddr)

glBindVertexArray(linesList.vao)
glDrawArrays(GL_LINES, 0, GLint(linesList.verteces.len()/3))

glBindVertexArray(pointsList.vao)
glDrawArrays(GL_POINTS, 0, GLint(pointsList.verteces.len()/3))

window.glSwapWindow()

var quit = false

while not quit:
    var event: sdl2.Event

    while sdl2.pollEvent(event):
        if event.kind == QuitEvent:
            quit = true
