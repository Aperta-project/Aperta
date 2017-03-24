Rails.configuration.x.git_commit_id = \
  begin
    revision_path = Rails.root.join('REVISION')
    if File.exist?(revision_path)
      File.read(revision_path).strip
    elsif system('git status')
      id = `git rev-parse HEAD`[0..6]
      if `git status --porcelain`.strip.empty?
        id
      else
        "#{id} (dirty)"
      end
    elsif ENV['HEROKU_SLUG_COMMIT'].present?
      ENV['HEROKU_SLUG_COMMIT'][0..6]
    end
  rescue => ex
    Bugsnag.notify(ex)
    Rails.logger.warn("Caught exception: #{ex} when loading git version")
  end

Rails.configuration.x.git_commit_id ||= 'UNKNOWN'
