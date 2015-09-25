require 'spec_helper'
require 'changelog'

describe Changelog do
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
