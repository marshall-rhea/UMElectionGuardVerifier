import glob
import read_json

from parameters import Parameters
from helpers import in_set_Zq, in_set_Zrp

class BallotVerifier():
    def __init__(self):
        self.Parameters = Parameters()
        print("q")

    def verifyBallot(self,ballot):
        """ Verifies an encrypted ballot """
        for contest in ballot["contests"]:
            verified = self.verifyContest(contest)
            print("Verified =",verified)
            break
        print(ballot["object_id"])

    def verifyContest(self,contest):
        """ Verifies a contest by checking that each selection in a contest is an encryption of either 1 or 0
        AND that the number of positive selections does not exceed a pre-defined limit """
        for selection in contest["ballot_selections"]:
            verified = self.verifySelection(selection)
            print("Verified =",verified)
            break
    
    def verifySelection(self,selection):
        """ Verifies a ballot selection is an encryption of either 1 or 0 pursuant to the checks in [step 3] """
        alpha = int(selection.get("ciphertext",{}).get("pad",None))
        print("alpha:",alpha)
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
            return (False,{"selection_object_id": selection.get("object_id"),"step": "Step 3","check": "Check 1","errorMsg": "FAILURE: alpha not in set Zrp"})
        if(not in_set_Zrp(beta,self.Parameters)):
            return (False,{"selection_object_id": selection.get("object_id"),"step": "Step 3","check": "Check 1","errorMsg": "FAILURE: beta not in set Zrp"})
        if(not in_set_Zrp(a0,self.Parameters)):
            return (False,{"selection_object_id": selection.get("object_id"),"step": "Step 3","check": "Check 1","errorMsg": "FAILURE: a0 not in set Zrp"})
        if(not in_set_Zrp(b0,self.Parameters)):
            return (False,{"selection_object_id": selection.get("object_id"),"step": "Step 3","check": "Check 1","errorMsg": "FAILURE: b0 not in set Zrp"})
        if(not in_set_Zrp(a1,self.Parameters)):
            return (False,{"selection_object_id": selection.get("object_id"),"step": "Step 3","check": "Check 1","errorMsg": "FAILURE: a1 not in set Zrp"})
        if(not in_set_Zrp(b1,self.Parameters)):
            return (False,{"selection_object_id": selection.get("object_id"),"step": "Step 3","check": "Check 1","errorMsg": "FAILURE: b1 not in set Zrp"})

        # Check 2: The challenge c is correctly computed as c = H(Qinv,(alpha,beta),(a0,b0),(a1,b1))

        # Check 3: The given values c0, c1, v0, and v1 are each in the set Zq
        if(not in_set_Zq(c0,self.Parameters)):
            return (False,{"selection_object_id": selection.get("object_id"),"step": "Step 3","check": "Check 3","errorMsg": "FAILURE: c0 not in set Zq"})
        if(not in_set_Zq(c1,self.Parameters)):
            return (False,{"selection_object_id": selection.get("object_id"),"step": "Step 3","check": "Check 3","errorMsg": "FAILURE: c1 not in set Zq"})
        if(not in_set_Zq(v0,self.Parameters)):
            return (False,{"selection_object_id": selection.get("object_id"),"step": "Step 3","check": "Check 3","errorMsg": "FAILURE: v0 not in set Zq"})
        if(not in_set_Zq(v1,self.Parameters)):
            return (False,{"selection_object_id": selection.get("object_id"),"step": "Step 3","check": "Check 3","errorMsg": "FAILURE: v1 not in set Zq"})

        # Check 4: The equation c = c0 + c1 mod q is satisfied
        

if __name__ == "__main__":
    ballots = []
    for filename in glob.iglob("../../data/encrypted_ballots/*"):
        ballot = read_json.read_json_file(filename)
        if ballot:
            ballots.append(ballot)
    if len(ballots) > 0:
        ballot_verifier = BallotVerifier()
        ballot_verifier.verifyBallot(ballots[0])
    
    
