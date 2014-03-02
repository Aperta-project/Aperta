json.users do
  json.array! @users, :id, :full_name, :image_url
end
