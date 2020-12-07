from .ballot_verifier import BallotVerifier
from .ballots import Ballots
from .decryptor import Decryptor
from .parameters import Parameters

def main():
    print("* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *")
    print("*                                                                 *")
    print("*  Welcome to the University of Michigan Election Guard Verifier  *")
    print("*                                                                 *")
    print("* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *")

    cmd = "y"
    while(cmd == "y"):
        print()
        print("We support the following elections:")
        print("\ta) 2020 Michigan General Election")
        print("\tb) 2019 Ozark County Election")
        print("\tc) 2018 Microsoft Research Supreme Dictator Election")
        print()

        choice = input("Enter your choice of elections to verify {\"a\", \"b\", or \"c\"}: ")
        print()
        while choice not in ["a","b","c"]:
            print("Oops! I don't think you entered a valid choice!")
            choice = input("Enter your choice of elections to verify {\"a\", \"b\", or \"c\"}: ")
            print()

        if(choice == "a"):
            print("Verifying the 2020 Michigan General Election")
        elif(choice == "b"):
            print("Verifiying the 2019 Ozark County Election")
        elif(choice == "c"):
            print("Verifying the 2018 Microsoft Research Supreme Dictator Election")

        election_params = Parameters(root_path="../results/")    
        bv = BallotVerifier(election_params)
        print(">> First verifying that your vote was cast as intended...")
        verified, response = bv.verify_all_ballots()
        if(not verified):
            print("OH NO!!! Your vote was NOT cast as intended!!!")
            print(response)
            return
        print(">> Success!")

        ballots = Ballots(election_params)
        dv = Decryptor(election_params,ballots)
        print(">> Now verifying that your vote was tallied as cast...")
        verified, response = dv.verify_all_tallies()
        if(not verified):
            print("OH NO!!! Your vote was NOT properly tallied!!!")
            print(response)
            return
        print(">> Success!")
        
        print("This election has been verified!")
        cmd = input("Would you like to verify your vote in another election? {\"y\" or \"n\"} ")
    return

if __name__ == "__main__":
    main()