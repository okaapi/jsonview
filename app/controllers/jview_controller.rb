require 'json'

class JviewController < ApplicationController

  skip_before_action :verify_authenticity_token  

  def index
    @body = params[:body] || 'enter json here'

    @json = JSON.parse(@body)
    
  end
  
end
