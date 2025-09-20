import sys
import json
import re

def parse_apmag(file_path):
    # Read the file, replacing literal '\n' with actual newlines if present
    with open(file_path, 'r') as f:
        raw = f.read().replace('\\n', '\n')

    lines = raw.splitlines()
    data_started = False
    data = []

    for line in lines:
        line = line.strip()

        if line.startswith("$$SOE"):
            data_started = True
            continue
        elif line.startswith("$$EOE"):
            break

        if data_started and line:
            parts = [p.strip() for p in line.split(',')]
            if len(parts) >= 5:
                date_str = parts[0]
                try:
                    apmag = float(parts[3])
                except ValueError:
                    continue  # Skip lines with invalid magnitude
                data.append({
                    "date": date_str,
                    "apmag": apmag
                })

    return data

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: python extract_apmag.py <input_file>")
        sys.exit(1)

    input_file = sys.argv[1]
    result = parse_apmag(input_file)
    print(json.dumps(result, indent=2))
