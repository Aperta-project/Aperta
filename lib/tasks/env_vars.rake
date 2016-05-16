namespace :app do
  namespace :env do
    desc "Recreate all of the versions of figure attachments"
    task :vars do
      require File.dirname(__FILE__) + '/../tahi_env'
      TahiEnv.registered_env_vars.each do |key, env_var|
        puts env_var.to_s
      end
    end
  end
end
