#!/bin/sh

echo "\033[32mTesting active_record 3.X:\033[0m"
BUNDLE_GEMFILE=gemfiles/Gemfile.rails-3.X.activerecord bundle > /dev/null
BUNDLE_GEMFILE=gemfiles/Gemfile.rails-3.X.activerecord COV=1 bundle exec rake

echo "\033[32mTesting active_record 4.0:\033[0m"
BUNDLE_GEMFILE=gemfiles/Gemfile.rails-4.0.activerecord bundle > /dev/null
BUNDLE_GEMFILE=gemfiles/Gemfile.rails-4.0.activerecord COV=1 bundle exec rake

echo "\033[32mTesting mongoid rails 3.X:\033[0m"
BUNDLE_GEMFILE=gemfiles/Gemfile.rails-3.X.mongoid bundle > /dev/null
BUNDLE_GEMFILE=gemfiles/Gemfile.rails-3.X.mongoid COV=1 PA_ORM=mongoid bundle exec rake

echo "\033[32mTesting mongoid rails 4.0:\033[0m"
BUNDLE_GEMFILE=gemfiles/Gemfile.rails-4.0.mongoid bundle > /dev/null
BUNDLE_GEMFILE=gemfiles/Gemfile.rails-4.0.mongoid COV=1 PA_ORM=mongoid bundle exec rake

echo "\033[32mTesting mongo_mapper rails 3.X:\033[0m"
BUNDLE_GEMFILE=gemfiles/Gemfile.rails-3.X.mongo_mapper bundle > /dev/null
BUNDLE_GEMFILE=gemfiles/Gemfile.rails-3.X.mongo_mapper COV=1 PA_ORM=mongo_mapper bundle exec rake

echo "\033[32mTesting mongo_mapper rails 4.0:\033[0m"
BUNDLE_GEMFILE=gemfiles/Gemfile.rails-4.0.mongo_mapper bundle > /dev/null
BUNDLE_GEMFILE=gemfiles/Gemfile.rails-4.0.mongo_mapper COV=1 PA_ORM=mongo_mapper bundle exec rake
