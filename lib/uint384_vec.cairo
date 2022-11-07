from lib.uint384 import Uint384, Uint384_expand, uint384_lib
from lib.uint384_extension import uint384_extension_lib, Uint768

// requires the sum of the bi's to be <2**64
func dot_by_uint64_vec12{range_check_ptr}(a0: Uint384, b0: felt,
					  a1: Uint384, b1: felt,
					  a2: Uint384, b2: felt,
					  a3: Uint384, b3: felt,
					  a4: Uint384, b4: felt,
					  a5: Uint384, b5: felt,
					  a6: Uint384, b6: felt,
					  a7: Uint384, b7: felt,
					  a8: Uint384, b8: felt,
					  a9: Uint384, b9: felt,
					  a10: Uint384, b10: felt,
					  a11: Uint384, b11: felt,
					  ) -> (low: Uint384, high: felt) {
    %{
        assert ids.b0+ids.b1+ids.b2+ids.b3+ids.b4+ids.b5+ids.b6+ids.b7+ids.b8+ids.b9+ids.b10+ids.b11 < 2**64
    %}
    let (res0, carry) = uint384_lib.split_128(a0.d0*b0 +
					      a1.d0*b1 +
					      a2.d0*b2 +
					      a3.d0*b3 +
					      a4.d0*b4 +
					      a5.d0*b5 +
					      a6.d0*b6 +
					      a7.d0*b7 +
					      a8.d0*b8 +
					      a9.d0*b9 +
					      a10.d0*b10 +
					      a11.d0*b11);
    let (res2, carry) = uint384_lib.split_128(a0.d1*b0 +
					      a1.d1*b1 +
					      a2.d1*b2 +
					      a3.d1*b3 +
					      a4.d1*b4 +
					      a5.d1*b5 +
					      a6.d1*b6 +
					      a7.d1*b7 +
					      a8.d1*b8 +
					      a9.d1*b9 +
					      a10.d1*b10 +
					      a11.d1*b11 + carry);
    let (res4, carry) = uint384_lib.split_128(a0.d2*b0 +
					      a1.d2*b1 +
					      a2.d2*b2 +
					      a3.d2*b3 +
					      a4.d2*b4 +
					      a5.d2*b5 +
					      a6.d2*b6 +
					      a7.d2*b7 +
					      a8.d2*b8 +
					      a9.d2*b9 +
					      a10.d2*b10 +
					      a11.d2*b11 + carry);
  
    return (
        low=Uint384(d0=res0, d1=res2, d2=res4),
        high=carry,
    );
}

// requires the sum of the bi's to be <2**64
func dot_by_uint64_vec23{range_check_ptr}(a0: Uint384, b0: felt,
					  a1: Uint384, b1: felt,
					  a2: Uint384, b2: felt,
					  a3: Uint384, b3: felt,
					  a4: Uint384, b4: felt,
					  a5: Uint384, b5: felt,
					  a6: Uint384, b6: felt,
					  a7: Uint384, b7: felt,
					  a8: Uint384, b8: felt,
					  a9: Uint384, b9: felt,
					  a10: Uint384, b10: felt,
					  a11: Uint384, b11: felt,
					  a12: Uint384, b12: felt,
					  a13: Uint384, b13: felt,
					  a14: Uint384, b14: felt,
					  a15: Uint384, b15: felt,
					  a16: Uint384, b16: felt,
					  a17: Uint384, b17: felt,
					  a18: Uint384, b18: felt,
					  a19: Uint384, b19: felt,
					  a20: Uint384, b20: felt,
					  a21: Uint384, b21: felt,
					  a22: Uint384, b22: felt,
					  ) -> (low: Uint384, high: felt) {
    %{
        assert ids.b0+ids.b1+ids.b2+ids.b3+ids.b4+ids.b5+ids.b6+ids.b7+ids.b8+ids.b9+\
               ids.b10+ids.b11+ids.b12+ids.b13+ids.b14+ids.b15+ids.b16+ids.b17+ids.b18+ids.b19+ids.b20+ids.b21+ids.b22 < 2**64
    %}
    let (res0, carry) = uint384_lib.split_128(a0.d0*b0 +
					      a1.d0*b1 +
					      a2.d0*b2 +
					      a3.d0*b3 +
					      a4.d0*b4 +
					      a5.d0*b5 +
					      a6.d0*b6 +
					      a7.d0*b7 +
					      a8.d0*b8 +
					      a9.d0*b9 +
					      a10.d0*b10 +
					      a11.d0*b11 +
					      a12.d0*b12 +
					      a13.d0*b13 +
					      a14.d0*b14 +
					      a15.d0*b15 +
					      a16.d0*b16 +
					      a17.d0*b17 +
					      a18.d0*b18 +
					      a19.d0*b19 +
					      a20.d0*b20 +
					      a21.d0*b21 +
					      a22.d0*b22);
    let (res2, carry) = uint384_lib.split_128(a0.d1*b0 +
					      a1.d1*b1 +
					      a2.d1*b2 +
					      a3.d1*b3 +
					      a4.d1*b4 +
					      a5.d1*b5 +
					      a6.d1*b6 +
					      a7.d1*b7 +
					      a8.d1*b8 +
					      a9.d1*b9 +
					      a10.d1*b10 +
					      a11.d1*b11 +
					      a12.d1*b12 +
					      a13.d1*b13 +
					      a14.d1*b14 +
					      a15.d1*b15 +
					      a16.d1*b16 +
					      a17.d1*b17 +
					      a18.d1*b18 +
					      a19.d1*b19 +
					      a20.d1*b20 +
					      a21.d1*b21 +
					      a22.d1*b22 + carry);
    let (res4, carry) = uint384_lib.split_128(a0.d2*b0 +
					      a1.d2*b1 +
					      a2.d2*b2 +
					      a3.d2*b3 +
					      a4.d2*b4 +
					      a5.d2*b5 +
					      a6.d2*b6 +
					      a7.d2*b7 +
					      a8.d2*b8 +
					      a9.d2*b9 +
					      a10.d2*b10 +
					      a11.d2*b11 +
					      a12.d2*b12 +
					      a13.d2*b13 +
					      a14.d2*b14 +
					      a15.d2*b15 +
					      a16.d2*b16 +
					      a17.d2*b17 +
					      a18.d2*b18 +
					      a19.d2*b19 +
					      a20.d2*b20 +
					      a21.d2*b21 +
					      a22.d2*b22 + carry);
  
    return (
        low=Uint384(d0=res0, d1=res2, d2=res4),
        high=carry,
    );
}

