require 'rails_helper'

describe 'data:populate_initial_roles:csv', rake_test: true do
  # Populated from the value of `csv`, an array of arrays.
  # e.g. [['JD', 'jd@example.com', Role::USER_ROLE, 'Production', 'PLOS Biology']]
  let(:csv_string) do
    ([%w(Name Email Role Environment Journals)] + csv)
      .map { |fields| CSV.generate_line(fields) }
      .join('')
  end

  let(:journal) { FactoryGirl.create(:journal) }
  let(:user_role) { Role.find_by(name: Role::USER_ROLE) }
  let!(:staff_admin_role) do
    FactoryGirl.create(:role,
                       name: 'Staff Admin',
                       journal: journal)
  end
  let(:task_name) { 'data:populate_initial_roles:csv' }
  let(:task_args) { ['foo'] }

  let(:user) { User.find_by(email: 'jane@example.edu') }

  before do
    expect(rake_object).to receive(:open).with('foo').and_return(csv_string)
  end

  context 'with a basic CSV file ' do
    let(:csv) do
      [['Jane Doe', 'jane@example.edu', "#{Role::USER_ROLE}, #{Role::STAFF_ADMIN_ROLE}", nil, journal.name],
       ['John Doe', 'john@example.edu', Role::USER_ROLE, nil, journal.name]]
    end

    it 'should insert the new users with the User role' do
      expect { run_rake_task }.to change { User.count }.by 2
      User.all.each do |user|
        expect(user).to have_role(Role::USER_ROLE)
      end
    end

    it 'should add the users to the listed roles' do
      run_rake_task
      expect(User.find_by(email: 'jane@example.edu'))
        .to have_role(journal.staff_admin_role, journal)
    end
  end

  context 'with an existing user' do
    let(:csv) do
      [['Jane Roe', 'jane@example.edu', 'Staff Admin', nil, journal.name]]
    end
    let!(:existing_user) do
      FactoryGirl.create(:user,
                         email: 'jane@example.edu',
                         first_name: 'Jane',
                         last_name: 'Doe',
                         username: 'jroe')
    end

    it 'should add the role to an existing user' do
      expect { run_rake_task }.not_to change { User.count }
      existing_user.reload
      expect(existing_user).to have_role(Role::USER_ROLE)
      expect(existing_user).to have_role(journal.staff_admin_role, journal)
    end

    it 'should not change the users name, username, or password' do
      expect { run_rake_task }.not_to change { user.first_name }
      expect { run_rake_task }.not_to change { user.last_name }
      expect { run_rake_task }.not_to change { user.username }
      expect { run_rake_task }.not_to change { user.password }
    end
  end

  context 'with a user assigned as site admin' do
    let(:csv) do
      [['Jane Doe', 'jane@example.edu', 'Site Admin', nil, journal.name]]
    end

    it 'should set the site_admin flag' do
      expect { run_rake_task }.to change { User.count }.by 1
      expect(user.site_admin).to be true
    end
  end

  context 'a user without a name' do
    let(:csv) { [[nil, 'jane@example.edu', Role::USER_ROLE, nil, journal.name]] }

    it 'should work' do
      expect { run_rake_task }.to change { User.count }.by 1
    end
  end

  context 'a user without a role' do
    let(:csv) { [['Jane Doe', 'jane@example.edu', nil, nil, journal.name]] }

    it 'should be given a User role and nothing else' do
      run_rake_task
      expect(user.assignments.map(&:role)).to contain_exactly(user_role)
    end
  end

  context 'extra spaces' do
    let(:csv) { [[' Jane Doe ', ' jane@example.edu ', ' Staff Admin ', nil, " #{journal.name} "]] }

    let!(:staff_admin_role) do
      FactoryGirl.create(:role,
                         name: 'Staff Admin',
                         journal: journal)
    end

    it 'should be ignored' do
      run_rake_task
      expect(user.first_name).to eq('Jane')
      expect(user.last_name).to eq('Doe')
      expect(user.username).to eq('jane')
      expect(user.assignments.map(&:role)).to contain_exactly(user_role, staff_admin_role)
    end
  end

  context 'when the Role field is set to "User"' do
    let(:csv) { [['Jane Doe', 'jane@example.edu', Role::USER_ROLE, nil, journal.name]] }

    it 'should be given a User role and nothing else' do
      run_rake_task
      expect(user.assignments.map(&:role)).to contain_exactly(user_role)
    end
  end

  context 'empty lines' do
    let(:csv) { [[nil, nil, nil, nil, nil]] }

    it 'should skip them' do
      expect { run_rake_task }.not_to change { User.count }
    end
  end
end
