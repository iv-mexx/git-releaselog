Gem::Specification.new do |s|
  s.name        = 'git-changelog'
  s.version     = '0.2.2'
  s.date        = '2015-07-07'
  s.summary     = "Generate a changelog from a git repository"
  s.description = "Generate a changelog from a git repository"
  s.authors     = ["Markus Chmelar"]
  s.email       = 'markus.chmelar@innovaptor.com'
  s.files       = ["bin/changelog","lib/changelog_helpers.rb"]
  s.homepage    = 'https://github.com/iv-mexx/git-changelog'
  s.license     = 'MIT'
  s.executables = "changelog"
end
