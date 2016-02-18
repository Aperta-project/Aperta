##
# The permissions controller doesn't deal one-to-one with Permission
# objects; instead it returns a permissions table for the current user
# and the given object.
#
class PermissionsController < ApplicationController
  respond_to :json

  def show
    # Both class and id are packed into one value to allow ember-data
    # to request and store permissions tables automatically.
    class_name, id = params[:id].split('+')
    klass = lookup_task_klass(class_name.camelize)
    target = klass.where(id: id)
    permissions = current_user.filter_authorized(
      :*, target, participations_only: false
    ).serializable

    if permissions.empty?
      render_empty_permissions
    else
      render json: permissions,
             each_serializer: PermissionResultSerializer,
             root: 'permissions'
    end
  end

  private

  # Lookup does a best effort attempt at finding the intended klass
  # based on what the front-end sent in. For example, ember will pass in
  # ethicsTask, but the EthicsTask is not a top-level class. It belongs inside
  # the TahiStandardTasks namespace. So we need to find it. Right now we assume
  # if we cannot find it then limit the scope to task.
  def lookup_task_klass(klass_name)
    if Object.const_defined?(klass_name)
      klass_name.constantize
    else
      Task.descendants.find do |descendant|
        descendant.name.demodulize == klass_name
      end
    end
  end

  def render_empty_permissions
    render json: {
      permissions: [{
        id: params[:id],
        permissions: []
      }]
    }
  end
end
