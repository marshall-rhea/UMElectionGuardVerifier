import glob
from .helpers import mod_p
from .read_json import read_json_file
from .parameters import Parameters

class Ballots():
    """
    This file generates a set of contests from the data found in the encrypted
    ballots files, and computes the tally for each contest from the ballot files
    """
    def __init__(self, param: Parameters):
        """Initializes ballot file with param object that handles files"""
        self.param = param
        self.contest_data = {} # all contest data with accum products

    def get_accum_contest_dic(self):
        """Get contest dictionary with accumulative products for all contests"""
        if len(self.contest_data) == 0:
            self.create_contest_dic()
            self.fill_contest_dic()
        return self.contest_data

    def create_contest_dic(self):
        """create dictionary for holding accumulative contest data"""
        description = self.param.get_description()

        contests = description.get('contests')

        for contest in contests:
            contest_name = contest.get('object_id')

            self.contest_data[contest_name] = {}

            selections = contest.get('ballot_selections')

            for selection in selections:
                selection_name = selection.get('object_id')

                # initialize data for each selection
                self.contest_data[contest_name][selection_name] = {
                    'pad': '',
                    'data': ''
                }

    def fill_contest_dic(self):
        """fill ballot dictionaries"""
        for ballot in self.param.get_encrypted_ballots():

            if ballot.get('state') == 'CAST':

                for contest in ballot.get('contests'): 
                    contest_name = contest.get('object_id')
                    selections = contest.get('ballot_selections')

                    for selection in selections:
                        selection_name = selection.get('object_id')

                        if not selection.get('is_placeholder_selection'):
                            pad = selection.get('ciphertext', {}).get('pad')
                            data = selection.get('ciphertext', {}).get('data')

                            # multiply ballot pad and data by the current accumulative product 
                            self.mult_selection(contest_name, selection_name, pad, data)

    def mult_selection(self, contest, selection, pad, data):
        """multiply current contest_data by a new set of pad/data values"""
        if self.contest_data.get(contest).get(selection).get('pad') == '':
            self.contest_data[contest][selection]['pad'] = pad
        else:
            term = int(self.contest_data[contest][selection]['pad'])
            prod = mod_p(term * int(pad), self.param)
            self.contest_data[contest][selection]['pad'] = str(prod)

        if self.contest_data.get(contest).get(selection).get('data') == '':
            self.contest_data[contest][selection]['data'] = data
        else:
            term = int(self.contest_data[contest][selection]['data'])
            prod = mod_p(term * int(data), self.param)
            self.contest_data[contest][selection]['data'] = str(prod)