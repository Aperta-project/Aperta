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

    it 'allows a duplicate doi_publisher_prefix' do
      journal.doi_publisher_prefix = existing_journal.doi_publisher_prefix
      expect(journal).to be_valid
      expect(journal.errors[:doi_publisher_prefix]).to be_empty
    end

    it 'allows a duplicate doi_journal_prefix' do
      journal.doi_journal_prefix = existing_journal.doi_journal_prefix
      expect(journal).to be_valid
      expect(journal.errors[:doi_publisher_prefix]).to be_empty
    end

    it 'requires a unique doi_journal_prefix and doi_publisher_prefix combination' do
      journal.doi_journal_prefix = existing_journal.doi_journal_prefix
      journal.doi_publisher_prefix = existing_journal.doi_publisher_prefix
      expect(journal).to_not be_valid
      expect(journal.errors[:doi_journal_prefix]).to contain_exactly('This DOI Journal Prefix has already been assigned to this publisher.  Please choose a unique DOI Journal Prefix')
    end

    it 'requires a valid doi_publisher_prefix' do
      journal.doi_publisher_prefix = '@'
      expect(journal).to_not be_valid
      expect(journal.errors[:doi_publisher_prefix]).to contain_exactly('The DOI Publisher Prefix is not valid. It can only contain word characters, numbers, -, and .')
    end

    it 'requires a doi_journal_prefix' do
      journal.doi_journal_prefix = nil
      expect(journal).to_not be_valid
      expect(journal.errors[:doi_journal_prefix]).to contain_exactly('Please include a DOI Journal Prefix')
    end

    it 'requires a valid doi_journal_prefix' do
      journal.doi_journal_prefix = 'not-valid'
      expect(journal).to_not be_valid
      expect(journal.errors[:doi_journal_prefix]).to contain_exactly('The DOI Journal Prefix is not valid. It must begin with \'journal\' and can contain any characters except /')
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

  describe "#next_doi!" do
    let(:journal) { FactoryGirl.create(:journal) }

    it "increments last_doi_issued each time it is called" do
      expect do
        journal.next_doi!
      end.to change { journal.last_doi_issued.to_i }.by 1

      expect do
        journal.next_doi!
        journal.next_doi!
      end.to change { journal.last_doi_issued.to_i }.by 2
    end

    it "returns the next DOI" do
      next_doi = journal.next_doi!
      expect(next_doi).to eq "#{journal.doi_publisher_prefix}/#{journal.doi_journal_prefix}.#{journal.last_doi_issued}"
    end

    it "raises an InvalidDoiError when the DOI is in an invalid format" do
      # Use update_column to bypass validations since the journal would not
      # normally let them save. This is to create the possibility of generating
      # a bad DOI.
      journal.update_column :doi_publisher_prefix, "B@D"
      journal.update_column :doi_journal_prefix, "R3@11Y-B@D"
      expected_error = Regexp.escape("Attempted to generate the next DOI, but it was in an invalid DOI format: B@D\/R3@11Y-B@D")
      expect do
        journal.next_doi!
      end.to raise_error(Journal::InvalidDoiError, /#{expected_error}\.\d+/)
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

  describe '.valid_doi?' do
    let(:doi) { 'any.thing/journal.thing.1' }

    it 'validates the given DOI string' do
      expect(Journal.valid_doi? doi).to eq true
      expect(Journal.valid_doi? "10.10.1038/journal.nphys1170").to eq true
      expect(Journal.valid_doi? "10.1002/journal.0470841559.ch1").to eq true
      expect(Journal.valid_doi? "10.1594/journal.PANGAEA.726855").to eq true
      expect(Journal.valid_doi? "10.1594/journal.GFZ.GEOFON.gfz2009kciu").to eq true
      expect(Journal.valid_doi? "10.1594/journal.PANGAEA.667386").to eq true
      expect(Journal.valid_doi? "10.3207/journal.2959859860").to eq true
      expect(Journal.valid_doi? "10.3866/journal.PKU.WHXB201112303").to eq true
      expect(Journal.valid_doi? "10.3972/journal.water973.0145.db").to eq true
      expect(Journal.valid_doi? "10.7666/journal.d.y351065").to eq true
      expect(Journal.valid_doi? "10.11467/journal.isss2003.7.1_11").to eq true
      expect(Journal.valid_doi? "10.7875/journal.leading.author.2.e008").to eq true
      expect(Journal.valid_doi? "10.1430/journal.8105").to eq true
      expect(Journal.valid_doi? "10.1392/journal.BC1.0").to eq true
      expect(Journal.valid_doi? "10.1000/journal.182").to eq true
      expect(Journal.valid_doi? "10.1234/journal.joe.jou.1516").to eq true
    end

    context "with a blank DOI" do
      it "returns false" do
        expect(described_class.valid_doi? nil).to eq false
      end
    end

    context "with an invalid DOI" do
      it "returns false" do
        expect(described_class.valid_doi? "10.1000/182/12").to eq false
        expect(described_class.valid_doi? "monkey").to eq false
      end
    end
  end
end
