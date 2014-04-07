class RegisterDecisionTaskSerializer < TaskSerializer
  attributes :id, :decision_letters

  def decision_letters
    { Accepted: object.accept_letter,
      Rejected: object.reject_letter,
      Revise: object.revise_letter }.to_json
  end
end
