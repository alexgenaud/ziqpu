python run_parse_jpl_horizons_vectors.py ../step_1_collect_nasa_jpl_data/helio_199_hourly.txt >helio_199mercury.json
python run_parse_jpl_horizons_vectors.py ../step_1_collect_nasa_jpl_data/helio_299_hourly.txt >helio_299venus.json
python run_parse_jpl_horizons_vectors.py ../step_1_collect_nasa_jpl_data/helio_399_hourly.txt >helio_399earth.json
python run_parse_jpl_horizons_vectors.py ../step_1_collect_nasa_jpl_data/helio_499_hourly.txt >helio_499mars.json
python run_parse_jpl_horizons_vectors.py ../step_1_collect_nasa_jpl_data/helio_599_hourly.txt >helio_499jupiter.json
python run_parse_jpl_horizons_vectors.py ../step_1_collect_nasa_jpl_data/helio_699_hourly.txt >helio_499saturn.json

python run_parse_jpl_horizons_vectors.py ../step_1_collect_nasa_jpl_data/geo_10_hourly.txt >geo_10sun.json
python run_parse_jpl_horizons_vectors.py ../step_1_collect_nasa_jpl_data/geo_199_hourly.txt >geo_199mercury.json
python run_parse_jpl_horizons_vectors.py ../step_1_collect_nasa_jpl_data/geo_299_hourly.txt >geo_299venus.json
python run_parse_jpl_horizons_vectors.py ../step_1_collect_nasa_jpl_data/geo_301_hourly.txt >geo_301moon.json
python run_parse_jpl_horizons_vectors.py ../step_1_collect_nasa_jpl_data/geo_499_hourly.txt >geo_499mars.json
python run_parse_jpl_horizons_vectors.py ../step_1_collect_nasa_jpl_data/geo_599_hourly.txt >geo_599jupiter.json
python run_parse_jpl_horizons_vectors.py ../step_1_collect_nasa_jpl_data/geo_699_hourly.txt >geo_699saturn.json

python run_parse_jpl_horizons_observations.py ../step_1_collect_nasa_jpl_data/observe_10_hourly.txt >observe_10sun.json
python run_parse_jpl_horizons_observations.py ../step_1_collect_nasa_jpl_data/observe_199_hourly.txt >observe_199mercury.json
python run_parse_jpl_horizons_observations.py ../step_1_collect_nasa_jpl_data/observe_299_hourly.txt >observe_299venus.json
python run_parse_jpl_horizons_observations.py ../step_1_collect_nasa_jpl_data/observe_301_hourly.txt >observe_301moon.json
python run_parse_jpl_horizons_observations.py ../step_1_collect_nasa_jpl_data/observe_499_hourly.txt >observe_499mars.json
python run_parse_jpl_horizons_observations.py ../step_1_collect_nasa_jpl_data/observe_599_hourly.txt >observe_599jupiter.json
python run_parse_jpl_horizons_observations.py ../step_1_collect_nasa_jpl_data/observe_699_hourly.txt >observe_699saturn.json
