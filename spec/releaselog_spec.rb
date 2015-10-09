require 'spec_helper'
require 'git-releaselog'

include Releaselog

describe Releaselog do
  subject do
    Releaselog::Releaselog.generate_releaselog(
      repo_path: ".",
      from_ref: arguments["<from-ref>"],
      to_ref: arguments["<to-ref>"],
      scope: arguments["--scope"],
      format: arguments["--format"] || "slack",
      generate_complete: arguments["--complete"],
      verbose: (arguments["--debug"] ? true : false)
      )
  end

  describe "Calling Releaselog" do
    context "without parameters" do
      let(:arguments) { arguments = {} }

      it "should create some output labelled as 'Unreleased'" do
        expect(subject).to include("Unreleased")
      end
    end

    context "from a certain tag" do 
      let(:arguments) { arguments = {"<from-ref>" => "0.5.0"} }

      it "should create some output labelled as 'Unreleased'" do
        expect(subject).to include("Unreleased")
      end

      it "should have at least sections `fix`, `feature`, `gui` and `refactor`" do
        expect(subject).to include("Fix")
        expect(subject).to include("Feature")
        expect(subject).to include("Gui")
        expect(subject).to include("Refactor")
      end
    end

    context "from one tag to another tag" do
      let(:arguments) { arguments = {"<from-ref>" => "0.5.0", "<to-ref>" => "0.6.0"} }

      it "should create some output labelled as '0.6.0' and the date of 0.6.0" do
        expect(subject).to include("0.6.0")
        expect(subject).to include("29.09.2015")
      end

      it "should have at least sections `fix`, `feature` and `refactor`, but not `gui`" do
        expect(subject).to include("Fix")
        expect(subject).to include("Feature")
        expect(subject).to include("Refactor")
        expect(subject).not_to include("Gui")
      end

      it "should contain all the correct changes" do
        expect(subject).to include("During changelog generation, use `commit_to` and `tag_to` instead of `commit_from` and `tag_from` to make an execution like `git-changelog 0.4.0 --format=slack` display information about the version being currently released")
        expect(subject).to include("strip note to make scope parsing more resilient")
        expect(subject).to include("Got us started with a basic rspec setup and some test for the most complicated new methods in `lib/changelog.rb`")
        expect(subject).to include("Add basic .travis.yml file to be able to start with CI")
        expect(subject).to include("Token for a `refactor` change has been changed from `* refactoring` to `* refactor`")
        expect(subject).to include("Keys of the `change` getter have been changed from (`fixes`, `features`, `gui`, `refactoring`) to (`fix`, `feature`, `gui`, `refactor`)")
        expect(subject).to include("Moved changelog formatting into `lib/changelog.rb`")
        expect(subject).to include("Added various helper methods to make it easier to change formatting output and to make it less error-prone to change displayed information across multiple formats")
        expect(subject).to include("Change `Changelog#changes` to return hash keys `gui` and `refactoring` instead of `gui_changes` and `refactorings`")
      end
    end

    context "creating complete changelog" do
      let(:arguments) { arguments = {"--complete" => true } }

      it "should do contain known release tags" do
        expect(subject).to include("0.1.0")
        expect(subject).to include("0.2.0")
        expect(subject).to include("0.2.1")
        expect(subject).to include("0.3.0")
        expect(subject).to include("0.4.0")
        expect(subject).to include("0.4.1")
        expect(subject).to include("0.5.0")
        expect(subject).to include("0.5.1")
        expect(subject).to include("0.6.0")
        expect(subject).to include("0.7.0")
        expect(subject).to include("0.7.1")
      end
    end

    context "using a scope" do
      let(:from_commit) { "932dc90"}
      let(:to_commit) { "f036a8b"}

      describe "no scope" do 
        let(:arguments) { arguments = {"<from-ref>" => from_commit, "<to-ref>" => to_commit} }

        it "should include the correct entries" do
          expect(subject).to include("this is just a test changelog entry without scope to be able to test scopes")
          expect(subject).to include("this is just a test changelog entry for scope `testscope1` to be able to test scopes")
          expect(subject).to include("this is just a test changelog entry for scope `testscope2` to be able to test scopes")
        end

        it "should still include the scope tags" do
          expect(subject).to include("[testscope1]")
          expect(subject).to include("[testscope2]")
        end
      end

      describe "`testscope1`" do
        let(:arguments) { arguments = {"<from-ref>" => from_commit, "<to-ref>" => to_commit, "--scope" => "testscope1" } }

        it "should include the correct entries" do
          expect(subject).to include("this is just a test changelog entry without scope to be able to test scopes")
          expect(subject).to include("this is just a test changelog entry for scope `testscope1` to be able to test scopes")
          expect(subject).not_to include("this is just a test changelog entry for scope `testscope2` to be able to test scopes")
        end

        it "should not include the scope tags anymore" do
          expect(subject).not_to include("[testscope1]")
          expect(subject).not_to include("[testscope2]")
        end
      end

      describe "`testscope2`" do
        let(:arguments) { arguments = {"<from-ref>" => from_commit, "<to-ref>" => to_commit, "--scope" => "testscope2" } }

        it "should include the correct entries" do
          expect(subject).to include("this is just a test changelog entry without scope to be able to test scopes")
          expect(subject).not_to include("this is just a test changelog entry for scope `testscope1` to be able to test scopes")
          expect(subject).to include("this is just a test changelog entry for scope `testscope2` to be able to test scopes")
        end

        it "should not include the scope tags anymore" do
          expect(subject).not_to include("[testscope1]")
          expect(subject).not_to include("[testscope2]")
        end
      end
    end

    context "output formats" do 
      let(:from_commit) { "932dc90"}
      let(:to_commit) { "f036a8b"}

      describe "slack" do
        let(:arguments) { arguments = {"<from-ref>" => from_commit, "<to-ref>" => to_commit, "--format" => "slack"} }

        it "should produce output formatted for slack" do
          expect(subject).to include("*Refactor*")
          expect(subject).to include("\t- this is just a test changelog entry without scope to be able to test scopes\n")
          expect(subject).to include("\t- [testscope1] this is just a test changelog entry for scope `testscope1` to be able to test scopes\n")
          expect(subject).to include("\t- [testscope2] this is just a test changelog entry for scope `testscope2` to be able to test scopes\n")
        end
      end

      describe "markdown" do
        let(:arguments) { arguments = {"<from-ref>" => from_commit, "<to-ref>" => to_commit, "--format" => "md"} }

        it "should produce output formatted for slack" do
          expect(subject).to include("#### Refactor")
          expect(subject).to include("* this is just a test changelog entry without scope to be able to test scopes\n")
          expect(subject).to include("* [testscope1] this is just a test changelog entry for scope `testscope1` to be able to test scopes\n")
          expect(subject).to include("* [testscope2] this is just a test changelog entry for scope `testscope2` to be able to test scopes\n")
        end
      end

      describe "raw" do
        let(:arguments) { arguments = {"<from-ref>" => from_commit, "<to-ref>" => to_commit, "--format" => "raw"} }

        it "should produce output formatted for slack" do
          expect(subject).to be_a(Changelog)
        end
      end
    end
  end
end