require 'spec_helper'
require 'changelog'

describe Changelog do
  context "creating and using the changelog" do 
    let(:change_feature_1) { "Feature 1"}
    let(:change_feature_2) { "Feature 2"}
    let(:change_fix_1) { "Fix 1"}
    let(:change_gui_1) { "GUI 1"}
    let(:changes) do 
      [
        Change.new(Change::FEAT, change_feature_1),
        Change.new(Change::GUI, change_gui_1),
        Change.new(Change::FEAT, change_feature_2),
        Change.new(Change::FIX, change_fix_1),
      ]
    end
    subject { Changelog.new(changes) }

    context "output" do
      context "slack format" do
        it "should create some output and contain the given changes" do
          expect(subject.to_slack).to include(change_feature_1)
          expect(subject.to_slack).to include(change_feature_2)
          expect(subject.to_slack).to include(change_fix_1)
          expect(subject.to_slack).to include(change_gui_1)
        end        
      end

      context "markdown format" do
        it "should create some output and contain the given changes" do
          expect(subject.to_md).to include(change_feature_1)
          expect(subject.to_md).to include(change_feature_2)
          expect(subject.to_md).to include(change_fix_1)
          expect(subject.to_md).to include(change_gui_1)
        end        
      end

      context "raw format" do
        it "should create some output and contain the given changes" do
          expect(subject.changes[:feature]).to include(change_feature_1)
          expect(subject.changes[:feature]).to include(change_feature_2)
          expect(subject.changes[:fix]).to include(change_fix_1)
          expect(subject.changes[:gui]).to include(change_gui_1)
          expect(subject.changes[:refactor]).to eq([])
        end        
      end

      it "should return `Unrelease` as tag_info" do
        expect(subject.tag_info{ |ti| "#{ti}" }).to eq("Unreleased")
      end

      it "should return an empty string as commit_info" do
        expect(subject.commit_info{ |ci| "#{ci}" }).to eq("")
      end
    end
  end

  context "without git information" do
    subject { Changelog.new([]) }
    let(:changes) do
      {
        fixes: ["Did this", "and that"],
        features: ["and this", "and more"]
      }
    end

    describe "single section" do
      it "should be able to style a section" do
        generated_string = subject.section(
          changes[:fixes],
          "*FIXES*\n",
          -> (field, _index) { "\t- #{field}\n" }
        )
        expect(generated_string).to eq("*FIXES*\n\t- Did this\n\t- and that\n")
      end

      it "should not style an empty section" do
        generated_string = subject.section(
          [],
          "",
          -> (field, _index) { "\t- #{field}\n" }
        )
        expect(generated_string).to eq("")
      end

      it "should accept a header style" do
        generated_string = subject.section(
          changes[:fixes],
          "fixes",
          -> (field, _index) { "\t- #{field}\n" },
          -> (header) { "*#{header.capitalize}*\n" }
        )
        expect(generated_string).to eq("*Fixes*\n\t- Did this\n\t- and that\n")
      end
    end

    describe "multiple sections" do
      it "should be able to style multiple sections" do
        generated_string = subject.sections(
         changes,
          -> (header) { "*#{header.capitalize}*\n" },
          -> (field, _index) { "\t- #{field}\n" }
        )
        expect(generated_string).to eq("*Fixes*\n\t- Did this\n\t- and that\n*Features*\n\t- and this\n\t- and more\n")
      end

      it "should skip empty sections" do
        empty_changes = {
          fixes: [],
          features: ["and this", "and more"]
        }
        generated_string = subject.sections(
          empty_changes,
          -> (header) { "*#{header.capitalize}*\n" },
          -> (field, _index) { "\t- #{field}\n" }
        )
        expect(generated_string).to eq("*Features*\n\t- and this\n\t- and more\n")
      end
    end
  end
end
