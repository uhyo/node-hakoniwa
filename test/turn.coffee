# turn process test
islands=require '../ts/islands'
lands=require '../coffee/lands'
turn=require '../ts/turn'

should=require 'should'

initIsland=->
    island=islands.makeNewIsland()
    # 全部海で初期化する
    landarea=island.land
    for x in [0...landarea.width]
        for y in [0...landarea.height]
            landarea.set x,y,new lands.Sea
    island

makeTown=(population)->
    town=new lands.Town
    town.population=population
    town

makeFarm=(quantity)->
    result=new lands.Farm
    result.quantity=quantity
    result
makeFactory=(quantity)->
    result=new lands.Factory
    result.quantity=quantity
    result
makeMine=(quantity)->
    result=new lands.Mine
    result.quantity=quantity
    result

describe 'turn process',->
    island=null
    ite=null
    turnprocess=null
    beforeEach ->
        island=initIsland()
        island.food=0
        island.money=0
        turnprocess=new turn.TurnProcess
        ite=new turn.IslandsIterator {1:island}

    describe 'estimate',->
        beforeEach ->
            landarea=island.land
            landarea.set 0,0,makeTown 50
            landarea.set 2,0,makeTown 70
            landarea.set 3,0,makeFarm 50
            landarea.set 1,1,makeFactory 10
            landarea.set 4,1,makeFactory 20
            landarea.set 2,1,makeMine 60
        it 'should estimate population',->
            turnprocess.estimate ite
            island.status.population.should.be.eql 120
        it 'should estimate farm',->
            turnprocess.estimate ite
            island.status.farm.should.be.eql 50
        it 'should estimate factory',->
            turnprocess.estimate ite
            island.status.factory.should.be.eql 30
        it 'should estimate mountain',->
            turnprocess.estimate ite
            island.status.mountain.should.be.eql 60
    describe 'income',->
        beforeEach ->
            landarea=island.land
            landarea.set 3,0,makeFarm 50
            landarea.set 1,1,makeFactory 10
            landarea.set 4,1,makeFactory 20
            landarea.set 2,1,makeMine 60
        it 'should gain food',->
            landarea=island.land
            landarea.set 0,0,makeTown 10
            landarea.set 0,1,makeTown 20
            turnprocess.estimate ite
            turnprocess.income ite
            island.food.should.be.eql 30
            island.money.should.be.eql 0
        it 'should gain food and money',->
            landarea=island.land
            landarea.set 0,0,makeTown 100
            landarea.set 0,1,makeTown 20
            turnprocess.estimate ite
            turnprocess.income ite
            island.food.should.be.eql 50
            island.money.should.be.eql 7
        it 'should gain food and money 2',->
            landarea=island.land
            landarea.set 0,0,makeTown 100
            landarea.set 0,1,makeTown 100
            turnprocess.estimate ite
            turnprocess.income ite
            island.food.should.be.eql 50
            island.money.should.be.eql 9

