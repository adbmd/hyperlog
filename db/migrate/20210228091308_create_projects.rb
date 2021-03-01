class CreateProjects < ActiveRecord::Migration[6.1]
  def change
    create_table :projects, id: :uuid do |t|
      t.belongs_to :profile, null: false, index: true, foreign_key: true

      t.string     :name, null: false
      t.string     :tagline, null: false
      t.string     :description, null: false
      t.string     :image_url, null: false

      t.timestamps
    end
  end
end
