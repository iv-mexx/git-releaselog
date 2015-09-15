## Version 0.4.1

*Fixes*
* fix executable name in gemspec

*Features*
*  new cmd-line parameter `format` instead of `--slack` and `--md` flags

## Version 0.4.0

*Features*
* this gem can now be "require"d from and be used in other ruby files

## Version 0.3.0

*Features*
* add scopes for filtering changelog entries
* new change type: "gui"
* gemspec added, so the tool can be built and installed as a ruby gem

## Version 0.2.1
*Fixes*
* the output format is not stuck to `md` anymore and defaults to `slack`
* complete changelog now also works if there is only one tag in the repo

*Features*
* Its now possible to generate the output with markdown syntax

## Version 0.2.0
*Fixes*
* The changelog is now correctly generated until the last tag if nothing is specified

*Features*
* use the `--complete` parameter to generate a complete changelog over all tags

## Version 0.1.0
*Fixes*
* The command line help now displays the correct arguments
* The git commits are now traversed correctly

*Features*
* It's now possible to specify both, `from`- and `to` commits.