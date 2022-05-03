from pathlib import Path
import subprocess

osc_ip = "192.168.0.163"

# check for files in current directory
current_files = list(Path('.').glob('*.txt'))
print(current_files)
trace_n = 0
if len(current_files)>0:
    trace_n = int(current_files[-1].stem.split('_')[-1]) + 1

out_fn = f"OscTrace_{trace_n}.txt"

subprocess.run(['ds1054z', 'save-data', '--filename', out_fn, osc_ip])

