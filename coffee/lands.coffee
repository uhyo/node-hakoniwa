gameconfig=require './gameconfig'
islands=require '../ts/islands'
effects=require './effects'
islandeffects=require '../ts/islandeffects'
util=require '../ts/util'
logs=require '../ts/logs'

#多重継承用の新しいクラスを用意する（前優先）
multi=(consts...)->
    # 順に継承したクラスを作るぞ!
    result=consts.pop()   #consts:0だったらエラーかも
    for con in consts by -1
        prot=result.prototype
        prop=Object.create prot
        prop.constructor=result
        result=((con)->`function ctor(){
            //super
            ctor.__super__.constructor.apply(this,arguments);
            //自分
            con.apply(this,arguments);
        }`)(con)
        result.__super__=prot
        result.prototype=prop

        # 詰め込む
        for key in Object.getOwnPropertyNames con.prototype
            desc=Object.getOwnPropertyDescriptor con.prototype,key
            if desc.configurable
                if "function"==typeof desc.value
                    # multiのは_superを渡さないといけない
                    desc.value=((name,func,sup)->
                        ->
                            args=arguments
                            _super= =>
                                if arguments.length==0
                                    sup[key].apply this,args
                                else
                                    sup[key].apply this,arguments
                            func.call this, _super,args...
                    )(key,desc.value,prot)
                Object.defineProperty prop,key,desc
        prop.constructor=result
    result

class Hex
    # mixin用
    ###
    @mixin:(classes...)->
        # @はコンストラクタ
        for k in classes by -1
            kp=k.prototype
            for key in Object.getOwnPropertyNames kp
                # _superをわたすやつがある
                if "function"===typeof kp[key]
                    @::[key]=((func)=>
                        ->
                            args=arguments
                            _super=->
                                if arguments.length==0


                    )(kp[key])
    ###

    constructor:->
        @position=null
        @land=null      #LandArea
        @island=null    # nullかもしれんから・・・

    name:
        ja:"?"
        en:"?"
    setPosition:(x,y)->
        if x instanceof islands.Position
            @position=x
        else
            @position=new islands.Position x,y
    setLand:(land)->@land=land
    setIsland:(island)->@island=island

    html:(lang,owner)->
        # owner:bool オーナー視点かどうか
        # HTMLを生成
        @rawhtml {
            src:"null.gif"
            title:"???"
            desc:""
        }
    rawhtml:(param)->
        # HTMLのtemp
        "<img class='hex' src='#{gameconfig.html.imagedir}#{param.src}'>"

    # 地形名を取得（デフォルトは名前）
    getName:(lang="ja")->@name[lang]

    # ターン処理
    turnProcess:->
    # 集計処理
    estimate:(status)->
    # 変化する
    change:(hex,optfunc)->
        eff=new effects.ChangeHex hex
        if optfunc?
            optfunc eff
        eff.on this
    # ダメージ処理
    damage:(type)-> # タイプ:文字列
        # 一般的な処理を記述
        switch type
            when "eruption-crator"
                # 火山ができる
                @change lands.Mountain,(e)=>
                    e.appendLog new logs.EruptionCrator @position
            when "eruption-edge"
                # 荒地になる
                @change lands.Waste,(e)=>
                    e.appendLog new logs.EruptionDamage @position,@clone()
            when "widedamage-crator"
                # 海に沈む
                @change lands.Sea,(e)=>
                    e.appendLog new logs.WideDamageSea @position,@clone()
            when "widedamage-edge1"
                # 浅瀬になる
                @change lands.Shoal,(e)=>
                    e.appendLog new logs.WideDamageSea @position,@clone()
            when "widedamage-edge2"
                # 荒地になる
                @change lands.Waste,(e)=>
                    e.appendLog new logs.WideDamageWaste @position,@clone()
            when "meteorite"
                # ふつうに沈む
                @change lands.Sea,(e)=>
                    e.appendLog new logs.MeteoriteNormal @position,@clone()
            when "subside"
                # だいたいは浅瀬になる
                @change lands.Shoal,(e)=>
                    e.appendLog new logs.SubsideLand @position,@clone()

    # 地形フラグ
    isLand:->true   # 陸かどうか
    isSea:->false   # 海系地形
    isTown:->false  # 街系地形（人口あり）かどうか
    isBase:->false  # ミサイル基地かどうか
    isMountain:->false # 山かどうか
    isForest:->false # 森かどうか
    # 一致 コンストラクタをわたして
    is:(con)->this instanceof con
    # clone:自分をコピー
    clone:->
        result=Object.create @constructor.prototype
        for key in Object.getOwnPropertyNames this
            desc=Object.getOwnPropertyDescriptor this,key
            Object.defineProperty result,key,desc
        result

