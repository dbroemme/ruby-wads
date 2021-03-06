require 'date'

module Wads

    SPACER = "  "
    VALUE_WIDTH = 10
    COLOR_TAG = "color"

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

    #
    # A convenience data structure to store multiple, named sets of key/value pairs
    #
    class HashOfHashes 
        attr_accessor :data

        def initialize
            @data = {}
        end

        #
        # Store the value y based on the key x for the named data set
        #
        def set(data_set_name, x, y)
            data_set = @data[data_set_name]
            if data_set.nil? 
                data_set = {}
                @data[data_set_name] = data_set
            end
            data_set[x] = y
        end

        #
        # Retrieve the value for the given key x in the named data set
        #
        def get(data_set_name, x)
            data_set = @data[data_set_name]
            if data_set.nil? 
                return nil
            end
            data_set[x]
        end

        #
        # Get the list of keys for the named data set
        #
        def keys(data_set_name)
            data_set = @data[data_set_name]
            if data_set.nil? 
                return nil
            end
            data_set.keys
        end
    end 

    #
    # Stats allows you to maintain sets of data values, identified by a key,
    # or data set name. You can then use Stats methods to get the count, average,
    # sum, or percentiles for these keys.
    #
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

    #
    # A node in a graph data structure. Nodes can be used independently, and you
    # connect them to other nodes, or you can use an overarching Graph instance
    # to help manage them. Nodes can carry arbitrary metadata in the tags map.
    # The children are either other nodes, or an Edge instance which can be used
    # to add information about the connection. For example, in a map graph use
    # case, the edge may contain information about the distance between the two
    # nodes. In other applications, metadata about the edges, or connections,
    # may not be necessary. This class, and the Graph data structure, support
    # children in either form. Each child connection is a one-directional 
    # connection. The backlinks are stored and managed internally so that we can
    # easily navigate between nodes of the graph. Nodes themselves have a name
    # an an optional value.
    #
    class Node
        attr_accessor :name
        attr_accessor :value
        attr_accessor :backlinks
        attr_accessor :outputs
        attr_accessor :visited
        attr_accessor :tags
        attr_accessor :depth

        def id 
            # id is an alias for name
            @name 
        end 

        def initialize(name, value = nil, tags = {})
            @name = name 
            @value = value
            @backlinks = [] 
            @outputs = []
            @visited = false
            @tags = tags
            @depth = 1
        end 

        def add(name, value = nil, tags = {})
            add_output_node(Node.new(name, value, tags))
        end

        def children 
            @outputs 
        end

        def number_of_links 
            @outputs.size + @backlinks.size
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

        def remove_output(name)
            output_to_delete = nil
            @outputs.each do |output|
                if output.is_a? Edge 
                    output_node = output.destination 
                    if output_node.id == name 
                        output_to_delete = output
                    end 
                elsif output.id == name
                    output_to_delete = output
                end 
            end 
            if output_to_delete
                @outputs.delete(output_to_delete)
            end
        end 

        def remove_backlink(name)
            backlink_to_delete = nil
            @backlinks.each do |backlink|
                if backlink.id == name
                    backlink_to_delete = backlink
                end 
            end 
            if backlink_to_delete
                @backlinks.delete(backlink_to_delete)
            end
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
                    if c.is_a? Edge 
                        c = c.destination 
                    end 
                    node_queue << c
                end
            end
        end

        def bfs(max_depth, &block)
            node_queue = [self]
            @depth = 1
            until node_queue.empty?
                node = node_queue.shift
                yield node
                node.visited = true
                if node.depth < max_depth
                    # Get the set of all outputs and backlinks
                    h = {}
                    node.outputs.each do |n|
                        if n.is_a? Edge 
                            n = n.destination 
                        end 
                        h[n.name] = n 
                    end 
                    node.backlinks.each do |n|
                        h[n.name] = n 
                    end 
        
                    h.values.each do |n|
                        if n.visited 
                            # ignore, don't process again
                        else
                            n.visited = true
                            n.depth = node.depth + 1
                            node_queue << n
                        end
                    end
                end
            end
        end

        def to_display 
            "Node #{@name}: #{value}   inputs: #{@backlinks.size}  outputs: #{@outputs.size}"
        end 
    end

    # 
    # An Edge is a connection between nodes that stores additional information
    # as arbitrary tags, or name/value pairs.
    #
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

    #
    # A Graph helps manage nodes by providing high level methods to 
    # add or connect nodes to the graph. It also maintains a list of
    # nodes and supports having multiple root nodes, i.e. nodes with
    # no incoming connections.
    # This class also supports constructing the graph from data stored
    # in a file.
    #
    class Graph 
        attr_accessor :node_list
        attr_accessor :node_map

        def initialize(root_node = nil)
            @node_list = []
            @node_map = {}
            if root_node 
                if root_node.is_a? Node
                    root_node.visit do |n|
                        add_node(n)
                    end
                elsif root_node.is_a? String 
                    read_graph_from_file(root_node)
                end
            end
        end

        def add(name, value = nil, tags = {}) 
            add_node(Node.new(name, value, tags))
        end 

        def connect(source, destination, tags = {})
            add_edge(source, destination)
        end

        def delete(node) 
            if node.is_a? String 
                node = find_node(node)
            end 
            node.backlinks.each do |backlink| 
                backlink.remove_output(node.name)
            end
            @node_list.delete(node)
            @node_map.delete(node.name)
        end 

        def disconnect(source, target)
            if source.is_a? String 
                source = find_node(source)
            end 
            if target.is_a? String 
                target = find_node(target)
            end 
            source.remove_output(target.name)
            target.remove_backlink(source.name)
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

        def node_with_most_connections 
            max_node = nil
            max = -1
            @node_list.each do |node|
                num_links = node.number_of_links
                if num_links > max 
                    max = num_links 
                    max_node = node
                end
            end 
            max_node
        end 

        def get_number_of_connections_range 
            # Find the min and max
            min = 1000
            max = 0
            @node_list.each do |node|
                num_links = node.number_of_links
                if num_links < min 
                    min = num_links 
                end 
                if num_links > max 
                    max = num_links 
                end
            end 
            
            # Then create the scale
            DataRange.new(min - 0.1, max + 0.1)
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
                node.depth = 0
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

        def leaf_nodes 
            list = []
            @node_list.each do |node|
                if node.outputs.empty? 
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

        def traverse_and_collect_nodes(node, max_depth = 0, current_depth = 1)
            if max_depth > 0
                if current_depth > max_depth 
                    return {}
                end
            end
            map = {}
            if node.visited 
                if current_depth < node.depth 
                    node.depth = current_depth 
                end
                return {} 
            else
                map[node.name] = node
                node.depth = current_depth
                node.visited = true
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
            node.backlinks.each do |child|
                map_from_child = traverse_and_collect_nodes(child, max_depth, current_depth + 1)
                map_from_child.each do |key, value|
                    map[key] = value 
                end
            end 
            map
        end

        def process_tag_string(tags, tag_string) 
            parts = tag_string.partition("=")
            tag_name = parts[0]
            tag_value = parts[2]
            if tag_name == COLOR_TAG
                begin
                    value = eval(tag_value)
                    puts "Adding tag #{tag_name} = #{value}"
                    tags[tag_name] = value 
                rescue => e
                    puts "Ignoring tag #{tag_name} = #{tag_value}"
                end
            else
                puts "Adding tag #{tag_name} = #{tag_value}"
                tags[tag_name] = tag_value 
            end
        end 

        # The format is a csv file as follows:
        # N,name,value            --> nodes
        # C,source,destination    --> connections (also called edges)
        #
        # Optionally, each line type can be followed by comma-separated tag=value
        def read_graph_from_file(filename)
            puts "Read graph data from file #{filename}"
            File.readlines(filename).each do |line|
                line = line.chomp  # remove the carriage return
                values = line.split(",")
                type = values[0]
                tags = {}
                if type == "N" or type == "n"
                    name = values[1]
                    if values.size > 2
                        value = values[2]
                        # The second position can be a tag or the node value
                        if value.include? "="
                            process_tag_string(tags, value)
                            value = nil 
                        end 
                    else 
                        value = nil 
                    end
                    if values.size > 3
                        values[3..-1].each do |tag_string|
                            process_tag_string(tags, tag_string) 
                        end
                    end
                    add(name, value, tags)
                elsif type == "E" or type == "e" or type == "L" or type == "l" or type == "C" or type == "c"
                    source_name = values[1]
                    destination_name = values[2]
                    if values.size > 3
                        values[3..-1].each do |tag_string|
                            process_tag_string(tags, tag_string) 
                        end
                    end
                    connect(source_name, destination_name, tags)
                else 
                    puts "Ignoring line: #{line}"
                end
            end
        end
    end

    #
    # An internally used data structure that facilitates walking from the leaf nodes
    # up to the top of the graph, such that a node is only visited once all of its
    # descendants have been visited.
    #
    class GraphReverseIterator
        attr_accessor :output
        def initialize(graph) 
            @output = []
            graph.root_nodes.each do |root|
                partial_list = process_node(root)
                @output.push(*partial_list)
            end 
        end 
    
        def process_node(node)
            list = []
            node.outputs.each do |child_node|
                if child_node.is_a? Edge 
                    child_node = child_node.destination 
                end
                child_list = process_node(child_node)
                list.push(*child_list)
            end 
    
            list << node
            list
        end    
    end 

    #
    # A single dimension range, going from min to max. 
    # This class has helper methods to create bins within the given range.
    #
    class DataRange 
        attr_accessor :min
        attr_accessor :max
        attr_accessor :range

        def initialize(min, max)
            if min < max
                @min = min 
                @max = max 
            else 
                @min = max 
                @max = min
            end
            @range = @max - @min
        end

        def bin_max_values(number_of_bins)
            bin_size = @range / number_of_bins.to_f 
            bins = []
            bin_start_value = @min
            number_of_bins.times do 
                bin_start_value = bin_start_value + bin_size 
                bins << bin_start_value
            end 
            bins
        end
    end 

    #
    # A two dimensional range used by Plot to determine the visible area
    # which can be a subset of the total data range(s)
    #
    class VisibleRange
        attr_accessor :left_x
        attr_accessor :right_x
        attr_accessor :bottom_y
        attr_accessor :top_y
        attr_accessor :x_range
        attr_accessor :y_range
        attr_accessor :is_time_based

        def initialize(l, r, b, t, is_time_based = false)
            if l < r
                @left_x = l 
                @right_x = r 
            else 
                @left_x = r 
                @right_x = l 
            end
            if b < t
                @bottom_y = b 
                @top_y = t 
            else 
                @bottom_y = t  
                @top_y = b 
            end
            @x_range = @right_x - @left_x
            @y_range = @top_y - @bottom_y
            @is_time_based = is_time_based

            @orig_left_x = @left_x
            @orig_right_x = @right_x
            @orig_bottom_y = @bottom_y
            @orig_top_y = @top_y
            @orig_range_x = @x_range
            @orig_range_y = @y_range
        end

        def plus(other_range)
            l = @left_x < other_range.left_x ? @left_x : other_range.left_x
            r = @right_x > other_range.right_x ? @right_x : other_range.right_x
            b = @bottom_y < other_range.bottom_y ? @bottom_y : other_range.bottom_y
            t = @top_y > other_range.top_y ? @top_y : other_range.top_y
            VisibleRange.new(l, r, b, t, (@is_time_based or other_range.is_time_based))
        end

        def x_ten_percent 
            @x_range.to_f / 10
        end 

        def y_ten_percent 
            @y_range.to_f / 10
        end 

        def scale(zoom_level)
            x_mid_point = @orig_left_x + (@orig_range_x.to_f / 2)
            x_extension = (@orig_range_x.to_f * zoom_level) / 2
            @left_x = x_mid_point - x_extension
            @right_x = x_mid_point + x_extension

            y_mid_point = @orig_bottom_y + (@orig_range_y.to_f / 2)
            y_extension = (@orig_range_y.to_f * zoom_level) / 2
            @bottom_y = y_mid_point - y_extension
            @top_y = y_mid_point + y_extension

            @x_range = @right_x - @left_x
            @y_range = @top_y - @bottom_y
        end 

        def scroll_up 
            @bottom_y = @bottom_y + y_ten_percent
            @top_y = @top_y + y_ten_percent
            @y_range = @top_y - @bottom_y
        end

        def scroll_down
            @bottom_y = @bottom_y - y_ten_percent
            @top_y = @top_y - y_ten_percent
            @y_range = @top_y - @bottom_y
        end

        def scroll_right
            @left_x = @left_x + x_ten_percent
            @right_x = @right_x + x_ten_percent
            @x_range = @right_x - @left_x
        end

        def scroll_left
            @left_x = @left_x - x_ten_percent
            @right_x = @right_x - x_ten_percent
            @x_range = @right_x - @left_x
        end

        def grid_line_x_values
            if @cached_grid_line_x_values
                return @cached_grid_line_x_values 
            end
            @cached_grid_line_x_values = divide_range_into_values(@x_range, @left_x, @right_x, false)
            @cached_grid_line_x_values
        end

        def grid_line_y_values
            if @cached_grid_line_y_values
                return @cached_grid_line_y_values 
            end
            @cached_grid_line_y_values = divide_range_into_values(@y_range, @bottom_y, @top_y, false)
            @cached_grid_line_y_values
        end

        def calc_x_values
            if @cached_calc_x_values
                return @cached_calc_x_values 
            end
            @cached_calc_x_values = divide_range_into_values(@x_range, @left_x, @right_x)
            #puts "The x_axis value to calculate are: #{@cached_calc_x_values}"
            @cached_calc_x_values
        end

        def clear_cache
            @cached_grid_line_x_values = nil
            @cached_grid_line_y_values = nil
            @cached_calc_x_values = nil
        end

        # This method determines what are equidistant points along
        # the x-axis that we can use to draw gridlines and calculate
        # derived values from functions
        def divide_range_into_values(range_size, start_value, end_value, is_derived_values = true)
            values = []
            # How big is x-range? What should the step size be?
            # Generally we want a hundred display points. Let's start there.
            if range_size < 1.1
                step_size = is_derived_values ? 0.01 : 0.1
            elsif range_size < 11
                step_size = is_derived_values ? 0.1 : 1
            elsif range_size < 111
                step_size = is_derived_values ? 1 : 10
            elsif range_size < 1111
                step_size = is_derived_values ? 10 : 100
            elsif range_size < 11111
                step_size = is_derived_values ? 100 : 1000
            elsif range_size < 111111
                step_size = is_derived_values ? 1000 : 10000
            else 
                step_size = is_derived_values ? 10000 : 100000
            end
            grid_x = start_value
            while grid_x < end_value
                values << grid_x
                grid_x = grid_x + step_size
            end
            values
        end
    end

end
