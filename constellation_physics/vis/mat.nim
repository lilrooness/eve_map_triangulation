import opengl

type
    Matrix* =
        tuple[
            data: seq[GLfloat],
            width: int,
            height: int
            ]

proc genMat(width: int, height: int): Matrix =
    result = (data: @[], width: width, height: height)


proc genId4D*(): Matrix =
    var matrix = genMat(4, 4)

    matrix.data = @[
        GLfloat(1.0), 0.0, 0.0, 0.0,
        0.0, 1.0, 0.0, 0.0,
        0.0, 0.0, 1.0, 0.0,
        0.0, 0.0, 0.0, 1.0,
    ]

    return matrix

proc genTranslationMatrix4D*(x: GLfloat, y: GLfloat, z: GLfloat): Matrix =
    var matrix = genMat(4,4)

    matrix.data = @[
        GLfloat(1.0), 0.0, 0.0, x,
        0.0, 1.0, 0.0, y,
        0.0, 0.0, 1.0, z,
        0.0, 0.0, 0.0, 1.0,
    ]

    return matrix

proc genScaleMatrix4D*(x: GLfloat, y: GLfloat, z: GLfloat): Matrix =
    var matrix = genMat(4,4)

    matrix.data = @[
        x, 0.0, 0.0, 0.0,
        0.0, y, 0.0, 0.0,
        0.0, 0.0, z, 0.0,
        0.0, 0.0, 0.0, 1.0,
    ]

    return matrix

proc multiplyMatrices*(a: Matrix, b: Matrix): Matrix =
    if a.width != b.height:
        raise newException(ValueError, "a.width does not equal b.height")

    var mat = genMat(a.height, b.width)

    for row in countup(0, a.height-1):
        var
            arow: seq[GLfloat]
        
        var aRowBase = row * a.width
        for i in 0..a.width-1:
            arow.add(a.data[i + aRowBase])
        
        for col in countup(0, b.width-1):
            var acc: GLfloat = 0.0
            var
                stride = b.width
                startOffset = col

            for i in 0..b.height-1:
                acc += arow[i] * b.data[startOffset + (i * stride)]
            
            mat.data.add(acc)

    return mat

proc genOrthographic*(xstart, xend, ystart, yend, zstart, zend: GLfloat): Matrix =
    var
        translation, scale, flipZMat: Matrix
        ortho: Matrix
        midx, midy, midz: GLfloat
        scalex, scaley, scalez: GLfloat
        
    flipZMat = genMat(4,4)
    flipZMat.data = @[
        GLfloat(1.0), 0.0, 0.0, 0.0,
        0.0, -1.0, 0.0, 0.0,
        0.0, 0.0, -1.0, 0.0,
        0.0, 0.0, 0.0, 1.0,
    ]

    var viewWidth = xend - xstart
    var viewHeight = yend - ystart
    var viewDepth = zend - zstart

    midx = xstart + viewWidth/2
    midy = ystart + viewHeight/2
    midz = zstart + viewDepth/2

    translation = genTranslationMatrix4D(-midx, -midy, -midz)

    scalex = 2.0 / viewWidth
    scaley = 2.0 / viewHeight
    scalez = 2.0 / viewDepth

    scale = genScaleMatrix4D(scalex, scaley, scalez)

    var tmp = multiplyMatrices(flipZMat, scale)

    ortho = multiplyMatrices(tmp, translation)

    return ortho
    

when isMainModule:

    echo "mat.nim tests."
    echo "[1] - Orthographic Projection Test..."
    var ortho = genOrthographic(600.0, 400.0, 400.0)

    var coords = genMat(1, 4)
    coords.data = @[
        GLfloat(600.0),
        300.0,
        400.0,
        1.0
    ]

    var projected = multiplyMatrices(ortho, coords)
    doAssert ortho.width == 4
    doAssert ortho.height == 4
    doAssert projected.data == @[GLfloat(1.0), 0.5, -1.0, 1.0]
    echo "Tests passed"
    


