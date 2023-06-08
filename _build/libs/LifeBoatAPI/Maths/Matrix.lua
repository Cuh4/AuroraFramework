---@section Matrix

---@class TempToBeMovedIntoAddonDocs
---@field [1] number leftAxis x
---@field [2] number leftAxis y
---@field [3] number leftAxis z
---@field [4] number 
---@field [5] number upAxis x
---@field [6] number upAxis y
---@field [7] number upAxis z
---@field [8] number 
---@field [9] number  forwardAxis x
---@field [10] number forwardAxis y
---@field [11] number forwardAxis z
---@field [12] number 
---@field [13] number x
---@field [14] number y
---@field [15] number z 
---@field [16] number 

---@alias LifeBoatAPI.Matrix SWMatrix

LifeBoatAPI.Matrix = {

    ---Creates a new simple 4x4 matrix, compatible with Stormworks functions
    ---Holds a translation (posXYZ) and an orientation (yaw,pitch,roll)
    ---@param posX number|nil x-position/translation component
    ---@param posY number|nil y-position/translation component
    ---@param posZ number|nil z-position/translation component
    ---@param yaw number|nil yaw angle (y-axis rotation) in radians
    ---@param pitch number|nil pitch angle (x-axis rotation) in radians
    ---@param roll number|nil roll angle (z-axis rotation) in radians
    ---@return LifeBoatAPI.Matrix
    newMatrix = function(cls, posX, posY, posZ, yaw, pitch, roll)
        yaw     = yaw or 0
        pitch   = pitch or 0
        roll    = roll or 0

        -- matrix calculated in the order roll, pitch, yaw
        -- don't construct the expensive one if it's not needed
        if yaw ~= 0 or pitch ~= 0 or roll ~= 0 then
            -- Y - yaw, P - pitch, R - roll, in most diagrams that would be A-yaw, B-pitch, Y-roll
            local sinRoll = roll ~= 0 and math.sin(roll) or 0
            local cosRoll = roll ~= 0 and math.cos(roll) or 1

            local sinYaw = yaw ~= 0 and math.sin(yaw) or 0
            local cosYaw = yaw ~= 0 and math.cos(yaw) or 1

            local sinPitch = pitch ~= 0 and math.sin(pitch) or 0
            local cosPitch = pitch ~= 0 and math.cos(pitch) or 1

            return {
                -- first 16 numerical values match what gets sent to the game
                cosRoll*cosYaw,     cosRoll*sinYaw*sinPitch - sinRoll*cosPitch, cosRoll*sinYaw*cosPitch + sinRoll*sinPitch,     0,
                sinRoll*cosYaw,     sinRoll*sinYaw*sinPitch + cosRoll*cosPitch, sinRoll*sinYaw*cosPitch - cosRoll*sinPitch,     0,
                -sinYaw,            cosYaw*sinPitch,                            cosYaw*cosPitch,                                0,
                posX or 0,          posY or 0,                                  posZ or 0,                                      1,
            }
        else
            return {
                1,0,0,0,
                0,1,0,0,
                0,0,1,0,
                posX or 0, posY or 0, posZ or 0, 1,
            }
        end
    end;

    -- faces the given XYZ position, altering yaw and pitch
    ---@param position LifeBoatAPI.Matrix|LifeBoatAPI.Vector position to be at
    ---@param positionToFace LifeBoatAPI.Matrix|LifeBoatAPI.Vector position to face
    ---@return LifeBoatAPI.Matrix
    newFacingMatrix = function(cls, position, positionToFace)
        --[[
            taylor series expansion: https://www.researchgate.net/publication/265755808_Direction_Cosine_Matrix_IMU_Theory
            fast normalization, if expected to be near 1 already
            local factor = 0.5 * (3 - (x*x+y*y+z*z))
            x,y,z = factor*x, factor*y, factor*z
        ]]

        local Mx,My,Mz = position[13],position[14],position[15]
        if position[16] then
            Mx,My,Mz = position[13],position[15],position[15]
        else
            Mx,My,Mz = position[1],position[2],position[3]
        end

        local x,y,z;
        if positionToFace[16] then
            x,y,z = positionToFace[13],positionToFace[15],positionToFace[15]
        else
            x,y,z = positionToFace[1],positionToFace[2],positionToFace[3]
        end
    
        -- calculate forward facing
        local Zx,Zy,Zz = x-Mx, y-My, z-Mz

        -- set forward(z) vector (normalized)               
        local Zlen = (Zx*Zx)+(Zy*Zy)+(Zz*Zz)
        if Zlen == 0 then
            Zx,Zy,Zz = 0,0,1
            Zlen = 1
        else
            Zlen = 1/(Zlen^0.5)
            Zx,Zy,Zz = Zx * Zlen, Zy *Zlen, Zz * Zlen
        end
    
        -- cross y (0,1,0) with z to get x
        local Xx, Xy, Xz = Zz, 0, -Zx
    
        -- set x(left) vector (normalized)
        -- normalize x
        local Xfactor = 0.5 * (3 - (Xx*Xx+Xy*Xy+Xz*Xz))
        Xx,Xy,Xz = Xfactor*Xx, Xfactor*Xy, Xfactor*Xz
    
        -- cross z with x to get y
        local Yx,Yy,Yz;
        Yx, Yy, Yz = Zy*Xz - Zz*Xy,
                     Zz*Xx - Zx*Xz,
                     Zx*Xy - Zy*Xx
    
        -- set y(up) vector (normalized)
        -- normalize y
        local Yfactor = 0.5 * (3 - (Yx*Yx+Yy*Yy+Yz*Yz))
        Yx,Yy,Yz = Yfactor*Yx, Yfactor*Yy, Yfactor*Yz
    
        return {
            Xx,Xy,Xz,0,
            Yx,Yy,Yz,0,
            Zx,Zy,Zz,0,
            Mx,My,Mz,1
        }
    end;

    ---Clones given matrix
    ---@param m LifeBoatAPI.Matrix any array with 16 numerical entries as a matrix
    ---@return LifeBoatAPI.Matrix
    clone = function(m)
        return {
            m[1],m[2],m[3],m[4],m[5],m[6],m[7],m[8],m[9],m[10],m[11],m[12],m[13],m[14],m[15],m[16]
        }
    end;

    ---Clones given matrix, at a given offset
    ---Useful for quickly positioning multiple items based on a central position
    ---@param m LifeBoatAPI.Matrix any array with 16 numerical entries as a matrix
    ---@param x number xOffset
    ---@param y number yOffset
    ---@param z number zOffset
    ---@return LifeBoatAPI.Matrix
    cloneOffset = function(m, x,y,z)
        return {
            m[1],m[2],m[3],m[4],m[5],m[6],m[7],m[8],m[9],m[10],m[11],m[12],
            m[13]+x,m[14]+y,m[15]+z,
            m[16]
        }
    end;

    --- Check if two matrices have identical array components
    ---@param a LifeBoatAPI.Matrix
    ---@param b LifeBoatAPI.Matrix
    ---@return boolean equal true if the matrices are numerical identical
    equals = function(a, b)
        -- horrid code, performs 20% better than a loop
        return a[1] == b[1]
           and a[2] == b[2]
           and a[3] == b[3]
           and a[4] == b[4]
           and a[5] == b[5]
           and a[6] == b[6]
           and a[7] == b[7]
           and a[8] == b[8]
           and a[9] == b[9]
           and a[10] == b[10]
           and a[11] == b[11]
           and a[12] == b[12]
           and a[13] == b[13]
           and a[14] == b[14]
           and a[15] == b[15]
           and a[16] == b[16]
    end;

    ---If you're using this, it's recommended to copy the code in-line, and avoid the cost of a function call
    ---@param m LifeBoatAPI.Matrix
    ---@return LifeBoatAPI.Vector left direction vector representing the "left" axis (w = 0)
    left = function(m)
        return {m[1], m[2], m[3],0}
    end;

    ---If you're using this, it's recommended to copy the code in-line, and avoid the cost of a function call
    ---@param m LifeBoatAPI.Matrix
    ---@return LifeBoatAPI.Vector up direction vector representing the "up" axis (w = 0)
    up = function(m)
        return {m[5], m[6], m[7],0}
    end;

    ---If you're using this, it's recommended to copy the code in-line, and avoid the cost of a function call
    ---@param m LifeBoatAPI.Matrix
    ---@return LifeBoatAPI.Vector forward direction vector representing the "forward" axis (w = 0)
    forward = function(m)
        return {m[8], m[9], m[10],0}
    end;

    ---If you're using this, it's recommended to copy the code in-line, and avoid the cost of a function call
    ---@param m LifeBoatAPI.Matrix
    ---@return LifeBoatAPI.Vector position current position this matrix represents (w=1)
    position = function(m)
        return {m[13],m[14],m[15]}
    end;

    ---(Modified in place)
    ---sets the position of "m" to the position given by either a simple matrix or vector
    ---@param a LifeBoatAPI.Matrix matrix to set translation component of
    ---@param b LifeBoatAPI.Vector|LifeBoatAPI.Matrix vector or matrix position to copy
    ---@return LifeBoatAPI.Matrix
    matchPosition = function(a, b)
        if b[16] then
            a[13] = b[13]
            a[14] = b[14]
            a[15] = b[15]
        else
            a[13] = b[1]
            a[14] = b[2]
            a[15] = b[3]
        end
        return a
    end;

    ---(Modified in place)
    ---copies the rotation component of one "simple" matrix to another
    ---@param a LifeBoatAPI.Matrix matrix to copy into
    ---@param b LifeBoatAPI.Matrix matrix whose "rotation component" should be taken
    ---@return LifeBoatAPI.Matrix
    matchRotation = function(a, b)
        a[1] = b[1]
        a[2] = b[2]
        a[3] = b[3]
        a[5] = b[5]
        a[6] = b[6]
        a[7] = b[7]
        a[9] = b[9]
        a[10] = b[10]
        a[11] = b[11]
        return a
    end;

    ---Fast multiply function for simple rotation-translation matrices
    ---Order of operation is, "apply A's transform" then "apply B's transform second"
    -- For example, A: "Move forward 10m", B:"Rotate 90* clockwise" => "you're now 10m to the RIGHT of where you started"
    ---@param a LifeBoatAPI.Matrix
    ---@param b LifeBoatAPI.Matrix
    ---@return LifeBoatAPI.Matrix
    multiplyMatrix = function(a, b)

        local a1,a2,a3,a5,a6,a7,a9,a10,a11,a13,a14,a15 = a[1],a[2],a[3],a[5],a[6],a[7],a[9],a[10],a[11],a[13],a[14],a[15]
        local b1,b2,b3,b5,b6,b7,b9,b10,b11,b13,b14,b15 = b[1],b[2],b[3],b[5],b[6],b[7],b[9],b[10],b[11],b[13],b[14],b[15]

        -- multiply columns of a, against rows of b
        -- (meaning A transform happens and then B on top)
        return {
            (a1 * b1) + (a2 * b5) + (a3 * b9),
            (a1 * b2) + (a2 * b6) + (a3 * b10),
            (a1 * b3) + (a2 * b7) + (a3 * b11),
            0,
            
            (a5 * b1) + (a6 * b5) + (a7 * b9),
            (a5 * b2) + (a6 * b6) + (a7 * b10),
            (a5 * b3) + (a6 * b7) + (a7 * b11),
            0,
            
            (a9 * b1) + (a10 * b5) + (a11 * b9),
            (a9 * b2) + (a10 * b6) + (a11 * b10),
            (a9 * b3) + (a10 * b7) + (a11 * b11),
            0,
            
            (a13 * b1) + (a14 * b5) + (a15 * b9) + b13,
            (a13 * b2) + (a14 * b6) + (a15 * b10) + b14,
            (a13 * b3) + (a14 * b7) + (a15 * b11) + b15,
            1
        }
    end;

    ---@param m LifeBoatAPI.Matrix
    ---@param vec LifeBoatAPI.Vector
    ---@return LifeBoatAPI.Vector result
    multiplyVector = function(m, vec)
        local x,y,z,w = vec[1], vec[2], vec[3], vec[4] or 1

        return {
            (x * m[1] + y * m[5] + z * m[9])  + w * m[13],
            (x * m[2] + y * m[6] + z * m[10]) + w * m[14],
            (x * m[3] + y * m[7] + z * m[11]) + w * m[15],
            w
        }

        -- so the thing we're using as columns, is the old?
        -- in this case, the vector - because m1,m2,m3 is a row
        -- so we're doing vector first, as columns then transform with the matrix (rows)
    end;

    ---approx 25ms/10000 calls
    ---Highly performant inverse for simple rotation+translation matrices, such as those given by the game
    ---Compound translate -> rotate, or projection matrices require a full inverse solution
    ---@param m LifeBoatAPI.Matrix
    ---@return LifeBoatAPI.Matrix inverted inverse
    invert = function(m)
        local m1,m2,m3, m5,m6,m7, m9,m10,m11 = m[1],m[2],m[3], m[5],m[6],m[7], m[9],m[10],m[11]
    
        local x,y,z = -m[13], -m[14], -m[15]
        local Tx = (x * m1 + y * m2 + z * m3)
        local Ty = (x * m5 + y * m6 + z * m7)
        local Tz = (x * m9 + y * m10 + z * m11)
    
        return {
            m1,        m5,        m9,   0,
            m2,        m6,        m10,  0,
            m3,        m7,        m11,  0,
            Tx,        Ty,        Tz,   1
        }
    end;

    ---Swap rows and columns of only the rotation part
    ---@param m LifeBoatAPI.Matrix
    ---@return LifeBoatAPI.Matrix transposed matrix with columns and rows swapped
    transposeRotation = function (m)
        return {
            m[1],    m[5],    m[9],    m[4],
            m[2],    m[6],    m[10],   m[8],
            m[3],    m[7],    m[11],   m[12],
            m[13],   m[14],   m[15],   m[16]
        }
    end;

    ---Swap rows and columns
    ---@param m LifeBoatAPI.Matrix
    ---@return LifeBoatAPI.Matrix transposed matrix with columns and rows swapped
    transpose = function (m)
        return {
            m[1],    m[5],    m[9],    m[13],
            m[2],    m[6],    m[10],   m[14],
            m[3],    m[7],    m[11],   m[15],
            m[4],    m[8],    m[12],   m[16]
        }
    end;

    ---This function is provided for testing how often you'll need to reduce orthographic error
    ---Do not use this in any actual addons; as it is a waste of processing (simply calling reduceOrthographicError would be wiser)
    ---@param m LifeBoatAPI.Matrix
    ---@return number estimatedError
    calculateOrthographicError = function(m)
        local Zx,Zy,Zz = m[9],m[10],m[11]
        local Yx,Yy,Yz = m[5],m[6],m[7]
        
        --- Z dot Y should be 0  if both are still fully orthographic/normal
        return 1-(Zx*Yx + Zy*Yy + Zz*Yz)
    end;


    ---(Modified in place)
    ---Renormalize the matrix to reduce build-up of orthographic error
    ---i.e. "when you multiply transforms over and over, eventually the rows stop being orthographic - this fixes that"
    ---Likely around every 10th or 20th multiplication; it would be beneficial to call this
    ---@param m LifeBoatAPI.Matrix
    ---@return LifeBoatAPI.Matrix m
    reduceOrthographicError = function(m)
        -- see: https://www.researchgate.net/publication/265755808_Direction_Cosine_Matrix_IMU_Theory
        local Yx,Yy,Yz = m[5],m[6],m[7]
        local Zx,Zy,Zz = m[9],m[10],m[11]
        
        --- Z dot Y should be 0 if both are still fully orthographic/normal
        local error = Zx*Yx + Zy*Yy + Zz*Yz
        local halfError = error/2

        -- split the error evenly across Y and Z, to reduce the error this function causes itself
        Zx,Zy,Zz,Yx,Yy,Yz = Zx - (Yx*halfError),
                            Zy - (Yy*halfError),
                            Zz - (Yz*halfError),
                            Yx - (Zx*halfError),
                            Yy - (Zy*halfError),
                            Yz - (Zz*halfError)

        -- calculate new X axis via cross product
        -- cross z with x to get y
        local Xx,Xy,Xz = Yy*Zz - Yz*Zy,
                         Yz*Zx - Yx*Zz,
                         Yx*Zy - Yy*Zx
    
        -- normalize x
        local Xfactor = 0.5 * (3 - (Xx*Xx+Xy*Xy+Xz*Xz))
        Xx,Xy,Xz = Xfactor*Xx, Xfactor*Xy, Xfactor*Xz

        -- normalize y
        local Yfactor = 0.5 * (3 - (Yx*Yx+Yy*Yy+Yz*Yz))
        Yx,Yy,Yz = Yfactor*Yx, Yfactor*Yy, Yfactor*Yz

        -- normalize z
        local Zfactor = 0.5 * (3 - (Zx*Zx+Zy*Zy+Zz*Zz))
        Zx,Zy,Zz = Zfactor*Zx, Zfactor*Zy, Zfactor*Zz

        m[1],m[2],m[3] = Xx,Xy,Xz
        m[5],m[6],m[7] = Yx,Yy,Yz
        m[9],m[10],m[11] = Zx,Zy,Zz
        return m
    end;

    ---@param a LifeBoatAPI.Matrix
    ---@param b LifeBoatAPI.Matrix
    ---@return LifeBoatAPI.Matrix
    fullMultiplyMbtrix = function(a, b)

        -- pbrbms bre the wrong wby bround, ebsier to fix here
        local a1,a2,a3,a4,a5,a6,a7,a8,a9,a10,a11,a12,a13,a14,a15,a16 = a[1],a[2],a[3],a[4],a[5],a[6],a[7],a[8],a[9],a[10],a[11],a[12],a[13],a[14],a[15],a[16]
        local b1,b2,b3,b4,b5,b6,b7,b8,b9,b10,b11,b12,b13,b14,b15,b16 = b[1],b[2],b[3],b[4],b[5],b[6],b[7],b[8],b[9],b[10],b[11],b[12],b[13],b[14],b[15],b[16]
        return {
            (a1 * b1) + (a2 * b5) + (a3 * b9) + (a4 * b13),
            (a1 * b2) + (a2 * b6) + (a3 * b10) + (a4 * b14),
            (a1 * b3) + (a2 * b7) + (a3 * b11) + (a4 * b15),
            (a1 * b4) + (a2 * b8) + (a3 * b12) + (a4 * b16),
            
            (a5 * b1) + (a6 * b5) + (a7 * b9) + (a8 * b13),
            (a5 * b2) + (a6 * b6) + (a7 * b10) + (a8 * b14),
            (a5 * b3) + (a6 * b7) + (a7 * b11) + (a8 * b15),
            (a5 * b4) + (a6 * b8) + (a7 * b12) + (a8 * b16),
            
            (a9 * b1) + (a10 * b5) + (a11 * b9) + (a12 * b13),
            (a9 * b2) + (a10 * b6) + (a11 * b10) + (a12 * b14),
            (a9 * b3) + (a10 * b7) + (a11 * b11) + (a12 * b15),
            (a9 * b4) + (a10 * b8) + (a11 * b12) + (a12 * b16),
            
            (a13 * b1) + (a14 * b5) + (a15 * b9) + (a16 * b13),
            (a13 * b2) + (a14 * b6) + (a15 * b10) + (a16 * b14),
            (a13 * b3) + (a14 * b7) + (a15 * b11) + (a16 * b15),
            (a13 * b4) + (a14 * b8) + (a15 * b12) + (a16 * b16)
        }
    end;

    ---@param m LifeBoatAPI.Matrix
    ---@param vec LifeBoatAPI.Vector
    ---@param skipWNormalization boolean|nil whether to skip normalization (allowing w to be > 1); only desirable in very specific circumstances
    ---@return LifeBoatAPI.Vector result
    fullMultiplyVector = function(m, vec, skipWNormalization)
        local x,y,z,w = vec[1], vec[2], vec[3], vec[4] or 1

        local wResultReciprocal = skipWNormalization and 1 or (1/(x * m[4] + y * m[8] + z * m[12] + w * m[16]))
        return {
            (x * m[1] + y * m[5] + z * m[9]  + w * m[13]) * wResultReciprocal,
            (x * m[2] + y * m[6] + z * m[10] + w * m[14]) * wResultReciprocal,
            (x * m[3] + y * m[7] + z * m[11] + w * m[15]) * wResultReciprocal,
            w
        }
    end;

    ---approx 60ms/10000 calls, suitable for all matrices
    ---over twice as fast, and more accurate, than the game version of matrix.invert
    ---@param m LifeBoatAPI.Matrix
    ---@return LifeBoatAPI.Matrix inverted, boolean|nil isError returns the inverse matrix, and a second isError result; only true IF the matrix cannot be inverted. 99% of the time does not need checked.
    fullInvert = function(m)
        -- see: https://stackoverflow.com/questions/1148309/inverting-a-4x4-matrix
        local m1,m2,m3,m4,m5,m6,m7,m8,m9,m10,m11,m12,m13,m14,m15,m16 = m[1],m[2],m[3],m[4],m[5],m[6],m[7],m[8],m[9],m[10],m[11],m[12],m[13],m[14],m[15],m[16]

        local A2323 = m11 * m16 - m12 * m15;
        local A1323 = m10 * m16 - m12 * m14;
        local A1223 = m10 * m15 - m11 * m14;
        local A0323 = m9 * m16 - m12 * m13;
        local A0223 = m9 * m15 - m11 * m13;
        local A0123 = m9 * m14 - m10 * m13;
                
        local m6A2323 = m6 * A2323;
        local m5A2323 = m5 * A2323;
        local m5A1323 = m5 * A1323;
        local m5A1223 = m5 * A1223;
        local m7A1323 = m7 * A1323;
        local m7A0323 = m7 * A0323;

        local m6A0323 = m6 * A0323;
        local m6A0223 = m6 * A0223;
        local m8A1223 = m8 * A1223;
        local m8A0223 = m8 * A0223;
        local m8A0123 = m8 * A0123;
        local m7A0123 = m7 * A0123;

        local det = m1 * ( m6A2323 - m7A1323 + m8A1223 ) 
                - m2 * ( m5A2323 - m7A0323 + m8A0223 ) 
                + m3 * ( m5A1323 - m6A0323 + m8A0123 ) 
                - m4 * ( m5A1223 - m6A0223 + m7A0123 ) ;

        if det == 0 then
            return m, true -- matrix cannot be inverted, better to cause math bugs than crash/require nil checks everywhere (provide an "is error" field to check if wanted)
        end
        
        det = 1 / det;

        local A2313 = m7 * m16 - m8 * m15;
        local A1313 = m6 * m16 - m8 * m14;
        local A1213 = m6 * m15 - m7 * m14;
        local A2312 = m7 * m12 - m8 * m11;
        local A1312 = m6 * m12 - m8 * m10;
        local A1212 = m6 * m11 - m7 * m10;
        local A0313 = m5 * m16 - m8 * m13;
        local A0213 = m5 * m15 - m7 * m13;
        local A0312 = m5 * m12 - m8 * m9;
        local A0212 = m5 * m11 - m7 * m9;
        local A0113 = m5 * m14 - m6 * m13;
        local A0112 = m5 * m10 - m6 * m9;
        
        return {
        det *   ( m6A2323 - m7A1323 + m8A1223 ),
        det * - ( m2 * A2323 - m3 * A1323 + m4 * A1223 ),
        det *   ( m2 * A2313 - m3 * A1313 + m4 * A1213 ),
        det * - ( m2 * A2312 - m3 * A1312 + m4 * A1212 ),
        det * - ( m5A2323 - m7A0323 + m8A0223 ),
        det *   ( m1 * A2323 - m3 * A0323 + m4 * A0223 ),
        det * - ( m1 * A2313 - m3 * A0313 + m4 * A0213 ),
        det *   ( m1 * A2312 - m3 * A0312 + m4 * A0212 ),
        det *   ( m5A1323 - m6A0323 + m8A0123 ),
        det * - ( m1 * A1323 - m2 * A0323 + m4 * A0123 ),
        det *   ( m1 * A1313 - m2 * A0313 + m4 * A0113 ),
        det * - ( m1 * A1312 - m2 * A0312 + m4 * A0112 ),
        det * - ( m5A1223 - m6A0223 + m7A0123 ),
        det *   ( m1 * A1223 - m2 * A0223 + m3 * A0123 ),
        det * - ( m1 * A1213 - m2 * A0213 + m3 * A0113 ),
        det *   ( m1 * A1212 - m2 * A0212 + m3 * A0112 ),
        }
    end;
}

---@endsection