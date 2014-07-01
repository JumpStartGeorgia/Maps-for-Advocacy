class RightTranslation < ActiveRecord::Base
	belongs_to :right

  attr_accessible :right_id, :name, :convention_article, :locale

  validates :name, :presence => true

  def required_data_provided?
    provided = false
    
    provided = self.name.present? && self.convention_article.present?
    
    return provided
  end
  
  def add_required_data(obj)
    self.name = obj.name if self.name.blank?
    self.convention_article = obj.convention_article if self.convention_article.blank?
  end

end
