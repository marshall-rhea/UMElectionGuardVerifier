import json

def read_json_file(filename: str):
    try:
        with open(filename) as f:
            json_dict = json.load(f)
        return json_dict
    except FileNotFoundError:
        print("Could not load file",filename)
    return None
