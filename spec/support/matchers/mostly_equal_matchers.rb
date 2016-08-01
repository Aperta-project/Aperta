RSpec::Matchers.define :mostly_eq do |expected|
  diffable

  match do |actual|
    actual = actual.respond_to?(:to_a) ? actual.to_a : [actual]
    actual.map! { |member| member.attributes.except(*@ignore) }
    expected = expected.respond_to?(:to_a) ? expected.to_a : [expected]
    expected.map! { |member| member.attributes.except(*@ignore) }

    # set instance variables for nice-looking diff
    @actual = actual
    @expected_as_array = [expected]

    values_match? expected, actual
  end

  chain :except do |*ignore|
    @ignore = ignore
  end
end
