class LabGroup < ActiveRecord::Base
  has_many :lab_memberships, :dependent => :destroy
  has_many :users, :through => :lab_memberships
  has_many :projects, :dependent => :destroy
  has_many :charge_sets, :dependent => :destroy

  validates_uniqueness_of :name

  def destroy_warning
    charge_sets = ChargeSet.find(:all, :conditions => ["lab_group_id = ?", id])
    
    return "Destroying this lab group will also destroy:\n" + 
           charge_sets.size.to_s + " charge set(s)\n" +
           projects.size.to_s + " project(s)\n" +
           "Are you sure you want to destroy it?"
  end
end
