class CreateQuestConvs < ActiveRecord::Migration
  def up
    # remove the single field
#    remove_index :question_pairings, :convention_category_id
#    remove_column :question_pairings, :convention_category_id
    
    # create the new table
    create_table :question_pairing_convention_categories do |t|
      t.integer :question_pairing_id
      t.integer :convention_category_id
      
      t.timestamps
    end
    add_index :question_pairing_convention_categories, :question_pairing_id, :name => 'idx_qpcc_qp_id'
    add_index :question_pairing_convention_categories, :convention_category_id, :name => 'idx_qpcc_cc_id'
    
  end

  def down
    add_column :question_pairings, :convention_category_id, :integer
    add_index :question_pairings, :convention_category_id
    
    drop_table :question_pairing_convention_categories
  end
end
