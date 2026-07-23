import datetime
import sys


def parse_horizons_observer_csv(file_path):
    data = []
    with open(file_path, "r") as f:
        lines = f.read().replace("\\n", "\n").splitlines()

    parsing = False
    for line in lines:
        if "$$SOE" in line:
            parsing = True
            continue
        if "$$EOE" in line:
            break
        if not parsing:
            continue
        if not line.strip():
            continue

        parts = [p.strip() for p in line.split(",")]

        try:
            dt = datetime.datetime.strptime(parts[0], "%Y-%b-%d %H:%M")
            lon = float(parts[3])
        except Exception as e:
            print(f"Skipping line: {line}\nReason: {e}")
            continue

        data.append((dt, lon))

    return data


def find_longitude_crossing(data):
    """
    Finds the transition from ~359.99 to ~0.00 degrees.
    Uses simple linear interpolation to estimate the crossing time.
    """
    for i in range(1, len(data)):
        prev_time, prev_lon = data[i - 1]
        curr_time, curr_lon = data[i]

        # Crossing from near 360° to 0°
        if prev_lon > 359 and curr_lon < 1:
            # Estimate the crossing time between prev_time and curr_time
            total_seconds = (curr_time - prev_time).total_seconds()
            delta_lon = (curr_lon + 360 if curr_lon < prev_lon else curr_lon) - prev_lon

            # linear interpolation factor
            frac = (360 - prev_lon) / delta_lon
            crossing_time = prev_time + datetime.timedelta(seconds=frac * total_seconds)

            return crossing_time, prev_lon, curr_lon

    return None, None, None


if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: python find_equinox.py <horizons_output.txt>")
        sys.exit(1)

    file_path = sys.argv[1]
    data = parse_horizons_observer_csv(file_path)

    crossing_time, lon1, lon2 = find_longitude_crossing(data)
    if crossing_time:
        print(f"\n🌞 Equinox Detected!")
        print(f"Crossing Time: {crossing_time.strftime('%Y-%m-%d %H:%M:%S')}")
        print(f"From longitude {lon1:.6f}° to {lon2:.6f}°")
    else:
        print("No 360° → 0° longitude crossing found in dataset.")
