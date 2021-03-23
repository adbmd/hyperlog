class ChangeProfileThemeToRelationship < ActiveRecord::Migration[6.1]
  def up
    change_table :profiles do |t|
      t.remove :theme
      t.belongs_to :theme, foreign_key: true
    end
  end

  def down
    change_table :profiles, bulk: true do |t|
      t.remove :theme_id
      t.integer :theme, default: 0
    end
  end
end
