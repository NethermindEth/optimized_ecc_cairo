from typing import List
import asyncio
import os
import pytest
from starkware.starknet.testing.starknet import Starknet
from starkware.starknet.compiler.compile import compile_starknet_files
from starkware.starknet.definitions.general_config import build_general_config, default_general_config


FQ_CONTRACT = os.path.join("contracts", "fq.cairo")
G1_CONTRACT = os.path.join("contracts", "g1.cairo")
G2_CONTRACT = os.path.join("contracts", "g2.cairo")
FQ2_CONTRACT = os.path.join("contracts", "fq2.cairo")
FQ12_CONTRACT = os.path.join("contracts", "fq12.cairo")
PAIRING_CONTRACT = os.path.join("contracts", "pairing.cairo")
HASH_TO_CURVE_CONTRACT = os.path.join("contracts", "hash_to_curve.cairo")
KARATSUBA_CONTRACT =  os.path.join("contracts", "karatsuba.cairo")

@pytest.fixture(scope="module")
def event_loop():
    return asyncio.new_event_loop()


@pytest.fixture(scope="module")
async def starknet_factory():
    MAX_STEPS = 10 ** 60
    default_config = default_general_config
    default_config['invoke_tx_max_n_steps'] = MAX_STEPS
    config = build_general_config(default_config)
    starknet = await Starknet.empty(config)
    return starknet


@pytest.fixture(scope="module")
async def fq_factory(starknet_factory):

    starknet = starknet_factory

    # Deploy the account contract
    contract_class = compile_starknet_files(
        files=[FQ_CONTRACT], disable_hint_validation=True
    )
    fq_contract = await starknet.deploy(contract_class=contract_class)

    return fq_contract


@pytest.fixture(scope="module")
async def g1_factory(starknet_factory):

    starknet = starknet_factory

    # Deploy the account contract
    contract_class = compile_starknet_files(
        files=[G1_CONTRACT], disable_hint_validation=True
    )
    g1_contract = await starknet.deploy(contract_class=contract_class)

    return g1_contract


@pytest.fixture(scope="module")
async def g2_factory(starknet_factory):

    starknet = starknet_factory

    # Deploy the account contract
    contract_class = compile_starknet_files(
        files=[G2_CONTRACT], disable_hint_validation=True
    )
    g2_contract = await starknet.deploy(contract_class=contract_class)

    return g2_contract


@pytest.fixture(scope="module")
async def g2_factory(starknet_factory):
    
    starknet = starknet_factory

    # Deploy the account contract
    contract_class= compile_starknet_files(files=[G2_CONTRACT], disable_hint_validation=True)
    g2_contract = await starknet.deploy(contract_class=contract_class)

    return g2_contract

@pytest.fixture(scope="module")
async def fq2_factory(starknet_factory):

    starknet = starknet_factory

    # Deploy the account contract
    contract_class = compile_starknet_files(
        files=[FQ2_CONTRACT], disable_hint_validation=True
    )
    fq_contract = await starknet.deploy(contract_class=contract_class)

    return fq_contract


@pytest.fixture(scope="module")
async def fq12_factory(starknet_factory):

    starknet = starknet_factory

    # Deploy the account contract
    contract_class = compile_starknet_files(
        files=[FQ12_CONTRACT], disable_hint_validation=True
    )
    fq_contract = await starknet.deploy(contract_class=contract_class)

    return fq_contract

@pytest.fixture(scope="module")
async def pairing_factory(starknet_factory):
    starknet = starknet_factory

    # Deploy the account contract
    contract_class = compile_starknet_files(
        files=[PAIRING_CONTRACT], disable_hint_validation=True
    )
    pairing_contract = await starknet.deploy(contract_class=contract_class)

    return pairing_contract

@pytest.fixture(scope="module")
async def pairing_factory(starknet_factory):
    starknet = starknet_factory

    # Deploy the account contract
    contract_class = compile_starknet_files(
        files=[PAIRING_CONTRACT], disable_hint_validation=True
    )
    pairing_contract = await starknet.deploy(contract_class=contract_class)

    return pairing_contract

@pytest.fixture(scope="module")        
async def hash_to_curve_factory(starknet_factory):
    starknet = starknet_factory

    # Deploy the account contract
    contract_class = compile_starknet_files(
        files=[HASH_TO_CURVE_CONTRACT], disable_hint_validation=True
    )
    hash_to_curve_contract = await starknet.deploy(contract_class=contract_class)

    return hash_to_curve_contract

@pytest.fixture(scope="module")        
async def karatsuba_factory(starknet_factory):
    starknet = starknet_factory

    # Deploy the account contract
    contract_class = compile_starknet_files(
        files=[KARATSUBA_CONTRACT], disable_hint_validation=True
    )
    kar_contract = await starknet.deploy(contract_class=contract_class)

    return kar_contract