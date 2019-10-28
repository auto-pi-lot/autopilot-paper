import sys
import os
from tqdm import tqdm
import pandas as pd
import datetime

sys.path.append('/path/to/autopilot/repo')

from autopilot.core.mouse import Mouse

data_dir = '/path/to/data/files'

total_trials = 0
for mouse_file in tqdm(os.listdir(data_dir)):
    amus = Mouse(file=os.path.join(data_dir, mouse_file))
    tr = amus.get_trial_data(step='all')
    total_trials += tr.shape[0]

print(total_trials)

# find earliest training day

earliest_day = datetime.datetime.now()
for mouse_file in tqdm(os.listdir(data_dir)):
    amus = Mouse(file = os.path.join(data_dir, mouse_file))
    tr = amus.get_trial_data(step='all')
    try:
        first_ts = pd.to_datetime(tr.loc[0,'timestamp'].decode(), format='%Y-%m-%dT%H:%M:%S.%f')
    except:
        first_ts = pd.to_datetime(tr.loc[0, 'RQ_timestamp'].decode(), format='%Y-%m-%dT%H:%M:%S.%f')
        #print('first table of {} was blank'.format(mouse_file))
        #continue
    if first_ts < earliest_day:
        earliest_day = first_ts

print(earliest_day)