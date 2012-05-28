islands=require './islands'
lands=require './lands'
module.exports=e=new (require('events').EventEmitter)

islandsdata={}	# id: (Island)

e.on "init",->
	# なんかデータを作っておく
	islandsdata["1"]=islands.makeNewIsland()

e.on "sight",(id,cb)->
	# そのidの島を観光する HTMLをcallbackに渡す
	unless islandsdata[id]?
		# そんな島はない
		cb error:"その島はありません"
		return
	island=islandsdata[id]

	cb island.html()

