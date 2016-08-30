module RSpec::Matchers
  DB_TIME_PRECISION = 1e-6.seconds

  def within_db_precision
    BuiltIn::BeWithin.new(DB_TIME_PRECISION)
  end

  alias_matcher :be_within_db_precision, :within_db_precision
end
