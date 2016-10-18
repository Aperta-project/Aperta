require 'csv'

class PaperTrackerCsvStreamer < CsvStreamerRaw
  def initialize(io)
    super(io,
          %w(title
             manuscript_id
             version_date
             submission_date
             article_type
             status
             fully_submitted?
             creator_email
             creator_first_name
             creator_last_name
             corresponding_author_first_name
             corresponding_author_middle_initial
             corresponding_author_last_name
             corresponding_author_email
             corresponding_author_country
             handling_editor
             cover_editor))
  end

  def write_line(paper)
    corr_author = paper.authors.select { |a| a.corresponding? }.try(:first)
    write_line_raw(paper.title,
                   paper.manuscript_id,
                   paper.submitted_at.try(:to_formatted_s, :csv),
                   paper.first_submitted_at.try(:to_formatted_s, :csv),
                   paper.paper_type,
                   paper.publishing_state,
                   paper.last_of_task(TahiStandardTasks::AuthorsTask).present?,
                   paper.creator.email,
                   paper.creator.first_name,
                   paper.creator.last_name,
                   corr_author.try(:first_name),
                   corr_author.try(:middle_initial),
                   corr_author.try(:last_name),
                   corr_author.try(:email),
                   corr_author.try(:current_address_country),
                   paper.cover_editors.first.try(:full_name),
                   paper.handling_editors.first.try(:full_name))
  end
end
