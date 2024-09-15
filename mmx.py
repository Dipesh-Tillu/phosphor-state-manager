#!/usr/bin/env python3

import os
import json
import sys
from pathlib import Path

class GCovFilesAnalysis:
    def __init__(self, code_source_path):
        self._code_source_path = code_source_path
        self._test_mapping_matrix = {}

    def process_files(self, path_directory):
        for entry in os.scandir(path_directory):
            file_path = Path(entry.path)
            if file_path.suffix == '.json':
                with open(file_path, 'r') as json_file:
                    json_file_data = json_file.read()
                self.process_json_file(json_file_data)

    def process_json_file(self, json_file_data):
        if not json_file_data:
            return

        try:
            doc = json.loads(json_file_data)
        except json.JSONDecodeError:
            print("Invalid JSON data")
            return

        for file_tag in doc.get("files", []):
            code_file = file_tag.get("file", "")

            if not code_file.startswith(self._code_source_path):
                continue

            print("Code file: " + code_file);
            for function_tag in file_tag.get("functions", []):
                if function_tag.get("execution_count", 0) > 0:
                    function_name = function_tag.get("demangled_name", "")
                    print("Function name: " + function_name);
                    if code_file not in self._test_mapping_matrix:
                        self._test_mapping_matrix[code_file] = set()
                    self._test_mapping_matrix[code_file].add(function_name)

    def get_test_mapping_matrix(self):
        return {k: list(v) for k, v in self._test_mapping_matrix.items()}

def print_usage():
    print("""
Usage: mmx <source_folder> <json_folder> <output_file>

Generate a traceability matrix from GCOV JSON files.

Arguments:
  <source_folder>  Path to the source code folder. This is used to filter
                   the files in the coverage data.
  <json_folder>    Path to the folder containing GCOV JSON files.
  <output_file>    Path where the traceability matrix JSON will be saved.

Example:
  mmx /path/to/source/code /path/to/gcov/json/files /path/to/output/traceability_matrix.json

Description:
  This script processes GCOV JSON files to create a traceability matrix.
  It maps source files to the functions that were executed during testing.
  The resulting matrix is saved as a JSON file, which can be used for
  further analysis or reporting.

  The source folder is used to filter the coverage data, ensuring that
  only files within the specified source directory are included in the
  traceability matrix.
    """)

def main(source_folder, json_folder, output_file):
    gcov_analysis = GCovFilesAnalysis(source_folder)
    gcov_analysis.process_files(json_folder)
    result = gcov_analysis.get_test_mapping_matrix()
    
    with open(output_file, 'w') as f:
        json.dump(result, f, indent=2)
    
    print(f"Traceability matrix has been saved to {output_file}")

if __name__ == "__main__":
    if len(sys.argv) != 4 or sys.argv[1] in ['-h', '--help']:
        print_usage()
        sys.exit(1 if len(sys.argv) != 4 else 0)
    
    source_folder = sys.argv[1]
    json_folder = sys.argv[2]
    output_file = sys.argv[3]
    
    main(source_folder, json_folder, output_file)

