class AddSlugToRepos < ActiveRecord::Migration[6.1]
  def change
    add_column :repos, :slug, :string
    add_index :repos, :slug, unique: true
  end
end
