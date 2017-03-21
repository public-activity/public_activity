# PublicActivity
## [![Build Status](https://travis-ci.org/chaps-io/public_activity.svg?branch=master)](https://travis-ci.org/chaps-io/public_activity) [![Coverage Status](http://img.shields.io/coveralls/pokonski/public_activity.svg)](https://coveralls.io/r/pokonski/public_activity) [![Code Climate](http://img.shields.io/codeclimate/github/pokonski/public_activity.svg)](https://codeclimate.com/github/pokonski/public_activity) [![Gem Version](http://img.shields.io/gem/v/public_activity.svg)](http://badge.fury.io/rb/public_activity) [![Inline docs](http://inch-ci.org/github/pokonski/public_activity.png)](http://inch-ci.org/github/pokonski/public_activity) [![Security](https://hakiri.io/github/chaps-io/public_activity/master.svg)](https://hakiri.io/github/chaps-io/public_activity/master)

## [![](http://www.deadgoodundies.com/files/images/full/gregg-homme-cowboy-chaps-steel-front-1.jpg)](https://chaps.io) proudly made by [Chaps](https://chaps.io)


`public_activity` provides easy activity tracking for your **ActiveRecord**, **Mongoid 3** and **MongoMapper** models
in Rails 3 and 4.

Simply put: it can record what happens in your application and gives you the ability to present those recorded activities to users - in a similar way to how GitHub does it.

## !! WARNING: README for unreleased version below. !!

You probably don't want to read the docs for this unreleased version 2.0.

*For the stable `1.5.X` readme see: https://github.com/chaps-io/public_activity/blob/1-5-stable/README.md*


## Table of contents

