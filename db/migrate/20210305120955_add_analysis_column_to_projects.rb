class AddAnalysisColumnToProjects < ActiveRecord::Migration[6.1]
  def change
    add_column :projects, :aggregated_tech_analysis, :jsonb
  end
end
