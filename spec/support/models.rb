class Department < ActiveRecord::Base
  activist
end

class Category < ActiveRecord::Base
  tracked
  validates_presence_of :name
end

class Note < ActiveRecord::Base
  tracked
  belongs_to :category
end
