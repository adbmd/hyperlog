class CreateThemes < ActiveRecord::Migration[6.1]
  def change
    create_table :themes do |t|
      t.string :name, null: false, index: { unique: true }
      t.string :preview_url
      t.string :image_url
      t.boolean :active, default: true

      t.timestamps
    end
  end
end
