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

# API for letter templates
class Admin::LetterTemplatesController < ApplicationController
  before_action :authenticate_user!
  before_action :authorized_user
  respond_to :json

  def index
    journal_id = letter_template_params[:journal_id]
    letter_templates = journal_id ? Journal.find(journal_id).letter_templates : []
    respond_with(letter_templates, only: [:id, :subject, :name])
  end

  def show
    respond_with letter_template
  end

  def update
    update_params = letter_template_params[:letter_template]
    letter_template.update(update_params)
    respond_with letter_template
  end

  def create
    journal = Journal.find(create_params[:journal_id])
    requires_user_can(:create_email_template, journal)
    template = LetterTemplate.create!(create_params)
    respond_with :admin, template
  end

  def preview
    preview_params = letter_template_params[:letter_template]
    letter_template.assign_attributes(preview_params)
    letter_template.render_dummy_data if letter_template.valid?
    respond_with :admin, letter_template
  end

  private

  def letter_template
    @letter_template ||= LetterTemplate.find(params[:id])
  end

  def authorized_user
    requires_user_can(:manage_users, Journal)
  end

  def letter_template_params
    params.permit(:journal_id, letter_template: [:body, :subject, :name, :cc, :bcc])
  end

  def create_params
    params.require(:letter_template).permit(:journal_id, :name, :scenario, :body, :subject)
  end
end
