//ターン処理
import lands=require('../coffee/lands');
import islands=require('./islands');
import islandeffects=require('./islandeffects');

//イテレータ
export interface IslandsDict{
    [id:string]:islands.Island;
}
export class IslandsIterator{
    constructor(private islandsdata:IslandsDict){
    }
    iterate(callback:(i:islands.Island)=>void):void{
        for(var key in this.islandsdata){
            callback(this.islandsdata[key]);
        }
    }
}
//ターン処理オブジェクト
export class TurnProcess{
    main(it:IslandsIterator):void{
        //ターン処理

        //まず全部集計してもらう
        this.estimate(it);
        //集計にしたがって収支処理をする
        this.income(it);
    }
    private estimate(it:IslandsIterator):void{
        it.iterate((island:islands.Island)=>{
            //状態を得る
            var status=island.status;
            status.reset();
            this.iterateLands(island.land,(hex)=>{
                hex.estimate(status);
            });
        });
    }
    private income(it:IslandsIterator):void{
        it.iterate((island:islands.Island)=>{
            //収入処理
            var status=island.status;
            var gainfood:number=0, gainmoney:number=0;
            //労働人口10単位=食料10単位=資金1単位
            if(status.population>status.farm){
                gainfood=status.farm;
                //余るので工場や採掘場で働いてもらう
                //余剰人口と職場規模のうち小さい方のぶんだけ収入あり
                gainmoney=Math.floor(Math.min(status.population-status.farm, status.factory+status.mountain)/10);

            }else{
                //人口に余裕がない（全員野良仕事）
                gainfood=status.population;
            }
            //収入処理
            if(gainfood>0){
                (new islandeffects.GainFood(gainfood)).on(island);
            }
            if(gainmoney>0){
                (new islandeffects.GainMoney(gainmoney)).on(island);
            }
        });
    }
    //地形を全部
    private iterateLands(landarea:islands.LandArea,callback:(hex:lands.Hex)=>void):void{
        var poss:islands.Position[]=landarea.randomPositions();
        for(var i=0,l=poss.length;i<l;i++){
            callback(landarea.get(poss[i]));
        }
    }
}
