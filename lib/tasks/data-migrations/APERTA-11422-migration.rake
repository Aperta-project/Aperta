def insert_element(array, element)
  if array.length == 1
    index = 1
  elsif !(array.last > element)
    index = array.length
  else
    index = [*array.each_with_index].bsearch { |x, _| x > element }.last
  end
  array[index - 1]
end

namespace :data do
  namespace :migrate do
    desc <<-DESC
      APERTA-11422: This checks if a correspondence manuscriptVersion is nil and if true,
      it replaces the nil value with the version of the paper at the time the correspondence
      was created. The closest date from a paper versioned_texts is the value used to backfill
      the correspondence manuscriptVersion

    DESC

    task aperta_11422_manuscript_version_and_status_in_correspondence_history: :environment do
      papers = Paper.all
      if papers.empty?
        raise Exception, "No paper was found."
      end

      papers.each do |paper|
        versions = paper.versioned_texts
        version_created_date = versions.map(&:created_at).sort
        paper.correspondence.each do |correspondence|
          next unless correspondence.manuscript_version.nil?
          version_date = insert_element(version_created_date, correspondence.created_at)
          selected_version = versions.select { |version| version.created_at == version_date }.first
          correspondence.update!(manuscript_version: selected_version.version)
        end
      end
    end
  end
end
