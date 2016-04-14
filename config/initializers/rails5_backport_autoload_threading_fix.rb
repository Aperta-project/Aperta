# Backported fix from Rails 5 to remove autoload threading issue.
#
# Related to issue: https://github.com/rails/rails/issues/13142
# Fix pulled from: https://github.com/rails/rails/commit/a71350cae0082193ad8c66d65ab62e8bb0b7853b
#
# This will disable autoloading when eager_loading=true and cache_classes=true
# (typical in test and production environments) in the Rails.application.config.
# This causes constants that are not loaded to fail.
#
Rails.application.config.after_initialize do
  config = Rails.application.config
  if config.eager_load && config.cache_classes
    ActiveSupport::Dependencies.unhook!
  end
end
