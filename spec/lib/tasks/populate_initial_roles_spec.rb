require 'rails_helper'

describe 'data:populate_initial_roles:csv', rake_test: true do
  # Populated from the value of `csv`, an array of arrays.
  # e.g. [['JD', 'jd@example.com', 'User', 'Production', 'PLOS Biology']]
  let(:csv_string) do
    ([%w(Name Email Role Environment Journals)] + csv)
      .map { |fields| CSV.generate_line(fields) }
      .join('')
  end

  let(:journal) { FactoryGirl.create(:journal) }
  let(:user_role) { Role.find_by(name: 'User') }

  let(:task_name) { 'data:populate_initial_roles:csv' }
  let(:task_args) { ['foo'] }

  let(:user) { User.find_by(email: 'jane@example.edu') }

  before do
    expect(rake_object).to receive(:open).with('foo').and_return(csv_string)
  end

  context 'with a basic CSV file ' do
    let(:csv) do
      [['Jane Doe', 'jane@example.edu', 'User', nil, journal.name],
       ['John Doe', 'john@example.edu', 'User', nil, journal.name]]
    end

    it 'should insert the new users with the User role' do
      expect { run_rake_task }.to change { User.count }.by 2
      User.all.each do |user|
        expect(user.assignments.map(&:role)).to include(user_role)
      end
    end
  end

  context 'with a user assigned as site admin ' do
    let(:csv) do
      [['Jane Doe', 'jane@example.edu', 'Site Admin', nil, journal.name]]
    end

    it 'should set the site_admin flag' do
      expect { run_rake_task }.to change { User.count }.by 1
      expect(user.site_admin).to be true
    end
  end

  context 'a user without a name' do
    let(:csv) { [[nil, 'jane@example.edu', 'User', nil, journal.name]] }

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

  context 'empty lines' do
    let(:csv) { [[nil, nil, nil, nil, nil]] }

    it 'should skip them' do
      expect { run_rake_task }.not_to change { User.count }
    end
  end
end
