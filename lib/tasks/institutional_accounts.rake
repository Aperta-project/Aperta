namespace :institutional_accounts do
  desc <<-DESC.strip_heredoc
    Adds the institutional account json seed to the database.

    This is referenced from Ember on the Billing Task. MAKE SURE to update this list whenever you
    add or remove institutions.
  DESC
  items =
  [
    { id: 'Bielefeld University', text: 'Bielefeld University', nav_customer_number: 'C01013' },
    { id: 'Brunel University', text: 'Brunel University', nav_customer_number: 'C01035' },
    { id: 'CINVESTAV Unidad Irapuato', text: 'CINVESTAV Unidad Irapuato', nav_customer_number: 'C01212' },
    { id: 'Delft University of Technology', text: 'Delft University of Technology', nav_customer_number: 'C01240' },
    { id: 'Dulbecco Telethon Institute (DTI)', text: 'Dulbecco Telethon Institute (DTI)', nav_customer_number: 'C00509' },
    { id: 'École Polytechnique Fédérale de Lausanne', text: 'École Polytechnique Fédérale de Lausanne', nav_customer_number: 'C01564' },
    { id: 'ETH Zurich', text: 'ETH Zurich', nav_customer_number: 'C00643' },
    { id: 'Faculty of Humanities and Social Sciences Libraries - University of Zagreb', text: 'Faculty of Humanities and Social Sciences Libraries - University of Zagreb', nav_customer_number: 'C01284' },
    { id: 'Francis Crick Institute', text: 'Francis Crick Institute', nav_customer_number: 'C01725' },
    { id: 'Fondazione Telethon Italy', text: 'Fondazione Telethon Italy', nav_customer_number: 'C00509' },
    { id: 'Forschungszentrum Jülich', text: 'Forschungszentrum Jülich', nav_customer_number: 'C01089' },
    { id: 'Georg-August-Universitaet Goettingen', text: 'Georg-August-Universitaet Goettingen', nav_customer_number: 'C00812' },
    { id: 'George Mason University', text: 'George Mason University', nav_customer_number: 'C01050' },
    { id: 'Helmholtz Centre for Environmental Research – UFZ', text: 'Helmholtz Centre for Environmental Research – UFZ', nav_customer_number: 'C01086' },
    { id: 'Helmholtz Centre for Infection Research', text: 'Helmholtz Centre for Infection Research', nav_customer_number: 'C01085' },
    { id: 'Helmholtz Centre for Materials and Coastal Research', text: 'Helmholtz Centre for Materials and Coastal Research', nav_customer_number: 'C01087' },
    { id: 'Helmholtz Zentrum Dresden Rossendorf', text: 'Helmholtz Zentrum Dresden Rossendorf', nav_customer_number: 'C01084' },
    { id: 'Imperial College London', text: 'Imperial College London', nav_customer_number: 'C01530' },
    { id: 'Institute for Health & Behavior - University of Luxembourg', text: 'Institute for Health & Behavior - University of Luxembourg', nav_customer_number: 'C01234' },
    { id: 'Instituto Venezolano de Investigaciones Cientificas', text: 'Instituto Venezolano de Investigaciones Cientificas', nav_customer_number: 'C01562' },
    { id: 'John Innes Centre', text: 'John Innes Centre', nav_customer_number: 'C01311' },
    { id: 'Karlsruhe Institute of Technology', text: 'Karlsruhe Institute of Technology', nav_customer_number: 'C01088' },
    { id: 'Leipzig University', text: 'Leipzig University', nav_customer_number: 'C01665' },
    { id: 'Lund University', text: 'Lund University', nav_customer_number: 'C00019' },
    { id: 'Macalester College', text: 'Macalester College', nav_customer_number: 'C01703' },
    { id: 'Max Planck Institute', text: 'Max Planck Institute', nav_customer_number: 'C00018' },
    { id: 'Newcastle University', text: 'Newcastle University', nav_customer_number: 'C01129' },
    { id: 'Nottingham Trent University', text: 'Nottingham Trent University', nav_customer_number: 'C01474' },
    { id: 'Queen Mary University of London', text: 'Queen Mary University of London', nav_customer_number: 'C01123' },
    { id: 'Queen\'s University Belfast', text: 'Queen\'s University Belfast', nav_customer_number: 'C01128' },
    { id: 'Rollins College', text: 'Rollins College', nav_customer_number: 'C01563' },
    { id: 'Ryerson University', text: 'Ryerson University', nav_customer_number: 'C01199' },
    { id: 'Ruhr University Bochum', text: 'Ruhr University Bochum', nav_customer_number: 'C01309' },
    { id: 'San Raffaele- Telethon Institute of Gene Therapy (HSR- TIGET)', text: 'San Raffaele- Telethon Institute of Gene Therapy (HSR- TIGET)', nav_customer_number: 'C00509' },
    { id: 'Simon Fraser University', text: 'Simon Fraser University', nav_customer_number: 'C00046' },
    { id: 'Technische Universitaet Muenchen', text: 'Technische Universitaet Muenchen', nav_customer_number: 'C01173' },
    { id: 'Telethon Institute of Genetics and Medicine (TIGEM)', text: 'Telethon Institute of Genetics and Medicine (TIGEM)', nav_customer_number: 'C00509' },
    { id: 'Temasek Life Sciences Laboratory', text: 'Temasek Life Sciences Laboratory', nav_customer_number: 'C01185' },
    { id: 'Universitatsbibliothek Regensburg', text: 'Universitatsbibliothek Regensburg', nav_customer_number: 'C00676' },
    { id: 'University College London', text: 'University College London', nav_customer_number: 'C00897' },
    { id: 'University of Birmingham', text: 'University of Birmingham', nav_customer_number: 'C01018' },
    { id: 'University of Bristol', text: 'University of Bristol', nav_customer_number: 'C01404' },
    { id: 'University of Edinburgh', text: 'University of Edinburgh', nav_customer_number: 'C01440' },
    { id: 'University of Glasgow', text: 'University of Glasgow', nav_customer_number: 'C01213' },
    { id: 'University of Leeds', text: 'University of Leeds', nav_customer_number: 'C01141' },
    { id: 'University of Manchester', text: 'University of Manchester', nav_customer_number: 'C01356' },
    { id: 'University of Manitoba', text: 'University of Manitoba', nav_customer_number: 'C00330' },
    { id: 'University of Potsdam', text: 'University of Potsdam', nav_customer_number: 'C01369' },
    { id: 'University of Reading', text: 'University of Reading', nav_customer_number: 'C01332' },
    { id: 'University of Sheffield', text: 'University of Sheffield', nav_customer_number: 'C01518' },
    { id: 'University of St. Andrews', text: 'University of St. Andrews', nav_customer_number: 'C01197' },
    { id: 'University of Stirling', text: 'University of Stirling', nav_customer_number: 'C01310' },
    { id: 'University of Stuttgart', text: 'University of Stuttgart', nav_customer_number: 'C01066' },
    { id: 'University of Warwick', text: 'University of Warwick', nav_customer_number: 'C01397' },
    { id: 'University of Western Sydney', text: 'University of Western Sydney', nav_customer_number: 'C01598' },
    { id: 'University of York', text: 'University of York', nav_customer_number: 'C01575' },
    { id: 'Victoria University', text: 'Victoria University', nav_customer_number: 'C01702' }
  ]
  task add_seed_accounts: :environment do
    account_list = ReferenceJson.find_or_create_by(name: "Institutional Account List")
    puts "Seeding institutional accounts.."
    account_list.update_column(:items, items)
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
      accounts = ReferenceJson.institutional_accounts
      accounts.items << new_hash
      accounts.save
      puts "Successfully added #{new_hash} to list of institutional_accounts"
    else
      puts "The text of the Institution name and a nav_customer_number is required to add the account"
    end
  end

  desc "Removes an old Institutional Account from the database"
  task :remove_account, [:nav_customer_number] => :environment do |t, args|
    if args[:nav_customer_number].present?
      account_list = ReferenceJson.institutional_accounts
      to_be_deleted = account_list.items.select { |item| item["nav_customer_number"] == args[:nav_customer_number] }
      post_delete_list = account_list.items.delete_if { |item| item["nav_customer_number"] == args[:nav_customer_number] }
      puts "Deleting #{to_be_deleted}.."
      account_list.update_column(:items, post_delete_list)
      puts "Deletion complete."
    else
      puts "A nav_customer_number is required to identify the account to remove"
    end
  end
end
