# PublicActivity ![Build Status](http://travis-ci.org/pokonski/public_activity.png)

public_activity provides smooth acitivity tracking for your ActiveRecord models in Rails 3.
Simply put: it records what has been changed or edited and gives you the ability to present those recorded activities to users - in a similar way Github does it.

## Example

A picture is worth a thousand words, so here is a visual representation of what this gem is about:

![Example usage](http://i.imgur.com/uGPSm.png)

## Installation

You can install this gem as you would any other gem:
    gem install public_activity
or in your Gemfile:
    gem 'public_activity'

## Usage

Create migration for activities (in your Rails project):

    rails g public_activity:migration
    rake db:migrate

Add 'tracked' to the model you want to keep track of:

    class Article < ActiveRecord::Base
      tracked
    end

To default the owner to the current user (optional)
    
    #Aplication Controller
    before_filter :define_current_user
    
    def define_current_user
      User.current_user = current_user
    end
    
    #User.rb (model)
    class User < ActiveRecord::Base
      cattr_accessor :current_user
    end
    
And now, by default create/update/destroy activities are recorded in activities table. 
To display them you can do a simple query:

    # some_controller.rb
    def index
      @activities = PublicActivity::Activity.all
    end
    
And in your views:

    <% for activity in @activities %>
      <%= activity.text %><br/>
    <% end %>
    
The only thing left is to add templates (config/pba.yml), for example:

      activity:
        article:
          create: 'Article has been created'
          update: 'Someone has edited the article'
          destroy: 'Some user removed an article!'

Place this in a file and reference it in a Rails initializer.

    PublicActivity::Activity.template = YAML.load_file("#{RAILS_ROOT}/config/pba.yml")

This is only a basic example, refer to documentation for more options and customization!
## Documentation

You can find documentation [here](http://rubydoc.info/gems/public_activity/)

## License
Copyright (c) 2012 Piotrek Okoński, released under the MIT license
