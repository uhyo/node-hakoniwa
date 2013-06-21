import islands=module("../ts/islands");
export class Hex{
	name:string;
	position:islands.Position;
	land:islands.LandArea;
	island:islands.Island;

	constructor();
	setPosition(x:number,y:number):void;
	setPosition(pos:islands.Position):void;
	setLand(land:islands.LandArea):void;
	setIsland(island:islands.Island):void;
	html(owner:bool):string;
	private rawhtml(param:{
		src:string;
	}):string;
	getName():string;
	turnProcess():void;
	damage(type:string):void;
	//地形判定系
	isLand():bool;
	isSea():bool;
	isTown():bool;
	isBase():bool;
	//一致
	is(con:new()=>Hex):bool;
}
export class Base extends Hex{
	expTable:number[];
	maxExp:number;
	expToLevel(exp:number):number;
}
