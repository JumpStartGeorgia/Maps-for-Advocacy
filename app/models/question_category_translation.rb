class QuestionCategoryTranslation < ActiveRecord::Base
	belongs_to :question_category

  attr_accessible :question_category_id, :name, :locale

  validates :name, :presence => true

  def required_data_provided?
    provided = false
    
    provided = self.name.present?
    
    return provided
  end
  
  def add_required_data(obj)
    self.name = obj.name
  end

end
