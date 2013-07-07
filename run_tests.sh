echo "Testing active_record:"
rm -f Gemfile.lock;
bundle > /dev/null; 
rake;
echo "Testing mongoid:";
rm -f Gemfile.lock;
PA_ORM=mongoid bundle > /dev/null; 
PA_ORM=mongoid rake;
echo "Testing mongo_mapper:";
rm -f Gemfile.lock;
PA_ORM=mongo_mapper bundle > /dev/null;
PA_ORM=mongo_mapper rake;