namespace :styleguide do
  desc "Generate Live Styleguide"
  task generate: :environment  do
    system "rspec spec/features/populate_styleguide.rb"
    system "ruby testing.rb"
  end

  task watch: :environment do
    system('nodemon --exec "ruby testing.rb" -w app/views/kss/home/styleguide_template.html.erb testing.rb -V')
  end
end
