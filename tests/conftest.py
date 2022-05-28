from typing import List
import asyncio
import os
import pytest
from starkware.starknet.testing.starknet import Starknet
from starkware.starknet.compiler.compile import compile_starknet_files

one_bigint6 = (1, 0, 0, 0, 0, 0)

max_base_bigint6 = (2**64 - 1, 0, 0, 0, 0, 0)
max_base_bigint6_sum = 2 ** (64 * 5)


def split(num: int) -> List[int]:
    BASE = 2**64
    a = ()
    for _ in range(6):
        num, residue = divmod(num, BASE)
        a.append(residue)
    assert num == 0
    return a


def pack(z):

    limbs = z.d0, z.d1, z.d2, z.d3, z.d4, z.d5

    return sum(limb * 2 ** (64 * i) for i, limb in enumerate(limbs))


FQ_CONTRACT = os.path.join("contracts", "fq.cairo")
G1_CONTRACT = os.path.join("contracts", "g1.cairo")
FQ2_CONTRACT = os.path.join("contracts", "fq2.cairo")
FQ12_CONTRACT = os.path.join("contracts", "fq12.cairo")
BARRET_ALGORITHM_CONTRACT = os.path.join("contracts", "barret_algorithm.cairo")


@pytest.fixture(scope="module")
def event_loop():
    return asyncio.new_event_loop()


@pytest.fixture(scope="module")
async def starknet_factory():
    starknet = await Starknet.empty()
    return starknet


@pytest.fixture(scope="module")
async def fq_factory(starknet_factory):

    starknet = starknet_factory

    # Deploy the account contract
    contract_def = compile_starknet_files(
        files=[FQ_CONTRACT], disable_hint_validation=True
    )
    fq_contract = await starknet.deploy(contract_def=contract_def)

    return fq_contract

@pytest.fixture(scope="module")
async def g1_factory(starknet_factory):
    
    starknet = starknet_factory

    # Deploy the account contract
    contract_def= compile_starknet_files(files=[G1_CONTRACT], disable_hint_validation=True)
    g1_contract = await starknet.deploy(contract_def=contract_def)

    return g1_contract

@pytest.fixture(scope="module")
async def fq2_factory(starknet_factory):

    starknet = starknet_factory

    # Deploy the account contract
    contract_def = compile_starknet_files(
        files=[FQ2_CONTRACT], disable_hint_validation=True
    )
    fq_contract = await starknet.deploy(contract_def=contract_def)

    return fq_contract



@pytest.fixture(scope="module")
async def fq12_factory(starknet_factory):

    starknet = starknet_factory

    # Deploy the account contract
    contract_def = compile_starknet_files(
        files=[FQ12_CONTRACT], disable_hint_validation=True
    )
    fq_contract = await starknet.deploy(contract_def=contract_def)

    return fq_contract



