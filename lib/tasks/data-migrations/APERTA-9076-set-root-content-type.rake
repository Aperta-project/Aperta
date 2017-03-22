namespace :data do
  namespace :migrate do
    namespace :cards do
      desc 'Sets content_type to "display-children" for all card_contents that are roots'
      task set_root_content_type: :environment do
        CardContent.where(parent: nil).update_all(content_type: 'display-children')
      end
    end
  end
end
