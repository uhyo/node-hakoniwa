declare var require:(path:string)=>any;
var gameconfig=require('../coffee/gameconfig');

import islands=module("./islands");
import effects=module("../coffee/effects");
import util=module("./util");

export class IslandEffect{
	constructor(){
	}
	on(island:islands.Island):void{
	}
}

//------------------------------------
//島が何かを得たりする系
export class Gain extends IslandEffect{
}
//食料を得る
export class GainFood extends Gain{
	constructor(private food:number){
		super();
	}
	on(island:islands.Island):void{
		island.food+=this.food;
	}
}
//資金を得る
export class GainMoney extends Gain{
	constructor(private money:number){
		super();
	}
	on(island:islands.Island):void{
		island.money+=this.money;
	}
}
//------------------------------------
//災害
export class Disaster extends IslandEffect{
}
//噴火
export class Eruption extends Disaster{
	constructor(private pos:islands.Position){
		super();
	}
	on(island:islands.Island):void{
		var land=island.land;
		//中心の被害
		(new effects.Damage("eruption-crator")).on(land.get(this.pos));
		//周辺の被害
		var edge=new effects.Damage("eruption-edge");
		land.ringAround(1).fromEach(this.pos).forEach((pos)=>{
			edge.on(land.get(pos));
		});
	}
}
export class Eartuquake extends Disaster{
	damageprob:number=gameconfig.disaster.earthquake.damageProb;

	on(island:islands.Island):void{
		//各ヘックスについて
		var rb=this.damageprob/1000, land=island.land;
		land.randomPositions().forEach((pos)=>{
			if(util.prob(rb)){
				//地震被害判定あり
				(new effects.Damage("earthquake")).on(land.get(pos));
			}
		});
	}
}
