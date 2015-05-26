# GIT-Changelog

This is a small script that generates changelog from a git log.


Generally, I don't beliefe that its possible to generate good changelog
from an ordinary git log. 
The git log usually contains very detailed, technical information, targeted
at the maintainers of a project. 

In contrast, the changelog should be targetet at the users of a project and 
should describe changes relevant to those users at a higher abstraction.

Thats why this tool does not attempt to build a changelog from normal commit
messages but instead requires special keywords to mark notes that should 
show up in the changelog.

These [keywords](#markup) can be used in commit messages. See the [Example](#example)
section.

## Usage

The default use is, to generate the changelog starting from the last release 
(the most recent tag) until now.

* `./changelog.rb`: will look up the most recent tag and will search all commits from this tag to
`HEAD`. 

If you want to controll the range of commits that should be searched, you can 
specify a _commit-hash_ or _tag-name_, e.g.

* `./changelog.rb v1.0` will look up the commits starting from the tag with name `v1.0` to `HEAD`.
* `./changelog.rb v1.0 7c064bb` will look up the commits starting from the tag with name `v1.0` to the commit `7c064bb`.

Alternatively, you can choose the generate the whole changelog for the whole repo:

* `./changelog.rb --complete` will search the whole git log and group the changes nicely in sections by existing tags.

To control in which format the output should be marked up, you can use these options (the default is slack):

* `--slack` produces output that looks nice when copy/pasted into slack
* `--md` produces markdown output in reverse order, e.g this repo's [Changelog]

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

    feat(changelog): new feature to create a complete changelog
    
    * feat: use the `--complete` parameter to generate a complete changelog over all tags

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
The changelog for these commits looks like this:
`./changelog.rb fa40cdb d41dac9 --md`

```
## Unreleased (_26.05.2015_)
#### Fixes
_No new Fixes_

#### Features
* use the `--complete` parameter to generate a complete changelog over all tags
```

[Changelog]: CHANGELOG.md