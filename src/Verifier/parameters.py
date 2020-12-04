import glob
from read_json import read_json_file

class Parameters():
    def __init__(self, root_path="../../data/"):
        """inititalize parameters with default path ../../data/"""
        self.root_path = root_path
        self.context = read_json_file(root_path + "context.json")
        self.constants = read_json_file(root_path + "constants.json")
        self.description = read_json_file(root_path + "description.json")

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