# Copyright (c) 2018 Public Library of Science

# Permission is hereby granted, free of charge, to any person obtaining a
# copy of this software and associated documentation files (the "Software"),
# to deal in the Software without restriction, including without limitation
# the rights to use, copy, modify, merge, publish, distribute, sublicense,
# and/or sell copies of the Software, and to permit persons to whom the
# Software is furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
# THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
# FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
# DEALINGS IN THE SOFTWARE.

##
# The permissions controller doesn't deal one-to-one with Permission
# objects; instead it returns a permissions table for the current user
# and the given object.
#
class PermissionsController < ApplicationController
  before_action :authenticate_user!

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
  # based on what the front-end sent in. For example, ember might pass in
  # a task model that is not a top-level model, but instead belongs inside
  # the TahiStandardTasks namespace, so we need to find it. Right now we assume
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
