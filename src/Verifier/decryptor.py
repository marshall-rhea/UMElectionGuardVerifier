from .read_json import read_json_file
from .parameters import Parameters
from .ballots import Ballots
from .helpers import mod_p, in_set_Zq, in_set_Zrp, hash_elems, exp_g


class Decryptor():
    """
    This class is responsible for checking that the ballot decryption is valid
    Checks Boxes 6 and 9 in the Verifier Construction spec
    """

    def __init__(self, param: Parameters, ballots: Ballots):
        """initializes decryptor class to use files from parameters and data from ballots"""
        self.param = param
        self.ballots = ballots
        self.contests = param.get_tally().get("contests")

    def verify_all_tallies(self):
        """
        verify all ballots are cast as intended and counted for
        follows steps outlined in step 6
        """

        #check ballot tallies match cumulative products
        ballot_agg = self.verfy_accum_prod()

        if not ballot_agg[0]:
            return ballot_agg

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

        return self.access_all_shares()

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
                    return False, {"object_id": contest_name,"step": "Step 6", "check": "Accum Prod", "errorMsg": "FAIRLURE: product of pad encryptions does not match tally"}
                if selection.get('data') != tally.get('data'):
                    return False, {"object_id": contest_name,"step": "Step 6", "check": "Accum Prod", "errorMsg": "FAIRLURE: product of data encryptions does not match tally"}

        return True, {}

    def access_all_shares(self):
        """access all ballot shares to do checking equations"""

        contest_names = list(self.contests.keys())

        for contest_name in contest_names:
            contest = self.contests.get(contest_name)

            selections = contest.get("selections")

            selection_names = list(selections.keys())

            for selection_name in selection_names:
                selection = selections.get(selection_name)
                shares = selection.get("shares")
                pad = selection.get("message").get("pad")
                data = selection.get("message").get("data")

                for share in shares:
                    val = self.share_verifier(share, pad, data)
                    if not val[0]:
                        return val

                #verify correct decryption by each trustee
                #B = M (∏ Mi) mod p
                #M = (g ^ t) mod p
                
                val = self.validate_correct_decryption(selection)
                if not val[0]:
                    return val

        return True, {}

    def share_verifier(self, share, pad, data):
        """check all equations for a share"""
        #vi in set Zq
        response = int(share.get("proof").get("response"))
        Zq_check = in_set_Zq(response, self.param)
        if not Zq_check:
            return False, {"object_id": share.get('object_id'),"step": "Step 6", "check": "Zq check", "errorMsg": "FAIRLURE: Failed vi in set Zq"}

        #ai bi in Zrp
        proof_pad = int(share.get("proof").get("pad"))
        proof_data = int(share.get("proof").get("data"))
        item_share = int(share.get("share"))
        Zrp_check_a = in_set_Zrp(proof_data, self.param)
        Zrp_check_b = in_set_Zrp(proof_pad, self.param)
        if not Zrp_check_a:
            return False, {"object_id": share.get('object_id'),"step": "Step 6", "check": "Zrp check", "errorMsg": "FAIRLURE: Failed ai in Zrp"}
        if not Zrp_check_b:
            return False, {"object_id": share.get('object_id'),"step": "Step 6", "check": "Zrp check", "errorMsg": "FAIRLURE: Failed bi in Zrp"}

        #ci = H(Q-bar, (A,B), (ai, bi), Mi)
        Q_bar = self.param.get_extended_base_hash_Qbar()
        challenge = int(share.get("proof").get("challenge"))

        hash_val = hash_elems(self.param, str(Q_bar), pad, data, str(proof_pad), 
                              str(proof_data), str(item_share))
        
        if challenge != hash_val:
            return False, {"object_id": share.get('object_id'),"step": "Step 6", "check": "Challenge check", "errorMsg": "FAIRLURE: Failed ci = H(Q-bar, (A,B), (ai, bi), Mi)"}

        #g ^ vi = ai * (Ki ^ ci) mod p
        g_vi = exp_g(response, self.param, self.param.get_large_prime_p())
        guardian_id = share.get("guardian_id")

        coefficient = self.param.get_coeff_by_name(guardian_id)

        K_i = int(coefficient.get("coefficient_commitments")[0])

        ki_ci = mod_p(proof_pad * pow(K_i, challenge, self.param.get_large_prime_p()), self.param)
        if g_vi != ki_ci:
            return False, {"object_id": share.get('object_id'),"step": "Step 6", "check": "gvi check", "errorMsg": "FAIRLURE: Failed g ^ vi = ai * (Ki ^ ci) mod p"}

        #A ^ vi = bi * (Mi ^ ci) mod p
        A_vi = pow(int(pad), response, self.param.get_large_prime_p())
        Mi_ci = mod_p(proof_data * pow(item_share, challenge, self.param.get_large_prime_p()), self.param)
        if A_vi != Mi_ci:
            return False, {"object_id": share.get('object_id'),"step": "Step 6", "check": "Avi check", "errorMsg": "FAIRLURE: Failed A ^ vi = bi * (Mi ^ ci) mod p"}

        return True, {}

    def validate_correct_decryption(self, selection):
        """verify that partial decryptions form the full decryption"""
        # Assert the following formulas
        #B = M (∏ Mi) mod p
        #M = (g ^ t) mod p

        eq1 = self.check_box_9_eq_1(selection)
        eq2 = self.check_box_9_eq_2(selection)

        if not eq1:
            return eq1, {"object_id": selection.get('object_id'),"step": "Step 9", "check": "Equation 1", "errorMsg": "FAIRLURE: Failed B = M (∏ Mi) mod p"}
        if not eq2:
            return eq2, {"object_id": selection.get('object_id'),"step": "Step 9", "check": "Equation 2", "errorMsg": "FAIRLURE: Failed M = (g ^ t) mod p"}

        return True, {}

    def check_box_9_eq_1(self, selection):
        """assert B = M (∏ Mi) mod p"""
        shares = selection.get("shares")
        value = int(selection.get("value")) # M
        data = int(selection.get("message").get("data")) # B

        accum_share = None

        # (∏ Mi)
        for share in shares:
            Mi = int(share.get("share"))

            if accum_share is None:
                accum_share = Mi
            else:
                accum_share = Mi * accum_share
        
        right = mod_p(value * accum_share, self.param)

        if data != right:
            return False # Failed B = M (∏ Mi) mod p

        return True # Passed B = M (∏ Mi) mod p

    def check_box_9_eq_2(self, selection):
        """Assert M = (g ^ t) mod p"""
        value = int(selection.get("value")) # M
        tally = selection.get("tally") # t
        g = self.param.get_generator_g()

        right = mod_p(pow(g, tally), self.param)

        if value != right:
            return False # Failed M = (g ^ t) mod p

        return True # Passed M = (g ^ t) mod p


#if __name__ == "__main__":
#    param = Parameters(root_path="../results/")
#    ballots = Ballots(param)
#    dv = Decryptor(param, ballots)
#    val = dv.verify_all_tallies()
#    print(val)