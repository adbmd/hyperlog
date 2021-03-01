class CreateProjectRepos < ActiveRecord::Migration[6.1]
  def change
    create_table :project_repos do |t|
      t.belongs_to :project, type: :uuid, null: false
      t.belongs_to :repo, type: :uuid, null: false
      t.integer :occurences

      t.index %i[project_id repo_id], unique: true

      t.timestamps
    end
  end
end