# 基本的地形
# 成長する地形
class Growable extends Hex
    grow:()->
    shrink:()->
# 居住地形
class Ecumene extends Growable
    constructor:->
        # 人口
        @population=1
    maxPopulation:200       # 最大人口
    borderPopulation:100    # 増加量変わる区切り
    growrate:10
    growrate2:0
    shrinkrate:30
    grow:()->
        if @population<@borderPopulation
            # よく成長する
            @population+=util.random(@growrate)+1
            if @population>@borderPopulation
                @population=@borderPopulation

        else if @growrate2>0
            @population+=util.random(@growrate2)+1
        if @population>@maxPopulation
            @population=@maxPopulation
    shrink:()->
        @population-=util.random(@shrinkrate)+1
        if @population<=0
            (new effects.ChangeHex(lands.Plains)).on this
    turnProcess:()->
        @grow()
    estimate:(status)->
        # 人口をカウントする
        status.population+=@population

#=================--- mixin用
# ミサイル基地
class Base
    isBase:->true
    maxExp:0
    expToLevel:(_super,exp)->
        # expからレベルを算出
        i=@expTable.length
        while i>=1
            if exp>=@expTable[i-1]
                # このレベルだ
                return i
            i-=1
        return 1
# 災害対応系
class EarthquakeVulnerable
    damage:(_super,type)->
        if type=='earthquake'
            @change lands.Waste,(e)=>
                e.appendLog new logs.EarthquakeDamage @position,@clone()
        else
            _super()
class TsunamiVulnerable
    damage:(_super,type)->
        if type=='tsunami'
            @change lands.Waste,(e)=>
                e.appendLog new logs.TsunamiDamage @position,@clone()
        else
            _super()
class TyphoonVulnerable
    damage:(_super,type)->
        if type=='typhoon'
            @change lands.Plains,(e)=>
                e.appendLog new logs.TyphoonDamage @position,@clone()
        else
            _super()


