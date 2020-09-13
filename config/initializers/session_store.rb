if Rails.env.production?
  Rails.application.config.session_store :active_record_store, :key => '__Host-notifier-session'
else
  Rails.application.config.session_store :active_record_store, :key => 'notifier-session'
end

ActiveRecord::SessionStore::Session.serializer = :json
