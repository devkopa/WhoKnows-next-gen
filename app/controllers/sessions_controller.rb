class SessionsController < ApplicationController
  def login
    render "login"
  end

  def register
    render "register"
  end
end