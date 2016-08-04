namespace :data do
  namespace :migrate do
    desc "Set the PLOS Biology journal's staff email if not set"
    task set_plos_biology_staff_email: :environment do
      plos_bio_staff_email = 'plosbiology@plos.org'
      journal = Journal.find_by(name: 'PLOS Biology')
      if journal.blank?
        print "Not setting staff_email on the PLOS Biology journal because "
          "a journal with that name was not found in the database.\n"
      elsif journal.staff_email.blank?
        puts "Set PLOS Biology journal's staff email to #{plos_bio_staff_email}"
        journal.update!(staff_email: plos_bio_staff_email)
      else
        print "Did not set PLOS Biology journal's staff email ",
          "as it was already set to #{journal.staff_email}\n"
      end
    end
  end
end
