# optimized_ecc_cairo


`optimized ecc cairo` is a set of operations over extension fields FQ, FQ2, and FQ12 as well as points in subgroups G1 and G2. 
The curve implementation contained in the code is bls12-381 however swapping out bls12-381 for another curve ought to be non-trivial by cairo standards.

[Uint-384](https://github.com/NethermindEth/uint384-cairo) and [Field arithmatic](https://github.com/NethermindEth/384bit-prime-field-arithmetic-cairo) are two libraries this project relies on. 
Please familiar yourself with these before proceeding to the higher level operations contained in this library.
