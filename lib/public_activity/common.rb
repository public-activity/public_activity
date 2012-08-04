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
      activity = self.activities.create(
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

      owner = case owner
        when Symbol
          self.try(owner)
        when Proc
          owner.call(self)
        else
          owner
      end

      # recipient
      recipient = self.activity_recipient

      #customizable parameters
      params = self.class.activity_params_global
      params.merge! self.activity_params if self.activity_params

      params.each do |key, value|
        params[key] = case value
          when Symbol
            self.try(value)
          when Proc
            value.call(PublicActivity.get_controller, self)
          else
            value
        end
      end
      return {
        :key        => key,
        :owner      => owner,
        :recipient  => recipient,
        :parameters => params
      }
    end
  end
end
