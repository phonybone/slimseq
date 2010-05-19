require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe LabGroupProfile do
  fixtures :site_config

  it "should provide a destroy warning" do
    lab_group_profile = LabGroupProfile.create(:lab_group_id => 3)

# bruz fixme
# <<<<<<< HEAD
#     Project.should_receive(:find).and_return( [mock_model(Project)] )

#     lab_group_profile.destroy_warning.should ==
#       "Destroying this lab group will also destroy:\n" + 
#            "1 project(s)\n" +
#            "Are you sure you want to destroy it?"
#=======
    ChargeSet.should_receive(:find).and_return( [mock_model(ChargeSet), mock_model(ChargeSet)] )

    lab_group_profile.destroy_warning.should ==
      "Are you sure you want to destroy this lab group?"
#>>>>>>> 4eb8855c27cf7c68d6682b9890fc080e1aa13712
  end

  it "should provide a detail hash of attributes" do
    lab_group_profile = LabGroupProfile.create(
      :file_folder => "yeast",
      :lab_group_id => 3
    )
    Project.should_receive(:find).
      with(:all, :conditions => {:lab_group_id => 3}).
      and_return( [mock_model(Project, :lab_group_id => 3, :id => 1)] )

    lab_group_profile.detail_hash.should == {}
  end
end
