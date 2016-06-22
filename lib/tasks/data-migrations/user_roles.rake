# rubocop:disable all
namespace :data do
  namespace :migrate do
    namespace :users do
      desc 'Migrates users to use new R&P'
      task make_into_new_roles: :environment do
        User.all.each(&:add_user_role!)
      end
    end
  end
end
