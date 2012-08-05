# PublicActivity ![Build Status](http://travis-ci.org/pokonski/public_activity.png)

public_activity provides smooth activity tracking for your ActiveRecord models in Rails 3.
Simply put: it records what has been changed or edited and gives you the ability to present those recorded activities to users - in a similar way Github does it.

## Example

Here is a simple example showing what this gem is about:

![Example usage](http://i.imgur.com/uGPSm.png)

## Upgrading to 0.4

If you are using versions earlier than 0.4.0 please click [here](#upgrading) or scroll to the "Upgrading" section at the bottom of this README.

## First time setup

### Gem installation

You can install `public_activity` as you would any other gem:

    gem install public_activity

or in your Gemfile:

    gem 'public_activity'

### Database setup

Create migration for activities and migrate the database (in your Rails project):

    rails g public_activity:migration
    rake db:migrate

### Model configuration

Include `PublicActivity::Model` and add `tracked` to the model you want to keep track of:

```ruby
class Article < ActiveRecord::Base
  include PublicActivity::Model
  tracked
end
```

And now, by default create/update/destroy activities are recorded in activities table. This is all you need to start recording activities for basic CRUD actions.

### Displaying activities

To display them you simply query the `PublicActivity::Activity` ActiveRecord model:

```ruby
# notifications_controller.rb
def index
  @activities = PublicActivity::Activity.all
end
```

And in your views:

```erb
<%= for activity in @activities %>
  <%= render_activity(activity) %>
<% end %>
```

*Note*: `render_activity` is a helper for use in view templates. `render_activity(activity)` can be written as `activity.render(self)` and it will have the same meaning.

You can also pass options to both `activity#render` and `#render_activity` methods, which are passed deeper to the `render_partial` method.
A useful example would be to render activities wrapped in layout, which shares common elements of an activity, like a timestamp, owner's avatar etc.

```erb
<%= for activity in @activities %>
  <%= render_activity(activity, :layout => :activity) %>
<% end %>
```

The activity will be wrapped with the `app/views/layouts/activity` layout, in the above example.

### Activity views

Since version `0.4.0` you can use views to render activities. `public_activity` looks for views in `app/views/public_activity`, and this is now the *default* behaviour.

For example, if you have an activity with `:key` set to `"activity.user.changed_avatar"`, the gem will look for a partial in `app/views/public_activity/user/_changed_avatar.(erb|haml|slim|something_else)`.

*Hint*: the `"activity."` prefix in `:key` is completely optional and kept for backwards compatibility, you can skip it in new projects.

If a view file does not exist, then p_a falls back to the old behaviour and tries to translate the activity `:key` using `I18n#translate` method (see the section below).

### i18n

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

There are a couple of major differences between 0.3 and 0.4 version. To upgrade, follow these steps:

1.  Add `include PublicActivity::Model` above `tracked` method call in your tracked models, like this:

    ```ruby
    class Article < ActiveRecord::Base
      include PublicActivity::Model
      tracked
    end
    ```

2.   public_activity's config YAML file is no longer used (by default in `config/pba.yml`). Move your YAML contents to your `config/locales/*.yml` files.

     <br/>**IMPORTANT**: Locales are no longer rendered with ERB, this has been removed in favor of real view partials like in actual Rails apps.
     Read [Activity views](#activity-views) section above to learn how to use those templates.<br/>

3.   Generate and run migration which adds new column to `activities` table:

     ```bash
     rails g public_activity:migration_upgrade
     rake db:migrate
     ```

## Documentation

For more customization go [here](http://rubydoc.info/gems/public_activity/index)

## License
Copyright (c) 2012 Piotrek Okoński, released under the MIT license