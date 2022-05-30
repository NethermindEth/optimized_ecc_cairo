import pytest

from utils import G1Point

#@pytest.mark.skip(reason="Pending math updates")
@pytest.mark.asyncio
async def test_g1_add_properties(g1_factory):
    contract = g1_factory

    a = G1Point((1,1,1))
    b = G1Point((2,2,1))
    zero = G1Point((0,0,0))
    # a + 0
    execution_info = await contract.add(a.asTuple(), zero.asTuple()).call()
    res = execution_info.result[0]
    
    assert a == G1Point(res)

    # 0 + b
    execution_info = await contract.add(zero.asTuple(), b.asTuple()).call()
    res = execution_info.result[0]
    assert G1Point(res) == b

    # a + b = b + a
    execution_info = await contract.add(a.asTuple(), b.asTuple()).call()
    res_1 = execution_info.result[0]

    execution_info = await contract.add(b.asTuple(), a.asTuple()).call()
    res_2 = execution_info.result[0]

    print( G1Point(res_1))
    print( G1Point(res_2))
    assert G1Point(res_1) == G1Point(res_2)
