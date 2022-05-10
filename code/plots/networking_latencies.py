"""
Extract and summarize networking latencies from subject
"""

from autopilot.data import Subject
import numpy as np

sub = Subject('network_latency')
# get last (only) stage data
data = sub.get_trial_data(-1)

# aggregation functions for computing first and third quartile
def q1(x):
    np.quantile(x, q=0.25)

def q3(x):
    np.quantile(x, q=0.75)

# summary of all sessions
# (first several are debugging sessions)
latency_summary = data.groupby('session'
    ).agg(['median', 'count', q1, q3])

latency_summary.to_csv('network_latency_summary.csv')
data.to_csv('network_latency.csv')

