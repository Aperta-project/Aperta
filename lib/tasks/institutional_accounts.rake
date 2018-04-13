# Copyright (c) 2018 Public Library of Science

# Permission is hereby granted, free of charge, to any person obtaining a
# copy of this software and associated documentation files (the "Software"),
# to deal in the Software without restriction, including without limitation
# the rights to use, copy, modify, merge, publish, distribute, sublicense,
# and/or sell copies of the Software, and to permit persons to whom the
# Software is furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
# THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
# FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
# DEALINGS IN THE SOFTWARE.

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
          Adds a new Institutional Account to the database

          Make sure to update the list above to keep the institution list current
          Example in zsh:
          rake 'institutional_accounts:add_accounts[Victoria University2, C01282]'
       DESC
  task :add_account, [:text, :nav_customer_number] => :environment do |_t, args|
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
  task :remove_account, [:nav_customer_number] => :environment do |_t, args|
    if args[:nav_customer_number].present?
      deleted = InstitutionalAccountsManager.new.remove!(args[:nav_customer_number])
      puts "Deletion of \"#{deleted}\" complete."
    else
      puts "A nav_customer_number is required to identify the account to remove"
    end
  end
end
