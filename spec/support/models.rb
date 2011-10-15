class Department < ActiveRecord::Base
  activist
end

class Category < ActiveRecord::Base
  tracked
  validates_presence_of :name
end

