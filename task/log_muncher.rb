require "rubygems/text"
include Gem::Text 
# levenshtein_distance('asd', 'sdf') # => 2


class BKTree
  attr_accessor :root

  def initialize
    @root = nil
  end

  def add(name, vote = 1)
    if @root.nil?
      @root = BKNode.new(name)
    else
      @root.add(name, vote)
    end
  end

  def search(name, max_distance)
    return [] if @root.nil?

    results = []
    @root.search(name, max_distance, results)
    results
  end

  def analyze(max_distance)
    return {} if @root.nil?

    results = {}
    unique_nodes = Set.new
    @root.analyze(max_distance, results, unique_nodes)
    results
  end

  class BKNode
    attr_accessor :name, :children, :votes
    
  
    def initialize(name, vote = 1)
      @name = name
      @children = {}
      @votes = vote
      @distance_cache = {}
    end

    def levenshtein_distance_cached(other_name)
      return @distance_cache[other_name] if @distance_cache.key?(other_name)
  
      distance = levenshtein_distance(@name, other_name)
      @distance_cache[other_name] = distance
      distance
    end

    def add(name, vote = 1)
      if name == @name
        @votes += vote
        return
      end
      
      distance = levenshtein_distance_cached(name)

      if @children[distance].nil?
        @children[distance] = BKNode.new(name, vote)
      else
        @children[distance].add(name, vote)
      end
    end


    def search(name, max_distance, results)
      distance = levenshtein_distance(@name, name)
  
      if distance <= max_distance
        results << "#{@name} - #{@votes}"
      end
  
      (@children.keys.select { |d| (d - distance).abs <= max_distance }).each do |d|
        @children[d].search(name, max_distance, results)
      end
    end
    
    def analyze(max_distance, results, unique_nodes)
      
      if votes > 0
        #unless unique_nodes.include?(@name) 
          unique_nodes.add(@name)
          results[@name] ||= 0
          results[@name] += @votes
        #end

        # analyze_sibling_nodes(max_distance, results, unique_nodes)

        (@children.keys.select { |d| d <= max_distance }).each do |d|
          child_node = @children[d]
          results[@name] += child_node.votes
          child_node.votes = 0
          child_node.analyze(max_distance, results, unique_nodes) unless unique_nodes.include?(child_node.name)
        end
      end  
      @children.each_value do |child|
        child.analyze(max_distance, results, unique_nodes)
      end
    end

    # def analyze_sibling_nodes(max_distance, results, unique_nodes)
    #   return unless parent

    #   parent.children.each_value do |sibling|
    #     next if sibling.name == @name 

    #     distance = levenshtein_distance_cached(sibling.name)
    #     if distance <= max_distance && !unique_nodes.include?(sibling.name)
    #       unique_nodes.add(sibling.name)
    #       results[sibling.name] ||= 0
    #       results[sibling.name] += sibling.votes
    #     end
    #   end
    # end
  end
end

bk_tree = BKTree.new

begin_time = Time.now

File.foreach("data/log.txt"){
  |line|
  name = line[line.index('>')+2...line.length-2]
  
  bk_tree.add(name)
}

puts "Added in tree in #{Time.now - begin_time} s"
middle_time = Time.now
results = bk_tree.analyze(8)
results = results.sort()

while results.size > 200
  bk_tree = BKTree.new
  sum = 0
  results.each do |name, votes|
    sum += votes
    bk_tree.add(name,votes)
  end
  puts "Sum #{sum}"
  results = bk_tree.analyze(8)
  results = results.sort_by{|key,value|-value}
  puts results.size
end

results = results.sort_by{|key,value|-value}
sum = 0
results.each do |name, votes|
  sum += votes
  puts "#{name} - #{votes}"
end
puts sum
puts  "Second part #{Time.now - middle_time} s"
puts  "Full time #{Time.now - begin_time} s"