module SessionsHelper

  # Logs in the given user.
  def login(user)
    session[:user_id] = user.id
  end
  
  #Returns the user corresponding to your session cookie
  def current_user
    if (user_id = session[:user_id])
      @current_user ||= User.find_by(id: user_id)
    elsif (user_id = cookies.signed[:user_id])
      user = User.find_by(id: user_id)
      if user && user.authenticated?(cookies[:remember_token])
        login user 
        @current_user = user
      end
    end
  end
  
  # Is a given user the current user?
  def current_user?(user)
    user == current_user
  end
  # Stores permament session for the given user
  def remember(user)
    user.remember
    cookies.permanent.signed[:user_id] = user.id
    cookies.permanent[:remember_token] = user.remember_token
  end
  

  def logged_in?
    !current_user.nil?
  end
  
   # Forgets a persistent session
  def forget(user)
    user.forget
    cookies.delete(:user_id)
    cookies.delete(:remember_token)
  end
  
  def logout
    forget(current_user)
    session.delete(:user_id)
    @current_user = nil
  end
  
  # Redirects back to an original url, fallback on the given default
  def redirect_back(default = root_url)
    redirect_to(session[:forwarding_url] || default)
    session.delete(:forwarding_url)
  end
  
  # Stores the original URL.
  def store_url
    session[:forwarding_url] = request.original_url if request.get?
  end
end