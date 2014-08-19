# Changelog

## 2.0 (unreleased)

This version brings a lot of API changes and improvements.

* More better documentation!
* Added ability to customize root path for directory in which partials/layouts are kept (defaults set to `app/views/public_activity` and `app/views/layouts` respectively) and can be customized like this:

  ```ruby
  render_activity(@activity, layout_root: 'app/views/custom_path', partial_path: 'app/views/left_nav/public_activity')
  ```

* Every `:params` option is now called `:parameters` (for example in `create_activity` or `tracked` methods). Also local variable in activity partials is renamed to `parameters`.
* Configuration of instance variables for tracked models is now removed. From now on use `create_activity` instead of `activity`.
* `a` and `p` shortcut variables are removed in activity partials. Use `activity` and `parameters` instead.

* Configurable fallbacks for activity partials. See [#148](https://github.com/pokonski/public_activity/pull/148) (thanks to [Chris Shorrock](https://github.com/shorrockin))

## 1.4.2

* Fix bug with migrations not having an extension in ActiveRecord >= 4.0.0
>>>>>>> 1-4-stable

## 1.4.1

* Fixed issue with Rails 4 when using ProtectedAttributes gem (see #128)
* General code clean-ups.

## 1.4.0

* Added support for MongoMapper ORM (thanks to [Julio Olivera](https://github.com/julioolvr)) [PR](https://github.com/pokonski/public_activity/pull/101)
* Added support for stable **Rails 4.0** while keeping compatibility with Rails 3.X
* `render_activity` can now render collections of activities instead of just a single one. Also aliased as `render_activities`
* Fix issue in rendering multiple activities when options were incomplete for every subsequent activity after the first one
* `render_activity` now accetps `:locals` option. Works the same way as `:locals` for Rails `render` method.

## 1.1.0

* Fixed an issue when AR was loading despite choosing Mongoid in multi-ORM Rails applications (thanks to [Robert Ulejczyk](https://github.com/robuye))

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
