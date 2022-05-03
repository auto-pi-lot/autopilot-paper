import os
import pandas as pd

combined_file = '/path/to/logs'

logs = pd.read_pickle(combined_file)

# counting functions
total_messages = logs.shape[0]
id_count = logs[['id', 'io']].groupby('id').count()
key_count = logs[['key', 'io']].groupby('key').count()

# saving timeseries only
logs[['timestamp']].to_csv('/path/to/logs/timestamps.csv')
# or just dropping the other columns...
#logs.drop(['type', 'id', 'io', 'key'], inplace=True, axis=1)

#ts = pd.to_datetime(logs['timestamp'], format="%Y-%m-%d %H:%M:%S,fff")

ts = pd.read_csv('/path/to/logs/timestamps.csv')
ts['timestamp'] = ts['timestamp'].str[:-4]
ts['timestamp'] = pd.to_datetime(ts['timestamp'], format="%Y-%m-%d %H:%M:%S")

#ts.to_pickle(os.path.join(combined_file, 'logs_timestamps_format.pck.xz'), compression="xz")