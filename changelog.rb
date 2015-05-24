#!/usr/bin/env ruby
require "docopt"
require "logger"
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
  -h --help     Show this screen.
  --version     Show version.
  --debug   Show debug output
DOCOPT

begin
  args =  Docopt::docopt(doc, version: '0.0.1')
  logger = Logger.new(STDOUT)
  logger.level = args["--debug"] ?  Logger::DEBUG : Logger::ERROR
  
rescue Docopt::Exit => e
  puts e.message
end

