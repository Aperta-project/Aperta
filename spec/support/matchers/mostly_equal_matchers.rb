RSpec::Matchers.define :mostly_eq do |expected|
  match do |actual|
    @actual = actual.attributes.except(*@ignore)
    @expected = expected.attributes.except(*@ignore)
    expect(@actual).to eq(@expected)
    # actual.reflections.keys.each do |rel|
  end

  chain :except do |*ignore|
    @ignore = ignore
  end
end

RSpec::Matchers.define :mostly_eq_ar do |expected|
  match do |actual|
    actual.to_a.zip(expected.to_a).each do |a, e|
      expect(a).to mostly_eq(e).except(*@ignore)
    end
  end

  chain :except do |*ignore|
    @ignore = ignore
  end
end
