import pytest

from utils import G2Point, splitFQP

@pytest.mark.asyncio
async def test_simplified_swu(g2_factory):
    contract = g2_factory

    u = (3167513664919274145284120531783832167109412382891894149785243170285502267171979051519659283907216630953242533668083, 937777375012248364046258719955852202763745212036378667068270601128566462923809130180553313818680631629584660435720)
    split_u = splitFQP(u)
    print(split_u)
    execution_info = await contract.swu(split_u).call()
    res_x = execution_info.result.x
    res_y = execution_info.result.y

    x = (1191280635306064362579559890038707975622268661555303961354228638611832621882023088035575204380024620397779485869656, 1933663121992846394380654530303100996747115576855130163728966149341897161049098093380522640470406163493706419998970)

    y2 = (1383282644364609129277359791348395049910790469702063624415180184742517341199180212944747239958125534558515354701338, 1540394283934845078656854127456278548048151841836384388403519137407486470551958789391043830952784400250293246580758)
    
    
    assert res_x == res_y


@pytest.mark.asyncio
async def test_g1_add_properties(g2_factory):
    contract = g2_factory

    a = G2Point((1,0,1))
    b = G2Point((2,1,1))
    zero = G2Point((0,0,0))
    # a + 0
    execution_info = await contract.add(a.asTuple(), zero.asTuple()).call()
    res = execution_info.result[0]
    
    assert a == G2Point(res)

    # 0 + b
    execution_info = await contract.add(zero.asTuple(), b.asTuple()).call()
    res = execution_info.result[0]
    assert G2Point(res) == b

    # a + b = b + a
    execution_info = await contract.add(a.asTuple(), b.asTuple()).call()
    res_1 = execution_info.result[0]

    execution_info = await contract.add(b.asTuple(), a.asTuple()).call()
    res_2 = execution_info.result[0]

    print( G2Point(res_1))
    print( G2Point(res_2))
    assert G2Point(res_1) == G2Point(res_2)

