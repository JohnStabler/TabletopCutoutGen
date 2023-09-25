type PointF
	ID as integer
	X as float
	Y as float
	U as float
	V as float
endtype

type Vector3
	X as float
	Y as float
	Z as float
endtype

type Triangle
	P1 as PointF
	P2 as PointF
	P3 as PointF
endtype

type Face
	RemovalIndex as integer
	Vertex as PointF[]
endtype

function Normalize(x#, y#, z#)
	
	d# = Sqrt(LengthSq3(x#, y#, z#))
	
	local v as Vector3
	v.X = x# / d#
	v.Y = y# / d#
	v.Z = z# / d#
	
endfunction v

function NormalizeVector3(v as Vector3)
	
	d# = Sqrt(LengthSq3(v.X, v.Y, v.Z))
	v.X = v.X / d#
	v.Y = v.Y / d#
	v.Z = v.Z / d#
	
endfunction v

function MakeVector3(x#, y#, z#)
	local v as Vector3
	v.X = x#
	v.Y = y#
	v.Z = z#
endfunction v

function EdgeVector3(x#, y#, z#)
	
endfunction

function LengthSq3(x#, y#, z#)
	
endfunction (x# * x#) + (y# * y#) + (z# * z#)

function LengthSq2(x#, y#)
	
endfunction (x# * x#) + (y# * y#)

function Triangulate(polygon as PointF[])
	
	local tmpPolygon as PointF[]
	local faces as Face[]
	local f as Face
	
	tmpPolygon = polygon
	
	while tmpPolygon.Length >= 2
		f = FindEar(tmpPolygon)
		if f.Vertex.Length > -1
			tmpPolygon.Remove(f.RemovalIndex)
			faces.Insert(f)
		else
			exit
		endif
	endwhile
	
	//faces.Insert(f)
	
endfunction faces

function FindEar(polygon ref as PointF[])
	
	local f as Face
	num_points = polygon.Length + 1
	
	for i = 0 to polygon.Length
		
		i2 = Mod(i + 1, num_points)
		i3 = Mod(i + 2, num_points)
		
		if FormsEar(polygon, i, i2, i3) = 1
			exitfunction CreateFace(i2, polygon[i], polygon[i2], polygon[i3])
		endif
		
	next i
	
endfunction f

function CreateFace(removal, p1 as PointF, p2 as PointF, p3 as PointF)
	
	local f as Face
	f.RemovalIndex = removal
	f.Vertex.Insert(p1)
	f.Vertex.Insert(p2)
	f.Vertex.Insert(p3)
	
endfunction f

function FormsEar(polygon ref as PointF[], p1, p2, p3)
	
	if GetAngle(polygon[p1].X, polygon[p1].Y, polygon[p2].X, polygon[p2].Y, polygon[p3].X, polygon[p3].Y) > 0 
		exitfunction 0
	endif
	
	local t as PointF[]
	t.Insert(polygon[p1])
	t.Insert(polygon[p2])
	t.Insert(polygon[p3])
	
	for i = 0 to polygon.Length
		
		if i <> p1 and i <> p2 and i <> p3
			
			if PointInPolygon(t, polygon[i].X, polygon[i].Y) = 1
				exitfunction 0
			endif
			
		endif
		
	next i
	
endfunction 1

function CreatePointF(id, x#, y#, u#, v#)
	
	local p as PointF
	p.ID = id
	p.X = x#
	p.Y = y#
	p.U = u#
	p.V = v#
	
endfunction p

function CrossProductLength(Ax#, Ay#, Bx#, By#, Cx#, Cy#)
	
	BAx# = Ax# - Bx#
	BAy# = Ay# - By#
	BCx# = Cx# - Bx#
	BCy# = Cy# - By#
	
endfunction (BAx# * BCy# - BAy# * BCx#)

function DotProduct(Ax#, Ay#, Bx#, By#, Cx#, Cy#)

	BAx# = Ax# - Bx#
	BAy# = Ay# - By#
	BCx# = Cx# - Bx#
	BCy# = Cy# - By#

endfunction (BAx# * BCx# + BAy# * BCy#)

function GetAngle(Ax#, Ay#, Bx#, By#, Cx#, Cy#)
	
	dot_product# = DotProduct(Ax#, Ay#, Bx#, By#, Cx#, Cy#)
	cross_product# = CrossProductLength(Ax#, Ay#, Bx#, By#, Cx#, Cy#)
	
	result# = Atan2(cross_product#, dot_product#)
	
endfunction result#

function PointInPolygon(polygon ref as PointF[], x#, y#)
	
	max_point = polygon.Length
	
	total_angle# = GetAngle(polygon[max_point].X, polygon[max_point].Y, x#, y#, polygon[0].X, polygon[0].Y)
	
	for i = 0 to max_point - 1
		total_angle# = total_angle# + GetAngle(polygon[i].X, polygon[i].Y, x#, y#, polygon[i + 1].X, polygon[i + 1].Y)		
	next i
	
	if Abs(total_angle#) > 0.00001
		exitfunction 1
	endif
	
endfunction 0

function DouglasPeuckerReduction(Points as PointF[], Tolerance as float)


    if Points.Length < 3 then exitfunction Points

    firstPoint = 0
    lastPoint = Points.Length
    local pointIndexsToKeep as integer[]

 

    //Add the first and last index to the keepers
    pointIndexsToKeep.Insert(firstPoint)
    pointIndexsToKeep.Insert(lastPoint)

    //The first and the last point cannot be the same
    while PointsEqual(Points[firstPoint], Points[lastPoint]) = 1
        dec lastPoint
    endwhile

    DouglasPeucker(Points, firstPoint, lastPoint, Tolerance, pointIndexsToKeep)

    local returnPoints as PointF[]

    pointIndexsToKeep.Sort()

    for index = 0 to pointIndexsToKeep.Length
        returnPoints.Insert(Points[pointIndexsToKeep[index]])
    next index

    // Renumber the IDs
    count = 0
    for index = 0 to returnPoints.Length
		returnPoints[index].id = count
		inc count
	next index

endfunction returnPoints

 

function PointsEqual(p1 as PointF, p2 as PointF)

	if p1.X = p2.X and p1.Y = p2.Y
		exitfunction 1
	endif

endfunction 0

 

function DouglasPeucker(points ref as PointF[], firstPoint as integer, lastPoint as integer, tolerance as float, pointIndexsToKeep ref as integer[])

 

    maxDistance# = 0

    indexFarthest = 0

   

    for index = firstPoint to lastPoint - 1

        distance# = PerpendicularDistance(points[firstPoint], points[lastPoint], points[index])

        if distance# > maxDistance#

            maxDistance# = distance#

            indexFarthest = index

        endif

    next index

 

    if maxDistance# > tolerance and indexFarthest <> 0

        //Add the largest point that exceeds the tolerance

        pointIndexsToKeep.Insert(indexFarthest)

   

        DouglasPeucker(points, firstPoint, indexFarthest, tolerance, pointIndexsToKeep)

        DouglasPeucker(points, indexFarthest, lastPoint, tolerance, pointIndexsToKeep)

    endif

 

endfunction

 

function PerpendicularDistance(p1 ref as PointF, p2 ref as PointF, p ref as PointF)

	area# = Abs(0.5 * (p1.X * p2.Y + p2.X * p.Y + p.X * p1.Y - p2.X * p1.Y - p.X * p2.Y - p1.X * p.Y))
	bottom# = Sqrt(Pow(p1.X - p2.X, 2) + Pow(p1.Y - p2.Y, 2))
	height# = area# / bottom# * 2

endfunction height#

function GetTriangleNormal(p1 as PointF, p2 as PointF, p3 as PointF, thick#)
	
	local v1 as Vector3
	local v2 as Vector3
	local v3 as Vector3
	
	v1 = MakeVector3(p1.X, p1.Y, thick#)
	v2 = MakeVector3(p2.X, p2.Y, -thick#)
	v3 = MakeVector3(p3.X, p3.Y, -thick#)
	
	local r as Vector3
	
	r = Vector3CrossProduct(Vector3Subtract(v2, v1), Vector3Subtract(v3, v1))
	
endfunction r

function Vector3CrossProduct(lhs as Vector3, rhs as Vector3)
	
	local r as Vector3
	r.X = lhs.y * rhs.z - lhs.z * rhs.y
    r.Y = lhs.z * rhs.x - lhs.x * rhs.z
    r.Z = lhs.x * rhs.y - lhs.y * rhs.x
	
endfunction r

function Vector3DotProduct(lhs as Vector3, rhs as Vector3)
	
	r# = lhs.x * rhs.x + lhs.y * rhs.y + lhs.z * rhs.z
	
endfunction r#

function Vector3Subtract(v1 as Vector3, v2 as Vector3)
	
	local r as Vector3
	r.X = v1.X - v2.X
	r.Y = v1.Y - v2.Y
	r.Z = v1.Z - v2.Z
	
endfunction r
