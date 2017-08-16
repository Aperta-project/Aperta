class RemovePBrFromPaperTitles < ActiveRecord::Migration
  def change
    # This query should be comprehensive. All titles with closing tags also contain
    # a corresponding starting tag, and none have self-closing <br /> tags.
    Paper.where("title ~ '<br>' OR title ~ '<p>' OR title ~ '<div>' OR title ~ '\\n'").each do |p|
      title = p.title
      # when \n separates words replace with a space
      title.gsub!(/(\w)\n(\w)/, '\1 \2')
      ["\n", '<p>', '</p>', '<br>', '<div>', '</div>'].each { |tag| title.gsub!(tag, '') }
      p.update_column(:title, title)
    end
  end
end
