json.extract! user, :id, :e_mail, :username, :firstname, :lastname, :role_id, :trusted, :active, :created_at, :updated_at
json.url user_url(user, format: :json)
