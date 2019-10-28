from fsm import FiniteStateMachine, State
import itertools

STATES = [
    "A",
    "AC",
    "ACE",
    "ACEM",
    "ACEMU",
    "ACEMK",
    "ACK",
    "ACKM",
    "ACKME",
    "ACKMU",
    "ACKS",
    "ACKSU",
    "ACKSQ",
    "ACKI",
    "ACKIQ",
    "AI",
    "AIQ",
    "AIQS",
    "AIQSK",
    "AIQSU",
    "AIK",
    "AIKC",
    "AIKCE",
    "AIKM",
    "AIKME",
    "AIKMU",
    "AIKS",
    "AIKSQ",
    "AIKSU",
    "REWARD",
    "PUNISHMENT"
    ]

bad_states = [s for s in STATES if (s != "ACKMU") and (len(s) == 5)]

maze = FiniteStateMachine("maze")



states = {}
states['A'] = State('A', initial=True)
for state in STATES[1:]:
    states[state] = State(state)
    states[state].DOT_ATTRS['shape'] = 'rectangle'
    states[state].DOT_ATTRS['height'] = 0.3

states['REWARD'].DOT_ATTRS['fillcolor'] = 'green'
states['PUNISHMENT'].DOT_ATTRS['fillcolor'] = 'red'

states['A'].update({'right': states['AC'],
                    'down' : states['AI']})

states['AC'].update({'right': states['ACE'],
                     'down' : states['ACK']})

states['ACE'].update({'down': states['ACEM']})

states['ACEM'].update({'left': states['ACEMK'],
                       'down': states['ACEMU']})

states['ACK'].update({'left': states['ACKI'],
                      'down': states['ACKS'],
                      'right': states['ACKM']})

states['ACKI'].update({'down': states['ACKIQ']})

states['ACKS'].update({'left': states['ACKSQ'],
                       'right': states['ACKSU']})

states['ACKM'].update({'up': states['ACKME'],
                      'down': states['ACKMU']})

states['AI'].update({'right': states['AIK'],
                     'down': states['AIQ']})

states['AIK'].update({'up': states['AIKC'],
                      'right': states['AIKM'],
                      'down': states['AIKS']})

states['AIKC'].update({'right': states['AIKCE']})

states['AIKM'].update({'up': states['AIKME'],
                       'down': states['AIKMU']})

states['AIKS'].update({'left': states['AIKSQ'],
                       'right': states['AIKSU']})

states['AIQ'].update({'right': states['AIQS']})

states['AIQS'].update({'up': states['AIQSK'],
                       'right': states['AIQSU']})

# win state
states['ACKMU'].update({'': states["REWARD"]})

#states['REWARD'].update({'restart task': states['A']})

# lose state

for state in bad_states:
    states[state].update({'': states['PUNISHMENT']})

#states['PUNISHMENT'].update({'restart task': states['A']})




def get_graph(fsm, title=None):
    """Generate a DOT graph with pygraphviz."""
    try:
        import pygraphviz as pgv
    except ImportError:
        pgv = None

    if title is None:
        title = fsm.name
    elif title is False:
        title = ''

    fsm_graph = pgv.AGraph(title=title, splines='ortho', **fsm.DOT_ATTRS)
    fsm_graph.node_attr.update(State.DOT_ATTRS)

    for state in [fsm.init_state] + fsm.states:
        shape = State.DOT_ATTRS['shape']
        if hasattr(fsm, 'accepting_states'):
            if id(state) in [id(s) for s in fsm.accepting_states]:
                shape = state.DOT_ACCEPTING
        fsm_graph.add_node(n=state.name, **state.DOT_ATTRS)

    #fsm_graph.add_node('null', shape='plaintext', label=' ')
    #fsm_graph.add_edge('null', fsm.init_state.name)

    for src, input_value, dst in fsm.all_transitions:
        label = str(input_value)
        fsm_graph.add_edge(src.name, dst.name, xlabel=label, splines='ortho')
    for state in fsm.states:
        if state.default_transition is not None:
            fsm_graph.add_edge(state.name, state.default_transition.name,
                               label='else', splines='ortho')
    return fsm_graph

graph = get_graph(maze)
graph.draw('maze_render.pdf', prog="dot")



