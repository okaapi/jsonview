class RulesController < ApplicationController

  skip_before_action :verify_authenticity_token  

  def index

	if params[:rulesfile]  
	  @body = params[:rulesfile].read
	elsif params[:body]
	  @body = params[:body]
    else
	  @body = "RuleName1# (A and B)# action1; action2 \r\nRuleName2# (A and (B or C))# action3"
	end
	
	if @body
	  @nodes, @links = RulesGenerator.parse( @body )	  
	else
	  @body = 'enter rules here'
	  @nodes = @links = []
	end
    
  end
  
end
