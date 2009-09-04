require 'rho/rhocontroller'
require 'rho/rhocontact'
require 'rho/rhosupport'

class CustomerController < Rho::RhoController

  Page_size=10
  
  #GET /Customer
  def index
    @customers = Customer.find(:all)
    render
  end
  
  def query_to_s(query)
    return '' if query.nil?
    qstring = '?'
    query.each do |key,value|
      qstring += '&' if qstring.length > 1
      qstring += Rho::RhoSupport.url_encode(key.to_s) + '=' + Rho::RhoSupport.url_encode(value.to_s)
    end
    qstring
  end
  
  def search
    page=1
    Customer.search(
      :from => 'search',
      :search_params => { :first => @params['query'] },
      :offset => page*Page_size,
      :max_results => Page_size,
      :callback => '/app/Customer/search_callback',:callback_param => query_to_s(:search_params => @params['query'], :page => page)
      )
  end
  
  def search_callback
    status = @params['status']
    if (status && status == 'ok')
      WebView.navigate ( url_for :action => :show_page, :query => {:query => @params['?search_params'], :page => @params['page']} )
    end
    #TODO: show error page if status == 'error'
    render :action => :ok
  end
  
  def ok
    render :action => :ok
  end
  
  def show_page
    @customers = Customer.find(:all,
      :conditions => { :first => @params['query'] } )    
    render :action => :index
  end

  # GET /Customer/{1}
  def show
    @customer = Customer.find(@params['id'])
    render :action => :show
  end

  # GET /Customer/new
  def new
    @customer = Customer.new
    render :action => :new
  end

  # GET /Customer/{1}/edit
  def edit
    @customer = Customer.find(@params['id'])
    render :action => :edit
  end

  # POST /Customer/create
  def create
    @customer = Customer.new(@params['customer'])
    @customer.save
    redirect :action => :index
  end

  # POST /Customer/{1}/update
  def update
    @customer = Customer.find(@params['id'])
    if @params['button']=='Update'
      @customer.update_attributes(@params['customer'])
    else
      Rho::RhoContact.create!(@params['customer'])
    end
    redirect :action => :index
  end

  # POST /Customer/{1}/delete
  def delete
    @customer = Customer.find(@params['id'])
    @customer.destroy
    redirect :action => :index
  end
end
 
