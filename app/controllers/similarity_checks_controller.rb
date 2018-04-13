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

#
# Controller for creating and retrieving SimilarityCheck records. This tries to
# handle all the permutations of being called with a versioned text or paper
# param, both of which have many SimilarityChecks.
#
class SimilarityChecksController < ::ApplicationController
  before_action :authenticate_user!

  respond_to :json

  def create
    requires_user_can(:perform_similarity_check, paper)
    similarity_check = SimilarityCheck.create!(
      versioned_text: versioned_text,
      automatic: false
    )
    similarity_check.start_report_async
    respond_with(similarity_check)
  end

  def update
    similarity_check = SimilarityCheck.find(params.require(:id))
    requires_user_can(:perform_similarity_check, paper)
    similarity_check.update(update_params)
    similarity_check.save!
    respond_with(similarity_check)
  end

  def index
    requires_user_can(:perform_similarity_check, paper)
    respond_with(paper.similarity_checks)
  end

  def show
    similarity_check = SimilarityCheck.find(params.require(:id))
    requires_user_can_view(similarity_check)
    respond_with(similarity_check)
  end

  def report_view_only
    similarity_check = SimilarityCheck.find(params.require(:id))
    requires_user_can(:perform_similarity_check, similarity_check.paper)
    redirect_to similarity_check.report_view_only_url || :back
  end

  private

  def create_params
    @create_params ||= params.require(:similarity_check)
                         .permit(:versioned_text_id)
  end

  def update_params
    @update_params ||= params.require(:similarity_check).permit(:dismissed)
  end

  def paper
    @paper ||=
      if params[:paper_id].present?
        Paper.find_by_id_or_short_doi(params[:paper_id])
      else
        versioned_text.paper
      end
  end

  def versioned_text
    @versioned_text ||= VersionedText.find(create_params[:versioned_text_id])
  end
end
