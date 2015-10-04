# A class for representing a change
# A change can have a type (fix or feature) and a note describing the change
module Releaselog
  class Change
    FIX = 1
    FEAT = 2
    GUI = 3
    REFACTOR = 4

    TOKEN_FIX = "* fix:"
    TOKEN_FEAT = "* feat:"
    TOKEN_GUI = "* gui:"
    TOKEN_REFACTOR = "* refactor:"

    def initialize(type, note)
      @type = type
      @note = note.strip
    end

    def type
      @type
    end

    def note
      @note
    end

    # Parse a single line as a `Change` entry
    # If the line is formatte correctly as a change entry, a corresponding `Change` object will be created and returned,
    # otherwise, nil will be returned.
    # 
    # The additional scope can be used to skip changes of another scope. Changes without scope will always be included.
    def self.parse(line, scope = nil)
      if line.start_with? Change::TOKEN_FEAT
        self.new(Change::FEAT, line.split(Change::TOKEN_FEAT).last).check_scope(scope)
      elsif line.start_with? Change::TOKEN_FIX
        self.new(Change::FIX, line.split(Change::TOKEN_FIX).last).check_scope(scope)
      elsif line.start_with? Change::TOKEN_GUI
        self.new(Change::GUI, line.split(Change::TOKEN_GUI).last).check_scope(scope)
      elsif line.start_with? Change::TOKEN_REFACTOR
        self.new(Change::REFACTOR, line.split(Change::TOKEN_REFACTOR).last).check_scope(scope)
      else
        nil
      end
    end

    # Checks the scope of the `Change` and the change out if the scope does not match.
    def check_scope(scope = nil)
      # If no scope is requested or the change has no scope include this change unchanged
      return self unless scope
      change_scope = /^\s*\[\w+\]/.match(@note)
      return self unless change_scope

      # change_scope is a string of format `[scope]`, need to strip the `[]` to compare the scope
      if change_scope[0][1..-2] == scope
        #  Change has the scope that is requested, strip the whole scope scope from the change note
        @note = change_scope.post_match.strip
        return self
      else
        #  Change has a different scope than requested
        return nil
      end
    end
  end
end