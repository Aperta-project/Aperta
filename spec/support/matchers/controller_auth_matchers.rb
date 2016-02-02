RSpec::Matchers.define :responds_with do |status_code|
  match do |response|
    response.status == status_code
  end

  failure_message do |str|
    "Expected response to be #{status_code} but it was  #{response.status}"
  end

  failure_message_when_negated do |str|
    "Expected response to NOT be #{status_code} but it was #{response.status}"
  end
end
