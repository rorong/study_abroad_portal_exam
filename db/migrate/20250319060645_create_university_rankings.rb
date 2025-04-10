class CreateUniversityRankings < ActiveRecord::Migration[7.1]
  def change
    create_table :university_rankings do |t|
      t.references :university, null: false, foreign_key: true
      t.string :ranking_type
      t.integer :ranking

      t.timestamps
    end
    
    # Add index for faster lookups on ranking_type and ranking
    add_index :university_rankings, [:ranking_type, :ranking]
  end
end
