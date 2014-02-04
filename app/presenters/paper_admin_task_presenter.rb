class PaperAdminTaskPresenter < TaskPresenter
  def data_attributes
    attrs = super
    attrs['admin-id'] = attrs['assignee-id']
    attrs['admins'] = attrs['assignees']
    attrs['assignee-id'] = nil
    attrs['assignees'] = "[]"
    attrs
  end
end
