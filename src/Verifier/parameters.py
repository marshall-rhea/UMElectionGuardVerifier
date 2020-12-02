from .read_json import read_json_file

class Parameters():
    def __init__(self):
        self.context = read_json_file("../data/context.json")
        self.constants = read_json_file("../data/constants.json")

    def get_context(self):
        return self.context

    def get_constants(self):
        return self.constants