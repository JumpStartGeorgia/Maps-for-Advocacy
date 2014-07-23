class OrganizationTranslation < ActiveRecord::Base
	belongs_to :organization

  attr_accessible :organization_id, :name, :description, :locale

  validates :name, :presence => true

  def required_data_provided?
    provided = false
    
    provided = self.name.present?

Rails.logger.debug "======= all data provided = #{provided}"
    
    return provided
  end
  
  def add_required_data(obj)
Rails.logger.debug "======= - adding missing data"
    self.name = obj.name if self.name.blank?
    self.description = obj.description if self.description.blank?
Rails.logger.debug "======= - name = #{self.name}; desc = #{self.description}"
  end

end
