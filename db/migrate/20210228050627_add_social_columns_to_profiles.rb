class AddSocialColumnsToProfiles < ActiveRecord::Migration[6.1]
  def change
    change_table :profiles do |t|
      t.string :tagline,       null: false, default: ''
      t.jsonb  :social_links,  null: false, default: {}
    end
  end
end
