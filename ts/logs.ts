import lands=require("../coffee/lands");
import islands=require("islands");

//多言語対応
export interface LocalizedObject{
    [index:string]:string;
}

// ログ
export class Log{
	//protected
	public island:islands.Island;
	public land:islands.LandArea;
	public lang:string="ja";
	setParam(island:islands.Island):void{
		this.island=island, this.land=island.land;
	}

	html():string{
		return "";
	}
	// HTML出力用
	disaster(name:string):string{
		return html.disaster(name);
	}
	keyword(word:string):string{
		return html.keyword(word);
	}
	islandname():string{
		return html.position(this.island.getMetadata().name);
	}
	position(pos:islands.Position):string{
		return html.position(this.island.getMetadata().name+pos.toString());
	}
	hex(hex:lands.Hex):string{
		return html.hex(hex,this.lang);
	}
}
// 災害ログ
export class DisasterLog extends Log{
}

// とりあえず壊滅する
export class Damage extends DisasterLog{
	//protected
	public source:LocalizedObject;
	constructor(private pos:islands.Position,private dhex:lands.Hex){
		super();
	}
	html():string{
		var source=this.source[this.lang];	//原因
		switch(this.lang){
			case "en":
				return "The "+this.hex(this.dhex)+" at "+this.position(this.pos)+" was destroyed"+ (source ? " due to "+this.disaster(source) : "")+".";
			default:
				return this.position(this.pos)+"地点の"+this.hex(this.dhex)+"は"+(source ? this.disaster(source)+"により" : "")+"壊滅しました。";
		}
	}
}

// 火山
export class EruptionCrator extends DisasterLog{
	constructor(private pos:islands.Position){
		super();
	}
	html():string{
		switch(this.lang){
			case "en":
				return this.disaster("An eruption")+" occurred at "+this.position(this.pos)+" and became "+this.keyword("a mountain")+".";
			default:
				return this.position(this.pos)+"地点で"+this.disaster("火山が噴火")+"、"+this.keyword("山")+"が出来ました。";
		}
	}
}
export class EruptionSea extends DisasterLog{
	constructor(private pos:islands.Position,private dhex:lands.Hex){
		super();
	}
	html():string{
		switch(this.lang){
			case "en":
				return "The "+this.hex(this.dhex)+" at "+this.position(this.pos)+" rose due to "+this.disaster("the eruption")+" and became a shoal.";
			default:
				return this.position(this.pos)+"地点の"+this.hex(this.dhex)+"は"+this.disaster("噴火")+"の影響で海底が隆起、浅瀬になりました。";
		}
	}
}
export class EruptionShoal extends DisasterLog{
	constructor(private pos:islands.Position,private dhex:lands.Hex){
		super();
	}
	html():string{
		switch(this.lang){
			case "en":
				return "The "+this.hex(this.dhex)+" at "+this.position(this.pos)+" rose to be a land due to "+this.disaster("the eruption")+".";
			default:
				return this.position(this.pos)+"の"+this.hex(this.dhex)+"は"+this.disaster("噴火")+"の影響で陸地になりました。";
		}
	}
}
export class EruptionDamage extends Damage{
	public source=<LocalizedObject>{
		ja:"噴火",
		en:"the eruption",
	};
}
//地震
export class EarthquakeOccurrence extends DisasterLog{
	html():string{
		switch(this.lang){
			case "en":
				return this.disaster("A major earthquake")+" struck "+this.islandname()+"!!";
			default:
				return this.islandname()+"で大規模な"+this.disaster("地震")+"が発生！！";
		}
	}

}
export class EarthquakeDamage extends Damage{
	public source=<LocalizedObject>{
		ja:"地震",
		en:"the earthquake",
	};
}
//津波
export class TsunamiOccurrence extends DisasterLog{
	html():string{
		switch(this.lang){
			case "en":
				return this.disaster("A tsunami")+" struck "+this.islandname()+"!!";
			default:
				return this.islandname()+"付近で"+this.disaster("津波")+"発生！！";
		}
	}

}
export class TsunamiDamage extends DisasterLog{
	constructor(private pos:islands.Position,private dhex:lands.Hex){
		super();
	}
	html():string{
		switch(this.lang){
			case "en":
				return "The "+this.hex(this.dhex)+" at "+this.position(this.pos)+" was destroyed due to "+this.disaster("the tsunami")+".";
			default:
				return this.position(this.pos)+"の"+this.hex(this.dhex)+"は"+this.disaster("津波")+"により崩壊しました。";
		}
	}
}
//台風
export class TyphoonOccurrence extends DisasterLog{
	html():string{
		switch(this.lang){
			case "en":
				return this.disaster("A typhoon")+" struck "+this.islandname()+"!!";
			default:
				return this.islandname()+"に"+this.disaster("台風")+"上陸！！";
		}
	}

}
export class TyphoonDamage extends DisasterLog{
	constructor(private pos:islands.Position,private dhex:lands.Hex){
		super();
	}
	html():string{
		switch(this.lang){
			case "en":
				return "The "+this.hex(this.dhex)+" at "+this.position(this.pos)+" was blown off by "+this.disaster("the typhoon")+".";
			default:
				return this.position(this.pos)+"の"+this.hex(this.dhex)+"は"+this.disaster("台風")+"で吹き飛ばされました。";
		}
	}
}

//広域被害
//海に沈む
export class WideDamageSea extends DisasterLog{
	constructor(private pos:islands.Position,private dhex:lands.Hex){
		super();
	}
	html():string{
		switch(this.lang){
			case "en":
				return "The "+this.hex(this.dhex)+" at "+this.position(this.pos)+" was submerged.";
			default:
				return this.position(this.pos)+"の"+this.hex(this.dhex)+"は"+this.keyword("水没")+"しました。";
		}
	}
}

