# coding: utf-8
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "git-releaselog/version"

Gem::Specification.new do |s|
  s.name        = "git-releaselog"
  s.version     = Releaselog::VERSION
  s.date        = "2015-09-15"
  s.summary     = "Generate a releaselog from a git repository"
  s.description = "Write your releaselog as part of your usual commit messages. This tool generates a useful releaselog from marked lines in your git commit messages"
  s.authors     = ["Markus Chmelar"]
  s.email       = "markus.chmelar@innovaptor.com"
  s.files       = ["bin/git-releaselog.rb", "bin/git-releaselog/change.rb", "bin/git-releaselog/changelog.rb", "bin/git-releaselog/changelog_helpers.rb", "bin/git-releaselog/version.rb", "bin/git-releaselog.rb"]
  s.homepage    = "https://github.com/iv-mexx/git-releaselog"
  s.license     = "MIT"
  s.executables = "git-releaselog"
  s.add_runtime_dependency "docopt", "~> 0.5", ">= 0.5.0"
  s.add_runtime_dependency "rugged", ">= 0.23.0"

  # Development only
  s.add_development_dependency "bundler"
  s.add_development_dependency "rake"
  s.add_development_dependency "pry"
  s.add_development_dependency "rspec", "~> 3.3.0"
end
