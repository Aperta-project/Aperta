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
# This is a way to tell Rails that when it auto-reloads code it should also
# make sure SnapshotService registrations get reloaded if necessary. Without
# this if the SnapshotService gets reloaded its registry gets cleared out
# and snapshotting fails after that point without a server restart.
#
# This only applies to 'development' or ANY environment where
# `config.cache_classes = false`. For environments where
# config.cache_classes is set to true this will only fire once.
#
# rubocop:disable Metrics/LineLength
ActionDispatch::Reloader.to_prepare do
  if SnapshotService.registry.empty?
    SnapshotService.configure do
      serialize AdhocAttachment, with: Snapshot::AttachmentSerializer
      serialize Author, with: Snapshot::AuthorSerializer
      serialize Figure, with: Snapshot::AttachmentSerializer
      serialize CardContent, with: Snapshot::CardContentSerializer
      serialize QuestionAttachment, with: Snapshot::AttachmentSerializer
      serialize SupportingInformationFile, with: Snapshot::AttachmentSerializer

      serialize TahiStandardTasks::AuthorsTask, with: Snapshot::AuthorTaskSerializer
      serialize TahiStandardTasks::FigureTask, with: Snapshot::FigureTaskSerializer
      serialize TahiStandardTasks::ReviewerRecommendationsTask, with: Snapshot::ReviewerRecommendationsTaskSerializer
      serialize TahiStandardTasks::ReviseTask, with: Snapshot::ReviseTaskSerializer
      serialize TahiStandardTasks::SupportingInformationTask, with: Snapshot::SupportingInformationTaskSerializer
      serialize TahiStandardTasks::TaxonTask, with: Snapshot::TaxonTaskSerializer
      serialize TahiStandardTasks::UploadManuscriptTask, with: Snapshot::UploadManuscriptTaskSerializer
      serialize CustomCardTask, with: Snapshot::CustomCardTaskSerializer
    end
  end
end
# rubocop:enable Metrics/LineLength
