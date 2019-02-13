require 'json'

class JviewController < ApplicationController

  skip_before_action :verify_authenticity_token  

  def index

	if params[:jsonfile]  
	  @body = params[:jsonfile].read
	elsif params[:body]
	  @body = params[:body]
    else
	  @body = nil
	end
	
	if @body
	  begin
        @json = JSON.parse(@body)
	  rescue Exception => e
	    @json = {}
	    @error = e.message
	  end
	  @nodes, @links = TreeGenerator.parse( @json, class_label = 'Type' )	  
	else
	  @body = 'enter JSON here'
	  @nodes = @links = []
	end
	
    
  end
  
end
