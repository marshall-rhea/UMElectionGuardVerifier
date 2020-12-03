import glob
import read_json

class BallotVerifier():
    def __init__(self):
        self.params = None

    def verifyBallot(self,ballot):
        """ Verifies an encrypted ballot """
        for contest in ballot["contests"]:
            verified = self.verifyContest(contest)
            print("Verified =",verified)
        print(ballot["object_id"])

    def verifyContest(self,contest):
        """ Verifies a contest by checking that each selection in a contest is an encryption of either 1 or 0
        AND that the number of positive selections does not exceed a pre-defined limit """
        for selection in contest["ballot_selections"]:
            verified = self.verifySelection(selection)
            print("Verified =",verified)
    
    def verifySelection(self,selection):
        """ Verifies a ballot selection is an encryption of either 1 or 0 """
        print("Verifying selection",selection["crypto_hash"])

if __name__ == "__main__":
    ballots = [read_json.read_json_file(filename) for filename in glob.iglob("../../data/encrypted_ballots/*")]
    ballot_verifier = BallotVerifier()
    ballot_verifier.verifyBallot(ballots[0])
    
    
