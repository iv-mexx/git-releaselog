# A class for representing a changelog consisting of several changes
# over a certain timespan (between two commits)
module Releaselog
  class Changelog
    def initialize(changes, tag_from = nil, tag_to = nil, from_commit = nil, to_commit = nil)
      @changes_fix = changes.select { |c| c.type == Change::FIX }
      @changes_feat = changes.select { |c| c.type == Change::FEAT }
      @changes_gui = changes.select { |c| c.type == Change::GUI }
      @changes_refactor = changes.select { |c| c.type == Change::REFACTOR }
      @tag_from = tag_from
      @tag_to = tag_to
      @commit_from = from_commit
      @commit_to = to_commit
    end

    # Returns a hash of the changes.
    # The changes are grouped by change type into `fix`, `feature`, `gui`, `refactor`
    # Each type is a list of changes where each change is the note of that change
    def changes
      {
        fix: @changes_fix.map(&:note),
        feature: @changes_feat.map(&:note),
        gui: @changes_gui.map(&:note),
        refactor: @changes_refactor.map(&:note)
      }
    end

    # Display tag information about the tag that the changelog is created for
    def tag_info
      if @tag_to && @tag_to.name
        yield("#{@tag_to.name}\n")
      else
        yield("Unreleased\n")
      end
    end

    # Display tinformation about the commit the changelog is created for
    def commit_info
      if @commit_to
        yield(@commit_to.time.strftime("%d.%m.%Y"))
      else
        yield("")
      end
    end

    # Format each section from #sections.
    #
    # section_changes ... changes in the format of { section_1: [changes...], section_2: [changes...]}
    # header_style ... is called for styling the header of each section
    # entry_style ... is called for styling each item of a section
    def sections(section_changes, header_style, entry_style)
      str = ""
      section_changes.each do |section_category, section_changes|
        str << section(
          section_changes,
          section_category.to_s,
          entry_style,
          header_style
        )
      end
      str
    end

    # Format a specific section.
    #
    # section_changes ... changes in the format of { section_1: [changes...], section_2: [changes...]}
    # header ... header of the section
    # entry_style ... is called for styling each item of a section
    # header_style ... optional, since styled header can be passed directly; is called for styling the header of the section
    def section(section_changes, header, entry_style, header_style = nil)
      return "" unless section_changes.size > 0
      str = ""

      unless header.empty?
        if header_style
          str << header_style.call(header)
        else
          str << header
        end
      end

      section_changes.each_with_index do |e, i|
        str << entry_style.call(e, i)
      end
      str
    end

    # Render the Changelog with Slack Formatting
    def to_slack
      str = ""

      str << tag_info { |t| t }
      str << commit_info { |ci| ci.empty? ? "" : "(_#{ci}_)\n"  }
      str << sections(
        changes,
        -> (header) { "*#{header.capitalize}*\n" },
        -> (field, _index) { "\t- #{field}\n" }
      )

      str
    end

    # Render the Changelog with Markdown Formatting
    def to_md
      str = ""

      str << tag_info { |t| "## #{t}" }
      str << commit_info { |ci| ci.empty? ? "" : "(_#{ci}_)\n" }
      str << sections(
        changes,
        -> (header) { "\n#####{header.capitalize}\n" },
        -> (field, _index) { "* #{field}\n" }
      )

      str
    end
  end
end