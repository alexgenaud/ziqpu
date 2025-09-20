import json
import re
import sys

def parse_vectors(file_path):
    with open(file_path, 'r') as f:
        raw = f.read()

    # Replace escaped newlines with real newlines
    raw = raw.replace('\\n', '\n')

    # Extract block between $$SOE and $$EOE
    match = re.search(r'\$\$SOE(.*?)\$\$EOE', raw, re.DOTALL)
    if not match:
        raise ValueError("Vector data block not found in file.")

    data_block = match.group(1).strip()
    parsed_data = []
    for line in data_block.splitlines():
        fields = [f.strip() for f in line.split(',')]
        if len(fields) < 6:
            continue

        jdtdb = float(fields[0])
        calendar_date = fields[1]
        x = float(fields[2])
        y = float(fields[3])
        z = float(fields[4])

        parsed_data.append({
            'jdtdb': jdtdb,
            'date': calendar_date,
            'x': x,
            'y': y,
            'z': z
        })

    return parsed_data

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: python parse_vectors.py <file_path>")
        sys.exit(1)

    file_path = sys.argv[1]
    data = parse_vectors(file_path)
    print(json.dumps(data, indent=2))
