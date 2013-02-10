# Changelog

## 1.0 (unreleased)

* Now supports for Mongoid 3.
* Added indexes for polymorphic column pairs to speed up queries in ActiveRecord (1a676856a15a26a4ca206fa7f685a8ff9c70db00)
* #create_activity now returns the newly created Activity object (ca52851e9bce269934278a6ac2a198c2fe03d125)
* Support for custom Activity attributes. Now if you need a custom relation for Activities you can 
  create a migration which adds the desired column, whitelist the attribute, and then you can simply pass the value to #create_activity (44d482e522b4a3a99e8a28ad2cd7f2421ac30b6c)
* #tracked now accepts a single Symbol for its `:only` and `:except` options. (fd69109bf0d29f0bc686345498ff829698046bbf)
* It is now possible to include `PublicActivity::Common` in your models if you just want to use #create_activity method
  and skip the default CRUD tracking. (eb18e0c148631869635b731819b961d1872050d0)
