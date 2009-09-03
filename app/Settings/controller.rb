require 'rho'
require 'rho/rhocontroller'

class SettingsController < Rho::RhoController
  
  def index
    @msg = @params['msg']
    render
  end

  def login
    @msg = @params['msg']
    render :action => :login
  end

  def do_login
    begin
      SyncEngine::login(@params['login'], @params['password'], (url_for :action => :login_callback) )
      render :action => :authenticating
    rescue RhoError => e
      @msg = e.message
      render :action => :login, :query => {:msg => @msg}
    end
  end
  
  def authenticating
    render :action => :authenticating
  end
  
  def downloading_data
    render :action => :downloading_data
  end
  
  def login_callback
    errCode = @params['error_code'].to_i
    if errCode == 0

      # run sync if we were successful
      # Customer.set_notification("/app/Settings/sync_notify", "doesnotmatter")
      # WebView.navigate(url_for(:action => :downloading_data))
      # SyncEngine::dosync
      WebView.navigate("/app/Customer/index")
    else
      if errCode == Rho::RhoError::ERR_REMOTESERVER
        @msg = @params['error_message']
      else 
        @msg = Rho::RhoError.new(errCode).message
      end
     
      if !@msg || @msg.length == 0
        @msg = "You entered an invalid login/password, please try again."
      end
      
      WebView.navigate(url_for(:action => :login, :query => {:msg => @msg}))
    end  
  end
  
  def logout
    SyncEngine::logout
    @msg = "You have been logged out."
    render :action => :login, :query => {:msg => @msg}
  end
  
  # handles errors and redirects to home on no error
  def sync_notify
    status = @params['status'] ? @params['status'] : ""
    if status == "error"
      errCode = @params['error_code'].to_i
      if errCode == Rho::RhoError::ERR_REMOTESERVER
        @msg = @params['error_message']
      else 
        @msg = Rho::RhoError.new(errCode).message
      end
     
      WebView.navigate(url_for(:action => :server_error, :query => {:msg => @msg}))
    elsif status == "ok"
      if SyncEngine::logged_in > 0
        WebView.navigate "/app/Customer"
      else
        # rhosync has logged us out
        WebView.navigate "/app/Settings/login"      
      end
    end  
  end
  
  def server_error
    render :action => :server_error
  end
  
  def reset
    render :action => :reset
  end
  
  def do_reset
    SyncEngine::trigger_sync_db_reset
    SyncEngine::dosync
    @msg = "Database has been reset."
    redirect :action => :index, :query => {:msg => @msg}
  end
  
  def do_sync
    SyncEngine::dosync
    @msg =  "Sync has been triggered."
    redirect :action => :index, :query => {:msg => @msg}
  end
end
