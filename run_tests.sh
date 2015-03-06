#!/bin/sh
echo "Testing active_record 3.X:"
rm -f Gemfile.lock;
BUNDLE_GEMFILE=gemfiles/Gemfile.rails-3.X bundle > /dev/null;
COV=1 bundle exec rake;
echo "Testing active_record 4.0:"
rm -f Gemfile.lock;
BUNDLE_GEMFILE=gemfiles/Gemfile.rails-4.0 bundle > /dev/null;
COV=1 bundle exec rake;
echo "Testing mongoid:";
rm -f Gemfile.lock;
PA_ORM=mongoid bundle > /dev/null;
COV=1 PA_ORM=mongoid bundle exec rake;
echo "Testing mongo_mapper:";
rm -f Gemfile.lock;
PA_ORM=mongo_mapper bundle > /dev/null;
COV=1 PA_ORM=mongo_mapper bundle exec rake;
