##
# Now that NestedQuestion idents are unique, we'd like to be able to
# be able to jump straight from a paper to the answer to a specific
# question. This requires a non-polymophic link between questions and
# papers.
#
class AddPaperIdToNestedQuestionAnswer < ActiveRecord::Migration
  def change
    add_column :nested_question_answers, :paper_id, :integer
  end
end
