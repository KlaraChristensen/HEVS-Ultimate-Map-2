centX = 0
centY = 0
zoom = 0
colorscheme = 0
nightMode = false

function onTick()
    centX = input.getNumber(8)
    centY = input.getNumber(9)
    zoom = input.getNumber(10)
    colorscheme = property.getNumber("Color Scheme")
    nightMode = input.getBool(10)
    output.setBool(1,nightMode)
end

function onDraw()
	
    if colorscheme == 1 then
		screen.setMapColorOcean(40,40,40)
		screen.setMapColorLand(200,200,200)
		screen.setMapColorShallows(80,80,80)
		screen.setMapColorGrass(180,180,180)
		screen.setMapColorSand(150,150,150)
		screen.setMapColorSnow(230,230,230)
	end
	if colorscheme == 2 then
		screen.setMapColorOcean(1,8,13)
		screen.setMapColorLand(4,24,38)
		screen.setMapColorShallows(1,8,13)
		screen.setMapColorGrass(10,50,68)
		screen.setMapColorSand(4,24,38)
		screen.setMapColorSnow(10,50,8)
	end
	if colorscheme == 3 then
		screen.setMapColorOcean(50/2,111/2,215/2)
		screen.setMapColorLand(200/2,200/2,200/2)
		screen.setMapColorShallows(50/2,111/2,215/2)
		screen.setMapColorGrass(100/2,210/2,100/2)
		screen.setMapColorSand(230/2,210/2,100/2)
		screen.setMapColorSnow(235/2,235/2,235/2)
	end
	if colorscheme == 4 then
		screen.setMapColorOcean(18,70,118)
		screen.setMapColorLand(121,121,121)
		screen.setMapColorShallows(18,70,118)
		screen.setMapColorGrass(121,121,121)
		screen.setMapColorSand(121,121,121)
		screen.setMapColorSnow(121,121,121)
	end
	if colorscheme == 5 then
		screen.setMapColorOcean(10,10,10)
		screen.setMapColorLand(50,50,50)
		screen.setMapColorShallows(20,20,20)
		screen.setMapColorGrass(45,45,45)
		screen.setMapColorSand(38,38,38)
		screen.setMapColorSnow(58,58,58)
	end
	if nightMode then
		screen.setMapColorOcean(0,0,0)
		screen.setMapColorLand(0,50,0)
		screen.setMapColorShallows(0,20,0)
		screen.setMapColorGrass(0,45,0)
		screen.setMapColorSand(0,37,0)
		screen.setMapColorSnow(0,57,0)
	end
		
	screen.drawMap(centX,centY,zoom)
end
