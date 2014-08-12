# lands test
islands=require '../ts/islands'
lands=require '../coffee/lands'
effects=require '../coffee/effects'
islandeffects=require '../ts/islandeffects'

should=require 'should'

initArea=->
    landarea=new islands.LandArea 10,10
    # 全部海で初期化
    for x in [0...10]
        for y in [0...10]
            landarea.set x,y,new lands.Sea
    landarea
initIsland=->
    islands.makeNewIsland()
initStatus=->
    island=initIsland()
    return new islands.IslandStatus island

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
            it 'SeaBase is sea',->
                (new lands.SeaBase).isSea().should.be.true
                (new lands.SeaBase).isLand().should.be.false
            it 'LandBase is base',->
                should.exist (new lands.LandBase).expToLevel
            it 'SeaBase is base',->
                should.exist (new lands.SeaBase).expToLevel
            it 'SeaBase is hex',->
                should.exist (new lands.SeaBase).is
            it 'Waste is not sea',->
                (new lands.Waste).isSea().should.be.false
        describe 'instance',->
            it 'Sea is sea',->
                (new lands.Sea).is(lands.Sea).should.be.true
                (new lands.Sea).is(lands.Plains).should.be.false
    describe 'Ecumene',->
        describe 'Town',->
            town=null
            beforeEach ->
                town=new lands.Town
            it 'should grow well',->
                town.population=10
                town.grow()
                town.population.should.be.above 10
            it 'should grow up to border',->
                town.population=99
                town.grow()
                town.population.should.eql 100
            it 'shouldn\'t grow above border',->
                town.population=150
                town.grow()
                town.population.should.eql 150
            it 'should cut off overpopulation',->
                town.population=203
                town.grow()
                town.population.should.eql 200
            it 'should shrink',->
                town.population=100
                town.shrink()
                town.population.should.be.below 100
            it 'should disappear',->
                town.population=1
                landarea=initArea()
                landarea.set 5,5,town
                town.shrink()
                landarea.get(5,5).is(lands.Plains).should.be.true
            it 'should accept Grow effect',->
                town.population=80
                (new effects.Grow).on town
                town.grow()
                town.population.should.be.above 80
            it 'should accept Grow effect (but no growth)',->
                town.population=120
                (new effects.Grow).on town
                town.grow()
                town.population.should.be.eql 120
            it 'should estimate population',->
                status=initStatus()
                status.population.should.be.eql 0
                town.population=120
                town.estimate status
                status.population.should.be.eql 120
    describe 'Plains',->
        landarea=null
        plains=null
        beforeEach ->
            landarea=initArea()
            plains=new lands.Plains
            landarea.set 5,5,plains
        it 'should grow to Town',->
            plains.grow()
            town=landarea.get 5,5
            town.is(lands.Town).should.be.true
            town.population.should.eql 1
        it 'should not change',->
            plains.growpop=->true
            plains.turnProcess()
            landarea.get(5,5).should.eql plains
        it 'should grow',->
            plains.growpop=->true
            landarea.set 4,5,new lands.Town
            plains.turnProcess()
            landarea.get(5,5).is(lands.Town).should.be.true
        it 'should grow',->
            plains.growpop=->true
            landarea.set 4,5,new lands.Farm
            plains.turnProcess()
            landarea.get(5,5).is(lands.Town).should.be.true
    describe 'Forest',->
        forest=null
        beforeEach ->
            forest=new lands.Forest
        it 'should grow',->
            forest.value=12
            forest.grow()
            forest.value.should.eql 13
        it 'should grow',->
            forest.value=12
            forest.turnProcess()
            forest.value.should.eql 13
    describe 'Farm',->
        farm=null
        beforeEach ->
            farm=new lands.Farm
        it 'should estimate',->
            status=initStatus()
            status.farm.should.be.eql 0
            farm.quantity=50
            farm.estimate status
            status.farm.should.be.eql 50
    describe 'Factory',->
        factory=null
        beforeEach ->
            factory=new lands.Factory
        it 'should estimate',->
            status=initStatus()
            status.factory.should.be.eql 0
            factory.quantity=50
            factory.estimate status
            status.factory.should.be.eql 50
    describe 'Mine',->
        mine=null
        beforeEach ->
            mine=new lands.Mine
        it 'should estimate',->
            status=initStatus()
            status.mountain.should.be.eql 0
            mine.quantity=50
            mine.estimate status
            status.mountain.should.be.eql 50
    describe 'OffshoreOilfield',->
        oil=null
        beforeEach ->
            oil=new lands.OffshoreOilfield
        it 'should not cause error',->
            oil.turnProcess()
        it 'should produce oil',->
            island=initIsland()
            island.money=500
            island.land.set 5,5,oil
            oil.turnProcess()
            island.money.should.eql 1500
