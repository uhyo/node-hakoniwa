import islands=module('./islands');
import lands=module('../coffee/lands');

export class Process{
	private islandsdata:{
		[id:string]:islands.Island;
	};
	constructor(){
		this.islandsdata={};
		//今はダミーデータを作るといいんじゃ?
		this.islandsdata["1"]=islands.makeNewIsland();
	}
	sight(id:string,callback:(err:any,html:string)=>void):void{
		var island=this.islandsdata[id];
		if(island==null){
			callback(new Error("その島はありません"),null);
			return;
		}
		callback(null,island.html(false));
	}
}
