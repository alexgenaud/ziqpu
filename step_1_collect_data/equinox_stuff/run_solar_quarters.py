import datetime
import requests
import re


def fetch_solar_longitudes(start_date, stop_date, step="1 d"):
    """
    Fetch ecliptic longitudes of the Sun as seen from Earth using JPL Horizons API.
    """
    url = (
        "https://ssd.jpl.nasa.gov/api/horizons.api?"
        "format=text&"
        "COMMAND=10&"
        "CENTER=500@399&"
        "MAKE_EPHEM=YES&"
        "EPHEM_TYPE=OBSERVER&"
        f"START_TIME=%27{start_date}%27&"
        f"STOP_TIME=%27{stop_date}%27&"
        f"STEP_SIZE=%27{step}%27&"
        "QUANTITIES=31&"
        "REF_SYSTEM=J2000&"
        "REF_PLANE=ECLIPTIC&"
        "CSV_FORMAT=YES"
    )

    # print(url)
    response = requests.get(url)
    raw = response.text.replace("\\n", "\n")
    # print(raw)

    # Extract lines between $$SOE and $$EOE
    match = re.search(r"\$\$SOE(.*?)\$\$EOE", raw, re.DOTALL)
    if not match:
        raise RuntimeError("No ephemeris data found.")

    block = match.group(1).strip()
    data = []
    for line in block.splitlines():

        # parts = [p.strip() for p in line.split(",") if p.strip()]
        parts = [p.strip() for p in line.split(",")]

        try:
            dt = datetime.datetime.strptime(parts[0], "%Y-%b-%d %H:%M")
            longitude = float(parts[3])
            data.append((dt, longitude))
        except (ValueError, IndexError):
            continue
    return data


def find_crossing(data, target_deg):
    """
    Find when ecliptic longitude crosses a specific degree (0, 90, 180, 270).
    Returns an approximate crossing datetime.
    """
    for i in range(1, len(data)):
        prev_time, prev_lon = data[i - 1]
        curr_time, curr_lon = data[i]
        # print(f"{prev_time=} {prev_lon=} {curr_time=} {curr_lon=}")

        # Handle wrap-around at 360 -> 0
        if prev_lon > 350 and curr_lon < 10 and target_deg == 0:
            print(f"{prev_lon=} {curr_lon=} X return {prev_time=} {curr_time=}")
            return prev_time, curr_time

        if prev_lon < target_deg <= curr_lon:
            print(f"{prev_lon=} {curr_lon=} Y return {prev_time=} {curr_time=}")
            return prev_time, curr_time
    return None, None


def refine_crossing(start, stop, target_deg, step="1 m"):
    # TODO if step="1 s" that's illegal, so we must
    # set step to 60 between two conseq minutes like 10:05 and 10:06
    # or step to 120 between 10:05 and 10:07
    if step == "1 s":
        step = "60"
    data = fetch_solar_longitudes(
        start.strftime("%Y-%m-%d %H:%M"), stop.strftime("%Y-%m-%d %H:%M"), step
    )
    # print(f"{data=}")
    return find_crossing(data, target_deg)


def detect_solar_quarters(year):
    events = {
        "march_equinox": 0,
        "june_solstice": 90,
        "september_equinox": 180,
        "december_solstice": 270,
    }

    rough_ranges = {
        "march_equinox": (f"{year}-03-18", f"{year}-03-22"),
        "june_solstice": (f"{year}-06-19", f"{year}-06-23"),
        "september_equinox": (f"{year}-09-20", f"{year}-09-24"),
        "december_solstice": (f"{year}-12-20", f"{year}-12-23"),
    }

    results = {}

    for name, target in events.items():
        start, stop = rough_ranges[name]
        data = fetch_solar_longitudes(start, stop, "1 h")
        # print(f"detect_solar_quarters {name} {data=}")
        t1, t2 = find_crossing(data, target)
        if not t1 or not t2:
            print(f"⚠️ Could not find crossing for {name}")
            continue
        t1, t2 = refine_crossing(t1, t2, target, "1 m")
        if t1 and t2:
            final_t1, final_t2 = refine_crossing(t1, t2, target, "1 s")
            crossing_time = final_t1 + (final_t2 - final_t1) / 2
            results[name] = crossing_time.strftime("%Y-%m-%d %H:%M:%S")
            print(f"✅ {name.replace('_', ' ').title()}: {results[name]}")
        else:
            print(f"⚠️ Could not refine crossing for {name}")

    return results


if __name__ == "__main__":
    import sys

    year = int(sys.argv[1]) if len(sys.argv) > 1 else datetime.datetime.now().year
    print(f"🔍 Finding equinoxes and solstices for {year}")
    detect_solar_quarters(year)
