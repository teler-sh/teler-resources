import json
import os
import yaml

def get_parent_directory(path, levels=1):
    levels = levels + 1 if os.path.isfile(path) else 0
    for _ in range(levels):
        path = os.path.dirname(path)
    return path

def convert_yaml_to_json(input_file):
    with open(input_file, 'r') as f:
        yaml_data = yaml.safe_load(f)

    try:
        json_data = {
            "id": yaml_data['id'],
            "info": {
                "name": yaml_data['info']['name'],
                "severity": yaml_data['info']['severity']
            },
            "requests": yaml_data['http']
        }
    except KeyError:
        return False

    return json_data

def convert_cves(directory_path):
    json_output = {"templates": []}
    for root, _, files in os.walk(directory_path):
        for file_name in files:
            if file_name.endswith(".yaml"):
                input_file = os.path.join(root, file_name)
                json_data = convert_yaml_to_json(input_file)
                if not json_data:
                    continue
                json_output["templates"].append(json_data)

    return json_output

if __name__ == "__main__":
    input_dir = "/tmp/nuclei-templates-main/http/cves/"
    workspace_dir = get_parent_directory(os.path.abspath(__file__), levels=2)
    output_file = os.path.join(workspace_dir, "db", "cves.json")

    converted_data = convert_cves(input_dir)

    with open(output_file, 'w') as f:
        json.dump(converted_data, f, separators=(',', ':'))
