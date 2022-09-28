
namespace fft_lib {
    // p=2**251 + 17*2**192 + 1
    const PRIM_ROOT = 3;

    func ft4(a0 : felt,  a1: felt, a2 : felt, a3 : felt) ->
      (b0: felt, b1: felt, b2 : felt, b3: felt) {
      const I = PRIM_ROOT**(2**(251-2) + 17*2**(192-2));
      return (a0 + a1 + a2 + a3,
	      a0 + a1*I - a2 - a3*I,
	      a0 - a1 + a2 - a3,
	      a0 - a1*I - a2 + a3*I);
    }

    func fft8(a0 : felt,  a1: felt, a2 : felt, a3 : felt, a4 : felt, a5 : felt, a6 : felt, a7 : felt) ->
      (b0: felt, b1: felt, b2 : felt, b3: felt, b4: felt, b5: felt, b6 : felt, b7: felt) {
      alloc_locals;
      const Z8 = PRIM_ROOT**(2**(251-3) + 17*2**(192-3));
      const I = Z8**2;
      const Z83 = Z8**3;
      let l = ft4(a0,a2,a4,a6);
      let r = ft4(a1,a3,a5,a7);

      let y0 = r.b0;
      let b0 = l.b0 + y0;
      let b4 = l.b0 - y0;
      
      local y1 = r.b1 * Z8;
      let b1 = l.b1 + y1;
      let b5 = l.b1 - y1;

      local y2 = r.b2 * I;
      let b2 = l.b2 + y2;
      let b6 = l.b2 - y2;

      local y3 = r.b3 * Z83;
      let b3 = l.b3 + y3;
      let b7 = l.b3 - y3;
      
      return (b0,b1,b2,b3,b4,b5,b6,b7);
    }
    
    func fft16(a0 : felt,  a1: felt, a2 : felt, a3 : felt, a4 : felt, a5 : felt, a6 : felt, a7 : felt,
	       a8 : felt,  a9: felt, a10 : felt, a11 : felt, a12 : felt, a13 : felt, a14 : felt, a15 : felt) ->
      (b0 : felt,  b1: felt, b2 : felt, b3 : felt, b4 : felt, b5 : felt, b6 : felt, b7 : felt,
       b8 : felt,  b9: felt, b10 : felt, b11 : felt, b12 : felt, b13 : felt, b14 : felt, b15 : felt) {
      alloc_locals;
      const Z16 = PRIM_ROOT**(2**(251-4) + 17*2**(192-4));
      const Z8 = Z16**2;
      const Z163 = Z16**3;
      const I = Z16**4;
      const Z165 = Z16**5;
      const Z83 = Z16**6;
      const Z167 = Z16**7;
      let l = fft8(a0,a2,a4,a6,a8,a10,a12,a14);
      let r = fft8(a1,a3,a5,a7,a9,a11,a13,a15);

      let y0 = r.b0;
      let b0 = l.b0 + y0;
      let b8 = l.b0 - y0;
      
      local y1 = r.b1 * Z16;
      let b1 = l.b1 + y1;
      let b9 = l.b1 - y1;

      local y2 = r.b2 * Z8;
      let b2 = l.b2 + y2;
      let b10 = l.b2 - y2;

      local y3 = r.b3 * Z163;
      let b3 = l.b3 + y3;
      let b11 = l.b3 - y3;
      
      local y4 = r.b4 * I;
      let b4 = l.b4 + y4;
      let b12 = l.b4 - y4;

      local y5 = r.b5 * Z165;
      let b5 = l.b5 + y5;
      let b13 = l.b5 - y5;

      local y6 = r.b6 * Z83;
      let b6 = l.b6 + y6;
      let b14 = l.b6 - y6;

      local y7 = r.b7 * Z167;
      let b7 = l.b7 + y7;
      let b15 = l.b7 - y7;
      
      return (b0,b1,b2,b3,b4,b5,b6,b7,b8,b9,b10,b11,b12,b13,b14,b15);
    }
    
    func fft16i(a0 : felt,  a1: felt, a2 : felt, a3 : felt, a4 : felt, a5 : felt, a6 : felt, a7 : felt,
		a8 : felt,  a9: felt, a10 : felt, a11 : felt, a12 : felt, a13 : felt, a14 : felt, a15 : felt) ->
      (b0 : felt,  b1: felt, b2 : felt, b3 : felt, b4 : felt, b5 : felt, b6 : felt, b7 : felt,
       b8 : felt,  b9: felt, b10 : felt, b11 : felt, b12 : felt, b13 : felt, b14 : felt, b15 : felt) {
      alloc_locals;
      let (b0,b1,b2,b3,b4,b5,b6,b7,b8,b9,b10,b11,b12,b13,b14,b15) = fft16(
	   a0,a1,a2,a3,a4,a5,a6,a7,a8,a9,a10,a11,a12,a13,a14,a15);
      return (b0/16,b15/16,b14/16,b13/16,b12/16,b11/16,b10/16,b9/16,b8/16,b7/16,b6/16,b5/16,b4/16,b3/16,b2/16,b1/16);

    }

}