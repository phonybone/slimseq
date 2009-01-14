require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe "Project" do
  fixtures :projects, :samples, :charge_sets, :projects

  it "should provide a hash of summary attributes" do
    project = create_project(:name => "Fungus Project")

    project.summary_hash.should == {
      :id => project.id,
      :name => "Fungus Project",
      :updated_at => project.updated_at,
      :uri => "http://example.com/projects/#{project.id}"
    }
  end

  it "should provide a hash of detailed attributes" do
    lab_group = create_lab_group(:name => "Fungus Group")
    project = create_project(
      :name => "Fungus Project",
      :file_folder => "fungus",
      :lab_group => lab_group
    )
    sample_1 = create_sample(:project => project)
    sample_2 = create_sample(:project => project)

    project.detail_hash.should == {
      :id => project.id,
      :name => "Fungus Project",
      :file_folder => "fungus",
      :lab_group => "Fungus Group",
      :lab_group_uri => "http://example.com/lab_groups/#{lab_group.id}",
      :updated_at => project.updated_at,
      :sample_uris => ["http://example.com/samples/#{sample_1.id}",
                        "http://example.com/samples/#{sample_2.id}"]
    }
  end
end
