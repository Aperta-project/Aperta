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

module Ithenticate
  # Adapter for document response from Ithenticate
  class DocumentResponse < Response
    def first_document
      @response_hash["documents"].try(:first) if @response_hash.present?
    end

    def first_part
      return unless first_document
      first_document["parts"].try(:first)
    end

    def report_complete?
      report_id.present? && first_document['is_pending'].zero?
    end

    def error
      first_document && first_document["error"]
    end

    def error?
      error.present?
    end

    def error_string
      error
    end

    def report_id
      return unless first_part
      first_part["id"]
    end

    def score
      return unless first_part
      first_part["score"]
    end
  end
end
