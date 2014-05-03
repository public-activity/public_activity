namespace :public_activity do
  desc "Public Activity rake tasks"
  
  desc "Deletes PublicActivity::Activity records that are more than x months old.  Usage rake public_activity:truncate[3].  Default 0 months."
  task :truncate, [:age]=>[:environment] do |t,args|
    age = args[:age] || 0
    Setting.load_and_apply
    x = PublicActivity::Activity.where("created_at < ?", Date.today << age.to_i).delete_all
    puts "Deleted all PublicActivity::Activity records that are more than %d months old, %d records." % [age,x]
  end
end
