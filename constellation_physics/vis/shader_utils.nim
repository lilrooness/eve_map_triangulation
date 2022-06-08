import opengl

proc readShaderFile(filename: string): string =  
    var file = open(filename)
    return  readAll(file)

proc getShaderLog(shaderProgramID: GLuint): string = 

    var
        infoLogLength: GLsizei
        buffer: array[2000, char]
    
    glGetShaderInfoLog(shaderProgramID, 2000, infoLogLength.addr, buffer.addr)

    var log = ""
    for c in buffer:
        add(log, $c)
    
    return log

proc createShaderProgram*(fragShaderFilename: string, vertShaderFilename: string): GLuint =
    var 
        programID: GLuint
        vertexShader: GLuint
        fragmentShader: GLuint
        programSuccess: GLint
    
    programID = glCreateProgram()
    vertexShader = glCreateShader(GL_VERTEX_SHADER)
    fragmentShader = glCreateShader(GL_FRAGMENT_SHADER)
    
    var vertex_string = readShaderFile(vertShaderFilename)
    var fragment_string = readShaderFile(fragShaderFilename)

    glShaderSource(vertexShader, 1, allocCStringArray([vertex_string]), nil)
    glCompileShader(vertexShader)

    var vShaderCompiled: GLint = 0
    glGetShaderiv(vertexShader, GL_COMPILE_STATUS, vShaderCompiled.addr)

    if vShaderCompiled != 1:
        echo "problem compiling vertex shader"
        echo getShaderLog(vertexShader)

    glShaderSource(fragmentShader, 1, allocCStringArray([fragment_string]), nil)
    glCompileShader(fragmentShader)
    
    var fShaderCompiled: GLint = 0
    glGetShaderiv(fragmentShader, GL_COMPILE_STATUS, fShaderCompiled.addr)

    if fShaderCompiled != 1:
        echo "problem compiling fragment shader"
        echo getShaderLog(fragmentShader)

    glAttachShader(programID, vertexShader)
    glAttachShader(programID, fragmentShader)
    glLinkProgram(programID)

    programSuccess = 0
    glGetProgramiv(programID, GL_LINK_STATUS, programSuccess.addr)

    if programSuccess != 1:
        echo "there was a problem linking the shader program"

    return programID