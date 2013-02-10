# Changelog

## 1.0 (unreleased)

* **Now supports Mongoid 3 and Active Record.**
* Added indexes for polymorphic column pairs to speed up queries in ActiveRecord 
* #create_activity now returns the newly created Activity object
* Support for custom Activity attributes. Now if you need a custom relation for Activities you can 
  create a migration which adds the desired column, whitelist the attribute, and then you can simply pass the value to #create_activity
* #tracked now accepts a single Symbol for its `:only` and `:except` options.
* It is now possible to include `PublicActivity::Common` in your models if you just want to use #create_activity method
  and skip the default CRUD tracking.


## 0.5.4

* Fixed support for namespaced classes when transforming into view path. 
  
  For example `MyNamespace::CamelCase` now correctly transforms to key: `my_namespace_camel_case.create`
