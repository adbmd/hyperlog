class AddOpengraphImageToProfiles < ActiveRecord::Migration[6.1]
  def change
    add_column :profiles, :opengraph_image, :string

    reversible do |dir|
      dir.up { Profile.all.each(&:update_opengraph) }
    end
  end
end
