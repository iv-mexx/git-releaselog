# 
# Helper Functions for git-changelog script
# 

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
  sorted_tags.last.target
end


# module Change
#   FIX = 1
#   FEAT = 2
# end

# A class for representing a change
class Change
  FIX = 1
  FEAT = 2

  TOKEN_FIX = "* fix: "
  TOKEN_FEAT = "* feat: "

  def initialize(type, note)
    @type = type
    @note = note
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

# Parses a commit message and returns an array of Changes
def parseCommit(commit)
  # Sepaerate into lines, remove whitespaces and filter out empty lines
  lines = commit.message.lines.map(&:strip).reject(&:empty?)
  # Parse the lines
  lines.map{|line| Change.parse(line)}.reject(&:nil?)
end