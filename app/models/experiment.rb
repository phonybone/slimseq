class Experiment < ActiveRecord::Base
  has_many :samples
  belongs_to :study
end
