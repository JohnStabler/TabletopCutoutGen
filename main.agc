#include "polygon.agc"

// show all errors
SetErrorMode(2)

// set window properties
SetWindowTitle("Tabletop")
SetWindowSize(1280, 720, 0)
SetWindowAllowResize( 1 ) // allow the user to resize the window

// set display properties
SetVirtualResolution(1920, 1080) // doesn't have to match the window
SetOrientationAllowed( 1, 1, 1, 1 ) // allow both portrait and landscape on mobile devices
SetSyncRate(30, 0 ) // 30fps instead of 60 to save battery
SetVSync(1)
SetScissor(0, 0, 0, 0) // use the maximum available screen space, no black borders
UseNewDefaultFonts(1) // since version 2.0.22 we can use nicer default fonts
SetAmbientColor(0, 0, 0)
SetAntialiasMode(1)
SetGenerateMipmaps(1)
SetShadowMappingMode(3)
SetShadowMapSize(2048, 2048)
SetShadowSmoothing(0)
SetShadowBias(0.01)

local sun as Vector3
sun = Normalize(1, -1, 1)

SetSunDirection(sun.X, sun.Y, sun.Z)
SetSunColor(255, 255, 255)

local points as PointF[]
local faces as Face[]

SetCameraPosition(1, 0, 0, -100)
SetCameraLookAt(1, 0, 0, 0, 0)

marbleImage = LoadImage("marble.png")
marbleNormalImage = LoadImage("marble_NORM.png")
baseImage = LoadImage("cloak-2.png")

Print("Flattening image...")
Sync()
texture = FlattenImage(baseImage)

Print("Creating point list...")
Sync()
points = DouglasPeuckerReduction(CalculateHull(baseImage, 512, 4), 0.005)

Print("Triangulating...")
Sync()
faces = Triangulate(points)

Print("Creating object...")
Sync()
ob = CreateCutoutObject(points, faces, 0.015)

SetObjectImage(ob, texture, 0)
SetObjectScalePermanent(ob, 50, 50, 50)
SetObjectPosition(ob, 0, 0, 0)
SetObjectCastShadow(ob, 1)
SetObjectReceiveShadow(ob, 0)
//SetObjectCullMode(ob, 0)
SetObjectLightMode(ob, 2)

base = CreateObjectCylinder(2, Abs(GetObjectSizeMinX(ob)) + GetObjectSizeMaxX(ob), 32)
SetObjectimage(base, marbleImage, 0)
SetObjectNormalMap(base, marbleNormalImage)
SetObjectPosition(base, GetObjectX(ob), GetObjectY(ob) - GetObjectSizeMaxY(ob), GetObjectZ(ob))
SetObjectCastShadow(base, 1)
FixObjectToObject(base, ob)

board = CreateObjectPlane(256, 256)
SetObjectRotation(board, 90, 0, 0)
SetObjectPosition(board, 0, GetObjectY(ob) - (GetObjectSizeMaxY(ob) + 1), 0)
SetObjectColor(board, 127, 127, 127, 255)
SetObjectReceiveShadow(board, 1)

do
	
	RotateObjectLocalY(ob, 0.5)
    Print("Triangles: " + Str((faces.Length * 2) + (points.Length * 2)))
    Sync()
loop

