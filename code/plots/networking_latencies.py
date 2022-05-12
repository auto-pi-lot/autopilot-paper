"""
Extract and summarize networking latencies from subject
"""

from autopilot.data import Subject
import numpy as np
import pandas as pd
from pathlib import Path


def export_latency(
        subject:str="network_latency",
        output_dir:Path=Path('.')
    ):

    output_dir = Path(output_dir)

    sub = Subject(subject)
    # get last (only) stage data
    data = sub.get_trial_data(-1)

    data['send_time'] = pd.to_datetime(data['send_time'])
    data['recv_time'] = pd.to_datetime(data['recv_time'])
    data['latency'] = (data['recv_time'] - data['send_time']).dt.total_seconds()

    # aggregation functions for computing first and third quartile
    def q1(x):
        return np.quantile(x, q=0.25)

    def q3(x):
        return np.quantile(x, q=0.75)

    # summary of all sessions
    # (first several are debugging sessions)
    latency_summary = data.groupby('session'
        ).agg(['median', 'count', q1, q3])

    latency_summary.to_csv(output_dir / 'network_latency_summary.csv')
    data.to_csv(output_dir / 'network_latency.csv')


