import json
import csv
import glob
import os

def generate_csv_headers():
    # Find all json files in tables directory
    json_files = glob.glob('tables/*.json')
    
    for json_file in json_files:
        try:
            with open(json_file, 'r') as f:
                data = json.load(f)
            
            # Extract headers from the schema 'name' field
            if isinstance(data, list):
                headers = [item['name'] for item in data if 'name' in item]
                
                if headers:
                    # Create csv filename
                    csv_file = os.path.splitext(json_file)[0] + '.csv'
                    
                    with open(csv_file, 'w', newline='') as f:
                        writer = csv.writer(f)
                        writer.writerow(headers)
                    
                    print(f"Created {csv_file}")
                else:
                    print(f"No headers found in {json_file}")
            else:
                print(f"Unexpected format in {json_file}")
                
        except Exception as e:
            print(f"Error processing {json_file}: {e}")

if __name__ == "__main__":
    generate_csv_headers()
