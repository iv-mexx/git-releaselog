# GIT-Changelog

This is a small script that generates changelog from a git log.


Generally, I don't beliefe that its possible to generate good changelog
from an ordinary git log. The git log usually contains much more information 
thats more detailled than needed in the changelog and it is not reasonable 
to change that.

Thats why this tool requires special mark up for entries that should show up
in the changelog.

## Markup

Entries that should show up in the changelog must have a special format:

`* <keyword>: <description>`

The descriptions are extracted from the git history and grouped by keyword. 
Currently, the following keynotes are supported

* `fix`
* `feat`

## Usage suggestion

This is just what works best for us: 

* Use guidelines for git commits, e.g. [AngularJS](https://github.com/angular/angular.js/blob/master/CONTRIBUTING.md#commit)
* Use the [Gitflow workflow](https://www.atlassian.com/git/tutorials/comparing-workflows/gitflow-workflow)
* Create Merge Requests for merging feature branches back to develop
  * Feature branch / merge request should address specific features / fixes / ...
  * The description of the merge request should contain markup for the changelog
  * The description of the merge request should be the commit message of the merge commit (done automatically e.g. by gitlab)

The only additional step from our normal workflow is to use special markup for the change log in the description of a merge request. 
Doing so enables the generation of change logs between arbitrary commits / releases