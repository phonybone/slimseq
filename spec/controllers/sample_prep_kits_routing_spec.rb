require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe SamplePrepKitsController do
  describe "route generation" do
    it "should map #index" do
      route_for(:controller => "sample_prep_kits", :action => "index").should == "/sample_prep_kits"
    end
  
    it "should map #new" do
      route_for(:controller => "sample_prep_kits", :action => "new").should == "/sample_prep_kits/new"
    end
  
    it "should map #show" do
      route_for(:controller => "sample_prep_kits", :action => "show", :id => "1").should == "/sample_prep_kits/1"
    end
  
    it "should map #edit" do
      route_for(:controller => "sample_prep_kits", :action => "edit", :id => "1").should == "/sample_prep_kits/1/edit"
    end
  
    it "should map #update" do
      route_for(:controller => "sample_prep_kits", :action => "update", :id => "1").
        should == {:path => "/sample_prep_kits/1", :method => :put}
    end
  
    it "should map #destroy" do
      route_for(:controller => "sample_prep_kits", :action => "destroy", :id => "1").
        should == {:path => "/sample_prep_kits/1", :method => :delete}
    end
  end

  describe "route recognition" do
    it "should generate params for #index" do
      params_from(:get, "/sample_prep_kits").should == {:controller => "sample_prep_kits", :action => "index"}
    end
  
    it "should generate params for #new" do
      params_from(:get, "/sample_prep_kits/new").should == {:controller => "sample_prep_kits", :action => "new"}
    end
  
    it "should generate params for #create" do
      params_from(:post, "/sample_prep_kits").should == {:controller => "sample_prep_kits", :action => "create"}
    end
  
    it "should generate params for #show" do
      params_from(:get, "/sample_prep_kits/1").should == {:controller => "sample_prep_kits", :action => "show", :id => "1"}
    end
  
    it "should generate params for #edit" do
      params_from(:get, "/sample_prep_kits/1/edit").should == {:controller => "sample_prep_kits", :action => "edit", :id => "1"}
    end
  
    it "should generate params for #update" do
      params_from(:put, "/sample_prep_kits/1").should == {:controller => "sample_prep_kits", :action => "update", :id => "1"}
    end
  
    it "should generate params for #destroy" do
      params_from(:delete, "/sample_prep_kits/1").should == {:controller => "sample_prep_kits", :action => "destroy", :id => "1"}
    end
  end
end
