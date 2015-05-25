#!/usr/bin/env ruby
require "docopt"
require "logger"
require "rugged"
require "./changelog_helpers"
require "pry"


doc = <<DOCOPT
A script to generate release-notes from a git repository

Entries for the release notes must have a special format:

`* fix: <description>`
`* feat: <description>`

Usage:
  #{__FILE__} [--debug]
  #{__FILE__} <from-commit> [--debug]
  #{__FILE__} -h | --help
  #{__FILE__} --version

Options:
  -h --help     Show this screen.
  --version     Show version.
  --debug   Show debug output
DOCOPT

begin
  args =  Docopt::docopt(doc, version: '0.0.1')
rescue Docopt::Exit => e
  puts e.message
  exit
end

logger = Logger.new(STDOUT)
logger.level = args["--debug"] ?  Logger::DEBUG : Logger::ERROR

# Initialize Repo
begin
  repo = Rugged::Repository.discover("/Users/mexx/code/qn/qonnect-enduser-ios")
rescue Rugged::OSError => e
  puts ("Current directory is not a git repo")
  logger.error(e.message)
  exit
end

# From given commit, or from hatest tag
commit_to = commit(repo, args["<to-commit>"], logger) || latestTagID(repo, logger)

# to-commit not yet implemented, will always use head
commit_from = commit(repo, args["<from-commit>"], logger) || repo.head.target

# Initialize a walker that walks through the commits from the <from-commit> to the <to-commit>
walker = Rugged::Walker.new(repo)
walker.sorting(Rugged::SORT_DATE)
walker.push(commit_from)
walker.hide(commit_to)

cnt = 0
for c in walker
  logger.info("c #{cnt} #{c.message}")
  cnt = cnt + 1
  # binding.pry
end


# binding.pry


logger.info("Continue")