function CreateCutoutObject(points ref as PointF[], faces ref as Face[], thickness as float)
	
	local tv as Vector3
	numVerticies = points.Length + 1
	numFaces = faces.Length + 1
	numIndicies = numFaces * 3
	numExtendedIndices = numVerticies * 2 * 3
	thick# = thickness / 2.0
	
	vString$ = ""
	vtString$ = ""
	vnString$ = ""
	fString$ = ""
	
	for i = 0 to points.Length
		vString$ = vString$ + "v " + Str(points[i].X) + " " + Str(-points[i].Y) + " " + Str(-thick#) + Chr(13) + chr(10)
		vtString$ = vtString$ + "vt " + Str(points[i].U) + " " + Str(1.0 - points[i].V) + Chr(13) + chr(10)
	next i
	
	vnString$ = vnString$ + "vn 0 0 -1.0" + Chr(13) + Chr(10)
	
	for i = 0 to points.Length
		vString$ = vString$ + "v " + Str(points[i].X) + " " + Str(-points[i].Y) + " " + Str(thick#) + Chr(13) + chr(10)
		vtString$ = vtString$ + "vt " + Str(points[i].U) + " " + Str(1.0 - points[i].V) + Chr(13) + chr(10)
	next i
	
	vnString$ = vnString$ + "vn 0 0 1.0" + Chr(13) + Chr(10)
	
	vtString$ = vtString$ + "vt 0 0 0"+ Chr(13) + chr(10)	
	fString$ = fString$ + "s off" + Chr(13) + Chr(10)
	
	for i = 0 to faces.Length
		fString$ = fString$ + "f " + FaceVTN(faces[i].Vertex[0].ID + 1, faces[i].Vertex[0].ID + 1, 1) + " " + FaceVTN(faces[i].Vertex[1].ID + 1, faces[i].Vertex[1].ID + 1, 1) + " " + FaceVTN(faces[i].Vertex[2].ID + 1, faces[i].Vertex[2].ID + 1, 1) + Chr(13) + Chr(10)
	next i
	
	for i = 0 to faces.Length
		fString$ = fString$ + "f " + FaceVTN(faces[i].Vertex[2].ID + 1 + numVerticies, faces[i].Vertex[2].ID + 1 + numVerticies, 2) + " " + FaceVTN(faces[i].Vertex[1].ID + 1 + numVerticies, faces[i].Vertex[1].ID + 1 + numVerticies, 2) + " " + FaceVTN(faces[i].Vertex[0].ID + 1 + numVerticies, faces[i].Vertex[0].ID + 1 + numVerticies, 2) + Chr(13) + Chr(10)
	next i
	
	// Extended indices
	cVT = points.Length * 2 + 1
	for i = 0 to points.Length
		p1 = i
		p2 = Mod(i + 1, points.Length + 1)
		tv = NormalizeVector3(GetTriangleNormal(points[p2], points[p2], points[p1], thick#))
		vnString$ = vnString$ + "vn " + Str(-tv.X) + " " + Str(tv.Y) + " " + Str(-tv.Z) + Chr(13) + Chr(10)
		//fString$ = fString$ + "f " + FaceVTN(p2 + numVerticies + 1, p2 + numVerticies + 1, i + 3) + " " + FaceVTN(p2 + 0 + 1, p2 + 0 + 1, i + 3) + " " + FaceVTN(p1 + 0 + 1, p1 + 0 + 1, i + 3) + Chr(13) + Chr(10)
		fString$ = fString$ + "f " + FaceVTN(p2 + numVerticies + 1, cVT, i + 3) + " " + FaceVTN(p2 + 0 + 1, cVT, i + 3) + " " + FaceVTN(p1 + 0 + 1, cVT, i + 3) + Chr(13) + Chr(10)
	next i
	
	for i = 0 to points.Length
		p1 = i
		p2 = Mod(i + 1, points.Length + 1)
		//fString$ = fString$ + "f " + FaceVTN(p1 + 0 + 1, p1 + 0 + 1, i + 3) + " " + FaceVTN(p1 + numVerticies + 1, p1 + numVerticies + 1, i + 3) + " " + FaceVTN(p2 + numVerticies + 1, p2 + numVerticies + 1, i + 3) + Chr(13) + Chr(10)
		fString$ = fString$ + "f " + FaceVTN(p1 + 0 + 1, cVT, i + 3) + " " + FaceVTN(p1 + numVerticies + 1, cVT, i + 3) + " " + FaceVTN(p2 + numVerticies + 1, cVT, i + 3) + Chr(13) + Chr(10)
	next i
		
	f = OpenToWrite("output.obj")
	WriteLine(f, "o object")
	WriteLine(f, vString$)
	WriteLine(f, vtString$)
	WriteLine(f, vnString$)
	WriteLine(f, fString$)
	CloseFile(f)
	
	ob = LoadObject("output.obj")
	
endfunction ob

function FaceVTN(p1, p2, p3)
	
	r$ = Str(p1) + "/" + Str(p2) + "/" + Str(p3)
	
endfunction r$

function FlattenImage(img as integer)
	
	rw = GetVirtualWidth()
	rh = GetVirtualHeight()
	
	iw = GetImageWidth(img)
	ih = GetImageHeight(img)
	
	r = CreateRenderImage(iw, ih, 0, 0)
	//SetImageMagFilter(r, 0)
	//SetImageMinFilter(r, 0)
	
	SetRenderToImage(r, 0)
	SetVirtualResolution(iw, ih)
	
	bgImg = CreateImageColor(255, 255, 255, 255)
	s = CreateSprite(bgImg)
	SetSpriteSize(s, iw, ih)
	SetSpritePosition(s, 0, 0)
	DrawSprite(s)
	DeleteSprite(s)
	DeleteImage(bgImg)
	
	s = CreateSprite(img)
	SetSpritePositionByOffset(s, iw / 2, ih / 2)
	DrawSprite(s)
	DeleteSprite(s)
	
	SetRenderToScreen()
	SetVirtualResolution(rw, rh)
	
	exitfunction r
	
	mem = CreateMemblockFromImage(r)
	
	for y = 0 to ih -1
		for x = 0 to iw -1
			
			i = (y * iw) + x
			alpha = GetMemblockByte(mem, (i * 4) + 3 + 12)
			
			if alpha = 0
				SetMemblockByte(mem, (i * 4) + 12, 255)
				SetMemblockByte(mem, (i * 4) + 1 + 12, 255)
				SetMemblockByte(mem, (i * 4) + 2 + 12, 255)
				SetMemblockByte(mem, (i * 4) + 3 + 12, 255)
			elseif alpha < 255
				SetMemblockByte(mem, (i * 4) + 3 + 12, 255)
			endif
			
		next x
	next y
	
	DeleteImage(r)
	r = CreateImageFromMemblock(mem)
	DeleteMemblock(mem)
	
endfunction r

function CalculateHull(img as integer, resolution as integer, erodeCount as integer)
	
	fres# = resolution
	hres# = fres# / 2.0
	
	rw = GetVirtualWidth()
	rh = GetVirtualHeight()
	
	iw# = GetImageWidth(img)
	ih# = GetImageHeight(img)
	
	if iw# > ih#
		m# = iw#
		uscale# = 1.0
		vscale# = iw# / ih#
	else
		m# = ih#
		uscale# = ih# / iw#
		vscale# = 1.0
	endif
	
	r = CreateRenderImage(resolution, resolution, 0, 0)
	SetImageMagFilter(r, 0)
	SetImageMinFilter(r, 0)
	
	SetRenderToImage(r, 0)
	SetVirtualResolution(m#, m#)
	
	s = CreateSprite(img)
	SetSpritePositionByOffset(s, m# / 2.0, m# / 2.0)
	DrawSprite(s)
	DeleteSprite(s)
	
	SetRenderToScreen()
	SetVirtualResolution(rw, rh)
	
	mem = CreateMemblockFromImage(r)
	mem2 = CreateMemblockFromImage(r)
	
	sx = -1
	sy = -1
	alpha = 0
	pcount = 0
	
	local state as integer[]
	local points as PointF[]
	
	// Erode edge
	for ec = 0 to erodeCount
		
		for y = 0 to resolution - 1
			for x = 0 to resolution - 1
				
				i = (y * resolution) + x
				alpha = GetMemblockByte(mem2, (i * 4) + 3 + 12)
				
				if alpha = 0 // Pixel is invisible
					
					c = 0
					for iy = MaxInteger(y - 1, 0) to MinInteger(y + 1, resolution - 1)
						for ix = MaxInteger(x - 1, 0) to MinInteger(x + 1, resolution - 1)
							
							if iy <> y or ix <> x
								ii = (iy * resolution) + ix
								ialpha = GetMemblockByte(mem2, (ii * 4) + 3 + 12)
								if ialpha > 0
									inc c
								endif
							endif
							
						next ix
					next iy
					
					if c > 0 // One or more adjacent visible pixels
						SetMemblockInt(mem, (i * 4) + 12, 0xFFFFFFFF)
						//SetMemblockByte(mem, (i * 4) + 12, 255)
						//SetMemblockByte(mem, (i * 4) + 1 + 12, 255)
						//SetMemblockByte(mem, (i * 4) + 2 + 12, 255)
						//SetMemblockByte(mem, (i * 4) + 3 + 12, 255)
					endif
					
				endif
				
			next x
		next y
	
		CopyMemblock(mem, mem2, 0, 0, GetMemblockSize(mem))
	
	next ec
	
	// Edge detection
	for y = 0 to resolution -1
		for x = 0 to resolution -1
			
			i = (y * resolution) + x
			alpha = GetMemblockByte(mem, (i * 4) + 3 + 12)
			
			if alpha = 0 or y = 0 or x = 0 or y = resolution - 1 or x = resolution - 1 // Pixel is invisible
								
				c = 0
				for iy = MaxInteger(y - 1, 0) to MinInteger(y + 1, resolution - 1)
					for ix = MaxInteger(x - 1, 0) to MinInteger(x + 1, resolution - 1)
						
						if iy <> y or ix <> x
							ii = (iy * resolution) + ix
							ialpha = GetMemblockByte(mem, (ii * 4) + 3 + 12)
							if ialpha > 0
								inc c
							endif
						endif
						
					next ix
				next iy
				
				if c = 0 // No visible pixels adjacent
					state.Insert(0)
				else // One or more adjacent visible pixels
					state.Insert(1)
					inc pcount
					if sy = -1 // Record top left pixel
						sy = y
						sx = x
					endif
				endif
			else // Visible pixel
				state.Insert(0)
			endif
			
		next x
	next y
		
	DeleteMemblock(mem)
	DeleteMemblock(mem2)
	DeleteImage(r)
	
	// Navigate the outline to generate a list of pixels
	lastAngle# = 0.0
	c = 0
	nx = sx
	ny = sy
	repeat
		
		found = 0
		i = (ny * resolution) + nx
		
		if i >= 0 and i < (resolution * resolution)
			
			state[i] = 2
			nxf# = nx
			nuf# = nxf# / fres#
			nxf# = (nxf# - hres#) / fres#
			nyf# = ny
			nvf# = nyf# / fres#
			nyf# = (nyf# - hres#) / fres#
			
			nuf# = (nxf# * uscale#) + 0.5
			nvf# = (nyf# * vscale#) + 0.5
			
			points.Insert(CreatePointF(c, nxf#, nyf#, nuf#, nvf#))
			
			inc c
			dec pcount
			
			ainc# = 22.5
			max = (360.0 / ainc#) - 1
			
			for a = 0 to max

				angle# = a * ainc#
				tangle# = FMod(lastAngle# - 180.0 + angle#, 360.0)
				ix = Round(Sin(tangle#)) + nx
				iy = Round(-Cos(tangle#)) + ny
				
				g = GetGridCell(state, ix, iy, resolution, resolution)
				
				if g = 1
					nx = ix
					ny = iy
					lastAngle# = tangle#
					found = 1
					exit
				endif
						
			next a
		
		endif
			
	until pcount = 0 or found = 0
	
endfunction points

function GetGridCell(grid ref as integer[], x, y, width, height)
	
	i = (y * width) + x
	
	if i < 0 or i >= (width * height)
		exitfunction 0
	else
		exitfunction grid[i]
	endif
	
endfunction 0

function MaxInteger(a, b)
	
	if a > b
		exitfunction a
	endif
	
endfunction b

function MinInteger(a, b)
	
	if a < b
		exitfunction a
	endif
	
endfunction b
