export class Position{
	private x:number;
	private y:number;
	constructor(x:number,y:number);
}
export class Hex{
	position:Position;
	name:string;

	constructor();
	setPosition(x:number,y:number):void;
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
