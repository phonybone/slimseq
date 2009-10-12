class Study < ActiveRecord::Base
  has_many :experiments
  belongs_to :project
end
