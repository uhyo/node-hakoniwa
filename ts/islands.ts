declare function require(path:string):any;
var gameconfig=require("../coffee/gameconfig");
import lands=module("../coffee/lands");

export class Island{
	public land:LandArea;
	constructor(){
		this.land=new LandArea(gameconfig.island.landwidth, gameconfig.island.landheight);
	}
	html(owner:bool):string{
		return this.land.html(owner);
	}
}

export class LandArea{
	private land:lands.Hex[][];
	constructor(public width:number,public height:number){
		//nullで初期化
		this.land=[];
		for(var y=0;y<height;y++){
			this.land[y]=[];
		}
	}
	set(x:number, y:number, hex:lands.Hex):void{
		hex.setPosition(x,y);
		if(x<0 || y<0 || x>=this.width || y>=this.height){
			//セットできない
			return;
		}
		this.land[y][x]=hex;
	}
	get(x:number, y:number):lands.Hex{
		return this.land[y][x];
	}
	html(owner:bool):string{
		return this.land.map(function(row){
			return row.map(function(hex){
				return hex.html(owner);
			}).join("");
		}).map(function(x:string,i:number){
			return i%2===0 ?
				"<div><img src='"+gameconfig.html.imagedir+"space.gif'>"+x+"</div>" :
					"<div>"+x+"<img src='"+gameconfig.html.imagedir+"space.gif'></div>";
		}).join("\n");
	}
}
export function makeNewIsland():Island{
	var result=new Island;
	var land=result.land;
	for(var y=0;y<result.land.height;y++){
		for(var x=0;x<result.land.width;x++){
			land.set(x,y,new (<any>lands).Sea);
		}
	}
	return result;
}
