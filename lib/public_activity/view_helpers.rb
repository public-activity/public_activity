# Provides a shortcut from views to the rendering method.
module PublicActivity
  # Module extending ActionView::Base and adding `render_activity` helper.
  module ViewHelpers
    # View helper for rendering an activity, calls {PublicActivity::Activity#render} internally.
    def render_activity activity, options = {}
      activity.render self, options
    end
  end

  ActionView::Base.class_eval { include ViewHelpers }
end
