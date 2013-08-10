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
		//災害も起こしてみたりして
		(new islandeffects.Earthquake).on(this.islandsdata["1"]);
	}
	sight(id:string,callback:(err:any,html:string)=>void):void{
		var island=this.islandsdata[id];
		if(island==null){
			callback(new Error("その島はありません"),null);
			return;
		}
		callback(null,island.html("ja",false));
	}
}
