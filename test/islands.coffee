# islands test
islands=require '../ts/islands'
islandeffects=require '../ts/islandeffects'
lands=require '../coffee/lands'

should=require 'should'

initIsland=->
    island=islands.makeNewIsland()
    # 全部海で初期化する
    landarea=island.land
    for x in [0...landarea.width]
        for y in [0...landarea.height]
            landarea.set x,y,new lands.Sea
    island

describe 'islandEffect',->
    island=null
    beforeEach ->
        island=initIsland()
    describe 'Gain',->
        it 'should gain food',->
            island.food=100
            (new islandeffects.GainFood 300).on island
            island.food.should.eql 400
        it 'should gain over',->
            island.food=100
            (new islandeffects.GainFood 20000).on island
            island.food.should.eql 20100
        it 'should gain money',->
            island.money=100
            (new islandeffects.GainMoney 820).on island
            island.money.should.eql 920
        it 'should gain over',->
            island.money=100
            (new islandeffects.GainMoney 30000).on island
            island.money.should.eql 30100
    describe 'Disaster',->
        describe 'Eruption',->
            describe 'erupts in sea',->
                center=new islands.Position 5,5
                it 'center is Mountain',->
                    # 海の真ん中で
                    (new islandeffects.Eruption center).on island
                    land=island.land
                    # 地形チェック
                    land.get(center).is(lands.Mountain).should.be.true
                it 'edge is shoal',->
                    (new islandeffects.Eruption center).on island
                    land=island.land
                    land.ringAround(1).fromEach(center).every((pos)->
                        land.get(pos).is lands.Shoal
                    ).should.be.true

                it 'secondtime edge is waste',->
                    # さらに噴火
                    (new islandeffects.Eruption center).on island
                    (new islandeffects.Eruption center).on island
                    land=island.land

                    land.ringAround(1).fromEach(center).every((pos)->
                        land.get(pos).is lands.Waste
                    ).should.be.true
