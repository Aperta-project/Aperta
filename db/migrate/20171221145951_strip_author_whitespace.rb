class StripAuthorWhitespace < ActiveRecord::Migration
  # This uses the same underlying method that runs in the author's
  # before_validation callback. That method will remove
  # leading and trailing whitespace from email, first_name, last_name, and
  # middle_initial.  We can't run the normal `save` method with validations because
  # some existing authors have other data problems outside the scope of this migration that
  # will fail validation
  # rubocop:disable Rails/Output
  def up
    puts "Before migration: #{email_count} authors with whitespace in their emails out of #{Author.count} total"
    Author.find_each do |author|
      author.strip_whitespace
      author.save(validate: false)
    end

    new_count = email_count
    puts "After migration: #{new_count}"
    raise ActiveRecord::Rollback, "The migration left #{new_count} emails unstripped" if new_count != 0
    puts "Whitespace removed"
  end
  # rubocop:enable Rails/Output

  def email_count
    Author.where('email like ? OR authors.email like ?', ' %', '% ').count
  end
end
