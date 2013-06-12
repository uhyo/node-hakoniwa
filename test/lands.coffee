# lands test
islands=require '../ts/islands'
lands=require '../coffee/lands'

should=require 'should'

initArea=->
    landarea=new islands.LandArea 10,10
    # 全部海で初期化
    for x in [0...10]
        for y in [0...10]
            landarea.set x,y,new lands.Sea
    landarea

describe 'countAround',->
    describe 'countAround',->
        landarea=null
        beforeEach ->
            landarea=initArea()
        it 'should count Sea in 1Hex',->
            landarea.countAround(5,5,1,lands.Sea).should.equal 7
        it 'should count Sea in 2Hex',->
            landarea.countAround(5,5,2,lands.Sea).should.equal 19
        it 'should count Waste',->
            landarea.set 4,5,new lands.Waste
            landarea.set 6,5,new lands.Waste
            landarea.countAround(5,5,1,lands.Waste).should.equal 2
        it 'should deal with function',->
            landarea.set 5,6,new lands.Town
            landarea.countAround(5,5,1,((hex)->hex.population>=1)).should.equal 1


