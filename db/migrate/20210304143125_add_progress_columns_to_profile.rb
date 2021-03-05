class AddProgressColumnsToProfile < ActiveRecord::Migration[6.1]
  def change
    add_column :profiles, :analysis_status, :jsonb
  end
end
