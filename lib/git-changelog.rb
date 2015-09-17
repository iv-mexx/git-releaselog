require "rugged"
require "changelog_helpers"
require "logger"

class Changelog
  def self.generate_changelog(options = {})
  repo_path = options.fetch(:repo_path, '.')
  from_tag_name = options.fetch(:from_tag, nil)
  to_tag_name = options.fetch(:to_tag, nil)
  scope = options.fetch(:scope, nil)
  format = options.fetch(:format, 'slack')
  generate_complete = options.fetch(:generate_complete, false)
  verbose = options.fetch(:verbose, false)

  # Initialize Logger
  logger = Logger.new(STDOUT)
  logger.level = verbose ?  Logger::DEBUG : Logger::ERROR

  # Initialize Repo
  begin
    repo = Rugged::Repository.discover(repo_path)
  rescue Rugged::OSError => e
    puts ("Current directory is not a git repo")
    logger.error(e.message)
    exit
  end

  # Find if we're operating on tags
  from_tag = tagWithName(repo, from_tag_name)
  to_tag = tagWithName(repo, to_tag_name)
  latest_tag = latestTagID(repo, logger)

  if from_tag
    logger.info("Found Tag #{from_tag.name} to start from")
  end

  if to_tag
    logger.info("Found Tag #{to_tag.name} to end at")
  end

  if latest_tag
    logger.info("Latest Tag found: #{latest_tag.name}")
  end

  if generate_complete && repo.tags.count > 0
    sorted_tags = repo.tags.sort { |t1, t2| t1.target.time <=> t2.target.time }
    changeLogs = []
    sorted_tags.each_with_index do |tag, index|
      if index == 0
          # First Interval: Generate from start of Repo to the first Tag
          changes = searchGitLog(repo, tag.target, nil, scope, logger)
          logger.info("First Tag: #{tag.name}: #{changes.count} changes")
          changeLogs += [Changelog.new(changes, tag, nil, nil, nil)]
        else
          # Normal interval: Generate from one Tag to the next Tag
          previousTag = sorted_tags[index-1]
          changes = searchGitLog(repo, tag.target, previousTag.target, scope, logger)
          logger.info("Tag #{previousTag.name} to #{tag.name}: #{changes.count} changes")
          changeLogs += [Changelog.new(changes, tag, previousTag, nil, nil)]
        end
      end

      if sorted_tags.count > 0
        lastTag = sorted_tags.last
        # Last Interval: Generate from last Tag to HEAD
        changes = searchGitLog(repo, repo.head.target, lastTag.target, scope, logger)
        logger.info("Tag #{lastTag.name} to HEAD: #{changes.count} changes")
        changeLogs += [Changelog.new(changes, nil, lastTag, nil, nil)]
      end

      # Print the changelog
      if format == "md"
        changeLogs.reverse.map { |log| "#{log.to_md}\n" }
      elsif format == "slack"
        changeLogs.map { |log| "#{log.to_slack}\n" }
      else
        logger.error("Unknown Format: `#{format}`")
      end
    else
      # From which commit should the log be followed? Will default to head
      commit_from = (from_tag && from_tag.target) || commit(repo, from_tag, logger) || repo.head.target

      # To which commit should the log be followed? Will default to the latest tag
      commit_to = (to_tag && to_tag.target) || commit(repo, to_tag, logger) || latest_tag && (latest_tag.target)


      changes = searchGitLog(repo, commit_from, commit_to, scope, logger)
      # Create the changelog
      log = Changelog.new(changes, from_tag, to_tag || latest_tag, commit_from, commit_to)

      # Print the changelog
      if format == "md"
        log.to_md
      elsif format == "slack"
        log.to_slack
      elsif format == "raw"
        log
      else
        logger.error("Unknown Format: `#{format}`")
      end
    end
  end
end