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

module TahiStandardTasks
  # The UploadManuscriptController is responsible for uploading
  # manuscripts (e.g. files that are doc, docx, etc) for the
  # UploadManuscriptTask.
  class UploadManuscriptController < ::ApplicationController
    before_action :authenticate_user!
    respond_to :json

    # begin tiny class hierarchy that is more readable than a hash
    class PaperAttachment < Object
      attr_reader :existing_file, :paper, :s3_url, :worker
      def initialize(paper, s3_url, worker)
        @paper = paper
        @s3_url = s3_url
        @worker = worker
      end
    end

    class Manuscript < PaperAttachment
      def file
        @existing_file = paper.file ? true : false
        paper.file || paper.create_file
      end
    end

    class Sourcefile < PaperAttachment
      def file
        @existing_file = paper.sourcefile ? true : false
        paper.sourcefile || paper.create_sourcefile
      end
    end
    # end tiny class hierarchy

    # The +upload+ action should be used when updating a paper's
    # attached manuscript file from a browser. This is because it enforces
    # permissions at the UploadManuscriptTask-level rather than at the
    # paper-level.
    def upload
      requires_user_can :edit, task

      attachment = paper_attachment.file
      paper_attachment.worker.download(
        paper,
        paper_attachment.s3_url,
        current_user
      )

      render json: attachment,
             status: paper_attachment.existing_file ? 200 : 201,
             root: 'attachment',
             serializer: AttachmentSerializer
    end

    # If a manuscript upload errors out then the user can clear the upload from
    # the UI.
    def destroy_manuscript
      requires_user_can :edit, task
      paper.file.destroy!

      head :no_content
    end

    def destroy_sourcefile
      requires_user_can :edit, task
      paper.sourcefile.destroy!

      head :no_content
    end

    private

    def task
      @task ||= UploadManuscriptTask.find(params[:id])
    end

    def paper
      @paper ||= task.paper
    end

    def paper_attachment
      if params[:sourcefile_attachment].present?
        Sourcefile.new(paper, params[:sourcefile_attachment][:s3_url], DownloadSourcefileWorker)
      else
        Manuscript.new(paper, params[:manuscript_attachment][:s3_url], DownloadManuscriptWorker)
      end
    end
  end
end
