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
#{__FILE__} [--complete][--debug]
#{__FILE__} <from-commit> [--debug]
#{__FILE__} <from-commit> <to-commit> [--debug]
#{__FILE__} -h | --help
#{__FILE__} --version

Options:
from-commit   From which commit should the log be followed? Will default to head
to-commit     To which commit should the log be followed? Will default to the latest tag
--complete    Traverses the whole git history and generates a changelog for all tags
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

if args["--complete"] && repo.tags.count > 0
  sorted_tags = repo.tags.sort { |t1, t2| t1.target.time <=> t2.target.time }
  changeLogs = []
  sorted_tags.each_with_index do |tag, index|
    if tag == sorted_tags.last
      # Last Interval: Generate from last Tag to HEAD
      changes = searchGitLog(repo, repo.head.target, tag.target, logger)
      logger.info("Tag #{tag.name} to HEAD: #{changes.count} changes")
      changeLogs += [Changelog.new(changes, nil, tag, nil, nil)]
    end

    if index == 0
      # First Interval: Generate from start of Repo to the first Tag
      changes = searchGitLog(repo, tag.target, nil, logger)
      logger.info("First Tag: #{tag.name}: #{changes.count} changes")
      changeLogs += [Changelog.new(changes, tag, nil, nil, nil)]
    else 
      # Normal interval: Generate from one Tag to the next Tag
      previousTag = sorted_tags[index-1]
      changes = searchGitLog(repo, tag.target, previousTag.target, logger)
      logger.info("Tag #{previousTag.name} to #{tag.name}: #{changes.count} changes")
      changeLogs += [Changelog.new(changes, previousTag, tag, nil, nil)]
    end
  end
  puts changeLogs.map { |log| "#{log.to_slack}\n" }
else
  # From which commit should the log be followed? Will default to head
  commit_from = (tag_from && tag_from.target) || commit(repo, arg_from, logger) || repo.head.target

  # To which commit should the log be followed? Will default to the latest tag
  commit_to = (tag_to && tag_to.target) || commit(repo, arg_to, logger) || tag_latest && (tag_latest.target)


  changes = searchGitLog(repo, commit_from, commit_to, logger)
  # Create the changelog
  log = Changelog.new(changes, tag_from, tag_to || tag_latest, commit_from, commit_to)

  # Print the changelog
  puts log.to_slack
end