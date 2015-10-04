module Fastlane
  module Actions
    module SharedValues
      FIND_LAST_TAG_CUSTOM_VALUE = :FIND_LAST_TAG_CUSTOM_VALUE
    end

    require "rugged"

    # To share this integration with the other fastlane users:
    # - Fork https://github.com/KrauseFx/fastlane
    # - Clone the forked repository
    # - Move this integration into lib/fastlane/actions
    # - Commit, push and submit the pull request

    class FindLastTagAction < Action
      def self.run(params)
        # Initialize Repo
        begin
          repo = Rugged::Repository.discover(".")
        rescue Rugged::OSError => e
          Helper.log.error "Here is no git repository"
          exit
        end

        # Get a list of all tags (with a certain prefix if given), sorted chronologically from newest to oldest
        prefix = params[:prefix] || ""
        Helper.log.info "Filtering with tag prefix `#{prefix}`"
        tags = repo.tags.select { |t| t.name.start_with?(prefix)}.sort { |t1, t2| t1.target.time <=> t2.target.time }.reverse

        # If the current version is not given we can only assume
        return tags.first unless current_version = params[:current_version]

        Helper.log.info "Searching for the latest tag before `#{current_version}`"
        current_version_found = false
        tags.each do |tag|
          if !current_version_found
            current_version_found = tag.name.include? current_version
          elsif !tag.name.include? current_version
            # The first tag AFTER the current version is the tag we are looking for
            Helper.log.info "The tag you were looking for is `#{tag.name}`"
            return tag.name
          end
        end
        Helper.log.info "Could not find the tag you were looking for, so here is the newest available tag `#{tags.last.name}`"
        return tags.first.name
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "Returns the last git tag of the previous app version"
      end

      def self.details
        [
          "This action will find the latest git tag of the previous app version. ",
          "It is useful, when several release candidates are submitted per version (each one tagged) and you need to find the last one",
          "which should be the final tag of that version"
        ].join(" ")
      end

      def self.available_options
        # Define all options your action supports. 
        
        # Below a few examples
        [
          FastlaneCore::ConfigItem.new(key: :prefix,
                                       env_name: "FL_FIND_LAST_TAG_PREFIX",
                                       description: "Search only tags with that prefix",
                                       is_string: true,
                                       default_value: ""),
          FastlaneCore::ConfigItem.new(key: :current_version,
                                       env_name: "FL_FIND_LAST_TAG_CURRENT_VERSION",
                                       description: "The current version, search for the latest tag before that version",
                                       is_string: true,
                                       default_value: nil)
        ]
      end

      def self.output
        [
          ['FIND_LAST_TAG_CUSTOM_VALUE', 'A description of what this value contains']
        ]
      end

      def self.return_value
        [
          ['GIT_TAG', "The last git tag of the previous app version"]
        ]
      end

      def self.authors
        ["iv-mexx"]
      end

      def self.is_supported?(platform)
        true
      end
    end
  end
end
