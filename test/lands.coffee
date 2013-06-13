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
    landarea=null
    beforeEach ->
        landarea=initArea()
    it 'should count Sea in 1Hex',->
        landarea.countAround(5,5,1,lands.Sea).should.equal 7
    it 'should count Sea in 2Hex',->
        landarea.countAround(5,5,2,lands.Sea).should.equal 19
    it 'should accept Position',->
        landarea.countAround(new islands.Position(5,5),1,lands.Sea).should.equal 7
    it 'should count Waste',->
        landarea.set 4,5,new lands.Waste
        landarea.set 6,5,new lands.Waste
        landarea.countAround(5,5,1,lands.Waste).should.equal 2
    it 'should deal with function',->
        landarea.set 5,6,new lands.Town
        landarea.countAround(5,5,1,((hex)->hex.population>=1)).should.equal 1

    it 'should count up outerArea as Sea',->
        landarea.countAround(0,0,1,lands.Sea).should.equal 7

    it 'should count any sea',->
        landarea.set 4,5,new lands.Shoal
        landarea.set 6,5,new lands.Shoal
        landarea.countAround(5,5,1,((hex)->hex.isSea())).should.equal 7

describe 'Hex',->
    describe 'basically',->
        describe 'flags',->
            it 'Sea is sea',->
                (new lands.Sea).isSea().should.be.true
                (new lands.Sea).isLand().should.be.false
            it 'Shoal is sea',->
                (new lands.Shoal).isSea().should.be.true
                (new lands.Shoal).isLand().should.be.false
            it 'Waste is not sea',->
                (new lands.Waste).isSea().should.be.false
        describe 'instance',->
            it 'Sea is sea',->
                (new lands.Sea).is(lands.Sea).should.be.true
                (new lands.Sea).is(lands.Plains).should.be.false
