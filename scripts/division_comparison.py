"""
This scripts illustrates how the division and Barret reduction algorithms from the library fail to terminate when the base is about more than 2**15
"""


def find_largest_limb_index(n, base, max_num_limbs=10000):
    for idx in range(max_num_limbs):
        if base**idx > n:
            return idx - 1


# Computes x mod y
def mod(x, y, base):
    iteration = 0
    while x >= y:
        x_largest_limb_idx = find_largest_limb_index(x, base)
        y_largest_limb_idx = find_largest_limb_index(y, base)
        
        if x_largest_limb_idx > y_largest_limb_idx:
            limb_delta = x_largest_limb_idx - y_largest_limb_idx
            int_to_subtract = y * (base ** (limb_delta - 1))
            x = x - int_to_subtract
        else:
            x = x - y
        # print(x, y,int_to_subtract, iteration, x_largest_limb_idx,y_largest_limb_idx, limb_delta)
        iteration += 1
    return x


def main_test(base_power):
    init_time = time.time()
    x = (2**64 - 1) * 2**64
    y = 2**64
    assert x % y == mod(x, y, base=2**base_power)
    print(
        f"Test for base 2**{base_power} passed in {round(time.time() -init_time, 2)} seconds"
    )


if __name__ == "__main__":
    import time

    for power in range(2, 32):
        main_test(base_power=power)
