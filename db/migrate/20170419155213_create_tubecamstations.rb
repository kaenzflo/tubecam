class CreateTubecamstations < ActiveRecord::Migration[5.0]
  def change
    create_table :tubecamstations do |t|
      t.string :serialnumber
      t.boolean :status
      t.references :user, foreign_key: true
      t.text :description
      t.boolean :active

      t.timestamps
    end
  end
end
