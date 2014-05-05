class InstitutionListQuerier
  attr_reader :list

  def initialize list
    @list = list
  end

  def filter query
    list.select {|item| item.downcase.include? query.downcase }
  end
end
