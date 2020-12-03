import glob
from . import helpers 
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
        self.contest_data = {} # all contest data with accum products

    def get_accum_contest_dic(self):
        if len(self.contest_data) == 0:
            self.create_contest_dic()
            self.fill_contest_dic()
        return self.contest_data

    def create_contest_dic():
        description = self.param.get_description()

        contest_names = description.get('contests')

        for contest in contests:
            contest_name = contest.get('object_id')

            self.contest_data[contest_name] = {}

            selections = contest.get('ballot_selections')

            for selection in selections:
                selection_name = selection.get('object_id')

                self.contest_data[contest_name][selection_name] = {
                    'pad': '',
                    'data': ''
                }

    def fill_contest_dic(self):
        """fill ballot dictionaries"""
        for ballot_f_name in glob.glob(self.ballot_path + '*.json'):
            ballot = read_json_file(ballot_f_name)

            if ballot.get('state') == 'CAST':

                for contest in ballot.get('contests'):
                    contest_name = contest.get('object_id')
                    selections = contest.get('ballot_selections')

                    for selection in selections:
                        selection_name = selection.get('object_id')

                        if not selection.get('is_placeholder_selection'):
                            pad = selection.get('ciphertext', {}).get('pad')
                            data = selection.get('ciphertext', {}).get('data')

                            self.mult_selection(contest_name, selection_name, pad, data)

    def mult_selection(self, contest, selection, pad, data):
        """multiply current contest_data by a new set of pad/data values"""
        if self.contest_data.get(contest).get(selection).get('pad') == '':
            self.contest_data[contest][selection]['pad'] = pad
        else: