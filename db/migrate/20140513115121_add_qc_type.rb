class AddQcType < ActiveRecord::Migration
  def up
    add_column :question_categories, :category_type, :tinyint, :default => 1
    add_index :question_categories, :category_type
    
    # add values
    # common
    QuestionCategory.where(:is_common => true).update_all(:category_type => QuestionCategory::TYPES['common'])
    # custom
    QuestionCategory.where(:is_common => false).update_all(:category_type => QuestionCategory::TYPES['custom'])
  end

  def down
    remove_index :question_categories, :category_type
    remove_column :question_categories, :category_type
  end
end
