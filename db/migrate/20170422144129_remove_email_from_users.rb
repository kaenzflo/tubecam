class RemoveEmailFromUsers < ActiveRecord::Migration[5.0]
  def change
    remove_column :users, :e_mail, :string
  end
end
