class SessionsController < ApplicationController
  def login
    if session[:user_id]
      redirect_to root_path
    else
      render :login
    end
  end

  def register
    flash.clear
    if session[:user_id]
      redirect_to root_path
    else
      render :register
    end
  end
end
