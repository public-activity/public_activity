# Changelog

## 1.0.3

* Fixed a bug which modified globals (thanks to [Weera Wu](https://github.com/wulab))

## 1.0.2

* Fixed undefined constant PublicActivity::Activity for Activist associations (thanks to [Стас Сушков](https://github.com/stas))

## 1.0.1

* #create_activity now correctly returns activity object.
* Fixed :owner not being set correctly when passed to #create_activity (thanks to [Drew Miller](https://github.com/mewdriller))

## 1.0 (released 10/02/2013)

* **Now supports Mongoid 3 and Active Record.**
* Added indexes for polymorphic column pairs to speed up queries in ActiveRecord
* `#create_activity` now returns the newly created Activity object
* Support for custom Activity attributes. Now if you need a custom relation for Activities you can
  create a migration which adds the desired column, whitelist the attribute, and then you can simply pass the value to #create_activity
* `#tracked` can now accept a single Symbol for its `:only` and `:except` options.
* It is now possible to include `PublicActivity::Common` in your models if you just want to use `#create_activity` method
  and skip the default CRUD tracking.
* `#render_activity` now accepts Symbols or Strings for :layout parameter.
  ### Example

  ```ruby
  # All look for app/views/layouts/_activity.erb
  render_activity @activity, :layout => "activity"
  render_activity @activity, :layout => "layouts/activity"
  render_activity @activity, :layout => :activity
  ```
## 0.5.4

* Fixed support for namespaced classes when transforming into view path.

  For example `MyNamespace::CamelCase` now correctly transforms to key: `my_namespace_camel_case.create`
