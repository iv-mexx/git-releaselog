# git-releaselog

This tool generates release log from a git repository.

Generally, I don't beliefe that its possible to generate good releaselog
from an ordinary git log. 
The git log usually contains very detailed, technical information, targeted
at the maintainers of a project. 

In contrast, the releaselog should be targetet at the users of a project and 
should describe changes relevant to those users at a higher abstraction.

Thats why this tool does not attempt to build a releaselog from normal commit
messages but instead requires special keywords to mark notes that should 
show up in the releaselog.

These [keywords](#markup) can be used in commit messages. See the [Example](#example)
section.

## Usage

The default use is to generate the releaselog starting from the last release 
(the most recent tag) until now.

* `git-releaselog`: will look up the most recent tag and will search all commits from this tag to `HEAD`. 

If you want to controll the range of commits that should be searched, you can 
specify a _commit-hash_ or _tag-name_, e.g.

* `git-releaselog v1.0` will look up the commits starting from the tag with name `v1.0` to `HEAD`.
* `git-releaselog v1.0 7c064bb` will look up the commits starting from the tag with name `v1.0` to the commit `7c064bb`.

Alternatively, you can choose the generate the whole releaselog for the whole repo:

* `git-releaselog --complete` will search the whole git log and group the changes nicely in sections by existing tags.

To control the markup of the output, you can use these options (the default is slack):

* `--slack` produces output that looks nice when copy/pasted into slack
* `--md` produces markdown output in reverse order, e.g this repo's [releaselog]

## Markup

Entries that should show up in the releaselog must have a special format:

`* <keyword>: [<optional-scope] <description>`

The descriptions are extracted from the git history and grouped by keyword. 
Currently, the following keynotes are supported

* `fix`
* `feat`
* `gui`
* `refactor`

### Scope

The releaselog can be limited to a certain __scope__. This is helpful when multiple projects / targets are in the same git repository (E.g. several targets of an app with a large shared codebase).

When a scope is declared for the generation of the releaselog, only entries that are marked with that scope and entries without scope are included into the releaselog.

### Example

Given these lines in a commit message:

```
* feat: [project-x] add a new feature to project-x
* fix: [project-y] fix a bug in project-y
* fix: fix a bug that affected both projects
```
running
```
git-releaselog --scope project-x
```
will generate this releaselog:

```
*Features*
* add a new feature to project-x

*Fixes*
* fix a bug that affected both projects
```

## Usage suggestion

This is just what works best for us: 

* Use guidelines for git commits, e.g. [AngularJS](https://github.com/angular/angular.js/blob/master/CONTRIBUTING.md#commit)
* Use the [Gitflow workflow](https://www.atlassian.com/git/tutorials/comparing-workflows/gitflow-workflow)
* Create Merge Requests for merging feature branches back to develop
  * Feature branch / merge request should address specific features / fixes / ...
  * The description of the merge request should contain markup for the releaselog
  * The description of the merge request should be the commit message of the merge commit (done automatically e.g. by gitlab)

The only additional step from our normal workflow is to use special markup for the change log in the description of a merge request. 
Doing so enables the generation of change logs between arbitrary commits / releases

## Example

The following is an excerpt of the this repos git log:

```
commit fa40cdb51c674df8b4a564e283a601d50fcdd55f
Author: MeXx <mexx@devsub.net>
Date:   Tue May 26 14:04:09 2015 +0200

    fix(repo): back to the local repo

commit 1f4abe3399891cfd429e5aa474e6c414f7e2b3b2
Author: MeXx <mexx@devsub.net>
Date:   Tue May 26 14:02:47 2015 +0200

    feat(releaselog): new feature to create a complete releaselog
    
    * feat: use the `--complete` parameter to generate a complete releaselog over all tags

commit 61fe21959bb52ce09eaf1ee995650c8c4c3b073e
Author: MeXx <mexx@devsub.net>
Date:   Tue May 26 13:18:10 2015 +0200

    refactor(searchChanges): moved the function to search the git log into a function

commit d41dac909757b265d226589ead6a5a57aba5dc87
Author: MeXx <mexx@devsub.net>
Date:   Tue May 26 12:49:00 2015 +0200

    feat(printing): nicer printing of the log
```

Notice, that commit `1f4abe3399891cfd429e5aa474e6c414f7e2b3b2` has an extra line with a `feat` keyword.
The releaselog for these commits looks like this:
`git-releaselog fa40cdb d41dac9 --md`

```
## Unreleased (_26.05.2015_)
#### Fixes
_No new Fixes_

#### Features
* use the `--complete` parameter to generate a complete releaselog over all tags
```

[releaselog]: CHANGELOG.md