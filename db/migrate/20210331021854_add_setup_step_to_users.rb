class AddSetupStepToUsers < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :setup_step, :integer, default: 1
  end
end
