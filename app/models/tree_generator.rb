
class TreeGenerator 

  @id = 0
  def self.parse( json, parent_id = nil, level = 0, nodes = [], links = [], link_label = '', class_label )
  
    node = {}
	@id = @id+1
	node['_id'] = @id 
	node['_label'] = '{...}'
	node['_level'] = level
	node['_fields'] = ""
	links << {child: @id, parent: parent_id, label: link_label } if parent_id
	if json.class == Hash
		json.each do |k,v|
		  if v.class == Hash
			nodes, links = TreeGenerator.parse(v,node['_id'],level+1,nodes,links, k, class_label)
		  elsif v.class == Array
			v.each do |x|
              nodes, links = TreeGenerator.parse(x,node['_id'],level+1,nodes,links, k, class_label)
			end
		  elsif k == class_label
			node['_label'] = v
			node['_fields'] =  class_label + ": " + v.to_s + "<br>" + node['_fields']
		  else
			v_text = v ? v.to_s : "null"
			node['_fields'] <<  k + ": " + v.to_s + "<br>" 
		  end
		end
    else
	  node['_fields'] = json.to_s
	end
    node['_fields'] = "<b>Attributes</b><br>" + node['_fields']
	nodes << node
	return nodes, links
  end
  
end