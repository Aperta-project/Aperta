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

# Models a response from ihat.
class IhatJobResponse
  attr_reader :outputs, :state, :metadata, :job_id, :recipe_name

  def initialize(params = {})
    @state = params[:state].to_sym
    @outputs = params[:outputs]
    @metadata = params[:options][:metadata] || {}
    @job_id = params[:id]
    @recipe_name = params[:options][:recipe_name]
  end

  def paper_id
    metadata[:paper_id]
  end

  def user_id
    metadata[:user_id]
  end

  def format_url(format)
    retval = outputs.detect { |o| o[:file_type] == format.to_s }
    retval && retval[:url]
  end

  def job_state
    "Ihat job state for paper #{paper_id}: #{state}"
  end

  [:pending, :processing, :completed, :errored, :archived, :skipped].each do |check_state|
    define_method("#{check_state}?") do
      state == check_state
    end
  end
end
