lands=require './lands'

class Effect
    constructor:->
        @logs=[]
    on:(hex)-> #hex: 適用先
        # ログがあったら適用するぞ!!!!!
        island=hex.land?.island
        if island?
            for log in @logs
                island.addLog log
    appendLog:(log)->
        @logs.push log
effects=
    Effect:Effect

    ChangeHex:class extends Effect
        constructor:(hex)->
            super
            if hex instanceof lands.Hex
                # 実物
                @hex=hex
            else if hex.prototype instanceof lands.Hex || hex==lands.Hex
                # コンストラクタ
                @cons=hex
            else if hex instanceof Function
                @hexfunc=hex
        on:(hex)->
            super
            land=hex.land
            newhex= if this.hex?
                this.hex
            else if this.cons?
                new this.cons
            else if this.hexfunc?
                this.hexfunc()
            else
                throw new Error "no hex"
            land.set hex.position, newhex
    Grow:class extends Effect
        on:(hex)->
            super
            unless hex instanceof lands.Growable
                # Growableじゃなかったら何もしない
                return
            hex.grow()
    Damage:class extends Effect
        constructor:(@type)->    # type:string
            super
        on:(hex)->
            super
            # そのまま適用
            hex.damage @type


# exportsに入れる
for key in Object.keys effects
    exports[key]=effects[key]
