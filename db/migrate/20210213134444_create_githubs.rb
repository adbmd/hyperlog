class CreateGithubs < ActiveRecord::Migration[6.1]
  def change
    create_table :githubs, id: :bigint, primary_key: :uid do |t|
      t.belongs_to :profile, index: true
      t.string :access_token

      t.timestamps
    end
  end
end
