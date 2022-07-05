What does it mean to make the autopilot paper into a "paper?"

using pycontrol paper as a guide:

- starts with system overview. 
- comparison to existing systems at the end
- framework vs. system overview. 
- otherwise they do the same kind of module overview.

# potential changes

- No TOC

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
	- Task header example in text rather than as code example.
		- 'why do we separate' these header components
		- -> discussion how this changes the way you do experiments
	- Task methods example
		- To text, then very abbreviated example of each of the components
		- eg. "use hardware objects like this," "then you can just use them in a task by assigning series of triggers," then return data and have it stored in your data model.
	- Maze: Move code example to margin figure
	- Transforms: move kalman filter example to jumping section
	- Description of network topology and 3.15
- Edit:
	- GUI statement "oldest in library" -> moving in a direction of making different components have a GUI representation instead of a separate GUI.
- Move:
	- Behavioral Topologies -> discussion

## Tests

- Split into benchmarks and example tasks
	- Header for example tasks about how each of these examples do things that aren't possible with other systems.
- Add gap detection laser task
	- graduation/shaping
	- example of extending a task to make different verions
	- continuous stimulus generation from a generator as another example of stimuli
- Jumping
	- Put in results section describing it how it works without saying that we've finished it. 
	- Use as an example that summarizes the rest of the way that autopilot works.
	- Then if time allows do a test with accel + gyro + DLC -> integrated signal.

## Reformatting

- Add line numbers lmao
- Sectioning
	- "Methods and Results"
		- Rename "Program Structure"
		- Make Tests a subsection
	- Make "Limitations & Future Directions" part of "discussion"
- Remove Glossary?
- Make "Discussion" section
	- Generally discussing the applicability to biology
		- Behavioral Topologies
		- Wiki/plugin discussion?
	- Or how science should work
		- data hygeine
