json.users do
  json.array! @users do |u|
   json.id u.id
   json.fullName u.full_name
   json.avatarUrl u.avatar_url
  end
end
