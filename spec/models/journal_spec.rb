require 'rails_helper'

describe Journal do
  it "will be valid with default factory data" do
    journal = build(:journal)
    expect(journal).to be_valid
  end

  describe "validations" do
    subject(:journal) do
      FactoryGirl.build(
        :journal,
        doi_publisher_prefix: 'a-doi-publisher-prefix',
        doi_journal_prefix: 'journal.foobar',
        last_doi_issued: '1234'
      )
    end
    let!(:existing_journal) { FactoryGirl.create(:journal) }

    it { is_expected.to be_valid }

    it 'requires a doi_publisher_prefix' do
      journal.doi_publisher_prefix = nil
      expect(journal).to_not be_valid
      expect(journal.errors[:doi_publisher_prefix]).to contain_exactly('Please include a DOI Publisher Prefix')
    end

    it 'requires a unique doi_publisher_prefix' do
      journal.doi_publisher_prefix = existing_journal.doi_publisher_prefix
      expect(journal).to_not be_valid
      expect(journal.errors[:doi_publisher_prefix]).to contain_exactly('The DOI Publisher Prefix has already been taken')
    end

    it 'requires a valid doi_publisher_prefix' do
      journal.doi_publisher_prefix = '@'
      expect(journal).to_not be_valid
      expect(journal.errors[:doi_publisher_prefix]).to contain_exactly('The DOI Publisher Prefix is not valid')
    end

    it 'requires a doi_journal_prefix' do
      journal.doi_journal_prefix = nil
      expect(journal).to_not be_valid
      expect(journal.errors[:doi_journal_prefix]).to contain_exactly('Please include a DOI Journal Prefix')
    end

    it 'requires a unique doi_journal_prefix' do
      journal.doi_journal_prefix = existing_journal.doi_journal_prefix
      expect(journal).to_not be_valid
      expect(journal.errors[:doi_journal_prefix]).to contain_exactly('The DOI Publisher Prefix has already been taken')
    end

    it 'requires a valid doi_journal_prefix' do
      journal.doi_journal_prefix = 'not-valid'
      expect(journal).to_not be_valid
      expect(journal.errors[:doi_journal_prefix]).to contain_exactly('The DOI Journal Prefix is not valid')
    end

    it 'requires a last_doi_issued' do
      journal.last_doi_issued = nil
      expect(journal).to_not be_valid
      expect(journal.errors[:last_doi_issued]).to contain_exactly('Please include a Last DOI Issued')
    end
  end

  context "that has DOI information" do
    before do
      @journal = build(:journal)
    end

    it "still valid" do
      expect(@journal.doi_publisher_prefix).to be_present
      expect(@journal.doi_journal_prefix).to be_present
      expect(@journal.last_doi_issued).to eq "10000"
      expect(@journal.save!).to eq true
    end
  end

  describe "#destroy" do
    context "with papers" do
      let!(:journal) { FactoryGirl.create(:journal, :with_paper) }

      it "throws error" do
        expect { journal.destroy }.to_not change { Journal.count }
        expect(journal.errors[:base].to_s).to match(/must be destroyed/)
      end
    end

    context "without papers" do
      let!(:journal) { FactoryGirl.create(:journal) }

      it "destroys journal" do
        expect { journal.destroy }.to change { Journal.count }.by(-1)
      end
   end
  end

  describe '#last_doi_issued' do
    subject(:journal) { FactoryGirl.build(:journal) }
    context 'and the journal is a new record' do
      before do
        expect(journal.new_record?).to be(true)
      end

      it 'allows last_doi_issued to be set' do
        expect do
          journal.last_doi_issued = '12345'
          journal.save!
          journal.reload
        end.to change { journal.last_doi_issued }.to eq('12345')
      end
    end

    context 'and the journal is not a new record' do
      before { journal.save! }

      it 'does not allow last_doi_issued to be set' do
        expect do
          journal.update!(last_doi_issued: '98765')
          journal.reload
        end.to_not change { journal.last_doi_issued }
      end
    end
  end

  describe "#next_doi_number!" do
    let(:journal) { FactoryGirl.create(:journal) }

    it "increments last_doi_issued and returns that value" do
      next_doi = nil
      expect do
        next_doi = journal.next_doi_number!
      end.to change { journal.last_doi_issued.to_i }.by 1
      expect(next_doi).to eq journal.last_doi_issued
    end
  end

  describe "DOI" do
    let(:journal) { FactoryGirl.create(:journal) }

    it "contains DOI information" do
      expect(journal.doi_publisher_prefix).to be_truthy
      expect(journal.doi_journal_prefix).to   be_truthy
      expect(journal.last_doi_issued).to      be_truthy
      expect(journal.last_doi_issued.class).to eq(String)
    end

    it "will not save invalid DOI publisher prefix" do
      journal.doi_publisher_prefix = "#"
      journal.save
      expect(journal).to have(1).errors_on(:doi)
    end

    it "will not save invalid DOI journal prefix" do
      journal.doi_journal_prefix = "miss/2"
      journal.save
      expect(journal).to have(1).errors_on(:doi)
    end

    describe "additional Journals" do
      before do
        existing_journal = create(:journal)

        @journal = build(:journal)
        @journal.doi_publisher_prefix = existing_journal.doi_publisher_prefix
        @journal.doi_journal_prefix = existing_journal.doi_journal_prefix
      end

      it "does not accept duplicate journal prefixes" do
        expect {
          @journal.save!
        }.to raise_error(ActiveRecord::RecordInvalid)
      end
    end
  end

  context "without DOI information" do
    it "can still be created" do
      journal = build(:journal)
      expect(journal).to be_valid
      journal.save!
    end
  end

  describe '.staff_admins_for_papers' do
    let(:journal) { FactoryGirl.create(:journal, :with_staff_admin_role) }
    let(:paper) { FactoryGirl.create(:paper, journal: journal) }
    let(:admin) { FactoryGirl.create(:user) }

    before do
      admin.assign_to!(role: journal.staff_admin_role, assigned_to: journal)
    end

    it <<-DESC do
      finds and returns staff_admins for journals associated with the
      given papers
    DESC
      admins = Journal.staff_admins_for_papers([paper])
      expect(admins).to eq([admin])
    end
  end

  describe '.staff_admins_across_all_journals' do
    let!(:journal_1) { FactoryGirl.create(:journal, :with_staff_admin_role) }
    let!(:journal_2) { FactoryGirl.create(:journal, :with_staff_admin_role) }
    let(:admin_1) { FactoryGirl.create(:user) }
    let(:admin_2) { FactoryGirl.create(:user) }

    before do
      admin_1.assign_to!(role: journal_1.staff_admin_role, assigned_to: journal_1)
      admin_2.assign_to!(role: journal_2.staff_admin_role, assigned_to: journal_2)
    end

    it 'finds and returns staff_admins across all journals' do
      admins = Journal.staff_admins_across_all_journals
      expect(admins).to contain_exactly(admin_1, admin_2)
    end
  end
end
