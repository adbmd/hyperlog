class CreateProfileRepoAnalysis < ActiveRecord::Migration[6.1]
  def change
    create_table :profile_repo_analyses do |t|
      t.belongs_to :profile, null: false, foreign_key: true
      t.belongs_to :repo, type: :uuid, null: false, foreign_key: true
      t.belongs_to :project, type: :uuid, foreign_key: true

      t.integer :contributions
      t.jsonb   :tech_analysis

      t.index :tech_analysis, using: :gin
      t.index %i[profile_id repo_id], unique: true

      t.timestamps
    end
  end
end