describe 'Effects',->
    landarea=null
    beforeEach ->
        landarea=initArea()
    it 'ChangeHex',->
        (new effects.ChangeHex lands.Plains).on landarea.get 5,5
        landarea.get(5,5).is(lands.Plains).should.be.true
    describe 'Damage',->
        it 'eruption-crator',->
            (new effects.Damage "eruption-crator").on landarea.get 5,5
            landarea.get(5,5).is(lands.Mountain).should.be.true
        it 'eruption-edge',->
            (new effects.Damage "eruption-edge").on landarea.get 5,5
            landarea.get(5,5).is(lands.Shoal).should.be.true
            (new effects.Damage "eruption-edge").on landarea.get 5,5
            landarea.get(5,5).is(lands.Waste).should.be.true
            (new effects.Damage "eruption-edge").on landarea.get 5,5
            landarea.get(5,5).is(lands.Waste).should.be.true

            landarea.set 5,5,new lands.Town
            (new effects.Damage "eruption-edge").on landarea.get 5,5
            landarea.get(5,5).is(lands.Waste).should.be.true
        describe 'earthquake',->
            dm=new effects.Damage "earthquake"
            it 'on small Town',->
                landarea.set 5,5,new lands.Town
                dm.on landarea.get 5,5
                landarea.get(5,5).is(lands.Town).should.be.true
            it 'on Town',->
                town=new lands.Town
                town.population=150
                landarea.set 5,5,town
                dm.on landarea.get 5,5
                landarea.get(5,5).is(lands.Waste).should.be.true
            it 'on Haribote',->
                landarea.set 5,5,new lands.Haribote
                dm.on landarea.get 5,5
                landarea.get(5,5).is(lands.Waste).should.be.true
            it 'on Factory',->
                landarea.set 5,5,new lands.Factory
                dm.on landarea.get 5,5
                landarea.get(5,5).is(lands.Waste).should.be.true
            it 'others',->
                landarea.set 5,5,new lands.Plains
                dm.on landarea.get 5,5
                landarea.get(5,5).is(lands.Plains).should.be.true
        describe 'tsunami',->
            dm=new effects.Damage "tsunami"
            it 'on town',->
                landarea.set 5,5,new lands.Town
                dm.on landarea.get 5,5
                landarea.get(5,5).is(lands.Waste).should.be.true
            it 'on farm',->
                landarea.set 5,5,new lands.Farm
                dm.on landarea.get 5,5
                landarea.get(5,5).is(lands.Waste).should.be.true
            it 'on Haribote',->
                landarea.set 5,5,new lands.Haribote
                dm.on landarea.get 5,5
                landarea.get(5,5).is(lands.Waste).should.be.true
            it 'on Factory',->
                landarea.set 5,5,new lands.Factory
                dm.on landarea.get 5,5
                landarea.get(5,5).is(lands.Waste).should.be.true
            it 'on LandBase',->
                landarea.set 5,5,new lands.LandBase
                dm.on landarea.get 5,5
                landarea.get(5,5).is(lands.Waste).should.be.true
            it 'on Defence',->
                landarea.set 5,5,new lands.Defence
                dm.on landarea.get 5,5
                landarea.get(5,5).is(lands.Waste).should.be.true
            it 'others',->
                landarea.set 5,5,new lands.Plains
                dm.on landarea.get 5,5
                landarea.get(5,5).is(lands.Plains).should.be.true
        describe 'typhoon',->
            dm=new effects.Damage "typhoon"
            it 'on farm',->
                landarea.set 5,5,new lands.Farm
                dm.on landarea.get 5,5
                landarea.get(5,5).is(lands.Plains).should.be.true
            it 'on Haribote',->
                landarea.set 5,5,new lands.Haribote
                dm.on landarea.get 5,5
                landarea.get(5,5).is(lands.Plains).should.be.true
            it 'others',->
                landarea.set 5,5,new lands.Town
                dm.on landarea.get 5,5
                landarea.get(5,5).is(lands.Town).should.be.true
        describe 'widedamage',->
            describe 'crator',->
                dm=new effects.Damage "widedamage-crator"
                it 'on shoal',->
                    landarea.set 5,5,new lands.Shoal
                    dm.on landarea.get 5,5
                    landarea.get(5,5).is(lands.Sea).should.be.true
                it 'on SeaBase',->
                    landarea.set 5,5,new lands.SeaBase
                    dm.on landarea.get 5,5
                    landarea.get(5,5).is(lands.Sea).should.be.true
                it 'others',->
                    landarea.set 5,5,new lands.Town
                    dm.on landarea.get 5,5
                    landarea.get(5,5).is(lands.Sea).should.be.true
            describe 'edge1',->
                dm=new effects.Damage "widedamage-edge1"
                it 'on shoal',->
                    landarea.set 5,5,new lands.Shoal
                    dm.on landarea.get 5,5
                    landarea.get(5,5).is(lands.Sea).should.be.true
                it 'on SeaBase',->
                    landarea.set 5,5,new lands.SeaBase
                    dm.on landarea.get 5,5
                    landarea.get(5,5).is(lands.Sea).should.be.true
                it 'others',->
                    landarea.set 5,5,new lands.Mountain
                    dm.on landarea.get 5,5
                    landarea.get(5,5).is(lands.Shoal).should.be.true
            describe 'edge2',->
                dm=new effects.Damage "widedamage-edge2"
                it 'on SeaBase',->
                    landarea.set 5,5,new lands.SeaBase
                    dm.on landarea.get 5,5
                    landarea.get(5,5).is(lands.SeaBase).should.be.true
                it 'on oil',->
                    landarea.set 5,5,new lands.OffshoreOilfield
                    dm.on landarea.get 5,5
                    landarea.get(5,5).is(lands.OffshoreOilfield).should.be.true
                it 'on Mountain',->
                    landarea.set 5,5,new lands.Mountain
                    dm.on landarea.get 5,5
                    landarea.get(5,5).is(lands.Mountain).should.be.true
                it 'others',->
                    landarea.set 5,5,new lands.Factory
                    dm.on landarea.get 5,5
                    landarea.get(5,5).is(lands.Waste).should.be.true
        describe 'meteorite',->
            dm=new effects.Damage "meteorite"
            it ' on mountain',->
                landarea.set 5,5,new lands.Mountain
                dm.on landarea.get 5,5
                landarea.get(5,5).is(lands.Waste).should.be.true
            it ' on seabase',->
                landarea.set 5,5,new lands.SeaBase
                dm.on landarea.get 5,5
                landarea.get(5,5).is(lands.Sea).should.be.true
            it 'others',->
                landarea.set 5,5,new lands.Town
                dm.on landarea.get 5,5
                landarea.get(5,5).is(lands.Sea).should.be.true






