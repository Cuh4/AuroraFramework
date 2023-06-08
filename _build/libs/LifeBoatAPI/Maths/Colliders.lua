
---@section Colliders

LifeBoatAPI.Colliders = {

    ---@param point LifeBoatAPI.Vector|LifeBoatAPI.Matrix
    ---@param sphereCenter LifeBoatAPI.Vector|LifeBoatAPI.Matrix
    ---@param radius number
    isPointInSphere = function(point, sphereCenter, radius)
        local Px,Py,Pz;
        local Sx,Sy,Sz;
        if point[16] then
            Px,Py,Pz = point[13],point[14],point[15]
        else
            Px,Py,Pz = point[1],point[2],point[3]
        end

        if sphereCenter[16] then
            Sx,Sy,Sz = sphereCenter[13],sphereCenter[14],sphereCenter[15]
        else
            Sx,Sy,Sz = sphereCenter[1],sphereCenter[2],sphereCenter[3]
        end

        -- heavily unreadable for performance
        -- effectively just (point:sub(sphere):length2() <= radius^2)
        local dx,dy,dz = Px-Sx, Py-Sy, Pz-Sz
        return (dx*dx)+(dy*dy)+(dz*dz) <= (radius * radius)
    end;

    ---@param point LifeBoatAPI.Vector|LifeBoatAPI.Matrix
    ---@param endPoint LifeBoatAPI.Vector|LifeBoatAPI.Matrix
    ---@param sphereCenter LifeBoatAPI.Vector|LifeBoatAPI.Matrix
    ---@param radius number
    isLineInSphere = function(point, endPoint, sphereCenter, radius)
        -- let point be A, point_old be B, sphere C
        local Cx,Cy,Cz;
        if sphereCenter[16] then
            Cx,Cy,Cz = sphereCenter[13],sphereCenter[14],sphereCenter[15]
        else
            Cx,Cy,Cz = sphereCenter[1],sphereCenter[2],sphereCenter[3]
        end

        local Ax,Ay,Az;
        if endPoint[16] then
            Ax,Ay,Az = endPoint[13]-Cx,endPoint[14]-Cy,endPoint[15]-Cz
        else
            Ax,Ay,Az = endPoint[1]-Cx,endPoint[2]-Cy,endPoint[3]-Cz
        end
        
        local Bx,By,Bz;
        if point[16] then
            Bx,By,Bz = point[13]-Cx,point[14]-Cy,point[15]-Cz
        else
            Bx,By,Bz = point[1]-Cx,point[2]-Cy,point[3]-Cz
        end

        -- start to end vector
        local BAx, BAy, BAz = Ax-Bx, Ay-By, Az-Bz
        local BAlen2 = (BAx*BAx) + (BAy*BAy) + (BAz*BAz)

        -- normalized BA, allowing projection
        local BAlen = BAlen2^0.5
        local BAlenR = 1/BAlen
        local BAnx, BAny, BAnz = (BAlenR*BAx), (BAlenR * BAy), (BAlenR * BAz)

        -- start->sphere projected onto start->end
        local projection = -(Bx*BAnx)-(By*BAny)-(Bz*BAnz)
        
        -- sphere behind start of line -> use line startPoint
        -- or line is extremely short, in which case this becomes like a point-in-sphere test
        if projection < 0 or BAlen < 0.01 then
            return (Bx*Bx)+(By*By)+(Bz*Bz) <= (radius * radius)

        -- sphere ahead of end of line -> use line end point
        elseif projection > BAlen then
            return (Ax*Ax)+(Ay*Ay)+(Az*Az) <= (radius*radius)

        else
            -- closest point sphere in the middle of the line
            --let P<x,y,z> by the Projection of BC along BA
            local Px,Py,Pz = Bx+(projection*BAnx), By+(projection*BAny), Bz+(projection*BAnz)
            return (Px*Px)+(Py*Py)+(Pz*Pz) <= (radius*radius)
        end
    end;
    
    ---@param point LifeBoatAPI.Vector|LifeBoatAPI.Matrix
    ---@param zoneMatrix LifeBoatAPI.Matrix
    ---@param xSize number
    ---@param ySize number
    ---@param zSize number
    isPointInZone = function(point, zoneMatrix, xSize, ySize, zSize)
        -- transform the point by M-1 (assume simple rotate -> then translate matrix)
        -- then do point : aabb test
        -- note, fake inverse as if all we've done is rotate->translate

        local i1,i2,i3, i5,i6,i7, i9,i10,i11 = 
        zoneMatrix[1],        zoneMatrix[5],        zoneMatrix[9],
        zoneMatrix[2],        zoneMatrix[6],        zoneMatrix[10], 
        zoneMatrix[3],        zoneMatrix[7],        zoneMatrix[11] 

        local Ax,Ay,Az;
        if point[16] then
            Ax,Ay,Az = point[13]-zoneMatrix[13], point[14]-zoneMatrix[14], point[15]-zoneMatrix[15]
        else
            Ax,Ay,Az = point[1]-zoneMatrix[13], point[2]-zoneMatrix[14], point[3]-zoneMatrix[15]
        end

        Ax,Ay,Az = (Ax * i1 + Ay * i5 + Az * i9) 
                  ,(Ax * i2 + Ay * i6 + Az * i10)
                  ,(Ax * i3 + Ay * i7 + Az * i11)

        -- copy of isPointInAABB from here
        return not ( 
                (Ax >  xSize)
             or (Ax < -xSize)
             or (Ay >  ySize)
             or (Ay < -ySize)
             or (Az >  zSize)
             or (Az < -zSize))
    end;

    ---@param point LifeBoatAPI.Vector|LifeBoatAPI.Matrix
    ---@param endPoint LifeBoatAPI.Vector|LifeBoatAPI.Matrix
    ---@param zoneMatrix LifeBoatAPI.Matrix
    ---@param xSize number
    ---@param ySize number
    ---@param zSize number
    isLineInZone = function(point, endPoint, zoneMatrix, xSize, ySize, zSize)
        -- tramsform both points by M-1
        -- then do line : aabb test
        local i1,i2,i3, i5,i6,i7, i9,i10,i11, i13,i14,i15 = 
            zoneMatrix[1],        zoneMatrix[5],        zoneMatrix[9],
            zoneMatrix[2],        zoneMatrix[6],        zoneMatrix[10], 
            zoneMatrix[3],        zoneMatrix[7],        zoneMatrix[11],
            zoneMatrix[13],       zoneMatrix[14],       zoneMatrix[15]  
        
        local Ax,Ay,Az;
        if point[16] then
            Ax,Ay,Az = point[13]-i13, point[14]-i14, point[15]-i15
        else
            Ax,Ay,Az = point[1]-i13, point[2]-i14, point[3]-i15
        end

        Ax,Ay,Az = (Ax * i1 + Ay * i5 + Az * i9) 
                  ,(Ax * i2 + Ay * i6 + Az * i10)
                  ,(Ax * i3 + Ay * i7 + Az * i11)

        local Bx,By,Bz;
        if endPoint[16] then
            Bx,By,Bz = endPoint[13]-i13, endPoint[14]-i14, endPoint[15]-i15
        else
            Bx,By,Bz = endPoint[1]-i13, endPoint[2]-i14, endPoint[3]-i15
        end

        -- rotate direction by inverse of matrix rotation
        Bx,By,Bz = (Bx * i1 + By * i5 + Bz * i9) 
                  ,(Bx * i2 + By * i6 + Bz * i10)
                  ,(Bx * i3 + By * i7 + Bz * i11)

        -------------------------------------------------------------
        -- start to end vector
        local BAx, BAy, BAz = Ax-Bx, Ay-By, Az-Bz
        local BAlen2 = (BAx*BAx) + (BAy*BAy) + (BAz*BAz)

        -- normalized BA, allowing projection
        local BAlen = BAlen2^0.5
        local BAlenR = 1/BAlen
        local BAnx, BAny, BAnz = (BAlenR*BAx), (BAlenR * BAy), (BAlenR * BAz)

        -- start->sphere projected onto start->end
        local projection = -(Bx*BAnx)-(By*BAny)-(Bz*BAnz)
        
        -- sphere behind start of line -> use line startPoint
        -- or line is extremely short, in which case this becomes like a point-in-sphere test
        if projection < 0 or BAlen < 0.01 then
            return not ( 
                (Bx > xSize)
             or (Bx < -xSize)
             or (By > ySize)
             or (By < -ySize)
             or (Bz > zSize)
             or (Bz < -zSize))

        -- sphere ahead of end of line -> use line end point
        elseif projection > BAlen then
            return not ( 
                (Ax > xSize)
             or (Ax < -xSize)
             or (Ay > ySize)
             or (Ay < -ySize)
             or (Az > zSize)
             or (Az < -zSize))

        else
            -- closest point sphere in the middle of the line
            --let P<x,y,z> by the Projection of BC along BA
            local Px,Py,Pz = Bx+(projection*BAnx), By+(projection*BAny), Bz+(projection*BAnz)
            return not ( 
                (Px > xSize)
             or (Px < -xSize)
             or (Py > ySize)
             or (Py < -ySize)
             or (Pz > zSize)
             or (Pz < -zSize))
        end
    end;
}

---@endsection