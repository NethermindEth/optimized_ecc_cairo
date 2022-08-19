import pytest
from utils import (
    pack,
)

@pytest.mark.asyncio
async def test_karatsuba(karatsuba_factory):

    num = 2 ** 96
    a = (num, num)
    b = (num, num)

    contract = karatsuba_factory
    execution_info = await contract.kar_a(a, b).call()

    print("\n")
    print(
    "%20s" % "function",
    "|",
    "%20s" % "n_steps",
    "|",
    "%-10s" % "builtins",
    )
    print(  
    "%20s" % "kar a",
    "|",
    "%20s" % execution_info.call_info.execution_resources.n_steps,
    "|",
    "%-10s" % execution_info.call_info.execution_resources.builtin_instance_counter,
    )

    execution_info = await contract.kar_b(a, b).call()

    print(
    "%20s" % "kar b",
    "|",
    "%20s" % execution_info.call_info.execution_resources.n_steps,
    "|",
    "%-10s" % execution_info.call_info.execution_resources.builtin_instance_counter,
    )

    #Todo check result
    #result = pack(execution_info.result, 2)

    #assert result == (x + y) % field_modulus
