namespace :flip do
  desc <<-USAGE.strip_heredoc
    This flips a feature flag either on or off for use in the app.
    :feature and :journal_id and :boolean is required

    Turn feature on idempotently
      Usage: rake flip:toggle[<feature_column_on_journal>,<journal_id>,true]
      Example: rake flip:toggle['pdf_allowed',3,true] (Will turn on the feature flag for pdf submissions for Journal 3)
  USAGE
  task :toggle, [:feature_string, :journal_id, :boolean] => :environment do |_, args|
    journal = Journal.find(args[:journal_id])
    bool = if args[:boolean] == 'false'
             false
           elsif args[:boolean] == 'true'
             true
           else
             args[:boolean]
           end
    journal.update_column(args[:feature_string].to_sym, bool)
    STDOUT.puts("Updating #{journal.name} to have feature #{args[:feature_string]} to #{args[:boolean]}")
  end
end
