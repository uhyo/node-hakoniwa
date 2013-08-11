# 確率は基本的に千分率
module.exports=
    island:
        landwidth:12
        landheight:12
    html:
        # 画像のディレクトリ
        imagedir:"/images/"
    # 単位
    unit:
        # 人口
        population:"00人"
        # 木
        tree:"00本"
    # 持ち物について
    owings:
        initialFood:100
        initialMoney:100
        maxFood:9999
        maxMoney:9999
    # ミサイル基地
    base:
        hide:true   # ミサイル基地を隠すかどうか

    # 災害
    disaster:
        # 地震
        earthquake:
            # 個々のヘックスがダメージを受ける確率
            damageProb:250
        # 津波
        tsunami:
            # 個々のヘックスがダメージが受けるかどうかの判定用ダイス
            damageDice:12
        typhoon:
            # 個々のヘックスがダメージが受けるかどうかの判定用ダイス
            damageDice:12
