module StandardTasks
  class PaperAdminTaskPresenter < TaskPresenter
    def data_attributes
      attrs = super
      attrs['adminId'] = attrs['assigneeId']
      attrs['admins'] = attrs['assignees']
      attrs['assigneeId'] = nil
      attrs['assignees'] = []
      attrs
    end
  end
end
