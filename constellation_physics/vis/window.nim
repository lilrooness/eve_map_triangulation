import sdl2
import opengl

proc driverDebugCallback(source: GLenum, typ: GLenum, id: GLuint, severity: GLenum, length: GLsizei, message: ptr GLchar, userParam: pointer) {.stdcall.} = 
    var printable: string = ""
    var recvBuff: array[2096, GLchar]

    copyMem(recvBuff.addr, message, length)

    for i in countup(0, length):
        add(printable, $char(recvBuff[i]))

    echo $printable


proc WindowInit*(screenw, screenh: int, title: string = "Default Title", debug: bool = true): void =
    discard sdl2.init(INIT_EVERYTHING)

    var
        window: WindowPtr

    window = createWindow(title, SDL_WINDOWPOS_UNDEFINED, SDL_WINDOWPOS_UNDEFINED, screenw.cint, screenh.cint, SDL_WINDOW_OPENGL)

    discard window.glCreateContext()

    loadExtensions()

    if debug:
        discard glSetAttribute(SDL_GL_CONTEXT_FLAGS, SDL_GL_CONTEXT_DEBUG_FLAG)
        glEnable(GL_DEBUG_OUTPUT)
        glDebugMessageCallback(driverDebugCallback, nil)
        glDebugMessageControl(GL_DONT_CARE, GL_DONT_CARE, GL_DONT_CARE, 0, nil, GL_TRUE)

    glDisable(GL_DEPTH_TEST)
    glClearColor(0.0, 0.0, 0.0, 1.0)
    glEnable(GL_BLEND);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    glClear(GL_COLOR_BUFFER_BIT)