//海の施設がやられる
export class WideDamageSea2 extends DisasterLog{
	constructor(private pos:islands.Position,private dhex:lands.Hex){
		super();
	}
	html():string{
		switch(this.lang){
			case "en":
				return "The "+this.hex(this.dhex)+" at "+this.position(this.pos)+" vanished.";
			default:
				return this.position(this.pos)+"の"+this.hex(this.dhex)+"は跡形もなくなりました。";
		}
	}
}
//荒地になる
export class WideDamageWaste extends DisasterLog{
	constructor(private pos:islands.Position,private dhex:lands.Hex){
		super();
	}
	html():string{
		switch(this.lang){
			case "en":
				return "The "+this.hex(this.dhex)+" at "+this.position(this.pos)+" was ruined outright.";
			default:
				return this.position(this.pos)+"の"+this.hex(this.dhex)+"は一瞬にして"+this.keyword("荒地")+"と化しました。";
		}
	}
}
export class HugeMeteorite extends DisasterLog{
	constructor(private pos:islands.Position){
		super();
	}
	html():string{
		switch(this.lang){
			case "en":
				return this.disaster("A huge meteorite")+" falled at "+this.position(this.pos)+"!!";
			default:
				return this.position(this.pos)+"地点で"+this.disaster("巨大隕石")+"が落下！！";
		}
	}
}
//隕石
export class MeteoriteNormal extends DisasterLog{
	constructor(private pos:islands.Position,private dhex:lands.Hex){
		super();
	}
	html():string{
		switch(this.lang){
			case "en":
				return this.disaster("A meteorite")+" fell to the "+this.hex(this.dhex)+" at "+this.position(this.pos)+" and submerged it.";
			default:
				return this.position(this.pos)+"地点の"+this.hex(this.dhex)+"に"+this.disaster("隕石")+"が落下、一帯が水没しました。";
		}
	}
}
export class MeteoriteMountain extends DisasterLog{
	constructor(private pos:islands.Position,private dhex:lands.Hex){
		super();
	}
	html():string{
		switch(this.lang){
			case "en":
				return this.disaster("A meteorite")+" fell to the "+this.hex(this.dhex)+" at "+this.position(this.pos)+" and the "+this.hex(this.dhex)+" vanished.";
			default:
				return this.position(this.pos)+"地点の"+this.hex(this.dhex)+"に"+this.disaster("隕石")+"が落下、"+this.hex(this.dhex)+"は消し飛びました。";
		}
	}
}
//水中施設を破壊
export class MeteoriteUnderSea extends DisasterLog{
	constructor(private pos:islands.Position,private dhex:lands.Hex){
		super();
	}
	html():string{
		switch(this.lang){
			case "en":
				return this.disaster("A meteorite")+" fell to the "+this.hex(this.dhex)+" at "+this.position(this.pos)+" and the "+this.hex(this.dhex)+" broke down.";
			default:
				return this.position(this.pos)+"地点の"+this.hex(this.dhex)+"に"+this.disaster("隕石")+"が落下、"+this.hex(this.dhex)+"は崩壊しました。";
		}
	}
}
//浅瀬を破壊
export class MeteoriteShoal extends DisasterLog{
	constructor(private pos:islands.Position,private dhex:lands.Hex){
		super();
	}
	html():string{
		switch(this.lang){
			case "en":
				return this.disaster("A meteorite")+" fell to the "+this.hex(this.dhex)+" at "+this.position(this.pos)+" and the area was deepened.";
			default:
				return this.position(this.pos)+"地点の"+this.hex(this.dhex)+"に"+this.disaster("隕石")+"が落下、海底がえぐられました。";
		}
	}
}
//海ポチャ
export class MeteoriteSea extends DisasterLog{
	constructor(private pos:islands.Position,private dhex:lands.Hex){
		super();
	}
	html():string{
		switch(this.lang){
			case "en":
				return this.disaster("A meteorite")+" fell to the "+this.hex(this.dhex)+" at "+this.position(this.pos)+".";
			default:
				return this.position(this.pos)+"地点の"+this.hex(this.dhex)+"に"+this.disaster("隕石")+"が落下しました。";
		}
	}
}
//地盤沈下
export class SubsidenceOccurrence extends DisasterLog{
	html():string{
		switch(this.lang){
			case "en":
				return this.islandname()+" started to "+this.disaster("sink")+"!!";
			default:
				return this.islandname()+"で"+this.disaster("地盤沈下")+"が発生しました！！";
		}
	}
}
export class SubsideLand extends DisasterLog{
	constructor(private pos:islands.Position,private dhex:lands.Hex){
		super();
	}
	html():string{
		switch(this.lang){
			case "en":
				return "The "+this.hex(this.dhex)+" at "+this.position(this.pos)+" sunk into the sea.";
			default:
				return this.position(this.pos)+"の"+this.hex(this.dhex)+"は海の中へ沈みました。";
		}
	}
}

//=== HTML funcs
module html{
	export function position(posstr:string):string{
		return "<b class='position'>"+posstr+"</b>";
	}
	export function disaster(name:string):string{
		return "<b class='disaster'>"+name+"</b>";
	}
	export function keyword(name:string):string{
		return "<b>"+name+"</b>";
	}
	export function hex(hex:lands.Hex,lang:string):string{
		return "<b class='hex'>"+hex.getName(lang)+"</b>";
	}
}
