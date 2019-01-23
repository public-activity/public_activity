# frozen_string_literal: true

MigrationsBase = if ActiveRecord.version.release() < Gem::Version.new('5.2.0')
  ActiveRecord::Migration
else
  ActiveRecord::Migration[5.2]
end
