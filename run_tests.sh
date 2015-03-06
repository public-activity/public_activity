#!/bin/sh

echo "Testing active_record 3.X:"
BUNDLE_GEMFILE=gemfiles/Gemfile.rails-3.X.activerecord bundle
BUNDLE_GEMFILE=gemfiles/Gemfile.rails-3.X.activerecord COV=1 bundle exec rake

echo "Testing active_record 4.0:"
BUNDLE_GEMFILE=gemfiles/Gemfile.rails-4.0.activerecord bundle
BUNDLE_GEMFILE=gemfiles/Gemfile.rails-4.0.activerecord COV=1 bundle exec rake

echo "Testing mongoid rails 3.X:"
BUNDLE_GEMFILE=gemfiles/Gemfile.rails-3.X.mongoid bundle
BUNDLE_GEMFILE=gemfiles/Gemfile.rails-3.X.mongoid COV=1 PA_ORM=mongoid bundle exec rake

echo "Testing mongoid rails 4.0:"
BUNDLE_GEMFILE=gemfiles/Gemfile.rails-4.0.mongoid bundle
BUNDLE_GEMFILE=gemfiles/Gemfile.rails-4.0.mongoid COV=1 PA_ORM=mongoid bundle exec rake

echo "Testing mongo_mapper rails 3.X:"
BUNDLE_GEMFILE=gemfiles/Gemfile.rails-3.X.mongo_mapper bundle
BUNDLE_GEMFILE=gemfiles/Gemfile.rails-3.X.mongo_mapper COV=1 PA_ORM=mongo_mapper bundle exec rake

echo "Testing mongo_mapper rails 4.0:"
BUNDLE_GEMFILE=gemfiles/Gemfile.rails-4.0.mongo_mapper bundle
BUNDLE_GEMFILE=gemfiles/Gemfile.rails-4.0.mongo_mapper COV=1 PA_ORM=mongo_mapper bundle exec rake
