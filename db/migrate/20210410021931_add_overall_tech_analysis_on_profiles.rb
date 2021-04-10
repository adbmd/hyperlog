class AddOverallTechAnalysisOnProfiles < ActiveRecord::Migration[6.1]
  def change
    add_column :profiles, :overall_tech_analysis, :jsonb

    reversible do |dir|
      dir.up do
        Profile.all.each do |prof|
          prof.aggregate_tech_analysis
        end
      end
    end
  end
end
