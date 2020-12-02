from .read_json import read_json_file
from .parameters import Parameters

class Ballots():
    def __init__(self, param: Parameters):
        self.param = param
        self.ballot_path = param.get_root_path() + "encrypted_ballots/"
        self.tally_path = param.get_root_path() + "tally.json"

        self.contest_names_to_order = {} # contest name -> order
        self.contest_order_to_names = {} # contest order -> name

        self.contest_selections = {} # contest names -> selections (list)
        self.contest_data = [] # all contest data

    def fill_ballot_dic():
        """fill ballot dictionaries"""

        