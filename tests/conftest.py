from typing import List
import asyncio
import os
import pytest
from starkware.starknet.testing.starknet import Starknet

one_bigint6 = ( 1, 0, 0, 0, 0, 0 )

max_base_bigint6 = (2 ** 64 - 1, 0, 0, 0, 0, 0)
max_base_bigint6_sum = 2 ** (64 * 5)

def split(num: int) -> List[int]:
    BASE = 2 ** 64
    a = ()
    for _ in range(6):
        num, residue = divmod(num, BASE)
        a.append(residue)
    assert num == 0
    return a


def pack(z):

    limbs = z.d0, z.d1, z.d2, z.d3, z.d4, z.d5

    return sum(limb * 2 ** (64 * i) for i, limb in enumerate(limbs))


MULTI_PRECISION_CONTRACT = os.path.join("contracts", "multi_precision.cairo")


@pytest.fixture(scope="module")
def event_loop():
    return asyncio.new_event_loop()


@pytest.fixture(scope="module")
async def starknet_factory():
    starknet = await Starknet.empty()
    return starknet


@pytest.fixture(scope="module")
async def multi_precision_factory(starknet_factory):
    
    starknet = starknet_factory

    # Deploy the account contract
    multi_precision_contract = await starknet.deploy(source=MULTI_PRECISION_CONTRACT)

    return multi_precision_contract
