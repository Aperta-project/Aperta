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
    klass = class_name.camelize.constantize
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

  def render_empty_permissions
    render json: {
      permissions: [{
        id: params[:id],
        permissions: []
      }]
    }
  end
end
