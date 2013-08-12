import islands=module('./islands');
import lands=module('../coffee/lands');

import islandeffects=module('./islandeffects');

export class Process{
	private islandsdata:{
		[id:string]:islands.Island;
	};
	constructor(){
		this.islandsdata={};
		//今はダミーデータを作るといいんじゃ?
		this.islandsdata["1"]=islands.makeNewIsland();
		this.islandsdata["1"].metadata.name="テス島";
	}
	sight(id:string,callback:(err:any,html:string)=>void):void{
		var island=this.islandsdata[id];
		if(island==null){
			callback(new Error("その島はありません"),null);
			return;
		}
		(new islandeffects.Meteorite(island.land.randomPosition())).on(island);
		callback(null,island.html("ja",false));
	}
}
