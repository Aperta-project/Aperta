namespace :app do
  namespace :env do
    desc "List out all ENV vars registered in the app's tahi_env.rb"
    task :vars do
      require File.dirname(__FILE__) + '/../tahi_env'
      TahiEnv.registered_env_vars.each do |key, env_var|
        puts env_var.to_s
      end
    end
  end
end
