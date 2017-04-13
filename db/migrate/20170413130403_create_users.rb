class CreateUsers < ActiveRecord::Migration[5.0]
  def change
    create_table :users do |t|
      t.string :e_mail
      t.string :username
      t.string :firstname
      t.string :lastname
      t.integer :role_id
      t.boolean :trusted
      t.boolean :active

      t.timestamps
    end
  end
end
