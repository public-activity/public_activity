class Department < ActiveRecord::Base
  include PublicActivity::Model
  tracked(:except => [:create])
  activist
end

class Category < ActiveRecord::Base
  include PublicActivity::Model
  tracked(:only =>  [:create, :update, :destroy])
  validates_presence_of :name
end

class Note < ActiveRecord::Base
  include PublicActivity::Model
  tracked(:only =>  [:update])
  belongs_to :category
end
