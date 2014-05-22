OAuth2::Response.register_parser(:text, 'text/plain') do |body|
  token_key, token_value, expiration_key, expiration_value = body.split(/[=&]/)
  {token_key => token_value, expiration_key => expiration_value}
end
