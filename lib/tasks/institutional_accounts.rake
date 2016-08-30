namespace :institutional_accounts do
  desc <<-DESC.strip_heredoc
    Adds the institutional account json seed to the database.

    This is referenced from Ember on the Billing Task. MAKE SURE to update this list whenever you
    add or remove institutions.
  DESC
  task add_seed_accounts: :environment do
    puts "Seeding institutional accounts.."
    InstitutionalAccountsManager.new.seed!
    puts "Finished updating"
  end

  desc <<-DESC.strip_heredoc
          Adds a new Institutional Accounts to the database

          Make sure to update the list above to keep the institution list current
          Example in zsh:
          rake 'institutional_accounts:add_accounts[Victoria University2, C01282]'
       DESC
  task :add_account, [:text, :nav_customer_number] => :environment do |t, args|
    if args[:text].present? && args[:nav_customer_number].present?
      new_hash = { "id" => args[:text], "text" => args[:text], "nav_customer_number" => args[:nav_customer_number] }
      puts "Adding #{new_hash}.."
      InstitutionalAccountsManager.new.add!(
        id: args[:text],
        text: args[:text],
        nav_customer_number: args[:nav_customer_number]
      )
      puts "Successfully added #{new_hash} to list of institutional_accounts"
    else
      puts "The text of the Institution name and a nav_customer_number is required to add the account"
    end
  end

  desc "Removes an old Institutional Account from the database"
  task :remove_account, [:nav_customer_number] => :environment do |t, args|
    if args[:nav_customer_number].present?
      deleted = InstitutionalAccountsManager.new.remove!(args[:nav_customer_number])
      puts "Deletion of \"#{deleted}\" complete."
    else
      puts "A nav_customer_number is required to identify the account to remove"
    end
  end
end
