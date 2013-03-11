class NotificationsController < ApplicationController
  def index
    @notifications = Notification.all
  end

  def show
    @notification = Notification.find(params[:id])
  end

  def new
    @notification = Notification.new
  end

  def edit
    @notification = Notification.find(params[:id])
  end

  def create
    @notification = Notification.new(params[:notification])

    if @notification.save
      $redis.publish('notifications.create', @notification.to_json)
      redirect_to @notification, notice: 'Notification was successfully created.'
    else
      render action: "new"
    end
  end

  def update
    @notification = Notification.find(params[:id])

    if @notification.update_attributes(params[:notification])
      redirect_to @notification, notice: 'Notification was successfully updated.'
    else
      render action: "edit"
    end
  end

  def destroy
    @notification = Notification.find(params[:id])
    @notification.destroy

    redirect_to notifications_url
  end
end
