#!/usr/bin/env rubyrequire "docopt"

doc = <<DOCOPT
A script to generate release-notes from a git repository

Entries for the release notes must have a special format:

`* fix: <description>`
`* feat: <description>`

Usage:
  #{__FILE__} changelog
  #{__FILE__} changelog <from-commit>
  #{__FILE__} changelog <from-commit>..<to-commit>
  #{__FILE__} -h | --help
  #{__FILE__} --version

Options:
  -h --help     Show this screen.
  --version     Show version.
DOCOPT

begin
  require "pp"
  pp Docopt::docopt(doc)
rescue Docopt::Exit => e
  puts e.message
end