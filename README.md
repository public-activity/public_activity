# PublicActivity [![Build Status](https://secure.travis-ci.org/pokonski/public_activity.png)](http://travis-ci.org/pokonski/public_activity) [![Dependency Status](https://gemnasium.com/pokonski/public_activity.png)](https://gemnasium.com/pokonski/public_activity)

_public_activity_ provides smooth activity tracking for your **ActiveRecord** and **Mongoid 3** models in Rails 3.
Simply put: it records what has been changed or created and gives you the ability to present those 
recorded activities to users - in a similar way to how GitHub does it.

## Table of contents

1. [Example](#example)
  * [Demo](#online-demo)
3. **[Upgrading](#upgrading)**
4. [Setup](#setup)
  1. [Gem installation](#gem-installation)
  2. [Database setup](#database-setup)
  3. [Model configuration](#model-configuration)
  4. [Custom activities](#custom-activities)
  5. [Displaying activities](#displaying-activities)
    1. [Activity views](#activity-views)
    2. [i18n](#i18n)
5. [Documentation](#documentation)
6. **[Help](#help)**


## Example

Here is a simple example showing what this gem is about:

![Example usage](http://i.imgur.com/q0TVx.png)

### Online demo

You can see an actual application using this gem here: http://public-activity-example.herokuapp.com/feed

The source code of the demo is hosted here: https://github.com/pokonski/activity_blog

## Upgrading from pre-0.4.0

If you are using versions earlier than 0.4.0 please click [here](#upgrading) or scroll to the "Upgrading" section at the bottom of this README.

## Setup

### Gem installation

You can install `public_activity` as you would any other gem:

    gem install public_activity

or in your Gemfile:

```ruby
gem 'public_activity'
```

### Database setup

By default _public_activity_ uses Active Record. If you want to use Mongoid as your backend, create
an initializer file in your Rails application with this code inside:

```ruby
# config/initializers/public_activity.rb
PublicActivity::Config.set do
  orm :mongoid
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
<% @activities.each do |activity| %>
  <%= render_activity(activity) %>
<% end %>
```

*Note*: `render_activity` is a helper for use in view templates. `render_activity(activity)` can be written as `activity.render(self)` and it will have the same meaning.

#### Layouts

You can also pass options to both `activity#render` and `#render_activity` methods, which are passed deeper 
to the internally used `render_partial` method.
A useful example would be to render activities wrapped in layout, which shares common elements of an activity, 
like a timestamp, owner's avatar etc:

```erb
<% @activities.each do |activity| %>
  <%= render_activity(activity, :layout => :activity) %>
<% end %>
```

The activity will be wrapped with the `app/views/layouts/_activity.erb` layout, in the above example.

**Important**: please note that layouts for activities are also partials. Hence the `_` prefix.

#### Activity views

Since version `0.4.0` you can use views to render activities. `public_activity` looks for views in `app/views/public_activity`, and this is now the *default* behaviour.

For example, if you have an activity with `:key` set to `"activity.user.changed_avatar"`, the gem will look for a partial in `app/views/public_activity/user/_changed_avatar.(erb|haml|slim|something_else)`.

*Hint*: the `"activity."` prefix in `:key` is completely optional and kept for backwards compatibility, you can skip it in new projects.

If a view file does not exist, then p_a falls back to the old behaviour and tries to translate the activity `:key` using `I18n#translate` method (see the section below).

#### i18n

Translations are used by the `#text` method, to which you can pass additional options in form of a hash. `#render` method uses translations when view templates have not been provided.

Translations should be put in your locale `.yml` files. To render pure strings from I18n Example structure:

```yaml
activity:
  article:
    create: 'Article has been created'
    update: 'Someone has edited the article'
    destroy: 'Some user removed an article!'
```

This structure is valid for activities with keys `"activity.article.create"` or `"article.create"`. As mentioned before, `"activity."` part of the key is optional.

## Upgrading

**Read this if you have been using versions older than 0.4.**

There are a couple of major differences between 0.3 and 0.4 version. To upgrade, follow these steps:

1.  Add `include PublicActivity::Model` above `tracked` method call in your tracked models, like this:
    
    _ActiveRecord:_

    ```ruby
    class Article < ActiveRecord::Base
      include PublicActivity::Model
      tracked
    end
    ```

    _Mongoid:_

    ```ruby
    class Article
      include Mongoid::Document
      include PublicActivity::Model
      tracked
    end
    ```

2.   _public_activity_'s config YAML file is no longer used (by default in `config/pba.yml`). Move your YAML contents to your `config/locales/*.yml` files.

     <br/>**IMPORTANT**: Locales are no longer rendered with ERB, this has been removed in favor of real view partials like in actual Rails apps.
     Read [Activity views](#activity-views) section above to learn how to use those templates.<br/>

3.   **(ActiveRecord only)** Generate and run migration which adds new column to `activities` table:

     ```bash
     rails g public_activity:migration_upgrade
     rake db:migrate
     ```

## Documentation

For more customization go [here](http://rubydoc.info/gems/public_activity/index)

## Useful examples

* [[How to] Set the Activity's owner to current_user by default](https://github.com/pokonski/public_activity/wiki/%5BHow-to%5D-Set-the-Activity's-owner-to-current_user-by-default)
* [[How to] Disable tracking for a class or globally](https://github.com/pokonski/public_activity/wiki/%5BHow-to%5D-Disable-tracking-for-a-class-or-globally)
* [[How to] Create custom activities](https://github.com/pokonski/public_activity/wiki/%5BHow-to%5D-Create-custom-activities)

## Help

If you need help with using public_activity please visit our discussion group and ask a question there:

https://groups.google.com/forum/?fromgroups#!forum/public-activity

Please do not ask general questions in the Github Issues.

## License
Copyright (c) 2012 Piotrek Okoński, released under the MIT license
