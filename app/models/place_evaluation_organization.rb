class PlaceEvaluationOrganization < ActiveRecord::Base
	belongs_to :place_evaluation
	belongs_to :organization

  validates :place_evaluation_id, :organization_id, :presence => true


  # for each evaluation, if the person is assigned to an org, 
  # but does not have an org record, add it
  def self.add_missing_records
    count = 0
    user_orgs = OrganizationUser.all
    if user_orgs.present?
      evals = PlaceEvaluation.select('id, user_id, created_at')
                .where(:user_id => user_orgs.map{|x| x.user_id}.uniq)

      puts "########## there are #{evals.length} evals"
      evals.each do |eval|
        # get org for user
        org = user_orgs.select{|x| x.user_id == eval.user_id}.first
        if org.present?
          # see if an eval org record exists, if not, create it
          match = where(:place_evaluation_id => eval.id, :organization_id => org.organization_id)
          if match.blank?
            count += 1
            puts "########## - creating record for eval #{eval.id}, org #{org.id}"
            create(:place_evaluation_id => eval.id, :organization_id => org.organization_id, :created_at => eval.created_at)
          end
        end
      end 
    end
    puts "######### -> created #{count} records"
    return count
  end

end
