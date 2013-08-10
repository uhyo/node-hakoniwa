import islands=module("../ts/islands");
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
	html(lang:string,owner:bool):string;
	private rawhtml(param:{
		src:string;
	}):string;
	getName(lang?:string):string;
	turnProcess():void;
	damage(type:string):void;
	//地形判定系
	isLand():bool;
	isSea():bool;
	isTown():bool;
	isBase():bool;
	//一致
	is(con:new()=>Hex):bool;
	clone():Hex;
}
export declare class Base extends Hex{
	expTable:number[];
	maxExp:number;
	expToLevel(exp:number):number;
}
