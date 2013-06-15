declare var require:(path:string)=>any;
var gameconfig=require('../coffee/gameconfig');

import islands=module("./islands");

export class IslandEffect{
	constructor(){
	}
	on(island:islands.Island):void{
	}
}

export class Gain extends IslandEffect{
}
export class GainFood extends Gain{
	constructor(private food:number){
		super();
	}
	on(island:islands.Island):void{
		island.food+=this.food;
	}
}
export class GainMoney extends Gain{
	constructor(private money:number){
		super();
	}
	on(island:islands.Island):void{
		island.money+=this.money;
	}
}
