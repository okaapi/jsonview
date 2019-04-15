
class RulesGenerator 

  @@id = 0
  def self.parse( rules )
  
    nodes = []
	links = []
    
	rules.each_line do |line|

	  line_itself = line.gsub(/\r\n/,'')
	  #puts '@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@'
	  #puts line_itself
	  
	  arr = line_itself.split('#')
	  if arr.size != 3
	    return nodes, links
	  end
	  
	  rule_name = arr[0]
	  rule_if = arr[1]
	  rule_then = arr[2]
	   
	  opnode = {}
	  @@id = @@id+1
	  opnode['_id'] = opnode_id = @@id 
	  opnode['_label'] = 'THEN' 
	  opnode['_level'] = -1
	  opnode['_title'] = rule_name + ' ' + @@id.to_s
	  opnode['_color'] = '#AEC833'
	  nodes << opnode	
	  
	  tokens = self.parse_brackets( rule_if )

	  token = tokens["#0#"]
      nodes, links = self.parse_my_tokens( opnode_id, nodes, links, -2, token[:value], tokens )	  
	  
	  conclusions = rule_then.split(';')
	  conclusions.each do |then_part|
	    node = {}
	    @@id = @@id+1
	    node['_id'] = @@id 
	    node['_label'] = then_part.gsub(/"|'/,'')
	    node['_level'] = 0
	    node['_title'] = then_part.gsub(/"|'/,'') + ' ' + @@id.to_s
		node['_color'] = '#73B9F2'
	    nodes << node
	    link = {child: @@id, parent: opnode_id, label: 'action' }
	    links << link
	  end
	  
	end
	return nodes, links
  end
  
  def self.parse_brackets( original_str )
  
	tokens = {}
	t = 0
	str = original_str.dup
	begin
	
	  changes = false
	  if /^(.*)\(\s*?Exist_In_Tube\s*?\(\s*?(.*?)\s*?\)\s*?\)\s*(.*)$/ =~ str

		t = t+1
		token = '#' + t.to_s + '#'
		tokens[ token ] = { type: :tube_content, value: 'ExistInTube['+$2+']'}
		str = $1 + ' ' + token + ' ' + $3
		changes = true		
	  elsif /^(.*)\(\s*?(.*?)\s*?=\s*?\'(.*?)\'\s*?\)\s*(.*)$/ =~ str

		t = t+1
		token = '#' + t.to_s + '#'
		tokens[ token ] = { type: :equality, value: $2 + '=' + $3 }
		str = $1 + ' ' + token + ' ' + $4
		changes = true		    
      elsif /^(.*)\((.*?)\)(.*)$/ =~ str

		t = t+1
		token = '#' + t.to_s + '#'
		tokens[ token ] = { type: :generic, value: $2}
		str = $1 + ' ' + token + ' ' + $3
		changes = true
	  
	  end
	  
	end until !changes
	
	tokens[ '#0#' ] = { type: :root, value: str }
	
    # puts
    # puts "---the end 1 ---"
	# puts "original_string = " + original_str
	# puts "result string = " + str
	# tokens.each do |k,v|
	  # puts k + "=>" + v.to_s
	# end
	
	# puts
	# puts "--------------------------"
	# puts
	
    begin 
	
	  changes = false
	  additional_tokens = {}
	  tokens.each do |token, payload|
	    if payload[:type] != :equality and payload[:type] != :tube_content
		  arr = payload[:value].split(' ')
		  arrlen = arr.count
		  if arrlen >= 3 and ( arr[1].upcase == 'AND' or arr[1].upcase == 'OR' )

            if arrlen > 3			
			  t = t+1
		      newtoken = '#' + t.to_s + '#'
		      tokens[ token ] = {type: :generic, value: newtoken + ' ' + arr[3..arrlen-1].join(' ') }
			  if arr[1].upcase == 'AND'
		        additional_tokens[ newtoken ] = { type: :and, value: arr[0..2].join(' ') } 
			  else 
			    additional_tokens[ newtoken ] = { type: :or, value: arr[0..2].join(' ') } 
			  end

		      changes = true
			elsif tokens[ token ][:type] != :root
			  if arr[1].upcase == 'AND'
			    tokens[ token ][:type] = :and
			  else
			    tokens[ token ][:type] = :or
			  end		  
			end
		  elsif arrlen >= 2 and arr[0].upcase == 'NOT'
	
            if arrlen > 2			
			  t = t+1
		      newtoken = '#' + t.to_s + '#'
		      tokens[ token ] = {type: :generic, value: newtoken + ' ' + arr[2..arrlen-1].join(' ') }
              additional_tokens[ newtoken ] = { type: :not, value: arr[0..1].join(' ') } 

		      changes = true
			else
              tokens[ token ][:type] = :not	  
			end
		  end			
		end
	  end
	  tokens = tokens.merge( additional_tokens )
	  
	  
	end until !changes
  
    # puts
    # puts "---the end 2 ---"
	# puts "original_string = " + original_str
	# puts "result string = " + str
	# tokens.sort.each do |k,v|
	  # puts k + "=>" + v.to_s
	# end

	# puts
	# puts "--------------------------"
	# puts
	

    str = tokens['#0#'][:value]
    begin 
	
      changes = false
      tokens.each do |token, payload|

	    newstr = str.gsub(/#{token}/,'(' + payload[:value]+')')

		if str != newstr
		  changes = true
		end
		str = newstr

	  end
	  
    end until !changes
	
    # puts
    # puts
    # puts "---the end 3 ---"
	# puts "original_string = " + original_str  
	# puts "result string = " + str
	# tokens.sort.each do |k,v|
	  # puts k + "=>" + v.to_s
	# end
	
	return tokens
	
  end
  
  def self.parse_my_tokens( parent_id, nodes, links, level, parent_token_str, tokens )
  
    
	# puts
	# puts
	# puts "#################################"
	# p parent_token_str
	
	arr = parent_token_str.split(' ')
	if( arr.count == 3 and ( arr[1].upcase == 'AND' or arr[1].upcase == 'OR' ) )
	
	  node = {}
	  @@id = @@id+1
	  node['_id'] = logop_id = @@id 
	  node['_label'] = arr[1].upcase
	  node['_level'] = level
	  node['_title'] = parent_token_str  
	  node['_color'] = '#AEC833'
 
	  
	  nodes << node
	  link = {child: parent_id, parent: @@id, label: 'condition' }
	  links << link

	
	  nodes, links = self.parse_my_tokens( logop_id, nodes, links, level-1, arr[0], tokens )
	  nodes, links = self.parse_my_tokens( logop_id, nodes, links, level-1, arr[2], tokens )
	  
	elsif( arr.count == 2 and  arr[0].upcase == 'NOT' )
	
	  node = {}
	  @@id = @@id+1
	  node['_id'] = logop_id = @@id 
	  node['_label'] = arr[1].upcase
	  node['_level'] = level
	  node['_title'] = parent_token_str  
	  node['_color'] = '#AEC833'
	  
	  
	  nodes << node
	  link = {child: parent_id, parent: @@id, label: 'condition' }
	  links << link
	  
	
	  nodes, links = self.parse_my_tokens( logop_id, nodes, links, level-1, arr[0], tokens )  
	  
    elsif arr.count == 1 and /^(\s*)(#\d*?#)(\s*)$/ =~ parent_token_str
	
	  token = tokens[$2]

      nodes, links = self.parse_my_tokens( parent_id, nodes, links, level, token[:value], tokens )
	  
	else
	
	  node = {}
	  @@id = @@id+1
	  node['_id'] = @@id 
	  node['_label'] = parent_token_str
	  node['_level'] = level
	  node['_title'] = parent_token_str	 
      node['_color'] = '#FEDF45'	  


	  nodes << node
	  link = {child: parent_id, parent: @@id, label: 'condition' }
	  links << link
	  
    end	
		
	return nodes, links
	
  end
end
  

#str = "(A and B and (Exist_In_Tube(I_RPTH))) and ((NOT C AND D) and ( I_RPTH = 'HEMOL' ) or E)" 
##str = "A and (B or C)"
#puts str
#pp RulesGenerator.parse_brackets( str)
