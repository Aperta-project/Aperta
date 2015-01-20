namespace :styleguide do
  desc "Generate Live Styleguide"
  task :generate => :environment  do
    system "rspec spec/features/populate_styleguide.rb"
    system "ruby testing.rb"
  end

  # TODO watch task for while we develop on the styleguide?
  # This is only for development
  task :watch => :environment do
    system('nodemon --exec "ruby testing.rb" -w app/views/kss/home/styleguide2.html.erb testing.rb -V')
  end
end
