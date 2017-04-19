class CreateMedia < ActiveRecord::Migration[5.0]
  def change
    create_table :media do |t|
      t.string :path
      t.string :filename
      t.string :mediatype
      t.datetime :datetime
      t.float :longitude
      t.float :latitude
      t.string :sequence
      t.integer :frame
      t.references :tubecamstation, foreign_key: true
      t.json :exifdata
      t.boolean :deleted

      t.timestamps
    end
  end
end
