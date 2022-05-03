import os
from tqdm import tqdm
import pandas as pd
from pandas.api.types import union_categoricals

log_dir = '/path/to/logs'

log_fn = [f for f in os.listdir(log_dir) if f.startswith('logs_collected')]

log_dfs = []
for log_f in tqdm(log_fn, desc="Loading log pieces..."):
    df = pd.read_pickle(os.path.join(log_dir, log_f)).astype({'key': 'category', 
                                                             'type': 'category', 
                                                             'id': 'category', 
                                                             'io': 'category',
                                                             'timestamp':'datetime64[s]'})
    #df.loc['timestamp'] = df['timestamp'].str[:-4]
    #df.loc['timestamp'] = pd.to_datetime(df['timestamp'], format="%Y-%m-%d %H:%M:%S")
    log_dfs.append(df)

# get levels for categories
print('key levels')
key_cats = union_categoricals([x['key'] for x in log_dfs]).categories
print('type levels')
type_cats = union_categoricals([x['type'] for x in log_dfs]).categories
print('id levels')
id_cats = union_categoricals([x['id'] for x in log_dfs]).categories
print('io levels')
io_cats = union_categoricals([x.io for x in log_dfs]).categories

# set levels
for x in tqdm(log_dfs, desc="setting levels"):
    x['key'] = pd.Categorical(x['key'], categories=key_cats)
    x['type'] = pd.Categorical(x['type'], categories=type_cats)
    x['id'] = pd.Categorical(x['id'], categories=id_cats)
    x['io'] = pd.Categorical(x['io'], categories=io_cats)

great_df = pd.concat(log_dfs, axis=0, ignore_index=True)
save_fn = os.path.join(log_dir, 'logs_all_collected_dtypes.pck.xz')
great_df.to_pickle(save_fn, compression='xz')
