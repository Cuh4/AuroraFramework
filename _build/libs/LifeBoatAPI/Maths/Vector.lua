
---@section Vector

---@class LifeBoatAPI.Vector
---@field [1] number conventionally: mapX axis
---@field [2] number conventionally: altitude
---@field [3] number conventionally: mapZ axis
---@field [4] number 0 = orientation only, 1 = position, used by matrix calculations only
LifeBoatAPI.Vector = {

    ---@param x number x component
    ---@param y number y component; conventially represents the altitude
    ---@param z number z component
    ---@param w number|nil optional w component (1=positional, 0=orientation-only)
    ---@overload fun(cls:LifeBoatAPI.Vector, x:number, y:number):LifeBoatAPI.Vector creates a vector2 (z-component is 0)
    ---@overload fun(cls:LifeBoatAPI.Vector):LifeBoatAPI.Vector creates a new zero-initialized vector3
    ---@return LifeBoatAPI.Vector
    new = function(x, y, z, w)
        return {
            x,y,z,w or 1,
        }
    end;

    --- from: https://www.mathworks.com/help/phased/ug/spherical-coordinates.html
    --- x=Rcos(el)cos(az)
    --- y=Rsin(el)
    --- z=Rcos(el)sin(az)
    ---@param azimuth number azimuth angle, 0 north -> 2pi north
    ---@param elevation number elevation +/- pi/2 radians from horizon
    ---@param distance number
    ---@param w number|nil optional w component (1=positional, 0=orientation-only)
    ---@return LifeBoatAPI.Vector
    newFromAzimuthElevation = function(azimuth, elevation, distance, w)
        local distCosEv = distance * math.cos(elevation)
        return {
            distCosEv * math.sin(azimuth),
            distance * math.sin(elevation),
            distCosEv * math.cos(azimuth),
            w or 1,
        }
    end;

    ---@param vec LifeBoatAPI.Vector vector to clone
    ---@param x number|nil x override
    ---@param y number|nil y override
    ---@param z number|nil z override
    ---@param w number|nil w override
    clone = function(vec, x, y, z, w)
        return {
            x or vec[1],
            y or vec[2],
            z or vec[3],
            w or vec[4],
        }
    end;

    ---@param vec LifeBoatAPI.Vector
    ---@param rhs LifeBoatAPI.Vector
    ---@return LifeBoatAPI.Vector result
    add = function(vec, rhs)
        return {
            vec[1]+rhs[1],
            vec[2]+rhs[2],
            vec[3]+rhs[3],
            vec[4],
        }
    end;

    ---@param vec LifeBoatAPI.Vector
    ---@param rhs LifeBoatAPI.Vector
    ---@return LifeBoatAPI.Vector result
    sub = function (vec, rhs)
        return {
            vec[1]-rhs[1],
            vec[2]-rhs[2],
            vec[3]-rhs[3],
            vec[4],
        }
    end;

    ---@param vec LifeBoatAPI.Vector
    ---@param rhs LifeBoatAPI.Vector
    ---@param t number 0->1 expected
    ---@return LifeBoatAPI.Vector result
    lerp = function (vec, rhs, t)
        local oneMinusT = 1 - t
        return {
            oneMinusT*vec[1] + t*rhs[1],
            oneMinusT*vec[2] + t*rhs[2],
            oneMinusT*vec[3] + t*rhs[3],
            vec[4],
        }
    end;

    ---@param vec LifeBoatAPI.Vector
    ---@param scalar number factor to scale by
    ---@return LifeBoatAPI.Vector result
    scale = function (vec, scalar)
        return {
            vec[1]*scalar,
            vec[2]*scalar,
            vec[3]*scalar,
            vec[4],
        }
    end;

    --- Direction determined by left-hand-rule; thumb is result, middle finger is "lhs", index finger is "rhs"
    ---@param a LifeBoatAPI.Vector
    ---@param b LifeBoatAPI.Vector
    ---@return LifeBoatAPI.Vector
    cross = function(a, b)
        local Ax,Ay,Az = a[1],a[2],a[3]
        local Bx,By,Bz = b[1],b[2],b[3]
        return {
            Ay*Bz - Az*By,
            Az*Bx - Ax*Bz,
            Ax*By - Ay*Bx,
            a[4],
        }
    end;

    ---(Immutable) Normalizes the vector so the magnitude is 1
    ---Ideal for directions; as they can then be multipled by a scalar distance to get a position
    ---@param vec LifeBoatAPI.Vector
    ---@return LifeBoatAPI.Vector result
    normalize = function(vec)
        local x,y,z = vec[1],vec[2],vec[3]
        local length = ((x*x) + (y*y) + (z*z))^0.5
        local lengthReciprocal = length ~= 0 and 1/length or 0
        return {
            x * lengthReciprocal,
            y * lengthReciprocal,
            z * lengthReciprocal,
            vec[4],
        }
    end;

    --- Reflects this vector about the given normal
    --- Normal is expected to be in the same direction as this vector, and will return the reflection circularly about that vector
    ---@param vec LifeBoatAPI.Vector
    ---@param normal LifeBoatAPI.Vector
    ---@param isAlreadyNormalized boolean is normal is already a unit vector, can skip some calculation
    ---@return LifeBoatAPI.Vector
    reflect = function(vec, normal, isAlreadyNormalized)
        local Vx,Vy,Vz = vec[1],vec[2],vec[3]
        local Nx,Ny,Nz = normal[1],normal[2],normal[3]
        -- r=d−2(d⋅n)n where r is the reflection, d is the vector, v is the normal to reflect over
        -- normally expects rays to be like light, coming into the mirror and bouncing off. We negate the parts to make this work in our favour

        -- normalize the normal (avoid extra function calls + table allocations)
        if not isAlreadyNormalized then
            local length = ((Nx*Nx) + (Ny*Ny) + (Nz*Nz))^0.5
            local lengthReciprocal = length ~= 0 and 1/length or 0
            Nx = Nx * lengthReciprocal
            Ny = Ny * lengthReciprocal
            Nz = Nz * lengthReciprocal
        end

        local dotProduct_times2 = 2 * (Vx * Nx) + (Vy * Ny) + (Vz * Nz)

        --equivilent of self:sub(normal:scale(2 * self:dot(normal)))
        return {
            -Vx - (Nx * dotProduct_times2),
            -Vy - (Ny * dotProduct_times2),
            -Vz - (Nz * dotProduct_times2),
            vec[4]
        }

    end;

    -- check two vectors are equal in contents
    ---@param a LifeBoatAPI.Vector
    ---@param b LifeBoatAPI.Vector
    ---@return boolean areEqual
    equals = function(a, b)
        -- horrible code but runs faster
        return a[1] == b[1]
           and a[2] == b[2]
           and a[3] == b[3]
           and a[4] == b[4]
    end;
    
    ---Calculates the Dot Product of the vectors
    ---@param a LifeBoatAPI.Vector
    ---@param b LifeBoatAPI.Vector
    ---@return number
    dot = function (a, b)
        return (a[1] * b[1]) + (a[2] * b[2]) + (a[3] * b[3])
    end;

    ---Gets the length (magnitude) of this vector
    ---i.e. gets the distance from this point; to the origin
    ---@param vec LifeBoatAPI.Vector
    ---@return number length
    length = function (vec)
        local x,y,z = vec[1],vec[2],vec[3]
        return ((x*x)+(y*y)+(z*z))^0.5
    end;

    ---Gets the length SQUARED (magnitude) of this vector
    ---i.e. gets the squared distance from this point; to the origin
    ---Useful for collision detection/distance comparisons
    ---@param vec LifeBoatAPI.Vector
    ---@return number lengthSquared
    length2 = function (vec)
        local x,y,z = vec[1],vec[2],vec[3]
        return ((x*x)+(y*y)+(z*z))
    end;

    ---Gets the distance between two points represented as Vecs
    ---@param a LifeBoatAPI.Vector
    ---@param b LifeBoatAPI.Vector
    ---@return number distance
    distance = function(a, b)
        local x = a[1] - b[1]
        local y = a[2] - b[2]
        local z = a[3] - b[3]
        return ((x * x) + (y * y) + (z * z))^0.5
    end;

    ---Gets the SQUARED distance between two points represented as Vecs
    ---Useful for collision detection/distance comparisons
    ---@param a LifeBoatAPI.Vector
    ---@param b LifeBoatAPI.Vector
    ---@return number distanceSquared
    distance2 = function(a, b)
        local x = a[1] - b[1]
        local y = a[2] - b[2]
        local z = a[3] - b[3]
        return (x * x) + (y * y) + (z * z)
    end;

    ---Calculates the shortest angle between two vectors
    ---Note, angle is NOT signed
    ---@param a LifeBoatAPI.Vector
    ---@param b LifeBoatAPI.Vector
    ---@return number
    anglebetween = function(a, b)
        local Ax,Ay,Az = a[1],a[2],a[3]
        local Bx,By,Bz = b[1],b[2],b[3]

        local Alen = ((Ax*Ax)+(Ay*Ay)+(Az*Az))^0.5
        local Blen = ((Bx*Bx)+(By*By)+(Bz*Bz))^0.5
        local ABdot = (Ax*Bx) + (Ay * By) + (Az * Bz)
        return math.acos(ABdot / (Alen * Blen))
    end;

    ---Converts the vector into spatial coordinates as an azimuth, elevation, distance triplet
    ---Formula from mathworks: https://www.mathworks.com/help/phased/ug/spherical-coordinates.html
    ---R=sqrt(x2+y2+z2)
    ---az=tan−1(y/x)
    ---el=tan−1(z/sqrt(x2+y2))
    ---@param vec LifeBoatAPI.Vector
    ---@return number,number,number components azimuth (North is 0), elevation (Horizon is 0), distance
    azimuthElevation= function(vec)
        local x,y,z = vec[1],vec[2],vec[3]

        local length = ((x*x) + (y*y) + (z*z))^0.5
        local lengthReciprocal = length ~= 0 and 1/length or 0
        
        x = x * lengthReciprocal
        y = y * lengthReciprocal
        z = z * lengthReciprocal

        return  math.atan(x, y),
                math.atan(z, (x*x + y*y)^0.5),
                length
    end;
}

---@endsection