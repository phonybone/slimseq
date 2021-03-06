class ChargesController < ApplicationController
  before_filter :login_required

  def list_within_charge_set
    # if a charge set id was passed in, use it.
    # otherwise, use the one that ought to be stored in
    # the session
    if(params[:charge_set_id] != nil)
      @charge_set = ChargeSet.find(params[:charge_set_id])
      session[:charge_set] = @charge_set
    elsif(session[:charge_set] != nil)
      @charge_set = session[:charge_set]    
    else
      @charge_set = ChargeSet.find(:first, :order => 'id DESC')
    end

    # non-admin users must belong to group they want to see
    if(!current_user.staff_or_admin?)
      # get lab group name
      lab_group_name = LabGroup.find(@charge_set.lab_group_id)
      # if login doesn't match name of lab group that owns this
      # charge set, don't allow access
      if(session[:user][:login] != lab_group_name)
        flash[:warning] = 'Attempt to charge information for a group other than your own.'
        redirect_to :controller => 'charge_sets', :action => 'index'
      end
    end
    
    @charges = Charge.find(:all, :conditions => ["charge_set_id = ?", @charge_set.id],
                           :order => 'date ASC, description ASC')
  end

  def new
    if(params[:charge_set_id] != nil)
      @charge_set = ChargeSet.find(params[:charge_set_id])
      session[:charge_set] = @charge_set
    else
      @charge_set = session[:charge_set]
    end

    # use template info if it exists
    if(params[:charge_template_id] != nil)
      template = ChargeTemplate.find(params[:charge_template_id])
      @charge = Charge.new(:charge_set => @charge_set,
                           :description => template.description,
                           :cost => template.cost)      
    # if no template is givin, show a blank charge form                           
    else
      @charge = Charge.new(:charge_set => @charge_set,
                           :cost => 0)
    end
                               
    @charge_templates = ChargeTemplate.find(:all, :order => "name ASC")
  end

  def create
    @charge_set = session[:charge_set]
    @charge = Charge.new(params[:charge])
    if @charge.save
      flash[:notice] = 'Charge was successfully created.'
      redirect_to :action => 'list_within_charge_set'
    else
      @charge_templates = ChargeTemplate.find(:all, :order => "name ASC")
      render :action => 'new'
    end
  end

  def edit
    @charge_set = session[:charge_set]
    @charge = Charge.find(params[:id])
  end

  def update
    @charge_set = session[:charge_set]
    @charge = Charge.find(params[:id])

    begin
      if @charge.update_attributes(params[:charge])
        flash[:notice] = 'Charge was successfully updated.'
        redirect_to :action => 'list_within_charge_set'
      else
        render :action => 'edit'
      end
    rescue ActiveRecord::StaleObjectError
      flash[:warning] = "Unable to update information. Another user has modified this charge."
      @charge = Charge.find(params[:id])
      render :action => 'edit'
    end
  end

  def bulk_edit_move_or_destroy
    # edit, move or destroy?
    if(params[:commit] == "Set Field")
      name = params[:field_name]
      value = params[:field_value]
      selected_charges = params[:selected_charges]
      success = true
      for charge_id in selected_charges.keys
        if selected_charges[charge_id] == '1'
          charge = Charge.find(charge_id)
          # update charge and keep track of whether any updates fail
          if( !charge.update_attributes( name => value ) )
            success = false
          end
        end
      end

      if( !success )
        flash[:warning] = "Setting field failed for one or more charges"
      end
    elsif(params[:commit] == "Move Charges To This Charge Set")
      charge_set_id = params[:move_charge_set_id]
      selected_charges = params[:selected_charges]
      for charge_id in selected_charges.keys
        if selected_charges[charge_id] == '1'
          charge = Charge.find(charge_id)
          charge.update_attributes( { :charge_set_id => charge_set_id } )
        end
      end
      
      # change current charge set to the one where we moved the charges
      session[:charge_set] = ChargeSet.find(charge_set_id.to_i)
    elsif(params[:commit] == "Delete Charges")
      selected_charges = params[:selected_charges]
      for charge_id in selected_charges.keys
        if selected_charges[charge_id] == '1'
          charge = Charge.find(charge_id)
          charge.destroy
        end
      end
    end
    
    list_within_charge_set
    render :action => 'list_within_charge_set'
  end

  def destroy
    @charge_set = session[:charge_set]
    Charge.find(params[:id]).destroy
    redirect_to :action => 'list_within_charge_set'
  end

end
