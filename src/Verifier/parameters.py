import glob
from .read_json import read_json_file

class Parameters():
    def __init__(self, root_path="../data/"):
        """inititalize parameters with default path ../data/"""
        self.root_path = root_path
        self.context = read_json_file(root_path + "context.json")
        self.constants = read_json_file(root_path + "constants.json")
        self.description = read_json_file(root_path + "description.json")
        self.tally = read_json_file(root_path + "tally.json")
        self.encrypted_ballots = []
        self.coefficient_dics = []
        self.coeff_order = {}

    def get_root_path(self):
        """get root path for data folder"""
        return self.root_path

    def get_context(self):
        """get dictionary of context variables"""
        return self.context

    def get_constants(self):
        """get dictionary of constants"""
        return self.constants

    def get_description(self):
        """get dictionary of election description"""
        return self.description

    def get_tally(self):
        """get dictionary of election description"""
        return self.tally

    def get_encrypted_ballots(self):
        if len(self.encrypted_ballots) == 0:
            self.find_encrypted_ballots()
        return self.encrypted_ballots

    def find_encrypted_ballots(self):
        ballot_path = self.get_root_path() + "encrypted_ballots/"

        for ballot_f_name in glob.glob(ballot_path + '*.json'):
            self.encrypted_ballots.append(read_json_file(ballot_f_name))

    def get_coefficient_files(self):
        if len(self.coefficient_dics) == 0:
            self.find_coefficient_dics()
        return self.coefficient_dics

    def find_coefficient_dics(self):
        coeff_path = self.get_root_path() + "coefficients/"

        for coeff_f_name in glob.glob(coeff_path + '*.json'):
            self.coefficient_dics.append(read_json_file(coeff_f_name))

    def get_coeff_by_name(self, name):
        if len(self.coefficient_dics) == 0:
            self.find_coefficient_dics()
        if len(self.coeff_order) == 0:
            self.fill_coeff_order()
        return self.coefficient_dics[self.coeff_order.get(name)]

    def fill_coeff_order(self):
        for i, coeff in enumerate(self.coefficient_dics):
            owner_id = coeff.get("owner_id")

            self.coeff_order[owner_id] = i

    def get_large_prime_p(self):
        """get large prime p"""
        return int(self.get_constants().get('large_prime'))

    def get_small_prime_q(self):
        """get large prime p"""
        return int(self.get_constants().get('small_prime'))

    def get_cofactor_r(self):
        """get cofactor r"""
        return int(self.get_constants().get('cofactor'))

    def get_generator_g(self):
        """get generator g"""
        return int(self.get_constants().get('generator'))

    def get_num_guardians(self):
        """get num guardians n"""
        return int(self.get_context().get('number_of_guardians'))

    def get_min_decrypt_guardians(self):
        """get min num guardians needed to decrypt k"""
        return int(self.get_context().get('quorum'))

    def get_base_hash(self):
        """get base hash value Q"""
        return int(self.get_context().get('crypto_base_hash'))

    def get_extended_base_hash_Qbar(self):
        """get extended base hash value Q-bar"""
        return int(self.get_context().get('crypto_extended_base_hash'))

    def get_joint_election_public_key_K(self):
        """get joint election public key K"""
        return int(self.get_context().get('elgamal_public_key'))

    def get_contest_selection_limit_L(self,contest_id):
        """get the contest selection limit L"""
        contests = self.get_description().get("contests",[])
        for contest in contests:
            if(contest["object_id"] == contest_id):
                return int(contest["votes_allowed"])
        return int(0)