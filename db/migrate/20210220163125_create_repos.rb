class CreateRepos < ActiveRecord::Migration[6.1]
  def change
    create_table :repos, id: :uuid do |t|
      t.string  :provider,         null: false
      t.bigint  :provider_repo_id, null: false
      t.string  :full_name,        null: false
      t.string  :avatar_url
      t.text    :description
      t.boolean :is_fork
      t.boolean :is_private
      t.string  :primary_language
      t.integer :stargazers
      t.string  :image_url
      t.jsonb   :analysis

      t.index :full_name
      t.index %i[provider_repo_id provider], unique: true

      t.timestamps
    end
  end
end
