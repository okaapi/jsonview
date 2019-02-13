require 'json'

class JviewController < ApplicationController

  skip_before_action :verify_authenticity_token  

  def index

	if @body = params[:body]
	  begin
        @json = JSON.parse(@body)
	  rescue Exception => e
	    @json = {}
	    @error = e.message
	  end
	  @nodes, @links = TreeGenerator.parse( @json )	 	 	  
	else
	  @body = params[:body]
	  @nodes = @links = []
	end
	
    
  end
  
end
