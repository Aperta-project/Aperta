json.users do
  json.array! @users do |u|
   json.id u.id
   json.fullName u.full_name
   json.imageUrl u.image_url
  end
end
