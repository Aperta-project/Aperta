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

module Tahi
  module AssignTeam
    # The AssignTeamTask represents the part of the paper workflow
    # responsible for assigning users to various roles on a paper.
    class AssignTeamTask < Task
      DEFAULT_TITLE = 'Assign Team'.freeze
      DEFAULT_ROLE_HINT = 'admin'.freeze

      def assignable_roles
        [
          journal.academic_editor_role,
          journal.cover_editor_role,
          journal.handling_editor_role,
          journal.reviewer_role
        ]
      end

      def assignments
        paper.assignments.where(role_id: assignable_roles)
      end

      def active_model_serializer
        AssignTeamTaskSerializer
      end
    end
  end
end
