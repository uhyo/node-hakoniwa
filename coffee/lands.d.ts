import islands=module("../ts/islands");
export class Hex{
	name:string;

	constructor();
	setPosition(x:number,y:number):void;
	setPosition(pos:islands.Position):void;
	html(owner:bool):string;
	private rawhtml(param:{
		src:string;
	}):string;
	getName():string;
	//地形判定系
	isLand():bool;
	isSea():bool;
	isTown():bool;
	isBase():bool;
}
export class Base extends Hex{
	expTable:number[];
	maxExp:number;
	expToLevel(exp:number):number;
}
