from .read_json import read_json_file
from .parameters import Parameters
from .ballots import Ballots
from . import helpers as hlp


class Decryptor():
    def __init__(self, param: Parameters, ballots: Ballots):
        self.param = param
        self.ballots = ballots
        self.contests = param.get_tally().get("contests")

    def verify_all_tallies(self):
        """
        verify all ballots are cast as intended and counted for
        follows steps outlined in step 6
        """

        #check ballot tallies match cumulative products
        return self.verfy_accum_prod()

        #check equations

        #vi in set Zq
        #Check 0 < vi < q


        #ai and bi in set Zrp

        #ci = H(Q-bar, (A,B), (ai, bi), Mi)

        #g ^ vi = ai * (Ki ^ ci) mod p

        #A ^ vi = bi * (Mi ^ ci) mod p

        #verify correct decryption by each trustee
        #B = M (∏ Mi) mod p
        #M = (g ^ t) mod p

    def verfy_accum_prod(self) -> bool:
        """verify accum prod of ballot data matches tally"""
        contest_data = self.ballots.get_accum_contest_dic()

        contest_names = list(contest_data.keys())

        for contest_name in contest_names:
            contest = contest_data.get(contest_name)

            selection_names = list(contest.keys())

            for selection_name in selection_names:
                selection = contest.get(selection_name)

                #get tally data
                tally = self.contests.get(contest_name).get(
                        'selections').get(selection_name).get('message')

                if selection.get('pad') != tally.get('pad'):
                    return False
                if selection.get('data') != tally.get('data'):
                    return False

        return True

    def access_all_shares(self) -> bool:
        """access all ballot shares to do checking equations"""

        contest_names = list(self.contests.keys())

        for contest_name in contest_names:
            contest = self.contests.get(contest_name)

            selections = contest.get("selections")

            selection_names = list(selections.keys())

            for selection_name in selection_names:
                selection = selections.get(selection_name)
                shares = selection.get("shares")
                pad = selection.get("pad")
                data = selection.get("data")

                for share in shares:
                    val = self.share_verifier(share, pad, data)
                    if not val:
                        return False
        return True

    def share_verifier(self, share, pad, data):
        """check all equations for a share"""
        #vi in set Zq

        #ai bi in Zrp

        #ci = H(Q-bar, (A,B), (ai, bi), Mi)

        #g ^ vi = ai * (Ki ^ ci) mod p

        #A ^ vi = bi * (Mi ^ ci) mod p

        return True





if __name__ == "__main__":
    param = Parameters()
    ballots = Ballots(param)
    dv = Decryptor(param, ballots)
    val = dv.verify_all_tallies()
    print(val)