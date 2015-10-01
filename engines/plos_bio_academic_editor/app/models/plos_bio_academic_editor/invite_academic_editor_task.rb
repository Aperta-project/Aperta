module PlosBioAcademicEditor
  class InviteAcademicEditorTask < Task

    register_task default_title: 'Invite Academic Editor Task', default_role: 'author'

    def active_model_serializer
      InviteAcademicEditorTaskSerializer
    end

  end
end
