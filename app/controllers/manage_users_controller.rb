class ManageUsersController < ApplicationController
  before_filter :authenticate_user!
  before_filter do |controller_instance|
    controller_instance.send(:valid_role?, User::ROLES[:organization_admin])
  end

  def index
    @orgs = current_user.organizations
    if @orgs.present?
      respond_to do |format|
        format.html # index.html.erb
      end
    else
      redirect_to root_path, :notice => t('app.msgs.not_authorized')    
    end
  end
  
  def add
    @org = Organization.find_by_id(params[:organization_id]) 
    if @org.present?
      org_user_ids = @org.users.map{|x| x.id}
      @users = User.not_in_list(org_user_ids)

      respond_to do |format|
        format.html # index.html.erb
      end
    else 
      redirect_to manage_users_path, :notice => t('app.msgs.not_authorized')    
    end
  end

  def add_user
    user = User.find_by_id(params[:user_id])
    org = Organization.find_by_id(params[:organization_id])
    if user.present? && org.present?
      org.users << user
      redirect_to add_manage_users_path, :notice => t('app.msgs.success_add_user', :nickname => user.nickname, :org => org.name)    
    else
      redirect_to manage_users_path
    end
  end

  def delete
    user = User.find_by_id(params[:user_id])
    org = Organization.find_by_id(params[:organization_id])
    if user.present? && org.present?
      OrganizationUser.where(:organization_id => params[:organization_id], :user_id => params[:user_id]).delete_all
      redirect_to manage_users_path, :notice => t('app.msgs.success_remove_user', :nickname => user.nickname, :org => org.name)    
    else
      redirect_to manage_users_path
    end
  end
end
