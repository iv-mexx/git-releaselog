# 
# Helper Functions for git-changelog script
# 

# A class for representing a change
# A change can have a type (fix or feature) and a note describing the change
class Change
  FIX = 1
  FEAT = 2
  GUI = 3

  TOKEN_FIX = "* fix: "
  TOKEN_FEAT = "* feat: "
  TOKEN_GUI = "* gui: "

  def initialize(type, note)
    @type = type
    @note = note
  end

  def type
    @type
  end

  def note
    @note
  end

  def self.parse(line)
    if line.start_with? Change::TOKEN_FEAT
      self.new(Change::FEAT, line.split(Change::TOKEN_FEAT).last)
    elsif line.start_with? Change::TOKEN_FIX
      self.new(Change::FIX, line.split(Change::TOKEN_FIX).last)
    elsif line.start_with? Change::TOKEN_GUI
      self.new(Change::GUI, line.split(Change::TOKEN_GUI).last)
    else
      nil
    end
  end
end

# A class for representing a changelog consisting of several changes
# over a certain timespan (between two commits)
class Changelog
  def initialize(changes, tag_from = nil, tag_to = nil, from_commit = nil, to_commit = nil)
    @fixes = changes.select{ |c| c.type == Change::FIX }
    @features = changes.select{ |c| c.type == Change::FEAT }
    @gui_changes = changes.select{ |c| c.type == Change::GUI }
    @tag_from = tag_from
    @tag_to = tag_to
    @commit_from = from_commit
    @commit_to = to_commit
  end

  def to_slack
    str = ""

    if @tag_from && @tag_from.name 
      str << "Version #{@tag_from.name}"
    else
      str << "Unreleased"
    end

    if @commit_to
      str << " (_#{@commit_to.time.strftime("%d.%m.%Y")}_)"
    end
    str << "\n"

    if @fixes.count > 0
      str << "*Fixes*\n"
      str << @fixes.map{|c| "\t- #{c.note}"}.join("\n")
    end

    if @features.count > 0
      str << "\n\n*Features*\n"
      str << @features.map{|c| "\t- #{c.note}"}.join("\n")
    end

    if @gui_changes.count > 0
      str << "\n\n*GUI*\n"
      str << @gui_changes.map{|c| "\t- #{c.note}"}.join("\n")
    end

    str << "\n"
    str    
  end

  def to_md
    str = ""

    if @tag_from && @tag_from.name 
      str << "## Version #{@tag_from.name}"
    else
      str << "## Unreleased"
    end

    if @commit_to
      str << " (_#{@commit_to.time.strftime("%d.%m.%Y")}_)"
    end
    str << "\n"

    if @fixes.count > 0
      str << "*Fixes*\n"
      str << @fixes.map{|c| "* #{c.note}"}.join("\n")
    end

    if @features.count > 0
      str << "\n\n*Features*\n"
      str << @features.map{|c| "* #{c.note}"}.join("\n")
    end

    if @gui_changes.count > 0
      str << "\n\n*GUI*\n"
      str << @gui_changes.map{|c| "* #{c.note}"}.join("\n")
    end

    str << "\n"
    str    
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
def parseCommit(commit, logger)
  logger.debug("Parsing Commit #{commit.oid}")
  # Sepaerate into lines, remove whitespaces and filter out empty lines
  lines = commit.message.lines.map(&:strip).reject(&:empty?)
  # Parse the lines
  lines.map{|line| Change.parse(line)}.reject(&:nil?)
end

def searchGitLog(repo, commit_from, commit_to, logger)
  logger.info("Traversing git tree from commit #{commit_from.oid} to commit #{commit_to && commit_to.oid}")

  # Initialize a walker that walks through the commits from the <from-commit> to the <to-commit>
  walker = Rugged::Walker.new(repo)
  walker.sorting(Rugged::SORT_DATE)
  walker.push(commit_from)
  commit_to.parents.each do |parent|
    walker.hide(parent)
  end unless commit_to == nil

  # Parse all commits and extract changes
  changes = walker.map{ |c| parseCommit(c, logger)}.reduce(:+) || []
  logger.debug("Found #{changes.count} changes")
  return changes
end