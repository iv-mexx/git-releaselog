Gem::Specification.new do |s|
  s.name        = 'git-changelog'
  s.version     = '0.3.0'
  s.date        = '2015-09-15'
  s.summary     = "Generate a changelog from a git repository"
  s.description = "Write your changelog as you go into your commit messages. This tool generates a useful changelog from marked lines in your git commit messages"
  s.authors     = ["Markus Chmelar"]
  s.email       = 'markus.chmelar@innovaptor.com'
  s.files       = ["bin/git-changelog","lib/changelog_helpers.rb","lib/git-changelog.rb"]
  s.homepage    = 'https://github.com/iv-mexx/git-changelog'
  s.license     = 'MIT'
  s.executables = "changelog"
  s.add_runtime_dependency 'docopt', '~> 0.5', '>= 0.5.0'
  s.add_runtime_dependency 'rugged'
end