1. [About](#about)
  * [Tutorials](#tutorials)
  * [Demo](#online-demo)
2. [Setup](#setup)
  1. [Gem installation](#gem-installation)
  2. [Database setup](#database-setup)
  3. [Model configuration](#model-configuration)
  4. [Custom activities](#custom-activities)
  5. [Displaying activities](#displaying-activities)
    1. [Activity views](#activity-views)
    2. [i18n](#i18n)
3. [Testing](#testing)
4. [Documentation](#documentation)
5. **[Common examples](#common-examples)**
6. [Help](#help)
7. [Upgrading](https://github.com/pokonski/public_activity/wiki/Upgrading-from-pre-2.0.0-versions)

## About

Here is a simple example showing what this gem is about:

![Example usage](http://i.imgur.com/q0TVx.png)

### Tutorials

#### Screencast

Ryan Bates made a [great screencast](http://railscasts.com/episodes/406-public-activity) describing how to integrate Public Activity.

#### Tutorial

A great step-by-step guide on [implementing activity feeds using public_activity](http://www.sitepoint.com/activity-feeds-rails/) by [Ilya Bodrov](https://github.com/bodrovis).

### Online demo

You can see an actual application using this gem here: http://public-activity-example.herokuapp.com/feed

The source code of the demo is hosted here: https://github.com/pokonski/activity_blog


## Setup

### Gem installation

You can install `public_activity` as you would any other gem:

    gem install public_activity

or in your Gemfile:

```ruby
gem 'public_activity'
```

### Database setup

By default `public_activity` uses Active Record. If you want to use Mongoid or MongoMapper as your backend, create
an initializer file in your Rails application with the corresponding code inside:

For _Mongoid:_

```ruby
# config/initializers/public_activity.rb
PublicActivity.configure do |config|
  config.orm = :mongoid
end
```

For _MongoMapper:_

```ruby
# config/initializers/public_activity.rb
PublicActivity.configure do |config|
  config.orm = :mongo_mapper
end
```

**(ActiveRecord only)** Create migration for activities and migrate the database (in your Rails project):

    rails g public_activity:migration
    rake db:migrate

### Model configuration

Include `PublicActivity::Model` and add `tracked` to the model you want to keep track of:

For _ActiveRecord:_

```ruby
class Article < ActiveRecord::Base
  include PublicActivity::Model
  tracked
end
```

For _Mongoid:_

```ruby
class Article
  include Mongoid::Document
  include PublicActivity::Model
  tracked
end
```

For _MongoMapper:_

```ruby
class Article
  include MongoMapper::Document
  include PublicActivity::Model
  tracked
end
```

And now, by default create/update/destroy activities are recorded in activities table.
This is all you need to start recording activities for basic CRUD actions.

_Optional_: If you don't need `#tracked` but still want the comfort of `#create_activity`,
you can include only the lightweight `Common` module instead of `Model`.

#### Custom activities

You can trigger custom activities by setting all your required parameters and triggering `create_activity`
on the tracked model, like this:

```ruby
@article.create_activity key: 'article.commented_on', owner: current_user
```

See this entry http://rubydoc.info/gems/public_activity/PublicActivity/Common:create_activity for more details.

### Displaying activities

To display them you simply query the `PublicActivity::Activity` model:

```ruby
# notifications_controller.rb
def index
  @activities = PublicActivity::Activity.all
end
```

And in your views:

```erb
<%= render_activities(@activities) %>
```

*Note*: `render_activities` is an alias for `render_activity` and does the same.

#### Layouts

You can also pass options to both `activity#render` and `#render_activity` methods, which are passed deeper
to the internally used `render_partial` method.
A useful example would be to render activities wrapped in layout, which shares common elements of an activity,
like a timestamp, owner's avatar etc:

```erb
<%= render_activities(@activities, layout: :activity) %>
```

The activity will be wrapped with the `app/views/layouts/_activity.html.erb` layout, in the above example.

**Important**: please note that layouts for activities are also partials. Hence the `_` prefix.

#### Locals

Sometimes, it's desirable to pass additional local variables to partials. It can be done this way:

```erb
<%= render_activity(@activity, locals: {friends: current_user.friends}) %>
```

*Note*: Before 1.4.0, one could pass variables directly to the options hash for `#render_activity` and access it from activity parameters. This functionality is retained in 1.4.0 and later, but the `:locals` method is **preferred**, since it prevents bugs from shadowing variables from activity parameters in the database.

#### Activity views

`public_activity` looks for views in `app/views/public_activity`.

For example, if you have an activity with `:key` set to `"activity.user.changed_avatar"`, the gem will look for a partial in `app/views/public_activity/user/_changed_avatar.html.(|erb|haml|slim|something_else)`.

*Hint*: the `"activity."` prefix in `:key` is completely optional and kept for backwards compatibility, you can skip it in new projects.

If you would like to fallback to a partial, you can utilize the `fallback` parameter to specify the path of a partial to use when one is missing:

```erb
<%= render_activity(@activity, fallback: 'default') %>
```

When used in this manner, if a partial with the specified `:key` cannot be located it will use the partial defined in the `fallback` instead. In the example above this would resolve to `public_activity/_default.html.(|erb|haml|slim|something_else)`.

If a view file does not exist then ActionView::MisingTemplate will be raised. If you wish to fallback to the old behaviour and use an i18n based translation in this situation you can specify a `:fallback` parameter of `text` to fallback to this mechanism like such:

```erb
<%= render_activity(@activity, fallback: :text) %>
```

#### i18n

Translations are used by the `#text` method, to which you can pass additional options in form of a hash. `#render` method uses translations when view templates have not been provided. You can render pure i18n strings by passing `{display: :i18n}` to `#render_activity` or `#render`.

Translations should be put in your locale `.yml` files. To render pure strings from I18n Example structure:

```yaml
activity:
  article:
    create: 'Article has been created'
    update: 'Someone has edited the article'
    destroy: 'Some user removed an article!'
```

This structure is valid for activities with keys `"activity.article.create"` or `"article.create"`. As mentioned before, `"activity."` part of the key is optional.

## Testing

For RSpec you can first disable `public_activity` and add require helper methods in
the `rails_helper.rb` with:

```ruby
#rails_helper.rb
require 'public_activity/testing'

PublicActivity.enabled = false
```

In your specs you can then blockwise decide whether to turn `public_activity` on
or off.

```ruby
# file_spec.rb
PublicActivity.with_tracking do
  # your test code goes here
end

PublicActivity.without_tracking do
  # your test code goes here
end
```

## Documentation

For more documentation go [here](http://rubydoc.info/gems/public_activity/index)

## Common examples

### Set the Activity's owner to current_user by default

You can set up a default value for `:owner` by doing this:

1. Include `PublicActivity::StoreController` in your `ApplicationController` like this:

  ```ruby
  class ApplicationController < ActionController::Base
    include PublicActivity::StoreController
  end
  ```

2. Use Proc in `:owner` attribute for `tracked` class method in your desired model. For example:

  ```ruby
  class Article < ActiveRecord::Base
    tracked owner: Proc.new{ |controller, model| controller.current_user }
  end
  ```


*Note:* `current_user` applies to Devise, if you are using a different authentication gem or your own code, change the `current_user` to a method you use.

### Disable tracking for a class or globally

If you need to disable tracking temporarily, for example in tests or `db/seeds.rb` then you can use `PublicActivity.enabled=` attribute like below:

```ruby
# Disable p_a globally
PublicActivity.enabled = false

# Perform some operations that would normally be tracked by p_a:
Article.create(title: 'New article')

# Switch it back on
PublicActivity.enabled = true
```

You can also disable public_activity for a specific class:

```ruby
# Disable p_a for Article class
Article.public_activity_off

# p_a will not do anything here:
@article = Article.create(title: 'New article')

# But will be enabled for other classes:
# (creation of the comment will be recorded if you are tracking the Comment class)
@article.comments.create(body: 'some comment!')

# Enable it again for Article:
Article.public_activity_on
```

### Create custom activities

Besides standard, automatic activities created on CRUD actions on your model (deactivatable), you can post your own activities that can be triggered without modifying the tracked model. There are a few ways to do this, as PublicActivity gives three tiers of options to be set.

#### Instant options
Because every activity **needs a key** (otherwise: `NoKeyProvided` is raised), the shortest and minimal way to post an activity is:

```ruby
@user.create_activity :mood_changed
# the key of the action will be user.mood_changed
@user.create_activity action: :mood_changed # this is exactly the same as above
```

Besides assigning your key (which is obvious from the code), it will take global options from User class (given in `#tracked` method during class definition) and overwrite them with instance options (set on `@user` by `#activity` method). You can read more about options and how PublicActivity inherits them for you [here](Options-in-Detail).

**Note** the action parameter builds the key like this: `"#{model_name}.#{action}"`. You can read further on options for `#create_activity` [here](http://rubydoc.info/gems/public_activity/PublicActivity/Common:create_activity).

To provide more options, you can do:

```ruby
@user.create_activity action: 'poke', parameters: {reason: 'bored'}, recipient: @friend, owner: current_user

```

In this example, we have provided all the things we could for a standard Activity.


### Use custom fields on Activity

Besides the few fields that every Activity has (`key`, `owner`, `recipient`, `trackable`, `parameters`), you can also set custom fields. This could be very beneficial, as `parameters` are a serialized hash, which cannot be queried easily from the database. That being said, use custom fields when you know that you will set them very often and search by them (don't forget database indexes :) ).

### Set `owner` and `recipient` based on associations


```ruby
class Comment < ActiveRecord::Base
  include PublicActivity::Model
  tracked owner: :commenter, recipient: :commentee

  belongs_to :commenter, :class_name => "User"
  belongs_to :commentee, :class_name => "User"
end
```

### Resolve parameters from a Symbol or Proc

```ruby
class Post < ActiveRecord::Base
  include PublicActivity::Model
  tracked only: [:update], parameters: :tracked_values
  
  def tracked_values
   {}.tap do |hash|
     hash[:tags] = tags if tags_changed?
   end
  end
end
```

#### Setup

**Skip this step if you are using ActiveRecord in Rails 4 or Mongoid**

The first step is similar in every ORM available (except mongoid):

```ruby
PublicActivity::Activity.class_eval do
  attr_accessible :custom_field
end
```

place this code under `config/initializers/public_activity.rb`, you have to create it first.

To be able to assign to that field, we need to move it to the mass assignment sanitizer's whitelist.

#### Migration

If you're using ActiveRecord, you will also need to provide a migration to add the actual field to the `Activity`. Taken from [our tests][tests-migration]:

```ruby
class AddCustomFieldToActivities < ActiveRecord::Migration
  def change
    change_table :activities do |t|
      t.string :custom_field
    end
  end
end
```

### Assigning custom fields

Assigning is done by the same methods that you use for normal parameters: `#tracked`, `#create_activity`. You can just pass the name of your custom variable and assign its value. Even better, you can pass it to `#tracked` to tell us how to harvest your data for custom fields so we can do that for you.

```ruby
class Article < ActiveRecord::Base
  include PublicActivity::Model
  tracked custom_field: proc {|controller, model| controller.some_helper }
end
```

[tests-migration]: https://github.com/pokonski/public_activity/blob/master/test/migrations/004_add_nonstandard_to_activities.rb

## Help

If you need help with using public_activity please visit our discussion group and ask a question there:

https://groups.google.com/forum/?fromgroups#!forum/public-activity

Please do not ask general questions in the Github Issues.

## License

Copyright (c) 2011-2014 Piotrek Okoński, released under the MIT license
