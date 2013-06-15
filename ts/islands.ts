declare function require(path:string):any;
var gameconfig=require("../coffee/gameconfig");
import lands=module("../coffee/lands");
import util=module("./util");
//座標オブジェクト
export class Position{
	constructor(public x:number,public y:number){
	}
	toString():string{
		return "("+this.x+", "+this.y+")";
	}
}

export class Island{
	public land:LandArea;
	constructor(){
		this.land=new LandArea(gameconfig.island.landwidth, gameconfig.island.landheight);
	}
	html(owner:bool):string{
		return this.land.html(owner);
	}
}

export class LandArea{
	//ルートキャッシュ
	static routes:RouteList[]=[];	//routes[n]: 距離n以下のルートの一覧
	static ringRoutes:RouteList[]=[];	//距離ちょうどn
	private land:lands.Hex[][];
	private island:Island;
	constructor(public width:number,public height:number,island?:Island){
		if(island){
			this.island=island;
		}
		//nullで初期化
		this.land=[];
		for(var y=0;y<height;y++){
			this.land[y]=[];
		}
	}
	set(x:number,y:number,hex:lands.Hex):void;
	set(pos:Position, hex:lands.Hex):void;
	set(arg1:any,arg2:any,arg3?:any):void{
		var x:number,y:number, pos:Position,hex:lands.Hex;
		if(arg3!=null){
			x=arg1, y=arg2, hex=arg3;
			pos=new Position(x,y);
		}else{
			pos=arg1, hex=arg2;
			x=pos.x, y=pos.y;
		}
		hex.setPosition(pos);
		hex.setLand(this);
		if(this.island){
			hex.setIsland(this.island);
		}
		if(!this.inArea(pos)){
			//セットできない
			return;
		}
		this.land[y][x]=hex;
	}
	get(x:number,y:number):lands.Hex;
	get(pos:Position):lands.Hex;
	get(arg1:any,arg2?:any):lands.Hex{
		var x:number, y:number;
		if(arg2!=null){
			x=arg1, y=arg2;
		}else{
			x=arg1.x, y=arg1.y;
		}
		return this.land[y][x];
	}
	html(owner:bool):string{
		return this.land.map(function(row){
			return row.map(function(hex){
				return hex.html(owner);
			}).join("");
		}).map(function(x:string,i:number){
			return i%2===0 ?
				"<div><img src='"+gameconfig.html.imagedir+"space.gif'>"+x+"</div>" :
					"<div>"+x+"<img src='"+gameconfig.html.imagedir+"space.gif'></div>";
		}).join("\n");
	}
	//判定
	inArea(pos:Position):bool{
		return 0<=pos.x && pos.x<this.width && 0<=pos.y && pos.y<this.height;
	}
	//カウントするぞーーーーーーーー
	listAround(distance:number):RouteList{
		//まずルートを生成
		//そのHexの情報を全部もらう
		var smallRoutes:RouteList;
		if(LandArea.routes[distance]){
			return LandArea.routes[distance];
		}else{
			//ない場合は生成する
			if(distance<1){
				//空の移動（移動しない）
				return new RouteList([new Route([])]);
			}else{
				smallRoutes=this.listAround(distance-1);
				var obj=smallRoutes.makeFlags();	//すでに到達したところは記録
				var zero=new Position(0,0);
				var orig=smallRoutes.getRoutes(), results=orig.concat([]);
				//1つ進む
				orig.forEach((route:Route)=>{
					for(var i=0;i<Step.directionNumber;i++){
						var newroute=route.append(new Step(i));
						var str=newroute.from(zero).toString();
						if(!obj[str]){
							//新しい
							results.push(newroute);
						}
						obj[str]=true;
					}
				});
				var result=new RouteList(results);
				LandArea.routes[distance]=result;
				return result;
			}
		}
	}
	ringAround(distance:number):RouteList{
		if(LandArea.ringRoutes[distance]){
			return LandArea.ringRoutes[distance];
		}else{
			//ない場合は生成する
			if(distance<=1){
				return this.listAround(distance);
			}else{
				var soto=this.listAround(distance), naka=this.listAround(distance-1);
				return soto.sub(naka);
			}
		}
	}
	//周囲nHex以内の数をカウント
	numberAround(distance:number):number{
		return this.listAround(distance).getRoutes().length;
	}
	countAround(x:number,y:number,distance:number,constr:new()=>lands.Hex):number;
	countAround(pos:Position,distance:number,constr:new()=>lands.Hex):number;
	countAround(x:number,y:number,distance:number,func:(hex:lands.Hex)=>bool):number;
	countAround(pos:Position,distance:number,func:(hex:lands.Hex)=>bool):number;
	countAround(arg1:any,arg2:any,arg3:any,arg4?:any):number{
		var pos:Position, distance:number, cond:any;
		if(arg1 instanceof Position){
			pos=arg1, distance=arg2, cond=arg3;
		}else{
			pos=new Position(arg1,arg2);
			distance=arg3, cond=arg4;
		}
		// もっときれいな書き方は?
		if(cond.prototype instanceof lands.Hex || cond===lands.Hex){
			cond=((con2:any)=>{
				return (hex:lands.Hex)=>{
					return hex instanceof con2;
				};
			})(cond);
		}
		var routes=this.listAround(distance);
		//数えるぞ!
		return routes.fromEach(pos).filter((pos)=>{
			var hex:lands.Hex = this.inArea(pos) ? this.get(pos) : ((hex:lands.Hex)=>{
				hex.setPosition(pos);
				return hex;
			})(new (<any>lands).Sea());
			return cond(hex);
		}).length;
	}
}
export function makeNewIsland():Island{
	var result=new Island;
	var land=result.land;
	var las=<any>lands;	//具体的な地形(dirty)
	var height=result.land.height, width=result.land.width;
	//真ん中
	var cx=Math.floor(width/2), cy=Math.floor(height/2);
	//海に初期化, 中央は荒地
	for(var y=0;y<height;y++){
		for(var x=0;x<width;x++){
			if(cy-1<=y && y<=cy+2 && cx-1<=x && x<=cx+2){
				land.set(x,y,new las.Waste);
			}else{
				land.set(x,y,new las.Sea);
			}
		}
	}
	//8x8で陸地を増殖する
	for(var i=0;i<120;i++){
		var x=util.random(8)+cx-3, y=util.random(8)+cy-3;
		var nonsea=land.countAround(x,y,1,(hex)=>!hex.isSea());
		//陸地があれば・・・
		if(nonsea>0){
			var lan=land.get(x,y);
			if(lan.is(las.Waste)){
				land.set(x,y,new las.Plains);
			}else if(lan.is(las.Shoal)){
					land.set(x,y,new las.Waste);
			}else if(lan.is(las.Sea)){
				land.set(x,y,new las.Shoal);
			}
		}
	}
	//森を作る
	var count=0;
	while(count<4){
		var x=util.random(4)+cx-1, y=util.random(4)+cy-1;

		if(!land.get(x,y).is(las.Forest)){
			var forest=new las.Forest;
			forest.value=5;	//木の本数
			land.set(x,y,forest);
			count++;
		}
	}
	//町を作る
	count=0;
	while(count<2){
		var x=util.random(4)+cx-1, y=util.random(4)+cy-1;

		var lan=land.get(x,y);
		if(!lan.is(las.Forest) && !lan.is(las.Town)){
			var town=new las.Town;
			town.population=5;	//人口
			land.set(x,y,town);
			count++;
		}
	}
	//山を作る
	count=0;
	while(count<1){
		var x=util.random(4)+cx-1, y=util.random(4)+cy-1;

		var lan=land.get(x,y);
		if(!lan.is(las.Forest) && !lan.is(las.Town)){
			land.set(x,y,new las.Mountain);
			count++;
		}
	}
	return result;
}
//-----------------------------
export interface RouteFlags{
	[index:string]:bool;	//(0,0)から行き先のPosition#toString()したところにtrue
}
//移動を定義する
export class Route{
	private length:number;
	//paths:移動方向を示す数値で指定
	constructor(private paths:Step[]){
	}
	//移動する
	from(pos:Position):Position{
		this.paths.forEach((step)=>{
			pos=step.from(pos);
		});
		return pos;
	}
	//1つつけたす
	append(step:Step):Route{
		return new Route(this.paths.concat(step));
	}
	//移動先全てについて
	toString():string{
		return "Route["+this.paths.map((path:Step)=>path.toString()).join(",")+"]";
	}
}
//いろんな経路
export class RouteList{
	constructor(private routes:Route[]){
	}
	getRoutes():Route[]{
		return this.routes.concat([]);
	}
	fromEach(pos:Position):Position[]{
		return this.routes.map((route)=>route.from(pos));
	}
	//フラグオブジェクトを作って返す
	makeFlags():RouteFlags{
		var obj=<RouteFlags>{};
		var zero=new Position(0,0);
		this.routes.forEach((route)=>{
			obj[route.from(zero).toString()]=true;
		});
		return obj;
	}
	push(route:Route):void{
		this.routes.push(route);
	}
	add(list:RouteList):RouteList{
		var newlist:Route[]=this.routes.concat([]);
		var obj=this.makeFlags();
		//新しいのだけ追加
		var zero=new Position(0,0);
		list.getRoutes().forEach((route)=>{
			if(!obj[route.from(zero).toString()]){
				newlist.push(route);
			}
		});
		return new RouteList(newlist);
	}
	sub(list:RouteList):RouteList{
		var newlist:Route[]=[];
		var obj=list.makeFlags();
		//listにないのだけ返す
		var zero=new Position(0,0);
		this.routes.forEach((route)=>{
			if(!obj[route.from(zero).toString()]){
				newlist.push(route);
			}
		});
		return new RouteList(newlist);
	}
	toString():string{
		return "["+this.routes.toString()+"]";
	}
}
//1Hexの移動
export class Step{
	constructor(private direction:number){
		//方向は整数で
	}
	from(pos:Position):Position{
		var func=Step.funcs[this.direction];
		if(!func)throw new Error("Invalid direction");

		var arr=func(pos.x,pos.y);
		return new Position(arr[0],arr[1]);
	}
	toString():string{
		return "Step("+this.direction+")";
	}
	//各方向の移動を定義(結果を[x,y]で返す)
	static directionNumber:number=6;	//方向がいくつあるか(funcs.lengthと一致)
	static funcs:Function[]=[
		//0:左上
		(x,y)=>{
			if(y%2===0){
				return [x,y-1];
			}else{
				return [x-1,y-1];
			}
		},
		//1:右上
		(x,y)=>{
			if(y%2===0){
				return [x+1,y-1];
			}else{
				return [x,y-1];
			}
		},
		//2:右
		(x,y)=>{
			return [x+1,y];
		},
		//3:右下
		(x,y)=>{
			if(y%2===0){
				return [x+1,y+1];
			}else{
				return [x,y+1];
			}
		},
		//4:左下
		(x,y)=>{
			if(y%2===0){
				return [x,y+1];
			}else{
				return [x-1,y+1];
			}
		},
		//5:左
		(x,y)=>{
			return [x-1,y];
		},
	];
}
