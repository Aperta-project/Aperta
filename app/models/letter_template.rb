# This is meant to hold different types of letter templates for decisions
# and any other use cases where a letter template with variable replacement
# would be useful.
class LetterTemplate < ActiveRecord::Base
  belongs_to :journal
end
