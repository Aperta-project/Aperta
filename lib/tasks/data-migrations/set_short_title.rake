namespace :data do
  namespace :migrate do
    namespace :nested_questions do
      desc "Sets the paper short title *answer* to be the paper's short title"
      task set_short_title: :environment do
        Paper.all.each do |paper|
          # OK this line looks very strange; but we're moving the
          # paper's short title *from* a string column on paper *to* a
          # nested question answer; the setting and getting of that
          # answer is transparent on Paper, so we can short_title = ...
          paper.short_title = paper.read_attribute(:short_title)
        end
      end
    end
  end
end
