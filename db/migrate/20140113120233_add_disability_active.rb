class AddDisabilityActive < ActiveRecord::Migration
  def up
    add_column :disabilities, :active, :boolean, :default => true
    add_index :disabilities, :active 
    
    # make deaf not active
    Disability.where(:code => 'd').update_all(:active => false)

  end

  def down
    drop_index :disabilities, :active 
    drop_column :disabilities, :active
  end
end
