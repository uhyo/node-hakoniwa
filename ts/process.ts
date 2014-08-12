import turn=require('./turn');
import islands=require('./islands');
import lands=require('../coffee/lands');

import islandeffects=require('./islandeffects');

export class Process{
	private islandsdata:turn.IslandsDict;
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
		(new islandeffects.Subsidence()).on(island);
		callback(null,island.html("ja",false));
	}
    //イテレータを返す
    getIterator():turn.IslandsIterator{
        return new turn.IslandsIterator(this.islandsdata);
    }
}
