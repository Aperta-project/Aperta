module TahiStandardTasks
  class PaperEditorTaskSerializer < TaskSerializer
    embed :ids
    has_many :academic_editors
    has_many :invitations, include: true
    attributes :invitation_template, :invitee_role
  end
end
