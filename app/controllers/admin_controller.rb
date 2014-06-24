class AdminController < ApplicationController
	require 'fileutils'
  before_filter :authenticate_user!
  before_filter do |controller_instance|
    controller_instance.send(:valid_role?, User::ROLES[:site_admin])
  end

  def index
    respond_to do |format|
      format.html # index.html.erb
    end
  end


end
