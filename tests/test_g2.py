import pytest

from utils import G2Point

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
