require_relative '../../app/services/institution_list_querier'

describe InstitutionListQuerier do
  let(:list) { ["Ohio", "Minnesota", "New York", "Idaho"] }
  let(:querier) { InstitutionListQuerier.new list }

  it "can return its list" do
    expect(querier.list).to eq list
  end

  context "filtering lists" do
    it "can filter its list" do
      expect(querier.filter("e")).to match_array ["Minnesota", "New York"]
    end

    it "is case insensitive" do
      expect(querier.filter("m")).to match_array ["Minnesota"]
    end
  end
end
