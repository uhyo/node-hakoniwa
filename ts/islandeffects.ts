declare var require:(path:string)=>any;
var gameconfig=require('../coffee/gameconfig');

import islands=module("./islands");
import effects=module("../coffee/effects");
import util=module("./util");
import logs=module("./logs");

export class IslandEffect{
	private logs:logs.Log[];
	constructor(){
		this.logs=[];
	}
	on(island:islands.Island):void{
		//ログがあったら適用するぞ!
		this.logs.forEach((log)=>{
			island.addLog(log);
		});
	}
	//エフェクトに追加
	appendLog(log:logs.Log):void{
		this.logs.push(log);
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
		super.on(island);
		island.food+=this.food;
	}
}
//資金を得る
export class GainMoney extends Gain{
	constructor(private money:number){
		super();
	}
	on(island:islands.Island):void{
		super.on(island);
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
		super.on(island);
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
//地震
export class Earthquake extends Disaster{
	damageprob:number=gameconfig.disaster.earthquake.damageProb;

	on(island:islands.Island):void{
		super.on(island);
		//発生ログ
		island.addLog(new logs.EarthquakeOccurrence());
		//各ヘックスについて
		var rb=this.damageprob/1000, land=island.land;
		var damage=new effects.Damage("earthquake");
		land.randomPositions().forEach((pos)=>{
			if(util.prob(rb)){
				//地震被害判定あり
				damage.on(land.get(pos));
			}
		});
	}
}
//津波
export class Tsunami extends Disaster{
	damagedice:number=gameconfig.disaster.tsunami.damageDice;

	on(island:islands.Island):void{
		super.on(island);
		//発生ログ
		island.addLog(new logs.TsunamiOccurrence());
		//各ヘックスについて
		var land=island.land;
		var damage=new effects.Damage("tsunami");
		land.randomPositions().forEach((pos)=>{
			//周囲の海の数を数えて1d12以下で崩壊
			var seas=land.countAround(pos,1,(hex)=>{
				return hex.isSea();
			});
			if(util.probb(seas,this.damagedice)){
				damage.on(land.get(pos));
			}
		});
	}
}
