# optimized_ecc_cairo

WARNING: The latest version of asyncio (>=0.19.0) is not supported. To downgrade do `pip install pytest-asyncio==0.18.3`

This (Work In Progress) repo implements operations over the elliptic curve BLS12-384. We ultimately aim to bild a BLS signature scheme and a Verifiable Random Function on top of it. Special emphasis is placed on speed optimization.


For people looking to collaborate on this repo: This project relies heavily on the library [Field arithmatic](https://github.com/NethermindEth/384bit-prime-field-arithmetic-cairo). It may be a good idea to check it out before diving into the present library.
