module PublicActivity
  # The ActiveRecord model containing
  # details about recorded activity.
  class Activity < ActiveRecord::Base
    # Define polymorphic association to the parent
    belongs_to :trackable, :polymorphic => true
    # Define ownership to a resource responsible for this activity
    belongs_to :owner, :polymorphic => true
    # Serialize parameters Hash
    serialize :parameters, Hash

    class_attribute :template

    attr_accessible :key, :owner, :parameters
    # Virtual attribute returning text description of the activity
    # using basic ERB templating
    #
    # == Example:
    #
    # Let's say you want to show article's title inside Activity message.
    #
    #   #config/pba.yml
    #   activity:
    #     article:
    #       create: "New <%= trackable.name %> article has been created"
    #       update: 'Someone modified the article'
    #       destroy: 'Someone deleted the article!'
    #
    # And in controller:
    #
    #   def create
    #     @article = Article.new
    #     @article.title = "Rails 3.0.5 released!"
    #     @article.activity_params = {:title => @article.title}
    #     @article.save
    #   end
    #
    # Now when you list articles, you should see:
    #   @article.activities.last.text #=> "Someone has created an article 'Rails 3.0.5 released!'"
    # @see #render Advanced rendering
    def text(params = {})
      I18n.t(key, parameters.merge(params) || {})
    end

    # Renders activity from views.
    #
    # @param [ActionView::Base] context
    # @return [nil] nil
    #
    # Renders activity to the given ActionView context with included
    # AV::Helpers::RenderingHelper (most commonly just ActionView::Base)
    #
    # The *preferred* *way* of rendering activities is
    # to provide a template specifying how the rendering should be happening.
    # However, one may choose using _I18n_ based approach when developing
    # an application that supports plenty of languages.
    #
    # If partial view exists that matches the *key* attribute
    # renders that partial with local variables set to contain both
    # Activity and activity_parameters (hash with indifferent access)
    #
    # Otherwise, it outputs the I18n translation to the context
    # @example Render a list of all activities from a view (erb)
    #   <ul>
    #     <% for activity in PublicActivity::Activity.all %>
    #      <li><%= render_activity(activity) %></li>
    #     <% end %>
    #   </ul>
    #
    # = Creating a template
    # To use templates for formatting how the activity should render,
    # create a template based on activity key, for example:
    #
    # Given a key _activity.article.create_, create directory tree
    # _app/views/public_activity/article/_ and create the _create_ partial there
    #
    # Note that if a key consists of more than three parts splitted by commas, your
    # directory structure will have to be deeper, for example:
    #   activity.article.comments.destroy => /app/views/public_activity/articles/comments/_destroy.html.erb
    #
    # == Variables in templates
    # From within a template there are two variables at your disposal:
    # * activity (aliased to *a* for a shortcut)
    # * params   (aliased to *p*) [hash with indifferent access]
    #
    # @example Template for key: _activity.article.create_ (erb)
    #   <p>
    #     Article <strong><%= p[:name] %></strong>
    #     was written by <em><%= p["author"] %></em>
    #     <%= distance_of_time_in_words_to_now(a.created_at) %>
    #   </p>
    def render(context, params = {})
      begin
        params_indifferent = self.parameters.with_indifferent_access
        params_indifferent.merge!(params)
        context.render :partial => self.template_path(self.key), :locals =>
          {:a => self, :activity => self,
           :current_user => PublicActivity.get_controller.try(:current_user),
           :p => params_indifferent, :params => params_indifferent}
      rescue ActionView::MissingTemplate
        context.render :text => self.text(params)
      end
    end

    protected
    # Builds the path to template based on activity key
    # TODO: verify that attribute `key` is splitted by commas
    #       and that the word before first comma is equal to
    #       "activity"
    def template_path(key)
      path = key.split(".")
      path[0] = "public_activity"
      return path.join("/")
    end
  end
end
