# PublicActivity
## [![Gittip](http://img.shields.io/gittip/pokonski.svg)](https://www.gittip.com/pokonski/) [![Build Status](http://img.shields.io/travis/pokonski/public_activity/master.svg)](http://travis-ci.org/pokonski/public_activity) [![Coverage Status](http://img.shields.io/coveralls/pokonski/public_activity.svg)](https://coveralls.io/r/pokonski/public_activity) [![Code Climate](http://img.shields.io/codeclimate/github/pokonski/public_activity.svg)](https://codeclimate.com/github/pokonski/public_activity) [![Gem Version](http://img.shields.io/gem/v/public_activity.svg)](http://badge.fury.io/rb/public_activity) [![Inline docs](http://inch-pages.github.io/github/pokonski/public_activity.png)](http://inch-pages.github.io/github/pokonski/public_activity)

`public_activity` provides easy activity tracking for your **ActiveRecord**, **Mongoid 3** and **MongoMapper** models
in Rails 3 and 4. Simply put: it can record what happens in your application and gives you the ability to present those recorded activities to users - in a similar way to how GitHub does it.

## Version notice

This documentation is for the unreleased 2.0 version. For the stable `1.4.X` readme see: https://github.com/pokonski/public_activity/blob/1-4-stable/README.md


## Table of contents

1. [Example](#example)
  * [Demo](#online-demo)
  * [Screencast](#screencast)
  * **[Common examples](#common-examples)**
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
5. **[Help](#help)**
6. [Upgrading](https://github.com/pokonski/public_activity/wiki/Upgrading-from-pre-2.0.0-versions)

## Example

Here is a simple example showing what this gem is about:

![Example usage](http://i.imgur.com/q0TVx.png)

### Online demo

You can see an actual application using this gem here: http://public-activity-example.herokuapp.com/feed

The source code of the demo is hosted here: https://github.com/pokonski/activity_blog

## Screencast

Ryan Bates made a [great screencast](http://railscasts.com/episodes/406-public-activity) describing how to integrate Public Activity in your Rails Application.

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

*Note*: `render_activity` is a helper for use in view templates. `render_activity(activity)` can be written as `activity.render(self)` and it will have the same meaning.

*Note*: `render_activities` is an alias for `render_activity` and does the same.

#### Layouts

You can also pass options to both `activity#render` and `#render_activity` methods, which are passed deeper
to the internally used `render_partial` method.
A useful example would be to render activities wrapped in layout, which shares common elements of an activity,
like a timestamp, owner's avatar etc:

```erb
<%= render_activities(@activities, layout: :activity) %>
```

The activity will be wrapped with the `app/views/layouts/_activity.erb` layout, in the above example.

**Important**: please note that layouts for activities are also partials. Hence the `_` prefix.

#### Locals

Sometimes, it's desirable to pass additional local variables to partials. It can be done this way:

```erb
<%= render_activity(@activity, locals: {friends: current_user.friends}) %>
```

*Note*: Before 1.4.0, one could pass variables directly to the options hash for `#render_activity` and access it from activity parameters. This functionality is retained in 1.4.0 and later, but the `:locals` method is **preferred**, since it prevents bugs from shadowing variables from activity parameters in the database.

#### Activity views

`public_activity` looks for views in `app/views/public_activity`.

For example, if you have an activity with `:key` set to `"activity.user.changed_avatar"`, the gem will look for a partial in `app/views/public_activity/user/_changed_avatar.(erb|haml|slim|something_else)`.

*Hint*: the `"activity."` prefix in `:key` is completely optional and kept for backwards compatibility, you can skip it in new projects.

If you would like to fallback to a partial, you can utilize the `fallback` parameter to specify the path of a partial to use when one is missing:

```erb
<%= render_activity(@activity, fallback: 'default') %>
```

When used in this manner, if a partial with the specified `:key` cannot be located it will use the partial defined in the `fallback` instead. In the example above this would resolve to `public_activity/_default.(erb|haml|slim|something_else)`.

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

For RSpec you can first disable `public_activity` and add the `test_helper` in
the `spec_helper.rb` with

```ruby
#spec_helper.rb
require 'public_activity/testing'

PublicActivity.enabled = false
```

In your specs you can then blockwise decide wether to turn `public_activity` on
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

* [[How to] Set the Activity's owner to current_user by default](https://github.com/pokonski/public_activity/wiki/%5BHow-to%5D-Set-the-Activity's-owner-to-current_user-by-default)
* [[How to] Disable tracking for a class or globally](https://github.com/pokonski/public_activity/wiki/%5BHow-to%5D-Disable-tracking-for-a-class-or-globally)
* [[How to] Create custom activities](https://github.com/pokonski/public_activity/wiki/%5BHow-to%5D-Create-custom-activities)
* [[How to] Use custom fields on Activity](https://github.com/pokonski/public_activity/wiki/%5BHow-to%5D-Use-custom-fields-on-Activity)

## Help

If you need help with using public_activity please visit our discussion group and ask a question there:

https://groups.google.com/forum/?fromgroups#!forum/public-activity

Please do not ask general questions in the Github Issues.

## License
Copyright (c) 2011-2014 Piotrek Okoński, released under the MIT license
