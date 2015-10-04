## Unreleased

#### Fix
* When there is no `to_tag`, the release log now correctly displays "Unreleased" again instead of the latest tag name
* Generating a release log from/to commit hashes now works again

#### Gui
* Markdown output for change-sections now as sub-sub-sub-headline instead of italic

## 0.7.0

#### Fix
* `--complete` option now generates a correct release log again
* tag-info does not display date-markup without date if there is no date
* --complete option does not crash the tool anymore

#### Feature
* Travis CI setup and activated for this project

#### Refactor
* Pack everything into a module (`Releaselog`)

## 0.6.0

#### Fix
* During changelog generation, use `commit_to` and `tag_to` instead of `commit_from` and `tag_from` to make an execution like `git-changelog 0.4.0 --format=slack` display information about the version being currently released

#### Feature
* Got us started with a basic rspec setup and some test for the most complicated new methods in `lib/changelog.rb`
* Add basic .travis.yml file to be able to start with CI

#### Refactor
* Token for a `refactor` change has been changed from `* refactoring` to `* refactor`
* Keys of the `change` getter have been changed from (`fixes`, `features`, `gui`, `refactoring`) to (`fix`, `feature`, `gui`, `refactor`)
* Moved changelog formatting into `lib/changelog.rb`
* Added various helper methods to make it easier to change formatting output and to make it less error-prone to change displayed information across multiple formats
* Change `Changelog#changes` to return hash keys `gui` and `refactoring` instead of `gui_changes` and `refactorings`

## 0.5.1

#### Fix
* strip note to make scope parsing more resilient

## 0.5.0

#### Fix
* use the correct date when rendering the changelog
* use the correct date when rendering the changelog

#### Feature
* add a new `refactoring` tag
* add a new `refactoring` tag
* A new `raw` format has been added that just returns the Chang…
* A new `raw` format has been added that just returns the Changelog object. Usefull when using the gem in another Ruby programm.

## 0.4.1

#### Fix
* fix executable name in gemspec

#### Feature
* new cmd-line parameter `format` instead of `--slack` and `--md` flags

## 0.4.0

#### Feature
* this gem can now be "require"d from and be used in other ruby files

## 0.3.0

#### Feature
* add scopes for filtering changelog entries
* new change type: "gui"
* gemspec added, so the tool can be built and installed as a ruby gem

## 0.2.1

#### Fix
* the output format is not stuck to `md` anymore and defaults to `slack`
* complete changelog now also works if there is only one tag in the repo

#### Feature
* Its now possible to generate the output with markdown syntax

## 0.2.0

#### Fix
* The changelog is now correctly generated until the last tag if nothing is specified

#### Feature
* use the `--complete` parameter to generate a complete changelog over all tags

## 0.1.0

#### Fix
* The command line help now displays the correct arguments
* The git commits are now traversed correctly

#### Feature
* It's now possible to specify both, `from`- and `to` commits.

