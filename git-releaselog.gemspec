Gem::Specification.new do |s|
  s.name        = 'git-releaselog'
  s.version     = '0.6.0'
  s.date        = '2015-09-15'
  s.summary     = "Generate a releaselog from a git repository"
  s.description = "Write your releaselog as part of your usual commit messages. This tool generates a useful releaselog from marked lines in your git commit messages"
  s.authors     = ["Markus Chmelar"]
  s.email       = 'markus.chmelar@innovaptor.com'
  s.files       = ["bin/git-releaselog","lib/changelog_helpers.rb","lib/git-releaselog.rb", "lib/changelog.rb"]
  s.homepage    = 'https://github.com/iv-mexx/git-releaselog'
  s.license     = 'MIT'
  s.executables = "git-releaselog"
  s.add_runtime_dependency 'docopt', '~> 0.5', '>= 0.5.0'
  s.add_runtime_dependency 'rugged', '>= 0.23.0'
  s.add_development_dependency 'rspec', '~> 3.3.0'
end
