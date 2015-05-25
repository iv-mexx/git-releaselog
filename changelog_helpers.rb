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
  sorted_tags = repo.tags.sort { |t1, t2| t1.target.time <=> t2.target.time }
  sorted_tags.last.target
end

