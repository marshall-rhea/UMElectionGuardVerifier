from parameters import Parameters

def in_set_Zq(num: int, param: Parameters) -> bool:
    q = param.get_small_prime_q()

    return 0 <= num < q

def in_set_Zrp(num: int, param: Parameters) -> bool:
    q = param.get_small_prime_q()
    p = param.get_large_prime_p()

    return 0 <= num < p and int(pow(num, q, p)) == 1

def mod_q(num: int, param: Parameters) -> int:
    return int(num) % param.get_small_prime_q()

def mod_p(num: int, param: Parameters) -> int:
    return int(num) % param.get_large_prime_p()

def exp_g(num: int, param: Parameters, mod=0) -> int:
    return pow(param.get_generator_g(),num,mod) if mod else pow(param.get_generator(),num)

def exp_K(num: int, param: Parameters, mod=0) -> int:
    return pow(param.get_joint_election_public_key_K(),num,mod) if mod else pow(param.get_joint_election_public_key_K(),num)
