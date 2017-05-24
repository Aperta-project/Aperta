namespace :data do
  namespace :migrate do
    desc <<-DESC
      Rebuilds card content boundary columns that got disjointed.
      see https://github.com/collectiveidea/awesome_nested_set#conversion-from-other-trees
    DESC
    task rebuild_card_content_boundaries: :environment do
      # rebuilding without validations because acts_as_nested_set will ignore any
      # scopes that were defined in the model code when a `rebuild!` happens, and
      # having deleted CardContent will cause this to explode otherwise
      STDOUT.puts "Rebuilding card content nested set boundaries..."
      CardContent.rebuild!(false)
    end
  end
end
