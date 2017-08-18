class RemovePBrFromPaperTitles < ActiveRecord::Migration
  def change
    # This query should be comprehensive. All titles with closing tags also contain
    # a corresponding starting tag.
    Paper.where("title ~ '<br\s*/?>' OR title ~ '<p>' OR title ~ '<div>' OR title ~ '\\n'").each do |p|
      title = p.title
      [/^<p>/, %r{</p>$}].each { |tag| title.gsub!(tag, '') }
      ["\n", '<p>', '</p>', %r{<br\s*/?>}, '<div>', '</div>'].each { |tag| title.gsub!(tag, ' ') }
      # rubocop:disable Rails/SkipsModelValidations:
      p.update_column(:title, title)
    end
  end
end
