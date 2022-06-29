What does it mean to make the autopilot paper into a "paper?"

using pycontrol paper as a guide:

- starts with system overview. 
- comparison to existing systems at the end
- framework vs. system overview. 
- otherwise they do the same kind of module overview.

# potential changes

## Design

- Keep:
	- header introducing the notion of using raspis
- Merge:
	- standardized task descriptions -> program structure:tasks
	- self-documenting data -> program structure:data
- Move:
	- testing & CI -> discussion
	- abbreviate expense -> discussion
- Nuke the rest

## Program Structure

- Remove:
	- Directory Structure
	- Data example (RIP accessible code communication)
	- Description of network topology, figure 3.14 and 3.15?
- Move:
	- Behavioral Topologies -> discussion

## Tests

- Add gap detection laser task
- ???


## Reformatting

- Sectioning
	- Rename "Program Structure" as "Results"
	- Make Tests a subsection in "Results"
	- Make "Limitations & Future Directions" part of "discussion"
- Remove Glossary?
- Make "Discussion" section
	- Generally discussing the applicability to biology
		- Behavioral Topologies
		- Wiki/plugin discussion?
