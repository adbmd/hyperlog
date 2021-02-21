class AddAnalysisColumnsToProfilesAndGithubs < ActiveRecord::Migration[6.1]
  def change
    change_table :githubs do |t|
      t.jsonb :user_profile
      t.jsonb :repos
      t.index :repos, using: :gin
    end

    change_table :profiles do |t|
      t.jsonb :tech_analysis
      t.index :tech_analysis, using: :gin
    end
  end
end
