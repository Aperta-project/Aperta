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

# rubocop:disable Metrics/LineLength
# This class is a stopgap to find the fully qualified name of an Answerable
# based on its un-namespaced form. We don't want to do this in the future but
# for now it's a simple alternative to having to change the client code. This
# service class is used in the NestedQuestionAnswersController
#
class LookupClassNamespace
  POSSIBLE_TYPES = {
    # Tasks
    "BillingTask"                    =>     "PlosBilling::BillingTask",
    "EditorsDiscussionTask"          =>     "PlosBioInternalReview::EditorsDiscussionTask",
    "ChangesForAuthorTask"           =>     "PlosBioTechCheck::ChangesForAuthorTask",
    "FinalTechCheckTask"             =>     "PlosBioTechCheck::FinalTechCheckTask",
    "InitialTechCheckTask"           =>     "PlosBioTechCheck::InitialTechCheckTask",
    "RevisionTechCheckTask"          =>     "PlosBioTechCheck::RevisionTechCheckTask",
    "AssignTeamTask"                 =>     "Tahi::AssignTeam::AssignTeamTask",
    "AuthorsTask"                    =>     "TahiStandardTasks::AuthorsTask",
    "DataAvailabilityTask"           =>     "TahiStandardTasks::DataAvailabilityTask",
    "FigureTask"                     =>     "TahiStandardTasks::FigureTask",
    "FrontMatterReviewerReportTask"  =>     "TahiStandardTasks::FrontMatterReviewerReportTask",
    "InitialDecisionTask"            =>     "TahiStandardTasks::InitialDecisionTask",
    "PaperEditorTask"                =>     "TahiStandardTasks::PaperEditorTask",
    "PaperReviewerTask"              =>     "TahiStandardTasks::PaperReviewerTask",
    "ProductionMetadataTask"         =>     "TahiStandardTasks::ProductionMetadataTask",
    "RegisterDecisionTask"           =>     "TahiStandardTasks::RegisterDecisionTask",
    "RelatedArticlesTask"            =>     "TahiStandardTasks::RelatedArticlesTask",
    "ReviewerRecommendationsTask"    =>     "TahiStandardTasks::ReviewerRecommendationsTask",
    "ReviewerReportTask"             =>     "TahiStandardTasks::ReviewerReportTask",
    "ReviseTask"                     =>     "TahiStandardTasks::ReviseTask",
    "SendToApexTask"                 =>     "TahiStandardTasks::SendToApexTask",
    "SupportingInformationTask"      =>     "TahiStandardTasks::SupportingInformationTask",
    "TaxonTask"                      =>     "TahiStandardTasks::TaxonTask",
    "TitleAndAbstractTask"           =>     "TahiStandardTasks::TitleAndAbstractTask",
    "UploadManuscriptTask"           =>     "TahiStandardTasks::UploadManuscriptTask",
    # The Rest
    "ReviewerRecommendation"         =>     "TahiStandardTasks::ReviewerRecommendation"
  }.freeze

  # If the type_name isn't found in the POSSIBLE_TYPES, let it go on through as-is.
  def self.lookup_namespace(type_name)
    POSSIBLE_TYPES.fetch(type_name, type_name)
  end
end
# rubocop:enable Metrics/LineLength
