#!/usr/bin/env ruby
require "docopt"
require "logger"
require "rugged"
require "./lib/changelog_helpers"
require "pry"


doc = <<DOCOPT
A script to generate release-notes from a git repository

Entries for the release notes must have a special format:

`* fix: <description>`
`* feat: <description>`

Usage:
#{__FILE__} [--debug]
#{__FILE__} <from-commit> [--debug]
#{__FILE__} <from-commit> <to-commit> [--debug]
#{__FILE__} -h | --help
#{__FILE__} --version

Options:
from-commit   From which commit should the log be followed? Will default to head
to-commit     To which commit should the log be followed? Will default to the latest tag
-h --help     Show this screen.
--version     Show version.
--debug       Show debug output
DOCOPT

# Parse Commandline Arguments
begin
  args =  Docopt::docopt(doc, version: '0.0.1')
rescue Docopt::Exit => e
  puts e.message
  exit
end

# Initialize Logger
logger = Logger.new(STDOUT)
logger.level = args["--debug"] ?  Logger::DEBUG : Logger::ERROR

# Initialize Repo
begin
  repo = Rugged::Repository.discover(".")
rescue Rugged::OSError => e
  puts ("Current directory is not a git repo")
  logger.error(e.message)
  exit
end

arg_from = args["<from-commit>"]
arg_to = args["<to-commit>"]

# Find if we're operating on tags
tag_from = tagWithName(repo, arg_from)
tag_to = tagWithName(repo, arg_to)
tag_latest = latestTagID(repo, logger)

if tag_from
  logger.info("Found Tag #{tag_from.name} to start from")
end

if tag_to
  logger.info("Found Tag #{tag_to.name} to end at")
end

if tag_latest
  logger.info("Latest Tag found: #{tag_latest.name}")
end


# From which commit should the log be followed? Will default to head
commit_from = (tag_from && tag_from.target) || commit(repo, arg_from, logger) || repo.head.target

# To which commit should the log be followed? Will default to the latest tag
commit_to = (tag_to && tag_to.target) || commit(repo, arg_to, logger) || tag_latest && (tag_latest.target)

logger.info("Traversing git tree from commit #{commit_from.oid} to commit #{commit_to && commit_to.oid}")

# Initialize a walker that walks through the commits from the <from-commit> to the <to-commit>
walker = Rugged::Walker.new(repo)
walker.sorting(Rugged::SORT_DATE)
walker.push(commit_from)
walker.hide(commit_to.parents.first) unless commit_to == nil

# Parse all commits and extract changes
changes = walker.map{ |c| parseCommit(c)}.reduce(:+)

logger.info("Found #{changes.count} changes")

# Create the changelog
log = Changelog.new(changes, tag_from, tag_to || tag_latest, commit_from, commit_to)

# Print the changelog
puts log.to_slack