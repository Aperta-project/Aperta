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

require 'zip'
require 'fileutils'

# This pollutes the global namespace
def append_paper_metadata_header(csv)
  csv << ["doi", "title", "status", "authors", "academic_editors", "handling_editors", "cover_editors", "reviewers"]
end

def append_paper_metadata(csv, paper)
  authors = paper.authors.map(&:full_name).join(",")
  academic_editors = paper.academic_editors.map(&:full_name).join(",")
  handling_editors = paper.handling_editors.map(&:full_name).join(",")
  cover_editors = paper.cover_editors.map(&:full_name).join(",")
  reviewers = ReviewerReport.where(task_id: paper.tasks.pluck(:id))
                .map(&:user).uniq.compact.map(&:full_name).join(",")
  csv << [paper.doi,
          paper.title,
          paper.publishing_state,
          authors,
          academic_editors,
          handling_editors,
          cover_editors,
          reviewers]
end

def mk_zip_entry(zos, entry_name, time=nil)
  dt = if time.nil?
         nil
       else
         Zip::DOSTime.parse(time.utc.strftime("%Y-%m-%d %H:%M:%S"))
       end
  entry = Zip::Entry.new(zos, entry_name, nil, nil, nil, nil, nil, nil, dt)
  zos.put_next_entry(entry)
  yield
end

def zip_add_url(zos, name, url)
  return if url.nil?
  conn = Faraday.new
  resp = conn.get(url)
  last_modified = if resp.headers['Last-Modified']
                    DateTime.rfc2822(resp.headers['Last-Modified'])
                  else
                    nil
                  end
  mk_zip_entry(zos, name, last_modified) do
    zos << resp.body
  end
rescue Faraday::ConnectionFailed => ex
  puts(ex)
end

def export_question(csv, node, level = nil)
  csv << [level, node.dig('value', 'title'), node.dig('value', 'answer')] if node['type'] == 'question'
  return unless node.key?('children')
  node['children'].each_with_index do |child, i|
    export_question(csv, child, [level, i + 1].compact.join("."))
  end
end

# Like Figure/SupportingInformationProxy, but more lightweight
class ExportProxy
  def self.figures_from_versioned_text(versioned_text)
    from_versioned_text(versioned_text, :figures)
  end

  def self.si_from_versioned_text(versioned_text)
    from_versioned_text(versioned_text, :supporting_information_files)
  end

  def self.from_versioned_text(versioned_text, what)
    if versioned_text.latest_version?
      versioned_text.paper.send(what).map do |model|
        from_model(model)
      end
    else
      major_version = versioned_text.major_version
      minor_version = versioned_text.minor_version
      snapshots = versioned_text.paper.snapshots.send(what)
                    .where(major_version: major_version,
                           minor_version: minor_version)
      snapshots.map do |snapshot|
        from_snapshot(snapshot)
      end
    end
  end

  def self.from_model(model)
    new(model: model)
  end

  def self.from_snapshot(snapshot)
    new(
      filename: snapshot.get_property("file"),
      s3_path: snapshot.key
    )
  end

  def filename
    return @model.filename if @model
    @filename
  end

  def initialize(model: nil, filename: nil, s3_path: nil)
    @model = model
    @filename = filename
    @s3_path = s3_path
  end

  def href
    return @model.proxyable_url if @model
    Attachment.authenticated_url_for_key(@s3_path)
  end
end

def export_paper(paper)
  prefix = paper.short_doi
  zipfile_name = "export/#{prefix}.zip"
  File.unlink(zipfile_name) if File.exist?(zipfile_name)
  Zip::OutputStream.open(zipfile_name) do |zos|
    mk_zip_entry(zos, "#{prefix}/metadata.csv") do
      csv = CSV.new(zos)
      append_paper_metadata_header(csv)
      append_paper_metadata(csv, paper)
    end
    DiscussionTopic.where(paper: paper).each do |topic|
      mk_zip_entry(zos, "#{prefix}/discussions/#{topic.title}.html", topic.discussion_replies.pluck(:updated_at).sort.last) do
        view = ActionView::Base.new(ActionController::Base.view_paths, topic: topic)
        zos << view.render(file: 'export/discussion.html.erb')
      end
    end
    Correspondence.where(paper: paper, versioned_text: nil).each do |email|
      mk_zip_entry(zos, "#{prefix}/email/#{email.message_id}.eml", email.sent_at) do
        zos << email.raw_source
      end
    end
    paper.versioned_texts.each do |vt|
      version = "v" + (vt.major_version || "0").to_s + "." + (vt.minor_version || "0").to_s
      dir = "#{prefix}/#{version}"
      zip_add_url(zos, "#{dir}/#{vt.manuscript_filename}", Attachment.authenticated_url_for_key(vt.manuscript_s3_path + '/' + vt.manuscript_filename)) if vt.manuscript_s3_path.present?
      zip_add_url(zos, "#{dir}/#{vt.sourcefile_filename}", Attachment.authenticated_url_for_key(vt.s3_full_sourcefile_path)) if vt.sourcefile_s3_path.present?
      Correspondence.where(versioned_text: vt).each do |email|
        mk_zip_entry(zos, "#{dir}/email/#{email.message_id}.eml", email.sent_at) do
          zos << email.raw_source
        end
      end
      ExportProxy.figures_from_versioned_text(vt).each do |figure|
        zip_add_url(zos, "#{dir}/figures/#{figure.filename}", figure.href)
      end
      ExportProxy.si_from_versioned_text(vt).each do |si|
        zip_add_url(zos, "#{dir}/si/#{si.filename}", si.href)
      end
      vt.paper.snapshots.where(major_version: vt.major_version, minor_version: vt.minor_version).each do |snapshot|
        mk_zip_entry(zos, "#{dir}/#{snapshot.contents['name']}.csv") do
          csv = CSV.new(zos)
          csv << ['id', 'question', 'answer']
          export_question(csv, snapshot.contents)
        end
      end
    end
  end
end

namespace :export do
  task :manuscript_zip, [:short_doi] => [:environment] do |_, args|
    export_paper(Paper.find_by(short_doi: args.fetch(:short_doi)))
  end

  task random_manuscript_zips: :environment do
    FileUtils.mkdir_p("export")
    papers = []
    # Ensure we have one from each state
    Paper.all.pluck(:publishing_state).uniq.each do |state|
      papers.append(Paper.where(publishing_state: state).order('RANDOM()').first)
    end
    while papers.size <= 20
      paper = Paper.order('RANDOM()').first
      next if papers.member?(paper)
      papers.append(paper)
      reviewer = ReviewerReport.where(task_id: paper.tasks.pluck(:id)).map(&:user).uniq.compact.sample
      paper2 = reviewer.reviewer_reports.first.try(:paper) unless reviewer.nil?
      papers.append(paper2) unless paper2.nil?
    end
    papers.each do |paper|
      export_paper(paper)
    end
  end

  task manuscripts_csv: :environment do
    FileUtils.mkdir_p("export")
    CSV.open("export/manuscripts.csv", "wb") do |csv|
      append_paper_metadata_header(csv)
      Paper.all.each { |paper| append_paper_metadata(csv, paper) }
    end
  end
end
