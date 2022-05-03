import sys
import os
from tqdm.rich import tqdm
import pandas as pd
import datetime
import tables
from pathlib import Path
from typing import TypedDict

class TrialSummary(TypedDict):
    subject: str
    task: str
    step: str
    n_trials: int


data_path = Path.home() / "Dropbox" / "lab" / "autopilot" / "data"
subjects = list(data_path.glob('*.h5'))

# counting manually because the table structure of 
# the subject file changed in v0.5.0 and automatically
# recreates a new file which can take awhile and this
# is almost as easy

summaries = []
for subject in tqdm(subjects):
    subject_id = subject.stem
    h5f = tables.open_file(str(subject), 'r')
    for table in h5f.walk_nodes('/data', classname="Table"):
        summary = TrialSummary(
            subject = subject_id, 
            step = table._v_parent._v_name,
            task = table._v_parent._v_parent._v_name,
            n_trials = table.nrows
        )
        summaries.append(summary)
    h5f.close()

df = pd.DataFrame(summaries)
df.to_csv('./trial_counts.csv', index=False)

print(f"Total subjects: {len(subjects)}\nTotal trials: {df['n_trials'].sum()}")