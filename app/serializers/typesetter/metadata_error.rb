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

module Typesetter
  # Custom error class for Typesetter::Metadata
  class MetadataError < StandardError
    class << self
      def no_task(task_type)
        new "A #{humanize_type(task_type)} is required."
      end

      def multiple_tasks(task)
        new("Found multiple #{humanize_type(task.type)}s," \
            ' but only one was expected.')
      end

      def no_answer(task, question_ident)
        new("No answer found for #{humanize_type(task.type)}" \
            " question #{question_ident}.")
      end

      def required_field(field)
        new "Field #{field} is required."
      end

      def not_accepted
        new "Paper has not been accepted"
      end

      def humanize_type(type_string)
        type_string.demodulize.titleize
      end
    end
  end
end
