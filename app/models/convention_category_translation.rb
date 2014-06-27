class ConventionCategoryTranslation < ActiveRecord::Base
	belongs_to :convention_category

  attr_accessible :convention_category, :name, :locale

  validates :name, :presence => true

  def required_data_provided?
    provided = false
    
    provided = self.name.present?
    
    return provided
  end
  
  def add_required_data(obj)
    self.name = obj.name if self.name.blank?
  end

end
