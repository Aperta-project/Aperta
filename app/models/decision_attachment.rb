# DecisionAttachment represents a file attachment that is added as part of an
# author response, that should show up both in the decision history of a
# Reponse to Reviewers card, and in the Register Decision card in workflow.
class DecisionAttachment < Attachment
  self.public_resource = true

  def revise_task
    paper.revise_task
  end

  def decision
    owner
  end

  protected

  def build_title
    file.filename || title
  end

end
