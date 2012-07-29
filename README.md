# PublicActivity ![Build Status](http://travis-ci.org/pokonski/public_activity.png)

public_activity provides smooth activity tracking for your ActiveRecord models in Rails 3.
Simply put: it records what has been changed or edited and gives you the ability to present those recorded activities to users - in a similar way Github does it.

## Example

Here is a simple example showing what this gem is about:

![Example usage](http://i.imgur.com/uGPSm.png)

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

Include `PublicActibity::Model` and add 'tracked' to the model you want to keep track of:

```ruby
class Article < ActiveRecord::Base
  include PublicActivity::Model
  tracked
end
```

And now, by default create/update/destroy activities are recorded in activities table. This is all you need to start recording activities for basic actions like update, create or destroy.

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
  <= activity.render %>
<% end %>
```

### Activity views

Since version `0.4.0` you can use views to render activities. `public_activity` looks for views in `app/views/public_activity`, and this is now the *default* behaviour.

For example, if you have an activity with `:key` set to `"activity.user.changed_avatar"`, the gem will look for a view file in `app/views/public_activity/user/changed_avatar.(erb|haml|slim|something_else)`. 

*Hint*: the `"activity."` prefix in `:key` is completely optional and kept for backwards compatibility, you can skip it in new projects.

If a view file does not exist, then `p_a` falls back to the old behaviour and tries to translate the activity `:key` using i18n.translate method. 

### i18n

Translations are used by the `text` (or when a view file is not present when executing `render`) instance method in Activity model and should be put in your locale `.yml` files. Example structure:

```yaml
activity:
  article:
    create: 'Article has been created'
    update: 'Someone has edited the article'
    destroy: 'Some user removed an article!'
```
This structure is valid for activities with keys `"activity.article.create"` or `"article.create"`. As mentioned before, `"activity."` part is optional.

*Important*: Basically the activity's key is also an i18n key.
## Documentation

For more customization go [here](http://rubydoc.info/gems/public_activity/index)

## License
Copyright (c) 2012 Piotrek Okoński, released under the MIT license