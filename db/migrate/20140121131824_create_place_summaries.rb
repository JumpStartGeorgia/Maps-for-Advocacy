class CreatePlaceSummaries < ActiveRecord::Migration
  def up
    create_table :place_summaries do |t|
      t.integer :place_id
      t.integer :summary_type
      t.integer :summary_type_identifier
      t.integer :data_type
      t.integer :data_type_identifier
      t.decimal :score, :precision => 10, :scale => 6
      t.integer :special_flag
      t.integer :num_answers
      t.integer :num_evaluations

      t.timestamps
    end
    
    add_index :place_summaries, :place_id
    add_index :place_summaries, [:summary_type, :summary_type_identifier], :name => 'idx_place_summary_summary_type'
    add_index :place_summaries, [:data_type, :data_type_identifier], :name => 'idx_place_summary_data_type'
  end
  
  def down
    drop_table :place_summaries
  end
end
