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
require 'eml_to_pdf'

# monkey patch em_to_pdf to use local bins
module EmlToPdf
  class Wkhtmltopdf
    class ConversionError < StandardError; end

    def self.convert(input, output_path)
      IO.popen("#{PDFKit.configuration.wkhtmltopdf} --encoding utf-8 --footer-center [page] --footer-spacing 2.5 --quiet - #{output_path} 2>&1", "r+") do |pipe|
        pipe.puts(input)
        pipe.close_write
        output = pipe.readlines.join
        pipe.close
        unless $?.success?
          raise ConversionError, output
        end
      end
    end
  end
end

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
end

def zip_add_rendered_html(zos, entry_name, time, template, context)
  mk_zip_entry(zos, entry_name, time) do
    view = ActionView::Base.new(ActionController::Base.view_paths, context)
    zos << view.render(file: template, layout: 'export/task_layout.html.erb')
  end
end

def context_list
  %w(first_name last_name middle_initial position email
    department title affiliation secondary_affiliation
    ringgold_id secondary_ringgold_id)
end

def context_node?(node)
  node['type'] == 'text' && context_list.include?(node['name'])
end

def make_snapshot_question_data(node, data = nil, level = nil)
  data = [] if data.nil?
  data << [level, node.dig('value', 'title'), node.dig('value', 'answer')] if node['type'] == 'question'
  data << [level, node['name'].humanize, node['value']] if context_node?(node)
  return data unless node.key?('children')
  node['children'].each_with_index do |child, i|
    make_snapshot_question_data(child, data, [level, i + 1].compact.join("."))
  end
  data
end

def export_email(email, prefix, zos)
  subject = (email.subject || 'no subject')[0..200].gsub(' ', '_').gsub(/[^0-9a-z_]/i, '')
  # some subjects have special chars in them, which messes with the wkhtmltopdf bash
  # truncate at 200 char or filename might be too long
  filename_sent_at = email.sent_at.try(&:iso8601) || "unsent#{SecureRandom.hex(3)}"
  filename = [filename_sent_at, subject].join('_')
  mk_zip_entry(zos, "#{prefix}/email/#{filename}.eml", email.sent_at) do
    zos << email.raw_source
  end

  # pdf creation
  temp_eml = Tempfile.new("#{filename}.eml")

  # generally the images link to expired s3 sources which fail the conversion
  sanitized_email_data = email.try(:raw_source) ? email.raw_source.gsub(/<img.*?>/m, '') : ''

  temp_eml.write(sanitized_email_data)
  temp_eml.close
  temp_pdf = Tempfile.new("#{filename}.pdf")
  EmlToPdf.convert(temp_eml.path, temp_pdf.path)
  mk_zip_entry(zos, "#{prefix}/email/#{filename}.pdf", email.sent_at) do
    zos << temp_pdf.read
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

def get_task_title_filename(task)
  return "#{task.phase.name.parameterize}--#{task.title.parameterize}-task"
end

def export_decision(zos, prefix, decision)
  version = "#{decision.major_version}.#{decision.minor_version}"
  dir = "#{prefix}/v#{version}/decision"
  decisions_with_attachments = decision.paper.decisions.reject do |d|
    d.attachments.empty?
  end.map do |d|
    "#{d.major_version}.#{d.minor_version}"
  end

  zip_add_rendered_html(zos,
                        "#{dir}/decision.html",
                        nil,
                        "export/decision.html.erb",
                        decision: decision,
                        owner: decision,
                        attachment_dir: "./",
                        decisions_with_attachments: decisions_with_attachments)
  decision.attachments.each do |attachment|
    zip_add_url(zos, "#{dir}/#{attachment.filename}", attachment.proxyable_url)
  end
  decision.reviewer_reports.each do |reviewer_report|
    next if reviewer_report.state == "invitation_not_accepted"
    zip_add_rendered_html(zos,
                          "#{dir}/#{get_task_title_filename(reviewer_report.task)}.html",
                          nil,
                          'export/review.html.erb',
                          content: reviewer_report.card_version.card_contents.root,
                          owner: reviewer_report)
  end
end

