module Fastlane
  module Actions
    module SharedValues
      CREATE_CHANGELOG_CUSTOM_VALUE = :CREATE_CHANGELOG_CUSTOM_VALUE
    end

    require 'git-releaselog'

    # To share this integration with the other fastlane users:
    # - Fork https://github.com/KrauseFx/fastlane
    # - Clone the forked repository
    # - Move this integration into lib/fastlane/actions
    # - Commit, push and submit the pull request

    class CreateChangelogAction < Action
      def self.run(params)

        Helper.log.info "from_tag: `#{params[:last_tag]}`"
        Helper.log.info "scope: `#{params[:scope]}`"

        return Releaselog::Releaselog.generate_releaselog(
          repo_path: ".",
          from_ref: params[:last_tag],
          to_ref: params[:new_tag],
          scope: params[:scope],
          format: params[:format],
          generate_complete: params[:complete]
        )
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "Generates a changelog with changes since the last version"
      end

      def self.details
        [
          "This uses the https://github.com/iv-mexx/git-changelog tool to generate a changelog from the git history.",
          "Change entries are extracted from special formatted lines in the git commit messages",
          "The changelog is generated for all changes since the last released version"
        ].join(" ")
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :scope,
                                       env_name: "FL_CREATE_CHANGELOG_SCOPE",
                                       description: "The Project scope",
                                       is_string: true,
                                       default_value: ""),
          FastlaneCore::ConfigItem.new(key: :last_tag,
                                       env_name: "FL_CREATE_CHANGELOG_LAST_TAG",
                                       description: "The name of the tag from which the changelog should be generated",
                                       is_string: true,
                                       default_value: ""),
          FastlaneCore::ConfigItem.new(key: :new_tag,
                                       env_name: "FL_CREATE_CHANGELOG_NEW_TAG",
                                       description: "The name of the tag to which the changelog should be generated, defaults to HEAD",
                                       is_string: true,
                                       default_value: "HEAD"),
          FastlaneCore::ConfigItem.new(key: :format,
                                       env_name: "FL_CREATE_CHANGELOG_FORMAT",
                                       description: "The format for whicht the changelog should be marked up. Supports 'md' (Markdown), 'slack' (Slack) and 'raw' (returns the raw Object)",
                                       is_string: true,
                                       default_value: "md"),
          FastlaneCore::ConfigItem.new(key: :complete,
                                       env_name: "FL_CREATE_CHANGELOG_COMPLETE",
                                       description: "Wether a complete changelog (for all versions) should be generated, or only from the given tag to the given tag. For complete changelogs, the `last_tag` and `new_tag` parameters are ignored",
                                       is_string: false,
                                       default_value: false)
        ]
      end

      def self.output
        []
      end

      def self.return_value
        [
          ['CHANGELOG', 'A changelog since the last released version']
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
