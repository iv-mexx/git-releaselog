require "codeclimate-test-reporter"
CodeClimate::TestReporter.start

require 'bundler/setup'
Bundler.setup

require 'git-releaselog'

RSpec.configure do |config|
end
