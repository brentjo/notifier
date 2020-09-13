class NotificationsController < ApplicationController

  before_action :require_authenticated_user, :except => [:send_notification]

  # send_notification does not make use of session-based authentication and is authorized solely
  # by the token in the URL, so it's fine to opt out of CSRF protections
  skip_before_action :verify_authenticity_token, only: [:send_notification]

  MAJOR_CARRIERS = {  'verizon'       => '@vtext.com',
                      'att'           => '@txt.att.net',
                      'tmobile'       => '@tmomail.net',
                      'sprintpcs'     => '@messaging.sprintpcs.com',
                      'virginmobile'  => '@vmobl.com',
                      'alltel'        => '@message.alltel.com',
                      'cingular'      => '@cingularme.com',
                      'nextel'        => '@messaging.nextel.com',
                      'unicel'        => '@utext.com',
                      'uscellular'    => '@email.uscc.net'
                    }

  def new
    render 'notifications/new'
  end


  def create
    unless email = fetch_email_from_params
      flash[:error] = "There was an error creating the notification."
      render 'notifications/new' and return
    end

    notification = current_user.notifications.build(email: email, default_message: params[:default_message])
    if notification.save
      flash[:success] = "Successfully created notification."
      redirect_to '/notifications'
    else
      flash[:error] = "#{notification.errors.full_messages.to_sentence}"
      redirect_to '/notifications/new'
    end
  end

  def show
    render 'notifications/show'
  end

  def destroy
    notification = current_user.notifications.find_by(id: params[:notification_id])
    if notification && notification.destroy
      flash[:success] = "Successfully deleted notification."
      redirect_to '/notifications'
    else
      flash[:error] = "There was an error deleting the notification."
      redirect_to '/notifications'
    end
  end

  def send_notification
    notification = Notification.find_by(token: params[:token])
    if notification
      if notification.send_notification(params[:message])
        render plain: "\nNotification sent."
      else
        render plain: 'Rate limit exceeded', status: 429
      end
    else
      render plain: "Notification not found.", status: 404
    end
  end

  def send_test_notification
    notification = current_user.notifications.find_by(id: params[:notification_id])

    unless notification
      flash[:error] = "There was an error sending the test message."
      redirect_to '/notifications'
      return
    end

    if notification.send_notification("Test message from https://notifierapi.herokuapp.com")
      flash[:success] = "Message to #{notification.email} sent."
      redirect_to '/notifications'
    else
      render plain: 'Rate limit exceeded', status: 429
    end
  end

  private

  def fetch_email_from_params
    if params[:carrier].present? && params[:phone_number].present?
      if MAJOR_CARRIERS.key?(params[:carrier]) && params[:phone_number] =~ /\A\d{10}\z/
        return params[:phone_number] + MAJOR_CARRIERS[params[:carrier]]
      end
    elsif params[:email].present?
      return params[:email]
    end
  end

end
