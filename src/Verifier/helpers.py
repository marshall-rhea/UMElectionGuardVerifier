from parameters import Parameters

def in_set_Zq(num: int, param: Parameters) -> bool:
    q = param.get_small_prime_q()

    return 0 <= num < q

def in_set_Zrp(num: int, param: Parameters) -> bool:
    q = param.get_small_prime_q()
    p = param.get_large_prime_p()
    
    return 0 <= num < p and int(pow(num, q, p)) == 1

def mod_q(num: int, param: Parameters) -> int:
    return int(num) % param.get_small_prime_q

def mod_p(num: int, param: Parameters) -> int:
    return int(num) % param.get_large_prime_p