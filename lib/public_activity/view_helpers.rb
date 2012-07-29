# Provides a shortcut from views to the rendering method.
module PublicActivity
  module ViewHelpers
    def render_activity activity, options = {}
      activity.render self, options
    end
  end

  ActionView::Base.class_eval { include ViewHelpers }
end
