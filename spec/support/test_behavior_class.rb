class TestBehavior < Behavior
  has_attributes boolean: %w[bool_attr], string: %w[string_attr], json: %w[json_attr]
  def call(*args); end
end
