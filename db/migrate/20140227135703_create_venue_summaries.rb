class CreateVenueSummaries < ActiveRecord::Migration
  def change
    create_table :venue_summaries do |t|
      t.integer :venue_id
      t.integer :venue_category_id
      t.integer :summary_type
      t.integer :summary_type_identifier
      t.integer :data_type
      t.integer :data_type_identifier
      t.integer :disability_id
      t.decimal :score, :precision => 10, :scale => 6
      t.integer :special_flag
      t.integer :num_answers
      t.integer :num_evaluations
      t.boolean :is_certified

      t.timestamps
    end
    
    add_index :venue_summaries, :venue_id
    add_index :venue_summaries, :venue_category_id
    add_index :venue_summaries, :disability_id
    add_index :venue_summaries, :is_certified
    add_index :venue_summaries, [:summary_type, :summary_type_identifier], :name => 'idx_venue_summary_summary_type'
    add_index :venue_summaries, [:data_type, :data_type_identifier], :name => 'idx_venue_summary_data_type'
  end
end
