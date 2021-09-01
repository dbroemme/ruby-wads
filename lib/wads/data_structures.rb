require 'date'

module Wads

    SPACER = "  "
    VALUE_WIDTH = 10

    DEG_0 = 0
    DEG_45 = Math::PI * 0.25
    DEG_90 = Math::PI * 0.5
    DEG_135 = Math::PI * 0.75
    DEG_180 = Math::PI 
    DEG_225 = Math::PI * 1.25
    DEG_270 = Math::PI * 1.5
    DEG_315 = Math::PI * 1.75
    DEG_360 = Math::PI * 2

    DEG_22_5 = Math::PI * 0.125
    DEG_67_5 = DEG_45 + DEG_22_5
    DEG_112_5 = DEG_90 + DEG_22_5
    DEG_157_5 = DEG_135 + DEG_22_5
    DEG_202_5 = DEG_180 + DEG_22_5
    DEG_247_5 = DEG_225 + DEG_22_5
    DEG_292_5 = DEG_270 + DEG_22_5
    DEG_337_5 = DEG_315 + DEG_22_5

    class HashOfHashes 
        attr_accessor :data

        def initialize
            @data = {}
        end

        def set(data_set_name, x, y)
            data_set = @data[x]
            if data_set.nil? 
                data_set = {}
                @data[x] = data_set
            end
            data_set[x] = y
        end

        def get(data_set_name, x)
            data_set = @data[x]
            if data_set.nil? 
                return nil
            end
            data_set[x]
        end
    end 

    class Stats
        attr_accessor :name
        attr_accessor :data

        def initialize(name)
            @name = name
            @data = {}
        end
        
        def add(key, value)
            data_set = @data[key]
            if data_set
                data_set << value
            else
                data_set = []
                data_set << value
                @data[key] = data_set
            end     
        end
        
        def increment(key)
            add(key, 1)
        end
        
        def count(key)
            data_set = @data[key]
            if data_set
                return data_set.size
            else
                return 0
            end
        end

        def sum(key)
            data_set = @data[key]
            if data_set
                return data_set.inject(0.to_f){|sum,x| sum + x }
            else
                return 0
            end
        end
        
        def average(key)
            data_set = @data[key]
            if data_set
                return (sum(key) / count(key)).round(5)
            else
                return 0
            end
        end
        
        def min(key)
            data_set = @data[key]
            if data_set
                return data_set.min
            else
                return 0
            end
        end

        def max(key)
            data_set = @data[key]
            if data_set
                return data_set.max
            else
                return 0
            end
        end

        def sample_variance(key)
            data_set = @data[key]
            return 0 unless data_set
            m = average(key)
            s = data_set.inject(0.0){|accum, i| accum +(i-m)**2 }
            s/(data_set.length - 1).to_f
        end

        def std_dev(key)
            Math.sqrt(sample_variance(key))
        end

        def halfway(b, e)
            d = e - b
            m = b + (d / 2).to_i
            m
        end 

        def percentile(key, pct)
            data_set = @data[key]
            if data_set
                sorted_data_set = data_set.sort
                pct_index = (data_set.length - 1).to_f * pct
                mod = pct_index.modulo(1.0)
                adj = pct_index
                if mod > 0.9
                    adj = pct_index.ceil
                elsif mod < 0.1
                    adj = pct_index.floor
                else
                    # We want halfway between the two indices
                    low = pct_index.floor
                    high = pct_index.ceil
                    if low < 0
                        low = 0
                    end
                    if high > data_set.size - 1
                        high = data_set.size - 1
                    end
                    result = halfway(sorted_data_set[low], sorted_data_set[high])
                    return result
                end
                
                if adj < 0
                    adj = 0
                elsif adj > data_set.size - 1
                    adj = data_set.size - 1
                end
                result = sorted_data_set[adj]
                return result
            else
                return 0
            end
        end

        def most_common(key)
            value_counts = {}
            data_set = @data[key]
            data_set.each do |data|
                c = value_counts[data]
                if c.nil?
                    value_counts[data] = 1
                else
                    value_counts[data] = value_counts[data] + 1
                end
            end
            
            largest_count = 0
            largest_key = "none"
            value_counts.keys.each do |key|
                key_count = value_counts[key]
                if key_count > largest_count
                    largest_count = key_count
                    largest_key = key
                end
            end
            largest_key
        end

        def pad(str, size, left_align = false)
            str = str.to_s
            if left_align
                str[0, size].ljust(size, ' ')
            else
                str[0, size].rjust(size, ' ')
            end
        end        

        def display_counts
            puts "#{pad(@name, 20)}   Value"
            puts "#{'-' * 20}   #{'-' * 10}"
            @data.keys.each do |key|
                #data_set = @data[key]
                puts "#{pad(key, 20)}   #{count(key)}"
            end
        end
        
        def keys 
            @data.keys 
        end 

        def report(report_keys = keys)
            puts "#{pad(@name, 10)}#{SPACER}#{pad('Count', 7)}#{SPACER}#{pad('Min', VALUE_WIDTH)}#{SPACER}#{pad('Avg', VALUE_WIDTH)}#{SPACER}#{pad('StdDev', VALUE_WIDTH)}#{SPACER}#{pad('Max', VALUE_WIDTH)}#{SPACER}| #{pad('p1', VALUE_WIDTH)}#{SPACER}#{pad('p10', VALUE_WIDTH)}#{SPACER}#{pad('p50', VALUE_WIDTH)}#{SPACER}#{pad('p90', VALUE_WIDTH)}#{SPACER}#{pad('p99', VALUE_WIDTH)}"
            puts "#{'-' * 10}#{SPACER}#{'-' * 7}#{SPACER}#{'-' * VALUE_WIDTH}#{SPACER}#{'-' * VALUE_WIDTH}#{SPACER}#{'-' * VALUE_WIDTH}#{SPACER}#{'-' * VALUE_WIDTH}#{SPACER}| #{'-' * VALUE_WIDTH}#{SPACER}#{'-' * VALUE_WIDTH}#{SPACER}#{'-' * VALUE_WIDTH}#{SPACER}#{'-' * VALUE_WIDTH}#{SPACER}#{'-' * VALUE_WIDTH}"
            if report_keys.nil?
                report_keys = @data.keys
            end
            report_keys.each do |key|
                data_set = @data[key]
                m1 = min(key).round(5)
                a = average(key).round(5)
                sd = std_dev(key).round(5)
                m2 = max(key).round(5)
                p1 = percentile(key, 0.01).round(5)
                p10 = percentile(key, 0.1).round(5)
                p50 = percentile(key, 0.5).round(5)
                p90 = percentile(key, 0.90).round(5)
                p99 = percentile(key, 0.99).round(5)
                puts "#{pad(key, 10)}#{SPACER}#{pad(count(key), 7)}#{SPACER}#{pad(m1, VALUE_WIDTH)}#{SPACER}#{pad(a, VALUE_WIDTH)}#{SPACER}#{pad(sd, VALUE_WIDTH)}#{SPACER}#{pad(m2, VALUE_WIDTH)}#{SPACER}| #{pad(p1, VALUE_WIDTH)}#{SPACER}#{pad(p10, VALUE_WIDTH)}#{SPACER}#{pad(p50, VALUE_WIDTH)}#{SPACER}#{pad(p90, VALUE_WIDTH)}#{SPACER}#{pad(p99, VALUE_WIDTH)}"
            end
            
        end
    end

    class Node
        attr_accessor :name
        attr_accessor :value
        attr_accessor :backlinks
        attr_accessor :outputs
        attr_accessor :visited
        attr_accessor :tags

        def initialize(name, value = nil, tags = {})
            @name = name 
            @value = value
            @backlinks = [] 
            @outputs = []
            @visited = false
            @tags = tags
        end 
        
        def add_child(name, value)
            add_output(name, value)
        end 

        def add_output(name, value)
            child_node = Node.new(name, value)
            add_output_node(child_node) 
        end

        def add_output_node(child_node)
            child_node.backlinks << self
            @outputs << child_node
            child_node
        end

        def add_output_edge(destination, tags = {})
            edge = Edge.new(destination, tags)
            destination.backlinks << self
            @outputs << edge
            edge
        end

        def add_tag(key, value)
            @tags[key] = value 
        end

        def get_tag(key) 
            @tags[key] 
        end

        def find_node(search_name)
            if @name == search_name
                return self
            end
            found_node_in_child = nil
    
            @outputs.each do |child|
                if child.is_a? Edge 
                    child = child.destination 
                end
                found_node_in_child = child.find_node(search_name)
                if found_node_in_child
                    return found_node_in_child
                end 
            end
            nil
        end
    
        def visit(&block)
            node_queue = [self]
            until node_queue.empty?
                node = node_queue.shift
                yield node
                node.outputs.each do |c|
                    if child.is_a? Edge 
                        child = child.destination 
                    end 
                    node_queue << c
                end
            end
        end

        def to_display 
            "#{@name}: #{value}   inputs: #{@backlinks.size}  outputs: #{@outputs.size}"
        end 

        def full_display 
            puts to_display
            @backlinks.each do |i|
                puts "Input:  #{i.name}"
            end
            #@outputs.each do |o|
            #    puts "Output: #{o.name}"
            #end
        end 
    end

    class Edge
        attr_accessor :destination
        attr_accessor :tags

        def initialize(destination, tags = {})
            @destination = destination
            @tags = tags
        end 

        def add_tag(key, value)
            @tags[key] = value 
        end

        def get_tag(key) 
            @tags[key] 
        end
    end 

    class Graph 
        attr_accessor :node_list
        attr_accessor :node_map

        def initialize 
            @node_list = []
            @node_map = {}
        end

        def add_node(node) 
            @node_list << node 
            @node_map[node.name] = node 
        end 

        def add_edge(source, target, tags = {})
            if source.is_a? String 
                source = find_node(source)
            end 
            if target.is_a? String 
                target = find_node(target)
            end 
            source.add_output_edge(target, tags)
        end

        def find_node(name) 
            @node_map[name]
        end 

        def node_by_index(index) 
            @node_list[index] 
        end 

        def reset_visited 
            @node_list.each do |node|
                node.visited = false 
            end 
        end

        def root_nodes 
            list = []
            @node_list.each do |node|
                if node.backlinks.empty? 
                    list << node 
                end  
            end 
            list 
        end 

        def is_cycle(node)
            reset_visited
            node.visit do |n|
                if n.visited 
                    return true
                else 
                    n.visited = true
                end
            end
            false
        end

        def traverse_and_collect_nodes(node, max_depth, current_depth = 1)
            if max_depth > 0
                if current_depth > max_depth 
                    return {}
                end
            end
            map = {}
            if node.visited 
                return {} 
            else
                map[node.name] = node
                node.visited = true
            end
            node.backlinks.each do |child|
                map_from_child = traverse_and_collect_nodes(child, max_depth, current_depth + 1)
                map_from_child.each do |key, value|
                    map[key] = value 
                end
            end 
            node.outputs.each do |child|
                if child.is_a? Edge 
                    child = child.destination 
                end
                map_from_child = traverse_and_collect_nodes(child, max_depth, current_depth + 1)
                map_from_child.each do |key, value|
                    map[key] = value 
                end
            end 
            map
        end
    end
end
