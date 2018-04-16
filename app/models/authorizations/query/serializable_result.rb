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

module Authorizations
  class Query
    # Authorizations::Query::SerializableResult represents an individual
    # row/object in the results of an Authorizations::Query. It is intended to \
    # be used for serializing and sending to front-end clients.
    #
    # == Example Result
    #
    #   <Authorizations::Query::SerializableResult:0x007f90453ab128
    #     @id="paper+1",
    #     @object={:id=>1, :type=>"Paper"},
    #     @permissions=
    #       {"assign_roles"=>{:states=>["*"]},
    #        "edit"=>{:states=>["*"]},
    #        "edit_authors"=>{:states=>["*"]},
    #        "edit_related_articles"=>{:states=>["*"]},
    #        "manage_collaborators"=>{:states=>["*"]},
    #        "manage_workflow"=>{:states=>["*"]},
    #        "reactivate"=>{:states=>["withdrawn"]},
    #        "register_decision"=>{:states=>["*"]},
    #        "rescind_decision"=>{:states=>["*"]},
    #        "search_academic_editors"=>{:states=>["*"]},
    #        "search_admins"=>{:states=>["*"]},
    #        "search_reviewers"=>{:states=>["*"]},
    #        "send_to_apex"=>{:states=>["*"]},
    #        "start_discussion"=>{:states=>["*"]},
    #        "submit"=>{:states=>["*"]},
    #        "view"=>{:states=>["*"]},
    #        "view_decisions"=>{:states=>["*"]},
    #        "view_user_role_eligibility_on_paper"=>{:states=>["*"]},
    #        "withdraw"=>{:states=>["*"]}}>
    class SerializableResult
      include ActiveModel::SerializerSupport

      # Returns the client-side friendly id, e.g.: "Paper+1"
      attr_reader :id

      # Returns the client-side view of the object, e.g.: { id: 1, type: 'Paper'}
      attr_reader :object

      # Returns the model instance that this SerializableResult was \
      # constructed with
      attr_reader :model

      # Returns the permissions that this SerializableResult was constructed \
      # with
      attr_reader :permissions

      # == Constructor Arguments
      # * model: the ActiveRecord model instance represented by this \
      #     SerializableResult
      # * permissions: the Hash of permissions for corresponding to the \
      #    +model+
      def initialize(model, permissions)
        @object = { id: model.id, type: model.class.sti_name }
        @permissions = permissions
        @id = "#{Emberize.class_name(model.class)}+#{model.id}"
      end
    end
  end
end
