import glob
from .read_json import read_json_file

from .parameters import Parameters
from .helpers import in_set_Zq, in_set_Zrp, mod_q, mod_p, exp_g, exp_K, hash_elems

class BallotVerifier():
    def __init__(self, param: Parameters):
        self.Parameters = param

    def verifyBallot(self,ballot):
        """ Verifies an encrypted ballot """
        for contest in ballot["contests"]:
            verified = self.verifyContest(contest)
            print("Verified =",verified)
        print(ballot["object_id"])

    def verifyContest(self,contest):
        """ Verifies a contest by checking that each selection in a contest is an encryption of either 1 or 0
        AND that the number of positive selections does not exceed a pre-defined limit """
        A = 1
        B = 1
        a = int(contest.get("proof",{}).get("pad",None))
        b = int(contest.get("proof",{}).get("data",None))
        C = int(contest.get("proof",{}).get("challenge",None))
        L = int(self.Parameters.get_contest_selection_limit_L(contest["object_id"]))
        V = int(contest.get("proof",{}).get("response",None))

        for selection in contest.get("ballot_selections",[]):
            verified,response = self.verifySelection(selection)
            if(verified):
                A = A * int(response["alpha"]) % int(self.Parameters.get_large_prime_p())
                B = B * int(response["beta"]) % int(self.Parameters.get_large_prime_p())
            else:
                return (verified,response)

        # Check 2: The contest total (A,B) satisfies A = prod(alpha_i) and B = prod(beta_i)
        
        # Check 3: The given value V is in Zq
        if(not in_set_Zq(V,self.Parameters)):
            return (False,{"object_id": contest.get("object_id"),"step": "Step 4", "check": "Check 3", "errorMsg": "FAIRLURE: V not in set Zq"})

        # Check 4: The given values a and b are in Zrp
        if(not in_set_Zrp(a,self.Parameters)):
            return (False,{"object_id": contest.get("object_id"),"step": "Step 4", "check": "Check 4", "errorMsg": "FAIRLURE: a not in set Zrp"})
        if(not in_set_Zrp(b,self.Parameters)):
            return (False,{"object_id": contest.get("object_id"),"step": "Step 4", "check": "Check 4", "errorMsg": "FAIRLURE: b not in set Zrp"})
        
        # Check 5: The challenge value C is correctly computed as C = H(Qbar,(A,B),(a,b))
        # if(not (C == hash_elems(self.Parameters.get_extended_base_hash_Qbar(),A,B,a,b,param=self.Parameters))):
        #     return (False,{"object_id": contest.get("object_id"),"step": "Step 4", "check": "Check 5", "errorMsg": "FAILURE: C = H(Qbar,(A,B),(a,b)) is not satisfied"})

        # Check 6: The equations g^V = a * A^C mod p and g^(LC) * K^V = b * B^C mod p are satisfied
        left = exp_g(V,self.Parameters,self.Parameters.get_large_prime_p())
        right = mod_p(mod_p(a,self.Parameters) * pow(A,C,self.Parameters.get_large_prime_p()),self.Parameters)
        if(not (left == right)):
            return (False,{"object_id": contest.get("object_id"),"step": "Step 4", "check": "Check 6", "errorMsg": "FAIRLURE: g^V = a * A^C mod p is NOT satisfied"})
        left = mod_p(pow(self.Parameters.get_generator_g(),mod_q(L * C,self.Parameters),self.Parameters.get_large_prime_p()) * pow(self.Parameters.get_joint_election_public_key_K(),V,self.Parameters.get_large_prime_p()),self.Parameters)
        right = mod_p(b * pow(B,C,self.Parameters.get_large_prime_p()),self.Parameters)
        if(not (left == right)):
            return (False,{"object_id": contest.get("object_id"),"step": "Step 4", "check": "Check 6", "errorMsg": "FAIRLURE: g^(LC) * K^V = b * B^C mod p is NOT satisfied"})
        
        return (True,{})

    def verifySelection(self,selection):
        """ Verifies a ballot selection is an encryption of either 1 or 0 pursuant to the checks in [step 3] """
        alpha = int(selection.get("ciphertext",{}).get("pad",None))
        beta = int(selection.get("ciphertext",{}).get("data",None))
        a0 = int(selection.get("proof",{}).get("proof_zero_pad",None))
        b0 = int(selection.get("proof",{}).get("proof_zero_data",None))
        a1 = int(selection.get("proof",{}).get("proof_one_pad",None))
        b1 = int(selection.get("proof",{}).get("proof_one_data",None))
        c = int(selection.get("proof",{}).get("challenge",None))
        c0 = int(selection.get("proof",{}).get("proof_zero_challenge",None))
        c1 = int(selection.get("proof",{}).get("proof_one_challenge",None))
        v0 = int(selection.get("proof",{}).get("proof_zero_response",None))
        v1 = int(selection.get("proof",{}).get("proof_one_response",None))

        # Check 1: The given values alpha, bet, a0, b0, a1, and b1 are each in the set Zrp
        if(not in_set_Zrp(alpha,self.Parameters)):
            return (False,{"object_id": selection.get("object_id"),"step": "Step 3","check": "Check 1","errorMsg": "FAILURE: alpha not in set Zrp"})
        if(not in_set_Zrp(beta,self.Parameters)):
            return (False,{"object_id": selection.get("object_id"),"step": "Step 3","check": "Check 1","errorMsg": "FAILURE: beta not in set Zrp"})
        if(not in_set_Zrp(a0,self.Parameters)):
            return (False,{"object_id": selection.get("object_id"),"step": "Step 3","check": "Check 1","errorMsg": "FAILURE: a0 not in set Zrp"})
        if(not in_set_Zrp(b0,self.Parameters)):
            return (False,{"object_id": selection.get("object_id"),"step": "Step 3","check": "Check 1","errorMsg": "FAILURE: b0 not in set Zrp"})
        if(not in_set_Zrp(a1,self.Parameters)):
            return (False,{"object_id": selection.get("object_id"),"step": "Step 3","check": "Check 1","errorMsg": "FAILURE: a1 not in set Zrp"})
        if(not in_set_Zrp(b1,self.Parameters)):
            return (False,{"object_id": selection.get("object_id"),"step": "Step 3","check": "Check 1","errorMsg": "FAILURE: b1 not in set Zrp"})

        # print("c =",c)
        # print("hash =",mod_q(hash_elems(self.param.get_extended_base_hash_Qbar(),(alpha,beta),(a0,b0),(a1,b1),param=self.param),self.param))

        # Check 2: The challenge c is correctly computed as c = H(Qbar,(alpha,beta),(a0,b0),(a1,b1))
        # if(not (c == mod_q(hash_elems(self.Parameters.get_extended_base_hash_Qbar(),(alpha,beta),(a0,b0),(a1,b1),param=self.Parameters),self.Parameters))):
        #     return (False,{"object_id": selection.get("object_id"),"step": "Step 2","check": "Check 2","errorMsg": "FAILURE c = H(Qbar,(alpha,beta),(a0,b0),(a1,b1) was NOT satisfied"})

        # Check 3: The given values c0, c1, v0, and v1 are each in the set Zq
        if(not in_set_Zq(c0,self.Parameters)):
            return (False,{"object_id": selection.get("object_id"),"step": "Step 3","check": "Check 3","errorMsg": "FAILURE: c0 not in set Zq"})
        if(not in_set_Zq(c1,self.Parameters)):
            return (False,{"object_id": selection.get("object_id"),"step": "Step 3","check": "Check 3","errorMsg": "FAILURE: c1 not in set Zq"})
        if(not in_set_Zq(v0,self.Parameters)):
            return (False,{"object_id": selection.get("object_id"),"step": "Step 3","check": "Check 3","errorMsg": "FAILURE: v0 not in set Zq"})
        if(not in_set_Zq(v1,self.Parameters)):
            return (False,{"object_id": selection.get("object_id"),"step": "Step 3","check": "Check 3","errorMsg": "FAILURE: v1 not in set Zq"})

        # Check 4: The equation c = c0 + c1 mod q is satisfied
        if(not (c == mod_q(int(c0 + c1),self.Parameters))):
            return (False,{"object_id": selection.get("object_id"),"step": "Step 3","check": "Check 4","errorMsg": "FAILURE: c = c0 + c1 mod q was NOT satisfied"})
 
        # Check 5: The remaining equations are satisfied
        if(not (exp_g(v0,self.Parameters,self.Parameters.get_large_prime_p()) == mod_p(int(a0 * pow(alpha,c0,self.Parameters.get_large_prime_p())),self.Parameters))):
            return (False,{"object_id": selection.get("object_id"),"step": "Step 3","check": "Check 5","errorMsg": "FAILURE: g^v0 = a0 * alpha^c0 mod p was NOT satisfied"})
        if(not (exp_g(v1,self.Parameters,self.Parameters.get_large_prime_p()) == mod_p(int(a1 * pow(alpha,c1,self.Parameters.get_large_prime_p())),self.Parameters))):
            return (False,{"object_id": selection.get("object_id"),"step": "Step 3","check": "Check 5","errorMsg": "FAILURE: g^v1 = a1 * alpha^c1 mod p was NOT satisfied"})
        if(not (exp_K(v0,self.Parameters,self.Parameters.get_large_prime_p()) == mod_p(int(b0 * pow(beta,c0,self.Parameters.get_large_prime_p())),self.Parameters))):
            return (False,{"object_id": selection.get("object_id"),"step": "Step 3","check": "Check 5","errorMsg": "FAILURE: K^v0 = b0 * beta^c0 mod p was NOT satisfied"})
        if(not (mod_p(exp_g(c1,self.Parameters,self.Parameters.get_large_prime_p()) * exp_K(v1,self.Parameters,self.Parameters.get_large_prime_p()),self.Parameters) == mod_p(int(b1 * pow(beta,c1,self.Parameters.get_large_prime_p())),self.Parameters))):
            return (False,{"object_id": selection.get("object_id"),"step": "Step 3","check": "Check 5","errorMsg": "FAILURE: g^c1 * K^v1 = b1 * beta^c1 mod p was NOT satisfied"})

        # All checks were passed! The selection is valid so return the information needed from this selection to check the entire contest
        return (True,{"alpha": alpha, "beta": beta})

if __name__ == "__main__":
    ballots = []
    for filename in glob.iglob("../../data/encrypted_ballots/*"):
        ballot = read_json.read_json_file(filename)
        if ballot:
            ballots.append(ballot)
    if len(ballots) > 0:
        ballot_verifier = BallotVerifier()
        ballot_verifier.verifyBallot(ballots[0])
    
    
