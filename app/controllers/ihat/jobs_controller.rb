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

module Ihat
  class JobsController < ApplicationController
    skip_before_action :authenticate_with_basic_http
    protect_from_forgery with: :null_session
    rescue_from ActiveSupport::MessageVerifier::InvalidSignature, with: :render_invalid_params
    rescue_from ActionController::ParameterMissing, with: :render_invalid_params

    def create
      PaperUpdateWorker.perform_async(safe_params)
      head :ok
    end

    private

    def safe_params
      params.require(:job).permit(:id, :state, outputs: [:file_type, :url], options: [:callback_url, :metadata, :recipe_name]).tap do |safe|
        safe[:options][:metadata] = Verifier.new(safe[:options][:metadata]).decrypt
      end
    end

    def render_invalid_params(e)
      render status: :unprocessable_entity, json: { error: e.message }
    end
  end
end
