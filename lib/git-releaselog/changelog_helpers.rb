#
# Helper Functions for git-changelog script
#
require "git-releaselog/change"
include Releaselog

# check if the given refString (tag name or commit-hash) exists in the repo
def commit(repo, refString, logger)
  logger.info("Searching for ref #{refString} in repo")

  return unless refString != nil
  begin
    repo.lookup(refString)
  rescue Rugged::OdbError => e
    logger.error("Searching for commit with ref #{refString} failure: #{e.message}")
    return nil
  rescue Exception => e
    logger.error("Searching for commit with ref #{refString} failure: #{e.message}")
    return nil
  end
end

# Returns the most recent tag
def latestTagID(repo, logger)
  return nil unless repo.tags.count > 0
  sorted_tags = repo.tags.sort { |t1, t2| t1.target.time <=> t2.target.time }
  sorted_tags.last
end

# Returns the tag with the given name (if exists)
def tagWithName(repo, name)
  tags = repo.tags.select { |t| t.name == name }
  return tags.first unless tags.count < 1
end

# Parses a commit message and returns an array of Changes
def parseCommit(commit, scope, logger)
  logger.debug("Parsing Commit #{commit.oid}")
  # Sepaerate into lines, remove whitespaces and filter out empty lines
  lines = commit.message.lines.map(&:strip).reject(&:empty?)
  # Parse the lines
  lines.map{|line| Change.parse(line, scope)}.reject(&:nil?)
end

# Searches the commit log messages of all commits between `commit_from` and `commit_to` for changes
def searchGitLog(repo, commit_from, commit_to, scope, logger)
  # logger.info("Traversing git tree from commit #{commit_from.oid} to commit #{commit_to && commit_to ? commit_to.oid : '(no oid)'}")

  # Initialize a walker that walks through the commits from the <from-commit> to the <to-commit>
  walker = Rugged::Walker.new(repo)
  walker.sorting(Rugged::SORT_DATE)
  walker.push(commit_to) unless commit_to == nil
  commit_from.parents.each do |parent|
    walker.hide(parent)
  end unless commit_from == nil

  # Parse all commits and extract changes
  changes = walker.map{ |c| parseCommit(c, scope, logger)}.reduce(:+) || []
  logger.debug("Found #{changes.count} changes")
  return changes
end