# A class for representing a changelog consisting of several changes
# over a certain timespan (between two commits)
class Changelog
  def initialize(changes, tag_from = nil, tag_to = nil, from_commit = nil, to_commit = nil)
    @fixes = changes.select { |c| c.type == Change::FIX }
    @features = changes.select { |c| c.type == Change::FEAT }
    @gui_changes = changes.select { |c| c.type == Change::GUI }
    @refactorings = changes.select { |c| c.type == Change::REFACTORING }
    @tag_from = tag_from
    @tag_to = tag_to
    @commit_from = from_commit
    @commit_to = to_commit
  end

  def changes
    {
      fixes: @fixes.map(&:note),
      features: @features.map(&:note),
      gui: @gui_changes.map(&:note),
      refactoring: @refactorings.map(&:note)
    }
  end

  # Display tag information about the tag that the changelog is created for
  def tag_info
    if @tag_to && @tag_to.name
      yield("#{@tag_to.name}")
    else
      yield("Unreleased")
    end
  end

  # Display tinformation about the commit the changelog is created for
  def commit_info
    if @commit_from
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

  def to_slack
    str = ""

    str << tag_info { |t| t }
    str << commit_info { |ci| " (_#{ci}_)\n" }
    str << sections(
      changes,
      -> (header) { "*#{header.capitalize}*\n" },
      -> (field, _index) { "\t- #{field}\n" }
    )

    str
  end

  def to_md
    str = ""

    str << tag_info { |t| "## #{t}" }
    str << commit_info { |ci| " (_#{ci}_)" }
    str << sections(
      changes,
      -> (header) { "\n*#{header.capitalize}*\n" },
      -> (field, _index) { "* #{field}\n" }
    )

    str
  end
end
