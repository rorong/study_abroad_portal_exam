class MarkPostgisMigrationAsComplete < ActiveRecord::Migration[7.0]
  def up
    execute "INSERT INTO schema_migrations (version) VALUES ('20250327054421') ON CONFLICT (version) DO NOTHING;"
  end

  def down
    execute "DELETE FROM schema_migrations WHERE version = '20250327054421';"
  end
end
