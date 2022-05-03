import os
import re
from tqdm import tqdm
import pandas as pd
import traceback
import pdb

log_dir = '/path/to/logs'

log_files = os.listdir(log_dir)

net_logs = [l for l in log_files if l.startswith('Net')]

hyphen_split = re.compile('(?<!_)_')
keyfinder_1 = re.compile('(?<=KEY: )\S*')
keyfinder_2 = re.compile('(?<=\'key\': )\S*')

all_lines = []

failure_bar = tqdm(position=2, desc='failures', mininterval=0.5)
split_bar = tqdm(position=3, desc='splits saved', mininterval=0.5)
total_bar = tqdm(position=4, desc='total messages', mininterval=0.5)

split_number = 0


def save_checkpoint(all_lines, split_number):

    df = pd.DataFrame.from_records(
        all_lines, 
        columns=('type', 'id', 'timestamp', 'io', 'key'))

    df.loc[df.io == 'TARGET','io'] = 'RECEIVED'

    df = df.astype({'key': 'category', 
              'type': 'category',
              'id': 'category', 
              'io': 'category'})

    df['timestamp'] = df['timestamp'].str[:-4]
    df['timestamp'] = pd.to_datetime(df['timestamp'], format="%Y-%m-%d %H:%M:%S")

    #pdb.set_trace()

    save_path = os.path.join(log_dir, 'logs_collected_{}.pck.xz'.format(split_number))

    df.to_pickle(save_path, compression='xz')

msg_num = 0

for log in tqdm(net_logs, position=0, mininterval=0.5):
    # get identifying info
    stripped_fn = log[0:-18]
    log_class, log_id = hyphen_split.split(stripped_fn, 1)
    if log_id == "Log":
        log_id = 'Terminal'

    # get number of lines
    # with open(os.path.join(log_dir, log), 'r') as logf:
    #     for i, l in enumerate(logf):
    #         pass
    # n_lines = i+1

    with open(os.path.join(log_dir, log), 'r') as logf:
        #lines = [logf.readline() for i in range(10)]
        # for line in tqdm(logf, position=1, total=n_lines, mininterval=0.5):
        for line in tqdm(logf, position=1, mininterval=0.2):

            try:
                timestamp = None
                log_type = None
                key_str = None

                # timestamps are alway the first 23 chars

                timestamp = line[0:23]

                # section after the level indicator
                log_level = line[24:].split(' : ', 1)[0]
                if log_level == 'WARNING':
                    continue
                message = line.split(' : ', 1)[1]
                if message.endswith('Logging Initiated\n') or message.endswith('Starting IOLoop\n') or message.startswith('CONFIRMED MESSAGE') or message.startswith('Received kill request') or message.startswith('Received ALIVE'):
                    continue

                if msg_num < 42000000:
                    msg_num += 1
                    total_bar.update()
                    continue

                try:
                    log_type, msg_content = message.split(' - ', 1)
                    if log_type.startswith("REPUBLISH"):
                        log_type = "REPUBLISH"
                    if log_type not in ('MESSAGE SENT', 'RECEIVED', 'REPUBLISH', 'PUBLISH', 'LISTEN', 'MESSAGE'):
                        log_type = message.split(':')[0].split(' - ')[1]
                except ValueError:
                    log_type, msg_content = message.split(': ', 1)
                    #key_str = [k for k in msg_content.split('; ') if k.startswith('KEY')][0]
                    #key_str = key_str.lstrip('KEY: ')
                except:
                    print(line)
                    continue

                key_str = keyfinder_1.findall(message)
                if len(key_str) == 0:
                    key_str = keyfinder_2.findall(message)
                assert(len(key_str) == 1)
                key_str = key_str[0].rstrip(';').strip(',').strip("'")

                all_lines.append((log_class, log_id, timestamp, log_type, key_str))
                total_bar.update()
            except Exception as e:
                with open(os.path.join(log_dir, 'compilation_log.txt') ,'a') as errorf:
                    errorf.write(str(line))
                    errorf.write(str(e))
                    errorf.write(traceback.format_exc())
                    errorf.write('')
                    failure_bar.update()

            # if len(all_lines) >= 1000000:
            #     save_checkpoint(all_lines, split_number)
            #     split_number += 1
            #     split_bar.update()
            #     all_lines = []

# one last save to catch the stragglers
#save_checkpoint(all_lines, split_number)
save_checkpoint(all_lines, 42)








