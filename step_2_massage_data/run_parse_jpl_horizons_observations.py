import sys
import json
from datetime import datetime

def parse_apmag(file_path):
    # Read file, replacing literal '\n' with actual newlines if present
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
                raw_date = parts[0]
                try:
                    # Parse using format like "2025-Dec-31 20:00"
                    dt = datetime.strptime(raw_date, "%Y-%b-%d %H:%M")
                    date_str = dt.strftime("%Y-%m-%d %H:%M")
                    apmag = float(parts[3])
                    data.append({
                        "date": date_str,
                        "apmag": apmag
                    })
                except ValueError:
                    continue  # Skip any malformed lines

    return data

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: python run_parse_jpl_horizons_observations.py <input_file>")
        sys.exit(1)

    input_file = sys.argv[1]
    result = parse_apmag(input_file)
    print(json.dumps(result, indent=2))

