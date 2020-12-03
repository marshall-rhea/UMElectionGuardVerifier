from .parameters import Parameters

def in_set_Zq(num: int, param: Parameters) -> bool:
    q = param.get_small_prime_q()

    return -1 < num < q

def in_set_Zrp(num: int, param: Parameters) -> bool:
    q = param.get_small_prime_q()

    p = param.get_large_prime_p()

    return -1 < num < q and pow(num, q) % p == 1