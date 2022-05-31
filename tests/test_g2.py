import pytest
from utils import splitFQP, split

@pytest.mark.asyncio
async def test_simplified_swu(g2_factory):
    contract = g2_factory

    print(split(2001204777610833696708894912867952078278441409969503942666029068062015825245418932221343814564507832018947136279893))
    execution_info = await contract.swu(splitFQP([1, 1]), splitFQP([1, 1])).call()
    res_x = execution_info.result.x
    res_y = execution_info.result.y

    assert res_x == res_y

