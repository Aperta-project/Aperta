namespace :data do
  namespace :migrate do
    desc <<-DESC
      Rebuilds card content boundary columns that got disjointed.
      see https://github.com/collectiveidea/awesome_nested_set#conversion-from-other-trees
    DESC
    task rebuild_card_content_boundaries: :environment do
      CardContent.rebuild!(false)
    end
  end
end
