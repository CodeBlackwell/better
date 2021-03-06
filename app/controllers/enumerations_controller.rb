# BetterMeans - Work 2.0
# Copyright (C) 2006-2011  See readme for details and license#

class EnumerationsController < ApplicationController
  layout 'admin'

  before_filter :require_admin

  def index # spec_me cover_me heckle_me
    list
    render :action => 'list'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def list # spec_me cover_me heckle_me
  end

  def new # spec_me cover_me heckle_me
    begin
      @enumeration = params[:type].constantize.new
    rescue NameError
      @enumeration = Enumeration.new
    end
  end

  def create # spec_me cover_me heckle_me
    @enumeration = Enumeration.new(params[:enumeration])
    @enumeration.type = params[:enumeration][:type]
    if @enumeration.save
      flash.now[:success] = l(:notice_successful_create)
      redirect_to :action => 'list', :type => @enumeration.type
    else
      render :action => 'new'
    end
  end

  def edit # spec_me cover_me heckle_me
    @enumeration = Enumeration.find(params[:id])
  end

  def update # spec_me cover_me heckle_me
    @enumeration = Enumeration.find(params[:id])
    @enumeration.type = params[:enumeration][:type] if params[:enumeration][:type]
    if @enumeration.update_attributes(params[:enumeration])
      flash.now[:success] = l(:notice_successful_update)
      redirect_to :action => 'list', :type => @enumeration.type
    else
      render :action => 'edit'
    end
  end

  def destroy # spec_me cover_me heckle_me
    @enumeration = Enumeration.find(params[:id])
    if !@enumeration.in_use?
      # No associated objects
      @enumeration.destroy
      redirect_to :action => 'index'
    elsif params[:reassign_to_id]
      if reassign_to = Enumeration.find_by_type_and_id(@enumeration.type, params[:reassign_to_id])
        @enumeration.destroy(reassign_to)
        redirect_to :action => 'index'
      end
    end
    @enumerations = Enumeration.find(:all, :conditions => ['type = (?)', @enumeration.type]) - [@enumeration]
  end
end
