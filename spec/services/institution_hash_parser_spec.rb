require_relative '../../app/services/institution_hash_parser'

describe InstitutionHashParser do
  let(:hash) { [
    {'name' => 'Oxford', 'country' => 'England'},
    {'name' => 'Cambridge', 'country' => 'England'},
    {'name' => 'Harvard', 'country' => 'USA'}
  ] }
  let(:parser) { InstitutionHashParser.new hash }

  it "returns the parsed hash" do
    parser.parse_names!
    expect(parser.names).to match_array %w{Oxford Cambridge Harvard}
  end
end
