# SaundersWehr-Autopilot2019
Manuscript for Autopilot: https://www.biorxiv.org/content/10.1101/807693v1

# Building

The document is written with [tectonic](https://tectonic-typesetting.github.io/book/latest/). From the `autopilot` directory or any of its subdirectories, to build the document, run 

```bash
tectonic -X build 
```

The built document will then be located in [`autopilot/build/autopilot_v2/autopilot_v2.pdf`](autopilot/build/autopilot_v2/autopilot_v2.pdf).

**Safety Note:** To highlight the code, examples, we use [minted](http://tug.ctan.org/macros/latex/contrib/minted/minted.pdf), which requires the `shell_escape` option (specified in `Tectonic.toml`), which has the potential to run arbitrary code on your computer (we didn't purposely bundle any malware in the document).

See the blog post ["A Halfway Decent LaTeX Writing Setup"](https://jon-e.net/blog/2022/04/16/a-halfway-decent-latex-setup/) for further details and some nice QoL ideas for writing with LaTeX.

## Requirements

To compile the document, you will need

* [tectonic](https://tectonic-typesetting.github.io/book/latest/)
* [pygments](https://pygments.org/)

The fonts used in the document are mostly embedded within the .pdfs when relevant, and the open source fonts have been included in the repository, but to modify any of the source materials, you will need these fonts:

* [EB Garamond](http://www.georgduffner.at/ebgaramond/) - Bold, Italic, Regular - main body font (packaged in [`autopilot/src/garamond`](autopilot/src/garamond))
* [Fedra Mono](https://www.typotheque.com/fonts/fedra_mono) - Bold, Book, Light, Medium, Normal - Figure annotations
* [Fedra Sans Std](https://www.typotheque.com/fonts/fedra_sans) - Bold, Book, Medium, Normal, Condensed Bold, Condensed Medium - Figure axes, figure text.
* [Fira Code](https://github.com/tonsky/FiraCode) - Bold, Retina - In-text code (packaged in [`autopilot/src/fira`](autopilot/src/fira))
* [FontAwesome](https://ctan.org/pkg/fontawesome5) - Some glyphs.
* Loaded by [tufte-latex](https://github.com/Tufte-LaTeX/tufte-latex)
	* Bera Sans - Bold, Roman
	* Menlo - Regular
	* Nimbus Sans
	* PazoMath


# Document Structure

## `autopilot/`

The built document is in `autopilot/build`, and the document source is in `autopilot/src`. The `Tectonic.toml` file configures the build.

The main document text is written with:

* `_preamble.tex` - header material that defines styles, loads packages, etc.
* `autopilot.tex` - Index file that uses `\input` to combine the sections
* `sections/` - Each section is split up into multiple files within subfolders that correspond to the chapters of the paper:
	* `introduction`
	* `design`
	* `structure` - Program AStructure
	* `tests`
	* `conclusion` - Limitations and Future Directions, Glossary
* `_postamble.tex` - Document conclusion stuff.

The remaining files and folders in `src`:

* `autopilot.bib` - Bibliography for the paper exported from Zotero with Better BibTeX
* `version.tex` - A version hash that is included in the title page of the document, generated from a git hook (`.git/hooks/post-commit`).
* `figures`: The figures for the paper. Most are vectors stored as editable `.pdf` files with the flag to retain Illustrator editing features. All figures, including many not included in the first version and removed in the second version, are there. Figures containing data were mostly generated in R using [ggplot2](https://ggplot2.tidyverse.org/) and then styled (without changing the data itself) in Illustrator.
* `fira` and `garamond`: Fonts described above
* `styles`: The document style is a modified version of [tufte-latex](https://github.com/Tufte-LaTeX/tufte-latex). The source is admittedly extremely messy, I sort of hate LaTeX.
* `todo`: a separate todo document used in preparation of v2, kept for the sake of provenance.


## `code/`

The code that analyzed the data and generated the figures. Code for running the tests can be found in the autopilot paper plugin ([wiki](https://wiki.auto-pi-lot.com/index.php/Plugin:Autopilot_Paper), [repo](https://github.com/auto-pi-lot/plugin-paper)).

## `data/`


