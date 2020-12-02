from .read_json import read_json_file
from .parameters import Parameters
from .ballots import Ballots
from . import helpers as hlp


class Decryptor():
    def __init__(self, param: Parameters, ballots: Ballots):
        self.param = param
        self.ballots = ballots

    def verify_all_tallies(self):
        """
        verify all ballots are cast as intended and counted for
        follows steps outlined in step 6
        """

        #check ballot tallies match cumulative products

        #check equations

        #vi in set Zq

        #ai and bi in set Zqr
