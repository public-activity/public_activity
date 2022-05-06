# frozen_string_literal: true

MigrationsBase = if ActiveRecord.version.release() < Gem::Version.new('5.1.0')
  ActiveRecord::Migration
else
  ActiveRecord::Migration[5.1]
end
