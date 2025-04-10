class AddLatitudeAndLongitudeToUniversities < ActiveRecord::Migration[7.0]
  def change
    add_column :universities, :latitude, :decimal, precision: 10, scale: 8
    add_column :universities, :longitude, :decimal, precision: 11, scale: 8
  end
end
