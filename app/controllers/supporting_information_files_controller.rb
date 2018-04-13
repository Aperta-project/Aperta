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

class SupportingInformationFilesController < ApplicationController
  respond_to :json
  before_action :authenticate_user!

  def show
    requires_user_can(:view, file.paper)
    respond_with file
  end

  def create
    requires_user_can(:edit, file.paper)
    DownloadAttachmentWorker
      .download_attachment(file, params[:url], current_user)
    respond_with file
  end

  def update
    requires_user_can(:edit, file.paper)
    file.update_attributes file_params
    respond_with file
  end

  def destroy
    requires_user_can(:edit, file.paper)
    file.destroy
    head :no_content
  end

  def update_attachment
    requires_user_can(:edit, file.paper)
    DownloadAttachmentWorker
      .download_attachment(file, params[:url], current_user)
    respond_with file
  end

  private

  def file
    @file ||= begin
                if params[:id].present?
                  SupportingInformationFile.find(params[:id])
                else
                  build_new_supporting_information_file
                end
              end
  end

  def build_new_supporting_information_file
    task = TahiStandardTasks::SupportingInformationTask.find(params[:task_id])
    task.supporting_information_files.new(paper_id: task.paper_id)
  end

  def file_params
    params.require(:supporting_information_file).permit(
      :title,
      :caption,
      :label,
      :category,
      :publishable,
      :attachment,
      attachment: [])
  end

end
