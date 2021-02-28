class CreateGithubs < ActiveRecord::Migration[6.1]
  def change
    create_table :githubs, id: :bigint, primary_key: :uid do |t|
      t.belongs_to :profile, index: { unique: true }, foreign_key: true
      t.string :access_token, null: false

      t.timestamps
    end
  end
end
