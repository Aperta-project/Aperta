namespace :tahi do
  desc 'Migrate striking image to use boolean in Figure table'
  task migrate_striking_image: :environment do
    Paper.all.each do |p|
      next unless p.striking_image
      figure = Figure.find(p.striking_image.id)
      figure.striking_image = true
      figure.save!
    end
  end
end
