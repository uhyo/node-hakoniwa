lands=require './lands'

class Effect
    on:(hex)-> #hex: 適用先

effects=
    Effect:Effect

    ChangeHex:class extends Effect
        constructor:(hex)->
            if hex instanceof lands.Hex
                # 実物
                @hex=hex
            else if hex.prototype instanceof lands.Hex || hex==lands.Hex
                # コンストラクタ
                @cons=hex
            else if hex instanceof Function
                @hexfunc=hex
        on:(hex)->
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
            unless hex instanceof lands.Growable
                # Growableじゃなかったら何もしない
                return
            hex.grow()

# exportsに入れる
for key in Object.keys effects
    exports[key]=effects[key]
