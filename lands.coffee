gameconfig=require './gameconfig'
# 座標オブジェクト
class Position
	constructor:(@x,@y)->

class Hex
	constructor:->
		@position=new Position null,null

	name:"?"
	setPosition:(x,y)->
		if x instanceof Position
			@position=x
		else
			@position=new Position x,y
	html:->
		# HTMLを生成
		@rawhtml {
			src:"null.gif"
			title:"???"
			desc:""
		}
	rawhtml:(param)->
		# HTMLのtemp
		"<img class='hex' src='#{gameconfig.html.imagedir}#{param.src}'>"

module.exports=lands=
	Position:Position
	Hex:Hex

	Sea:class extends Hex
		name:"海"
		html:->
			@rawhtml {
				src:"land0.gif"
				title:"海"
				desc:""
			}
