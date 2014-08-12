import islands=require("../ts/islands");
export declare class Hex{
	name:string;
	position:islands.Position;
	land:islands.LandArea;
	island:islands.Island;

	constructor();
	setPosition(x:number,y:number):void;
	setPosition(pos:islands.Position):void;
	setLand(land:islands.LandArea):void;
	setIsland(island:islands.Island):void;
	html(lang:string,owner:boolean):string;
	private rawhtml(param:{
		src:string;
	}):string;
	getName(lang?:string):string;
	turnProcess():void;
    //島情報の集計
    estimate(status:islands.IslandStatus):void;

	damage(type:string):void;
	//地形判定系
	isLand():boolean;
	isSea():boolean;
	isTown():boolean;
	isBase():boolean;
	isForest():boolean;
	//一致
	is(con:new()=>Hex):boolean;
	clone():Hex;
}
export declare class Base extends Hex{
	expTable:number[];
	maxExp:number;
	expToLevel(exp:number):number;
}
