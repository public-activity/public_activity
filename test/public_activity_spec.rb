require 'spec_helper'

describe "public_activity" do
  before(:all) do
    self.class.fixtures :categories, :departments, :notes
  end
  
  describe "tracked" do
    
    it "should create a record in activity table" do
      #we should have no records
      PublicActivity::Activity.count.should == 0
    
      lambda do
        category = Category.create(:name => "test cat")
        activity = PublicActivity::Activity.last
        activity.trackable_id.should == category.id
      end.should change(PublicActivity::Activity, :count).by(1)
    end
    
    describe "activity model" do
      before(:each) do
        @category = Category.create(:name => "test cat")
      end
  
      it "should have a nil owner" do
        activity = PublicActivity::Activity.last
        activity.owner.should be_nil
      end
  
      it "should have an owner" do
        department = Department.create(:name => "test dept")
        @category.activity_owner = department
        @category.save
    
        activity = PublicActivity::Activity.last
        activity.owner.should_not be_nil
      end
      
      it "should have activites" do
         @category.activities.should_not be_nil
      end
      
      it "should translate" do
        @category.activities.last.text.should_not be_nil
        @category.activities.last.text.should == "New test cat category has been created"
      end
      
      it "should track deletes" do
        lambda do
          @category.destroy
          @category.activities.last.text.should == "Someone deleted the category!"
        end.should change(PublicActivity::Activity, :count).by(1)  
      end
      
      it "should track updates" do
        lambda do
          @category.name = "new cat"
          @category.save
          @category.activities.last.text.should == "Someone modified the category"
        end.should change(PublicActivity::Activity, :count).by(1)  
      end
      
      it "should evaluate associations" do
        note = Note.find(1)
        note.body = "New Test"
        note.save
        note.activities.last.text.should == "Someone modified note New Test with category Category 1"
      end
    end
    
    describe "tracked options" do
      it "should not track destroy for note (only)" do
        lambda do
         note = Note.find(1)
         note.destroy
        end.should change(PublicActivity::Activity, :count).by(0)
      end
      
      it "should not track create for department (except)" do
        lambda do
         dept = Department.find(1)
         dept.name = "new name"
         dept.save
        end.should change(PublicActivity::Activity, :count).by(1)
        
        lambda do
         dept = Department.find(1)
         dept.destroy
        end.should change(PublicActivity::Activity, :count).by(1)     
           
        lambda do
         dept = Department.new
         dept.name = "some name"
         dept.save
        end.should change(PublicActivity::Activity, :count).by(0)   
             
      end
    end
  end
  
  describe "activist" do
    
    before(:each) do
      @category = Category.create(:name => "test cat")
      @department = Department.create(:name => "test dept")
      @category.activity_owner = @department
      @category.save
    end
    
    it "should have activites" do
      @department.activities.should_not be_nil
    end
  end
  
  describe "template failures" do
    it "should not die on nil" do
      PublicActivity::Activity.template = nil
      @category = Category.create(:name => "test cat")
      @category.activities.last.text.should == "Template not defined"
    end
    
    it "should evaluate associations" do
      note = Note.find(2)
      note.body = "New Test"
      note.save
      note.activities.last.text.should == "Template not defined"
    end
    
  end
end