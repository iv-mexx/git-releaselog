#
# Helper Functions for git-changelog script
#

# A class for representing a change
# A change can have a type (fix or feature) and a note describing the change
class Change
  FIX = 1
  FEAT = 2
  GUI = 3
  REFACTORING = 4

  TOKEN_FIX = "* fix:"
  TOKEN_FEAT = "* feat:"
  TOKEN_GUI = "* gui:"
  TOKEN_REFACTORING = "* refactoring:"

  def initialize(type, note)
    @type = type
    @note = note.strip
  end

  def type
    @type
  end

  def note
    @note
  end

  # Parse a single line as a `Change` entry
  # If the line is formatte correctly as a change entry, a corresponding `Change` object will be created and returned,
  # otherwise, nil will be returned.
  # 
  # The additional scope can be used to skip changes of another scope. Changes without scope will always be included.
  def self.parse(line, scope = nil)
    if line.start_with? Change::TOKEN_FEAT
      self.new(Change::FEAT, line.split(Change::TOKEN_FEAT).last).check_scope(scope)
    elsif line.start_with? Change::TOKEN_FIX
      self.new(Change::FIX, line.split(Change::TOKEN_FIX).last).check_scope(scope)
    elsif line.start_with? Change::TOKEN_GUI
      self.new(Change::GUI, line.split(Change::TOKEN_GUI).last).check_scope(scope)
    elsif line.start_with? Change::TOKEN_REFACTORING
      self.new(Change::REFACTORING, line.split(Change::TOKEN_REFACTORING).last).check_scope(scope)
    else
      nil
    end
  end

  # Checks the scope of the `Change` and the change out if the scope does not match.
  def check_scope(scope = nil)
    # If no scope is requested or the change has no scope include this change unchanged
    return self unless scope
    change_scope = /^\s*\[\w+\]/.match(@note)
    return self unless change_scope

    # change_scope is a string of format `[scope]`, need to strip the `[]` to compare the scope
    if change_scope[0][1..-2] == scope
      #  Change has the scope that is requested, strip the whole scope scope from the change note
      @note = change_scope.post_match.strip
      return self
    else
      #  Change has a different scope than requested
      return nil
    end
  end
end

# check if the given refString (tag name or commit-hash) exists in the repo
def commit(repo, refString, logger)
  return unless refString != nil
  begin
    repo.lookup(refString)
  rescue Rugged::OdbError => e
    puts ("Commit `#{refString}` does not exist in Repo")
    logger.error(e.message)
    exit
  rescue Exception => e
    puts ("`#{refString}` is not a valid OID")
    logger.error(e.message)
    exit
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
  logger.info("Traversing git tree from commit #{commit_from.oid} to commit #{commit_to && commit_to.oid}")

  # Initialize a walker that walks through the commits from the <from-commit> to the <to-commit>
  walker = Rugged::Walker.new(repo)
  walker.sorting(Rugged::SORT_DATE)
  walker.push(commit_to)
  commit_from.parents.each do |parent|
    walker.hide(parent)
  end unless commit_from == nil

  # Parse all commits and extract changes
  changes = walker.map{ |c| parseCommit(c, scope, logger)}.reduce(:+) || []
  logger.debug("Found #{changes.count} changes")
  return changes
end