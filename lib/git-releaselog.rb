require "rugged"
require "logger"
require "git-releaselog/changelog_helpers"
require "git-releaselog/changelog"
require "git-releaselog/version"

module Releaselog
  class Releaselog
    def self.generate_releaselog(options = {})
    repo_path = options.fetch(:repo_path, '.')
    from_ref_name = options.fetch(:from_ref, nil)
    to_ref_name = options.fetch(:to_ref, nil)
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
    from_ref = tagWithName(repo, from_ref_name)
    to_ref = tagWithName(repo, to_ref_name)
    latest_tag = latestTagID(repo, logger)

    if from_ref
      logger.info("Found Tag #{from_ref.name} to start from")
    end

    if to_ref
      logger.info("Found Tag #{to_ref.name} to end at")
    end

    if latest_tag
      logger.info("Latest Tag found: #{latest_tag.name}")
    end

    if generate_complete && repo.tags.count > 0
      sorted_tags = repo.tags.sort { |t1, t2| t1.target.time <=> t2.target.time }
      changeLogs = []
      sorted_tags.each_with_index do |tag, index|
        logger.error("Tag #{tag.name} with date #{tag.target.time}")

        if index == 0
            # First Interval: Generate from start of Repo to the first Tag
            changes = searchGitLog(repo, nil, tag.target, scope, logger)
            changeLogs += [Changelog.new(changes, nil, tag, nil, nil)]

            logger.info("Parsing from start of the repo to #{tag.target.oid}")
            logger.info("First Tag: #{tag.name}: #{changes.count} changes")
          else
            # Normal interval: Generate from one Tag to the next Tag
            previousTag = sorted_tags[index-1]
            changes = searchGitLog(repo, previousTag.target, tag.target, scope, logger)
            changeLogs += [Changelog.new(changes, previousTag, tag, nil, nil)]

            logger.info("Parsing from #{tag.target.oid} to #{previousTag.target.oid}")
            logger.info("Tag #{previousTag.name} to #{tag.name}: #{changes.count} changes")
          end
        end

        if sorted_tags.count > 0
          lastTag = sorted_tags.last
          # Last Interval: Generate from last Tag to HEAD
          changes = searchGitLog(repo, lastTag.target, repo.head.target, scope, logger)
          changeLogs += [Changelog.new(changes, lastTag, nil, nil, nil)]

          logger.info("Parsing from #{lastTag.target.oid} to HEAD")
          logger.info("Tag #{lastTag.name} to HEAD: #{changes.count} changes")
        end

        # Print the changelog
        if format == "md"
          changeLogs.reverse.map { |log| "#{log.to_md}\n" }
        elsif format == "slack"
          changeLogs.reduce("") { |log, version| log + "#{version.to_slack}\n" }
        else
          logger.error("Unknown Format: `#{format}`")
        end
      else
        # From which commit should the log be followed? Will default to the latest tag
        commit_from = (from_ref && from_ref.target) || commit(repo, from_ref, logger) || latest_tag && (latest_tag.target)

        # To which commit should the log be followed? Will default to HEAD
        commit_to = (to_ref && to_ref.target) || commit(repo, to_ref, logger) || repo.head.target


        changes = searchGitLog(repo, commit_from, commit_to, scope, logger)
        # Create the changelog
        log = Changelog.new(changes, from_ref, to_ref || latest_tag, commit_from, commit_to)

        # Print the changelog
        case format
        when "md"
          log.to_md
        when "slack"
          log.to_slack
        when "raw"
          log
        else
          logger.error("Unknown Format: `#{format}`")
        end
      end
    end
  end
end