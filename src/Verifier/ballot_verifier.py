import glob
from .read_json import read_json_file

from .parameters import Parameters
from .helpers import in_set_Zq, in_set_Zrp, mod_q, mod_p, exp_g, exp_K, hash_elems

class BallotVerifier():
    """
    This class is responsible for checking that the ballot encryption is valid
    Checks Boxes 3 and 4 in the Verifier Construction spec
    """

    def __init__(self, param: Parameters):
        """initializes ballot_verifier class to use files from parameters"""
        self.param = param

    def verify_all_ballots(self):
        """perform verification checks on all ballots in election"""
        for ballot in self.param.get_encrypted_ballots():
            verified = self.verifyBallot(ballot)
            if not verified[0]:
                return verified

        return (True, {})

    def verifyBallot(self,ballot):
        """ Verifies an encrypted ballot """
        for contest in ballot["contests"]:
            verified = self.verifyContest(contest)
            if not verified[0]:
                return verified
            #print("Verified =",verified)
        #print(ballot["object_id"])

        return (True, {})

    def verifyContest(self,contest):
        """ Verifies a contest by checking that each selection in a contest is an encryption of either 1 or 0
        AND that the number of positive selections does not exceed a pre-defined limit """
        A = 1
        B = 1
        placeholder_selection_count = 0
        a = int(contest.get("proof", {}).get("pad",None))
        b = int(contest.get("proof", {}).get("data",None))
        C = int(contest.get("proof", {}).get("challenge",None))
        L = int(self.param.get_contest_selection_limit_L(contest["object_id"]))
        V = int(contest.get("proof", {}).get("response",None))
        
        for selection in contest.get("ballot_selections",[]):
            verified,response = self.verifySelection(selection)
            if(verified):
                A = A * int(response["alpha"]) % int(self.param.get_large_prime_p())
                B = B * int(response["beta"]) % int(self.param.get_large_prime_p())
            else:
                return (verified,response)

            if selection.get('is_placeholder_selection'):
                placeholder_selection_count += 1

        # Check 1: Vote selection limit L = number of placeholder selections
        if L != placeholder_selection_count:
            return (False, {"object_id": contest.get("object_id"), "step": "Step 4", "check": "Check 1", "errorMsg": "FAIRLURE: selection limit does not equal number of placeholder selections"})

        # Check 2: The contest total (A,B) satisfies A = prod(alpha_i) and B = prod(beta_i)
        
        # Check 3: The given value V is in Zq
        if not in_set_Zq(V,self.param):
            return (False, {"object_id": contest.get("object_id"), "step": "Step 4", "check": "Check 3", "errorMsg": "FAIRLURE: V not in set Zq"})

        # Check 4: The given values a and b are in Zrp
        if not in_set_Zrp(a,self.param):
            return (False, {"object_id": contest.get("object_id"), "step": "Step 4", "check": "Check 4", "errorMsg": "FAIRLURE: a not in set Zrp"})
        if not in_set_Zrp(b,self.param):
            return (False, {"object_id": contest.get("object_id"), "step": "Step 4", "check": "Check 4", "errorMsg": "FAIRLURE: b not in set Zrp"})
        
        # Check 5: The challenge value C is correctly computed as C = H(Qbar,(A,B),(a,b))
        if C != hash_elems(self.param, self.param.get_extended_base_hash_Qbar(), A, B, a, b):
           return (False, {"object_id": contest.get("object_id"), "step": "Step 4", "check": "Check 5", "errorMsg": "FAILURE: C = H(Qbar,(A,B),(a,b)) is not satisfied"})

        # Check 6: The equations g^V = a * A^C mod p and g^(LC) * K^V = b * B^C mod p are satisfied
        left = exp_g(V,self.param,self.param.get_large_prime_p())
        right = mod_p(mod_p(a,self.param) * pow(A,C,self.param.get_large_prime_p()),self.param)
        if not left == right:
            return (False, {"object_id": contest.get("object_id"), "step": "Step 4", "check": "Check 6", "errorMsg": "FAIRLURE: g^V = a * A^C mod p is NOT satisfied"})
        left = mod_p(pow(self.param.get_generator_g(),mod_q(L * C,self.param),self.param.get_large_prime_p()) * pow(self.param.get_joint_election_public_key_K(),V,self.param.get_large_prime_p()),self.param)
        right = mod_p(b * pow(B,C,self.param.get_large_prime_p()),self.param)
        if not left == right:
            return (False, {"object_id": contest.get("object_id"), "step": "Step 4", "check": "Check 6", "errorMsg": "FAIRLURE: g^(LC) * K^V = b * B^C mod p is NOT satisfied"})
        
        return (True, {})

    def verifySelection(self,selection):
        """ Verifies a ballot selection is an encryption of either 1 or 0 pursuant to the checks in [step 3] """
        alpha = int(selection.get("ciphertext", {}).get("pad",None))
        beta = int(selection.get("ciphertext", {}).get("data",None))
        a0 = int(selection.get("proof", {}).get("proof_zero_pad",None))
        b0 = int(selection.get("proof", {}).get("proof_zero_data",None))
        a1 = int(selection.get("proof", {}).get("proof_one_pad",None))
        b1 = int(selection.get("proof", {}).get("proof_one_data",None))
        c = int(selection.get("proof", {}).get("challenge",None))
        c0 = int(selection.get("proof", {}).get("proof_zero_challenge",None))
        c1 = int(selection.get("proof", {}).get("proof_one_challenge",None))
        v0 = int(selection.get("proof", {}).get("proof_zero_response",None))
        v1 = int(selection.get("proof", {}).get("proof_one_response",None))

        # Check 1: The given values alpha, bet, a0, b0, a1, and b1 are each in the set Zrp
        if(not in_set_Zrp(alpha,self.param)):
            return (False, {"object_id": selection.get("object_id"), "step": "Step 3", "check": "Check 1", "errorMsg": "FAILURE: alpha not in set Zrp"})
        if(not in_set_Zrp(beta,self.param)):
            return (False, {"object_id": selection.get("object_id"), "step": "Step 3", "check": "Check 1", "errorMsg": "FAILURE: beta not in set Zrp"})
        if(not in_set_Zrp(a0,self.param)):
            return (False, {"object_id": selection.get("object_id"), "step": "Step 3", "check": "Check 1", "errorMsg": "FAILURE: a0 not in set Zrp"})
        if(not in_set_Zrp(b0,self.param)):
            return (False, {"object_id": selection.get("object_id"), "step": "Step 3", "check": "Check 1", "errorMsg": "FAILURE: b0 not in set Zrp"})
        if(not in_set_Zrp(a1,self.param)):
            return (False, {"object_id": selection.get("object_id"), "step": "Step 3", "check": "Check 1", "errorMsg": "FAILURE: a1 not in set Zrp"})
        if(not in_set_Zrp(b1,self.param)):
            return (False, {"object_id": selection.get("object_id"), "step": "Step 3", "check": "Check 1", "errorMsg": "FAILURE: b1 not in set Zrp"})

        hash_val = hash_elems(self.param, self.param.get_extended_base_hash_Qbar(), alpha, beta, a0, b0, a1, b1)

        # Check 2: The challenge c is correctly computed as c = H(Qbar,(alpha,beta),(a0,b0),(a1,b1))
        if not c == hash_val:
            return (False, {"object_id": selection.get("object_id"), "step": "Step 2", "check": "Check 2", "errorMsg": "FAILURE c = H(Qbar,(alpha,beta),(a0,b0),(a1,b1) was NOT satisfied"})

        # Check 3: The given values c0, c1, v0, and v1 are each in the set Zq
        if(not in_set_Zq(c0,self.param)):
            return (False, {"object_id": selection.get("object_id"), "step": "Step 3", "check": "Check 3", "errorMsg": "FAILURE: c0 not in set Zq"})
        if(not in_set_Zq(c1,self.param)):
            return (False, {"object_id": selection.get("object_id"), "step": "Step 3", "check": "Check 3", "errorMsg": "FAILURE: c1 not in set Zq"})
        if(not in_set_Zq(v0,self.param)):
            return (False, {"object_id": selection.get("object_id"), "step": "Step 3", "check": "Check 3", "errorMsg": "FAILURE: v0 not in set Zq"})
        if(not in_set_Zq(v1,self.param)):
            return (False, {"object_id": selection.get("object_id"), "step": "Step 3", "check": "Check 3", "errorMsg": "FAILURE: v1 not in set Zq"})

        # Check 4: The equation c = c0 + c1 mod q is satisfied
        if(not (c == mod_q(int(c0 + c1),self.param))):
            return (False, {"object_id": selection.get("object_id"), "step": "Step 3", "check": "Check 4", "errorMsg": "FAILURE: c = c0 + c1 mod q was NOT satisfied"})
 
        # Check 5: The remaining equations are satisfied
        if(not (exp_g(v0,self.param,self.param.get_large_prime_p()) == mod_p(int(a0 * pow(alpha,c0,self.param.get_large_prime_p())),self.param))):
            return (False, {"object_id": selection.get("object_id"), "step": "Step 3", "check": "Check 5", "errorMsg": "FAILURE: g^v0 = a0 * alpha^c0 mod p was NOT satisfied"})
        if(not (exp_g(v1,self.param,self.param.get_large_prime_p()) == mod_p(int(a1 * pow(alpha,c1,self.param.get_large_prime_p())),self.param))):
            return (False, {"object_id": selection.get("object_id"), "step": "Step 3", "check": "Check 5", "errorMsg": "FAILURE: g^v1 = a1 * alpha^c1 mod p was NOT satisfied"})
        if(not (exp_K(v0,self.param,self.param.get_large_prime_p()) == mod_p(int(b0 * pow(beta,c0,self.param.get_large_prime_p())),self.param))):
            return (False, {"object_id": selection.get("object_id"), "step": "Step 3", "check": "Check 5", "errorMsg": "FAILURE: K^v0 = b0 * beta^c0 mod p was NOT satisfied"})
        if(not (mod_p(exp_g(c1,self.param,self.param.get_large_prime_p()) * exp_K(v1,self.param,self.param.get_large_prime_p()),self.param) == mod_p(int(b1 * pow(beta,c1,self.param.get_large_prime_p())),self.param))):
            return (False, {"object_id": selection.get("object_id"), "step": "Step 3", "check": "Check 5", "errorMsg": "FAILURE: g^c1 * K^v1 = b1 * beta^c1 mod p was NOT satisfied"})

        # All checks were passed! The selection is valid so return the information needed from this selection to check the entire contest
        return (True, {"alpha": alpha, "beta": beta})

#if __name__ == "__main__":
#    param = Parameters(root_path="../results/")
#    bv = BallotVerifier(param)
#    val = bv.verify_all_ballots()
#    print(val)
