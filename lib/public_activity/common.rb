module PublicActivity
  # Common methods shared across the gem.
  module Common
    extend ActiveSupport::Concern
    # Directly creates activity record in the database, based on supplied arguments.
    # Only first argument - key - is required.
    #
    # == Usage:
    #
    #   current_user.create_activity("activity.user.avatar_changed") if @user.avatar_file_name_changed?
    #
    # == Parameters:
    # [:key]
    #   Custom key that will be used as a i18n translation key - *required*
    # [:owner]
    #   Polymorphic relation specifying the owner of this activity (for example, a User who performed this task) - *optional*
    # [:params]
    #  Hash with parameters passed directly into i18n.translate method - *optional*
    #
    def create_activity(settings = {})
      self.activities.create(
        :key        => settings[:key],
        :owner      => settings[:owner],
        :recipient  => settings[:recipient],
        :parameters => settings[:parameters]
      )
    end

    # Prepares settings used during creation of Activity record.
    # params passed directly to tracked model have priority over
    # settings specified in tracked() method
    def prepare_settings(action)
      # key
      key = self.activity_key || ("activity." +
            self.class.name.parameterize('_') + "." + action)

      # user responsible for the activity
      owner = self.activity_owner ? self.activity_owner : self.class.activity_owner_global

      case owner
        when Symbol
          owner = __send(owner)
        when Proc
          owner = owner.call(self)
      end

      #customizable parameters
      params = self.class.activity_params_global
      params.merge! self.activity_params if self.activity_params

      params.each do |k, v|
        case v
          when Symbol
            params[k] = __send__(v)
          when Proc
            params[k] = v.call(PublicActivity.get_controller, self)
        end
      end

      {
        :key        => key,
        :owner      => owner,
        :recipient  => self.activity_recipient,
        :parameters => params
      }
    end
  end
end