lands=
    Hex:Hex
    Base:Base
    Growable:Growable
    Ecumene:Ecumene

    Sea:class Sea extends Hex
        name:
            ja:"海"
            en:"sea"
        damage:(type)->
            # 多くの場合ダメージを受けない
            switch type
                when "eruption-crator"
                    # 火山の噴火は仕方ない
                    super
                when "eruption-edge"
                    # 周囲1Hex
                    @change lands.Shoal,(e)=>
                        e.appendLog new logs.EruptionSea @position,@clone()
                when "meteorite"
                    # ログだけだす
                    @island.addLog new logs.MeteoriteSea @position,@clone()
        isLand:->false
        isSea:->true
        html:(lang)->
            @rawhtml {
                src:"land0.gif"
                title:@getName lang
                desc:""
            }
    Shoal:class Shoal extends Hex
        constructor:->
            super
        name:
            ja:"浅瀬"
            en:"shoal"
        damage:(type)->
            # 浅瀬もダメージを受けない
            switch type
                when "eruption-crator"
                    super
                when "eruption-edge"
                    @change lands.Waste,(e)=>
                        e.appendLog new logs.EruptionShoal @position,@clone()
                when "widedamage-crator","widedamage-edge1","subside"
                    # 音もなく沈む
                    @change lands.Sea
                when "meteorite"
                    #  えぐられる
                    @change lands.Sea,(e)=>
                        e.appendLog new logs.MeteoriteShoal @position,@clone()
        isLand:->false
        isSea:->true
        html:(lang)->
            @rawhtml {
                src:"land14.gif"
                title:@getName lang
                desc:""
            }
    # 荒地
    Waste:class extends Hex
        constructor:->
            super
            @type=0 # タイプ:0=通常 1=ミサイル跡
        name:
            ja:"荒地"
            en:"waste lang"
        html:(lang)->
            @rawhtml {
                src: if @type==0 then "land1.gif" else "land13.gif"
                title:@getName lang
                desc:""
            }
    # 平地
    Plains:class extends Growable
        name:
            ja:"平地"
            en:"plains"
        grow:->
            # 村ができる
            (new effects.ChangeHex (->
                town=new lands.Town
                town.population=1
                town
            )).on this
        turnProcess:->
            # 周囲に農場か村があったら一定確率で成長
            unless @land?
                return
            if @growpop()
                if @land.countAround(@position,1,(hex)->
                    hex instanceof Ecumene || hex.is lands.Farm
                ) > 0
                    @grow()
        # 成長判定をする
        growpop:->util.random(5)==0
                    

        html:(lang)->
            @rawhtml {
                src:"land2.gif"
                title:@getName lang
                desc:""
            }
    # 街系地形
    Town:class extends multi TsunamiVulnerable,EarthquakeVulnerable,Ecumene
        name:"街系地形"
        damage:(type)->
            if type=='earthquake' && @population<100
                # 町以下の場合は被害うけない
            else
                super
        getName:(lang)->
            if @population<30
                switch lang
                    when "ja"
                        "村"
                    when "en"
                        "village"
            else if @population<100
                switch lang
                    when "ja"
                        "町"
                    when "en"
                        "town"
            else
                switch lang
                    when "ja"
                        "都市"
                    when "en"
                        "city"
        html:(lang)->
            @rawhtml {
                src: (if @population<30
                    "land3.gif"
                else if @population<100
                    "land4.gif"
                else
                    "land5.gif"
                )
                title:@getName lang
                desc:"#{@population}#{gameconfig.unit.population}"
            }
    # 森
    Forest:class extends Growable
        constructor:->
            super
            @value=1
        name:
            ja:"森"
            en:"forest"
        maxValue:200
        isForest:->true
        grow:->
            if @value<@maxValue
                @value+=1
        html:(lang,owner)->
            @rawhtml {
                src:"land6.gif"
                title:@getName lang
                desc: if owner then "#{@value}#{gameconfig.unit.tree}" else ""
            }
        turnProcess:->@grow()
    # 農場
    Farm:class extends multi TyphoonVulnerable,TsunamiVulnerable,Hex
        constructor:->
            super
            @quantity=0
        name:
            ja:"農場"
            en:"farm"
        html:(lang)->
            @rawhtml {
                src:"land7.gif"
                title:@getName lang
                desc:"#{@quantity}#{gameconfig.unit.population}規模"
            }
        estimate:(status)->
            status.farm+=@quantity
    # 工場
    Factory:class extends multi TsunamiVulnerable,EarthquakeVulnerable,Hex
        constructor:->
            super
            @quantity=0
        name:
            ja:"工場"
            en:"factory"
        damage:(type)->
            super
        html:(lang)->
            @rawhtml {
                src:"land8.gif"
                title:@getName lang
                desc:"#{@quantity}#{gameconfig.unit.population}規模"
            }
        estimate:(status)->
            status.factory+=@quantity
    # ミサイル基地
    LandBase:class extends multi TsunamiVulnerable,Base,Hex
        constructor:->
            super
            @exp=0
        expTable:[20,60,120,200]
        name:
            ja:"ミサイル基地"
            en:"missile base"
        html:(lang,owner)->
            if gameconfig.base.hide && !owner
                @rawhtml {
                    src:"land6.gif"
                    title:@getName lang
                    desc:""
                }
            else
                @rawhtml {
                    src:"land9.gif"
                    title:@getName lang
                    desc:"レベル#{@expToLevel @exp}"
                }
    # 防衛施設
    Defence:class Defence extends multi TsunamiVulnerable,Hex
        name:
            ja:"防衛施設"
            en:"defense base"
        html:(lang)->
            @rawhtml {
                src:"land10.gif"
                title:@getName lang
                desc:""
            }
    # 山
    Mountain:class Mountain extends Hex
        constructor:->
            super
        name:
            ja:"山"
            en:"mountain"
        damage:(type)->
            # 山はダメージを受けにくい
            switch type
                when "widedamage-crator","widedamage-edge1"
                    super
                when "meteorite"
                    # 隕石に破壊される
                    @change lands.Waste,(e)=>
                        e.appendLog new logs.MeteoriteMountain @position,@clone()
        isMountain:->true
        html:(lang)->
            @rawhtml {
                src:"land11.gif"
                title:@getName lang
                desc:""
            }
    # 採掘場
    Mine:class extends Mountain
        constructor:->
            super
            @quantity=0
        name:
            ja:"採掘場"
            en:"mine"
        isMountain:->true
        html:(lang)->
            @rawhtml {
                src:"land15.gif"
                title:@getName lang
                desc:"#{@quantity}#{gameconfig.util.population}規模"
            }
        estimate:(status)->
            status.mountain+=@quantity
    # ミサイル基地
    #SeaBase:class extends multi Sea,Base
    SeaBase:class extends multi Base,Sea
        constructor:->
            super
            @exp=0
        expTable:[50,200]
        name:
            ja:"海底基地"
            en:"undersea missile base"
        damage:(type)->
            # 水没するときはログが出る
            switch type
                when "widedamage-crator","widedamage-edge1"
                    @change lands.Sea,(e)=>
                        e.appendLog new logs.WideDamageSea2 @position,@clone()
                when "meteorite"
                    @change lands.Sea,(e)=>
                        e.appendLog new logs.MeteoriteUnderSea @position,@clone()
                else
                    super
        html:(lang,owner)->
            if gameconfig.base.hide && !owner
                @rawhtml {
                    src:"land0.gif"
                    title:@getName lang
                    desc:""
                }
            else
                @rawhtml {
                    src:"land12.gif"
                    title:@getName lang
                    desc:"レベル#{@expToLevel @exp}"
                }
    OffshoreOilfield:class extends Sea
        name:
            ja:"海底油田"
            en:"offshore oilfield"
        oilPrice:1000
        turnProcess:->
            if @island?
                (new islandeffects.GainMoney @oilPrice).on @island
        damage:(type)->
            # 水没するときはログが出る
            if type in ["widedamage-crator","widedamage-edge1"]
                @change lands.Sea,(e)=>
                    e.appendLog new logs.WideDamageSea2 @position,@clone()
            else
                super
        html:(lang)->
            @rawhtml {
                src:"land16,gif"
                title:@getName lang
                desc:""
            }
    Monument:class extends Hex
        constructor:->
            super
            @type=0    #記念碑の種類
        types:(->
                [
                    #0
                    {
                        name:
                            ja:"モノリス"
                            en:"Monolith"
                        image:"monument0.gif"
                    },
                    #1
                    {
                        name:
                            ja:"平和記念碑"
                            en:"Monument of Peace"
                        image:"monument0.gif"
                    }
                    #2
                    {
                        name:
                            ja:"戦いの碑"
                            en:"Monument of War"
                        image:"monument0.gif"
                    }
                ]
               )()
        name:
            ja:"記念碑"
            en:"monument"
        html:(lang)->
            obj=@types[@type]
            if obj?
                @rawhtml {
                    src:obj.image
                    title:@getName lang
                    desc:obj.name[lang]
                }
            else
                @rawhtml {
                    src:""
                    title:@getName lang
                    desc:""
                }
    Haribote:class extends multi TyphoonVulnerable,TsunamiVulnerable,EarthquakeVulnerable,Hex
        name:
            ja:"ハリボテ"
            en:"haribote"
        damage:(type)->
            super
        html:(lang,owner)->
            if owner
                @rawhtml {
                    src:"land10.gif"
                    title:@getName lang
                    desc:""
                }
            else
                @rawhtml {
                    sec:"land10.gif"
                    title:(new Defence).getName lang
                    desc:""
                }

# exportsに入れる
for key in Object.keys lands
    exports[key]=lands[key]

