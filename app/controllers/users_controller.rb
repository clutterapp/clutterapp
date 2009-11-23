class UsersController < ApplicationController
  before_filter :authorize, :except => [:new, :create]
  
  # render new.rhtml
  def new
    # derived from Railscasts #124: Beta Invites <http://railscasts.com/episodes/124-beta-invites>
    @user = User.new(:invite_token => params[:invite_token])
    @user.email = @user.invite.recipient_email if @user.invite
  end
  
  
  def create
    
    @user = User.new(params[:user])
    success = @user && @user.save
    if success && @user.errors.empty?
      # Protects against session fixation attacks, causes request forgery protection if visitor resubmits an earlier form using back button. Uncomment if you understand the tradeoffs.
      # reset session
      self.current_user = @user # !! now logged in
      redirect_back_or_default('/')
      flash[:notice] = "Thanks for signing up! Enjoy organizing your clutter!"
      logger.prefixed 'USER', :light_yellow, "New user '#{@user.login}' created from #{request.remote_ip} at #{Time.now.utc}"
    else
      flash[:error]  = "We couldn't set up that account, sorry. Please try again, or contact an admin."
      render :action => 'new'
    end
  end
  
  
  def show
    @user = User.find_by_login(params[:id])
    
    if !@user.nil?
      @public_piles = @user.piles # @todo: make it actually show only public piles, once they're implemented
      render # show.html.erb
      
    else
      flash[:error]  = %{Couldn't find user by the name of "#{params[:id]}".}
      redirect_to home_path
    end
  end
  
end
