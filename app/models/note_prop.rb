class NoteProp < ActiveRecord::Base
  has_one :node, :as => :prop
end