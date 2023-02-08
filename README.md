# optimized_ecc_cairo

Development on this repo is currently inactive. BLS12-381 pairing will not complete on most computers due to high memory consumption. The following repo, built on top of ours, is actively working on BLS12-381 cryptography: https://github.com/keep-starknet-strange/garaga/tree/main/src

-----

WARNING: The latest version of asyncio (>=0.19.0) is not supported. To downgrade do `pip install pytest-asyncio==0.18.3`


The curve implementation contained in the code is bls12-381 however swapping out bls12-381 for another curve ought to be non-trivial by cairo standards.

[Uint-384](https://github.com/NethermindEth/uint384-cairo) and [Field arithmatic](https://github.com/NethermindEth/384bit-prime-field-arithmetic-cairo) are two libraries this project relies on. 
Please familiar yourself with these before proceeding to the higher level operations contained in this library.
