class AddAnalysisColumnsToProfilesAndGithubs < ActiveRecord::Migration[6.1]
  def change
    change_table :githubs do |t|
      t.jsonb :user_profile
    end
  end
end
