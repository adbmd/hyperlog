class CreateProfiles < ActiveRecord::Migration[6.1]
  def change
    create_table :profiles do |t|
      t.belongs_to :user
      t.string :about, null: false, default: ''

      t.timestamps
    end
  end
end
