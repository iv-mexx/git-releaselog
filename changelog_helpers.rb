# 
# Helper Functions for git-changelog script
# 

# A class for representing a change
# A change can have a type (fix or feature) and a note describing the change
class Change
  FIX = 1
  FEAT = 2

  TOKEN_FIX = "* fix: "
  TOKEN_FEAT = "* feat: "

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
    @tag_from = tag_from
    @tag_to = tag_to
    @commit_from = from_commit
    @commit_to = to_commit
  end

  def since
    "#{@tag_to && @tag_to.name || @commit_to.object_id} (#{@commit_to && @commit_to.time.strftime("%d.%m.%Y")})"
  end

  def to_slack
    str = "Changes since #{since}\n"
    str << "*Fixes*\n"
    str << @fixes.map{|c| "\t- #{c.note}"}.join("\n")
    str << "\n\n*Features*\n"
    str << @features.map{|c| "\t- #{c.note}"}.join("\n")
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
def parseCommit(commit)
  # Sepaerate into lines, remove whitespaces and filter out empty lines
  lines = commit.message.lines.map(&:strip).reject(&:empty?)
  # Parse the lines
  lines.map{|line| Change.parse(line)}.reject(&:nil?)
end