gameconfig=require './gameconfig'
lands=require './lands'

exports.Island=class Island
	constructor:->
		@land=new LandArea gameconfig.island.landwidth, gameconfig.island.landheight
	html:->
		# HTMLを生成する
		@land.html()

exports.LandArea=class LandArea
	constructor:(@width,@height)->
		#@land[x][y]
		@land = ((null for x in [0...@width]) for y in [0...@height])
	set:(x,y,hex)->
		#hex: Hex Object(in lands.coffee)
		hex.setPosition x,y
		if x<0 || y<0 || x>=@width || y>=@height
			return
		@land[x][y]=hex
	html:->
		# HTMLを生成する
		((hex.html() for hex in row).join("") for row in @land).map((x,i)->
			if i%2==0
				"<div><img src='#{gameconfig.html.imagedir}space.gif'>#{x}</div>"
			else
				"<div>#{x}<img src='#{gameconfig.html.imagedir}space.gif'></div>"
		).join("\n")
exports.makeNewIsland=->
	result=new Island
	land=result.land

	# 地形を作る
	for y in [0...result.land.height]
		for x in [0...result.land.width]
			land.set x,y,new lands.lands.Sea
	result

