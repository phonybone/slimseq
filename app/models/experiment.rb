class Experiment < ActiveRecord::Base
  has_many :samples
  belongs_to :study

  def tree_hash 
    children=samples.map {|s| s.tree_hash}
    { :id => "e_#{id}",
      :text => name,
      :href => "#{SiteConfig.site_url}/experiments/#{id}",
      :children=>children }
  end
end
