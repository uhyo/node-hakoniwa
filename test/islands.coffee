# islands test
islands=require '../ts/islands'
islandeffects=require '../ts/islandeffects'

should=require 'should'

initIsland=->islands.makeNewIsland()

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
