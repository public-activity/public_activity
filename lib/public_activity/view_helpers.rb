# Provides a shortcut from views to the rendering method.
ActionView::Base.class_eval do
  def render_activity activity
    activity.render self
  end
end
