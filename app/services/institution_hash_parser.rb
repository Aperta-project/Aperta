class InstitutionHashParser
  attr_reader :hash, :names

  def initialize hash
    @hash = hash
  end

  def parse_names!
    @names = @hash.map {|institution| institution['name'] }
  end
end
