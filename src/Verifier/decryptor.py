from .read_json import read_json_file
from .parameters import Parameters
from .ballots import Ballots
from . import helpers as hlp


class Decryptor():
    def __init__(self, param: Parameters, ballots: Ballots):
        self.param = param
        self.ballots = ballots
        self.contests = param.get_tally.get("contests")

    def verify_all_tallies(self):
        """
        verify all ballots are cast as intended and counted for
        follows steps outlined in step 6
        """

        #check ballot tallies match cumulative products
        self.verfy_accum_prod()

        #check equations

        #vi in set Zq

        #ai and bi in set Zrp

        #ci = H(Q-bar, (A,B), (ai, bi), Mi)

        #g ^ vi = ai * (Ki ^ ci) mod p

        #A ^ vi = bi * (Mi ^ ci) mod p


        #verify correct decryption by each trustee
        #B = M (∏ Mi) mod p
        #M = (g ^ t) mod p

    def verfy_accum_prod(self):
        