func dot_by_uint64_vec12_mod{range_check_ptr}(a0: Uint384, b0: felt,
					      a1: Uint384, b1: felt,
					      a2: Uint384, b2: felt,
					      a3: Uint384, b3: felt,
					      a4: Uint384, b4: felt,
					      a5: Uint384, b5: felt,
					      a6: Uint384, b6: felt,
					      a7: Uint384, b7: felt,
					      a8: Uint384, b8: felt,
					      a9: Uint384, b9: felt,
					      a10: Uint384, b10: felt,
					      a11: Uint384, b11: felt,
					      p: Uint384_expand) -> (res: Uint384) {
    let (sum,carry) = dot_by_uint64_vec12(a0, b0,
					 a1, b1,
					 a2, b2,
					 a3, b3,
					 a4, b4,
					 a5, b5,
					 a6, b6,
					 a7, b7,
					 a8, b8,
					 a9, b9,
					 a10, b10,
					 a11, b11);
    let (_, rem) = uint384_extension_lib.unsigned_div_rem_uint768_by_uint384_expand(Uint768(sum.d0, sum.d1, sum.d2, carry, 0, 0), p);

    return (rem,);
}

func dot_by_uint64_vec23_mod{range_check_ptr}(a0: Uint384, b0: felt,
					      a1: Uint384, b1: felt,
					      a2: Uint384, b2: felt,
					      a3: Uint384, b3: felt,
					      a4: Uint384, b4: felt,
					      a5: Uint384, b5: felt,
					      a6: Uint384, b6: felt,
					      a7: Uint384, b7: felt,
					      a8: Uint384, b8: felt,
					      a9: Uint384, b9: felt,
					      a10: Uint384, b10: felt,
					      a11: Uint384, b11: felt,
					      a12: Uint384, b12: felt,
					      a13: Uint384, b13: felt,
					      a14: Uint384, b14: felt,
					      a15: Uint384, b15: felt,
					      a16: Uint384, b16: felt,
					      a17: Uint384, b17: felt,
					      a18: Uint384, b18: felt,
					      a19: Uint384, b19: felt,
					      a20: Uint384, b20: felt,
					      a21: Uint384, b21: felt,
					      a22: Uint384, b22: felt,
					      p: Uint384_expand) -> (res: Uint384) {
    let (sum,carry) = dot_by_uint64_vec23(a0, b0,
					 a1, b1,
					 a2, b2,
					 a3, b3,
					 a4, b4,
					 a5, b5,
					 a6, b6,
					 a7, b7,
					 a8, b8,
					 a9, b9,
					 a10, b10,
					 a11, b11,
					 a12, b12,
					 a13, b13,
					 a14, b14,
					 a15, b15,
					 a16, b16,
					 a17, b17,
					 a18, b18,
					 a19, b19,
					 a20, b20,
					 a21, b21,
					 a22, b22);
    let (_, rem) = uint384_extension_lib.unsigned_div_rem_uint768_by_uint384_expand(Uint768(sum.d0, sum.d1, sum.d2, carry, 0, 0), p);

    return (rem,);
}
