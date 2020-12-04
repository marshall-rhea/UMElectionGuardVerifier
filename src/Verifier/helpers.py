import hashlib
from .parameters import Parameters
from typing import Sequence

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

def hash_elems(*a,param=Parameters()) -> int:
    """
    main hash function using SHA-256, used in generating data, reference:
    :param a: elements being fed into the hash function
    :return: a hash number of 256 bit
    """
    h = hashlib.sha256()
    h.update("|".encode("utf-8"))

    for x in a:

        if not x:
            # This case captures empty lists and None, nicely guaranteeing that we don't
            # need to do a recursive call if the list is empty. So we need a string to
            # feed in for both of these cases. "None" would be a Python-specific thing,
            # so we'll go with the more JSON-ish "null".
            hash_me = "null"

        elif isinstance(x, str):
            # strings are iterable, so it's important to handle them before the following check
            hash_me = x
        elif isinstance(x, Sequence):
            # The simplest way to deal with lists, tuples, and such are to crunch them recursively.
            hash_me = str(hash_elems(*x,param=param))
        else:
            hash_me = str(x)
        h.update((hash_me + "|").encode("utf-8"))

    # Note: the returned value will range from [1,Q), because zeros are bad
    # for some of the nonces. (g^0 == 1, which would be an unhelpful thing
    # to multiply something with, if you were trying to encrypt it.)

    # Also, we don't need the checked version of int_to_q, because the
    # modulo operation here guarantees that we're in bounds.
    # return int_to_q_unchecked(
    #     1 + (int.from_bytes(h.digest(), byteorder="big") % Q_MINUS_ONE)
    # )

    return int.from_bytes(h.digest(), byteorder="big") % (param.get_small_prime_q() - 1)