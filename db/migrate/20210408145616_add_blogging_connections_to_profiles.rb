class AddBloggingConnectionsToProfiles < ActiveRecord::Migration[6.1]
  def change
    reversible do |dir|
      change_table :profiles do |t|
        dir.up { t.jsonb :blogging_connections, default: {} }
        dir.down { t.remove :blogging_connections }
      end
    end
  end
end
