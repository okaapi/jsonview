
class TreeGenerator 

  @id = 0
  def self.parse( json, parent_id = nil, level = 0, nodes = [], links = [], default_label = 'Object', class_label = 'Type' )
  
    node = {}
	@id = @id+1
	node['_id'] = @id 
	node['_type'] = default_label
	node['_level'] = level
	node['_fields'] = "<b>Attributes</b><br>"
	links << {child: @id, parent: parent_id} if parent_id
	if json.class == Hash
		json.each do |k,v|
		  if v.class == Hash
			nodes, links = TreeGenerator.parse(v,node['_id'],level+1,nodes,links, k)
		  elsif v.class == Array
			v.each do |x|
			  #if x.class == Hash
			    nodes, links = TreeGenerator.parse(x,node['_id'],level+1,nodes,links, k)
			  #else
			  #  node['_fields'] <<  k + ": " + x.to_s + "<br>" 
			  #end
			end
		  elsif k == class_label
			node['_type'] = v
		  else
			v_text = v ? v.to_s : "null"
			node['_fields'] <<  k + ": " + v.to_s + "<br>" 
		  end
		end
    else
	  node['_fields'] = json.to_s
	end
	nodes << node
	return nodes, links
  end
  
end