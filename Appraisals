# frozen_string_literal: true

if RUBY_VERSION.to_f < 3.0
  appraise 'rails_5.0' do
    gem 'rails', '~> 5.0.5'
    gem 'sqlite3', '~> 1.3.6'
  end

  appraise 'rails_5.1' do
    gem 'rails', '~> 5.1.0'
    gem 'sqlite3', '~> 1.3.6'
  end

  appraise 'rails_5.2' do
    gem 'rails', '~> 5.2.0'
    gem 'psych', '< 4'
  end
end

if RUBY_VERSION.to_f >= 2.5 && RUBY_VERSION.to_f < 3.0
  appraise 'rails_6.0' do
    gem 'rails', '~> 6.0.0'
  end
end

if RUBY_VERSION.to_f >= 2.5 && RUBY_VERSION.to_f < 3.1
  appraise 'rails_6.1' do
    gem 'rails', '~> 6.1.0'
  end
end

if RUBY_VERSION.to_f >= 2.7
  appraise 'rails_7.0' do
    gem 'rails', '~> 7.0.1'
  end
end
