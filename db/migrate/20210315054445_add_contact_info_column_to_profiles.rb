class AddContactInfoColumnToProfiles < ActiveRecord::Migration[6.1]
  def change
    add_column :profiles, :contact_info, :jsonb
  end
end
