class MyApplicationSessionsController < Devise::SessionsController
  responders :my_application
  
  def create
    super { |resource| @resource = resource }
  end
end
