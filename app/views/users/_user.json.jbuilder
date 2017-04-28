json.extract! user, :id, :e_mail, :username, :firstname, :lastname, :spotter_role, :verified_spotter_role, :trapper_role, :admin_role, :active, :created_at, :updated_at
json.url user_url(user, format: :json)
