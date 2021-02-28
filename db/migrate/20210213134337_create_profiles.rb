class CreateProfiles < ActiveRecord::Migration[6.1]
  def change
    create_table :profiles do |t|
      t.belongs_to :user, type: :uuid,
                          index: { unique: true }, foreign_key: true
      t.string :about, null: false, default: ''

      t.timestamps
    end
  end
end
