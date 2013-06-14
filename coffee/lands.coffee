gameconfig=require './gameconfig'
islands=require '../ts/islands'

class Hex
    constructor:->
        @position=null

    name:"?"
    setPosition:(x,y)->
        if x instanceof islands.Position
            @position=x
        else
            @position=new islands.Position x,y
    html:(owner)->
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
    getName:->@name
    # 地形フラグ
    isLand:->true   # 陸かどうか
    isSea:->false   # 海系地形
    isTown:->false  # 街系地形（人口あり）かどうか
    isBase:->false  # ミサイル基地かどうか
    isMountain:->false # 山かどうか
    # 一致 コンストラクタをわたして
    is:(con)->this instanceof con
# 基本的地形
# ミサイル基地
class Base extends Hex
    isBase:->true
    expTable:[]
    maxExp:0
    expToLevel:(exp)->
        # expからレベルを算出
        i=@expTable.length
        while i>=1
            if exp>=@expTable[i-1]
                # このレベルだ
                return i
            i-=1
        return 1

module.exports=lands=
    Hex:Hex

    Sea:class extends Hex
        name:"海"
        isLand:->false
        isSea:->true
        html:->
            @rawhtml {
                src:"land0.gif"
                title:"海"
                desc:""
            }
    Shoal:class extends Hex
        name:"浅瀬"
        isLand:->false
        isSea:->true
        html:->
            @rawhtml {
                src:"land14.gif"
                title:"浅瀬"
                desc:""
            }
    # 荒地
    Waste:class extends Hex
        constructor:->
            super
            @type=0 # タイプ:0=通常 1=ミサイル跡
        name:"荒地"
        html:->
            @rawhtml {
                src: if @type==0 then "land1.gif" else "land13.gif"
                title:"荒地"
                desc:""
            }
    # 平地
    Plains:class extends Hex
        name:"平地"
        html:->
            @rawhtml {
                src:"land2.gif"
                title:"平地"
                desc:""
            }
    # 街系地形
    Town:class extends Hex
        constructor:->
            super
            @population=1   # 人口
        name:"街系地形"
        getName:->
            if @population<30
                "村"
            else if @population<100
                "町"
            else
                "都市"
        html:->
            @rawhtml {
                src: (if @population<30
                    "land3.gif"
                else if @population<100
                    "land4.gif"
                else
                    "land5.gif"
                )
                title:@getName()
                desc:"#{@population}#{gameconfig.unit.population}"
            }
    # 森
    Forest:class extends Hex
        constructor:->
            super
            @value=1
        name:"森"
        html:(owner)->
            @rawhtml {
                src:"land6.gif"
                title:"森"
                desc: if owner then "#{@value}#{gameconfig.unit.tree}" else ""
            }
    # 農場
    Farm:class extends Hex
        constructor:->
            super
            @quantity=0
        name:"農場"
        html:->
            @rawhtml {
                src:"land7.gif"
                title:"農場"
                desc:"#{@quantity}0#{gameconfig.unit.population}規模"
            }
    # 工場
    Factory:class extends Hex
        constructor:->
            super
            @quantity=0
        name:"工場"
        html:->
            @rawhtml {
                src:"land8.gif"
                title:"工場"
                desc:"#{@quantity}0#{gameconfig.unit.population}規模"
            }
    # ミサイル基地
    LandBase:class extends Base
        constructor:->
            super
            @exp=0
        expTable:[20,60,120,200]
        name:"ミサイル基地"
        html:(owner)->
            if gameconfig.base.hide && !owner
                @rawhtml {
                    src:"land6.gif"
                    title:"森"
                    desc:""
                }
            else
                @rawhtml {
                    src:"land9.gif"
                    title:"ミサイル基地"
                    desc:"レベル#{@expToLevel @exp}"
                }
    # 防衛施設
    Defence:class extends Hex
        name:"防衛施設"
        html:->
            @rawhtml {
                src:"land10.gif"
                title:"防衛施設"
                desc:""
            }
    # 山
    Mountain:class extends Hex
        name:"山"
        isMountain:->true
        html:->
            @rawhtml {
                src:"land11.gif"
                title:"山"
                desc:""
            }
    # 採掘場
    Mine:class extends Hex
        name:"採掘場"
        isMountain:->true
        html:->
            @rawhtml {
                src:"land15.gif"
                title:"採掘場"
                desc:"#{@quantity}0#{gameconfig.util.population}規模"
            }
    # ミサイル基地
    SeaBase:class extends Base
        constructor:->
            super
            @exp=0
        expTable:[50,200]
        isLand:->false
        isSea:->true
        name:"海底基地"
        html:(owner)->
            if gameconfig.base.hide && !owner
                @rawhtml {
                    src:"land0.gif"
                    title:"海"
                    desc:""
                }
            else
                @rawhtml {
                    src:"land12.gif"
                    title:"海底基地"
                    desc:"レベル#{@expToLevel @exp}"
                }
    OffshoreOilfield:class extends Hex
        isLand:->false
        isSea:->true
        name:"海底油田"
        html:->
            @rawhtml {
                src:"land16,gif"
                title:"海底油田"
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
                        name:"モノリス"
                        image:"monument0.gif"
                    },
                    #1
                    {
                        name:"平和記念碑"
                        image:"monument0.gif"
                    }
                    #2
                    {
                        name:"戦いの碑"
                        image:"monument0.gif"
                    }
                ]
               )()
        name:"記念碑"
        html:->
            obj=@types[@type]
            if obj?
                @rawhtml {
                    src:obj.image
                    title:"記念碑"
                    desc:obj.name
                }
            else
                @rawhtml {
                    src:""
                    title:"記念碑"
                    desc:""
                }
    Haribote:class extends Hex
        name:"ハリボテ"
        html:(owner)->
            if owner
                @rawhtml {
                    src:"land10.gif"
                    title:"ハリボテ"
                    desc:""
                }
            else
                @rawhtml {
                    sec:"land10.gif"
                    title:"防衛施設"
                    desc:""
                }
