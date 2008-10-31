require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe FlowCellLanesController do
  describe "route generation" do
    it "should map #index" do
      route_for(:controller => "flow_cell_lanes", :action => "index").should == "/flow_cell_lanes"
    end
  
    it "should map #new" do
      route_for(:controller => "flow_cell_lanes", :action => "new").should == "/flow_cell_lanes/new"
    end
  
    it "should map #show" do
      route_for(:controller => "flow_cell_lanes", :action => "show", :id => 1).should == "/flow_cell_lanes/1"
    end
  
    it "should map #edit" do
      route_for(:controller => "flow_cell_lanes", :action => "edit", :id => 1).should == "/flow_cell_lanes/1/edit"
    end
  
    it "should map #update" do
      route_for(:controller => "flow_cell_lanes", :action => "update", :id => 1).should == "/flow_cell_lanes/1"
    end
  
    it "should map #destroy" do
      route_for(:controller => "flow_cell_lanes", :action => "destroy", :id => 1).should == "/flow_cell_lanes/1"
    end
  end

  describe "route recognition" do
    it "should generate params for #index" do
      params_from(:get, "/flow_cell_lanes").should == {:controller => "flow_cell_lanes", :action => "index"}
    end
  
    it "should generate params for #new" do
      params_from(:get, "/flow_cell_lanes/new").should == {:controller => "flow_cell_lanes", :action => "new"}
    end
  
    it "should generate params for #create" do
      params_from(:post, "/flow_cell_lanes").should == {:controller => "flow_cell_lanes", :action => "create"}
    end
  
    it "should generate params for #show" do
      params_from(:get, "/flow_cell_lanes/1").should == {:controller => "flow_cell_lanes", :action => "show", :id => "1"}
    end
  
    it "should generate params for #edit" do
      params_from(:get, "/flow_cell_lanes/1/edit").should == {:controller => "flow_cell_lanes", :action => "edit", :id => "1"}
    end
  
    it "should generate params for #update" do
      params_from(:put, "/flow_cell_lanes/1").should == {:controller => "flow_cell_lanes", :action => "update", :id => "1"}
    end
  
    it "should generate params for #destroy" do
      params_from(:delete, "/flow_cell_lanes/1").should == {:controller => "flow_cell_lanes", :action => "destroy", :id => "1"}
    end
  end
end