def export_paper(paper)
  prefix = paper.short_doi
  zipfile_name = "exports/#{prefix}.zip"
  File.unlink(zipfile_name) if File.exist?(zipfile_name)
  Zip::OutputStream.open(zipfile_name) do |zos|
    mk_zip_entry(zos, "#{prefix}/metadata.csv") do
      csv = CSV.new(zos)
      append_paper_metadata_header(csv)
      append_paper_metadata(csv, paper)
    end
    DiscussionTopic.where(paper: paper).each do |topic|
      zip_add_rendered_html(zos,
                            "#{prefix}/discussions/#{topic.title}.html",
                            topic.discussion_replies.pluck(:updated_at).sort.last,
                            'export/discussion.html.erb',
                            topic: topic)
    end
    Correspondence.where(paper: paper, versioned_text: nil).each do |email|
      export_email(email, prefix, zos)
    end
    Activity.where(subject: paper).includes(:user).order(:created_at).tap do |activities|
      mk_zip_entry(zos, "#{prefix}/activities.csv") do
        csv = CSV.new(zos)
        csv << ['timestamp', 'actor_full_name', 'message']
        activities.each do |a|
          actor_full_name = a.user.try(:full_name) || 'system'
          csv << [a.created_at.iso8601, actor_full_name, a.message]
        end
      end
    end
    paper.decisions.each do |decision|
      next if decision.verdict.nil?
      export_decision(zos, prefix, decision)
    end
    paper.versioned_texts.each do |vt|
      version = "v" + (vt.major_version || "0").to_s + "." + (vt.minor_version || "0").to_s
      dir = "#{prefix}/#{version}"
      zip_add_url(zos, "#{dir}/#{vt.manuscript_filename}", Attachment.authenticated_url_for_key(vt.manuscript_s3_path + '/' + vt.manuscript_filename)) if vt.manuscript_s3_path.present?
      zip_add_url(zos, "#{dir}/#{vt.sourcefile_filename}", Attachment.authenticated_url_for_key(vt.s3_full_sourcefile_path)) if vt.sourcefile_s3_path.present?
      Correspondence.where(versioned_text: vt).each do |email|
        export_email(email, dir, zos)
      end
      ExportProxy.figures_from_versioned_text(vt).each do |figure|
        zip_add_url(zos, "#{dir}/figures/#{figure.filename}", figure.href)
      end
      ExportProxy.si_from_versioned_text(vt).each do |si|
        zip_add_url(zos, "#{dir}/si/#{si.filename}", si.href)
      end
      vt.paper.snapshots.where(major_version: vt.major_version, minor_version: vt.minor_version).each do |snapshot|
        zip_add_rendered_html(zos,
                              "#{dir}/#{snapshot.contents['name']}.html",
                              nil,
                              'export/generic_snapshot.html.erb',
                              owner: snapshot.source,
                              data: make_snapshot_question_data(snapshot.contents))
      end
    end
    paper.tasks.each do |task|
      next unless task.card_version.try(:card_contents).try(:root) ||
          task.comments.any? ||
          task.try(:invitations).try(:any?) ||
          task.is_a?(AdHocTask)

      task_title = get_task_title_filename(task)

      view = if task.is_a? AdHocTask
               'export/ad_hoc_task.html.erb'
             else
               'export/normal_task.html.erb'
             end
      attachment_dir = "#{prefix}/#{task_title}-attachments"
      zip_add_rendered_html(zos,
                            "#{prefix}/#{task_title}.html",
                            nil,
                            view,
                            content: task.card_version.card_contents.root,
                            owner: task,
                            attachment_dir: "../#{attachment_dir}")
      task.attachments.each do |attachment|
        zip_add_url(zos, "#{attachment_dir}/#{attachment.filename}", attachment.proxyable_url)
      end
    end
  end
end

namespace :export do
  task :manuscript_zip, [:short_doi] => [:environment] do |_, args|
    export_paper(Paper.find_by(short_doi: args.fetch(:short_doi)))
  end

  task manuscript_zips: :environment do
    Paper.all.each do |paper|
      prefix = paper.short_doi
      zipfile_name = "exports/#{prefix}.zip"
      next if File.exist?(zipfile_name)
      begin
        export_paper(paper)
      rescue Exception => e
        puts("error exporting #{paper.short_doi}: #{e.message}")
        raise
      end
    end
  end

  task random_manuscript_zips: :environment do
    FileUtils.mkdir_p("exports")
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
      papers.append(paper2) unless paper2.nil? || papers.include?(paper2)
    end

    puts "exporting #{papers.size} papers: #{papers.map(&:short_doi)}"
    paper_queue = Queue.new
    papers.each { |paper| paper_queue << paper}
    (0...4).map do |i|
      Thread.new do
        loop do
          paper = paper_queue.pop(true) rescue break
          begin
            export_paper(paper)
          rescue Exception => e
            puts("Exception exporting #{paper.short_doi}: #{e.message}")
            raise
          end
        end
      end
    end.map(&:join)
  end

  task manuscripts_csv: :environment do
    FileUtils.mkdir_p("export")
    CSV.open("exports/manuscripts.csv", "wb") do |csv|
      append_paper_metadata_header(csv)
      Paper.all.each { |paper| append_paper_metadata(csv, paper) }
    end
  end
end
