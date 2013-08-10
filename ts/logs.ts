import lands=module("../coffee/lands");
import islands=module("islands");


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
	public source:{[index:string]:string;};
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
	public source={
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
	public source={
		ja:"地震",
		en:"the earthquake",
	};
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
