require "rubygems/text"
include Gem::Text 
# levenshtein_distance('asd', 'sdf') # => 2


class BKTree
  attr_accessor :root

  def initialize
    @root = nil
  end

  def add(name)
    if @root.nil?
      @root = BKNode.new(name)
    else
      @root.add(name)
    end
  end

  def search(name, max_distance)
    return [] if @root.nil?

    results = []
    @root.search(name, max_distance, results)
    results
  end


  class BKNode
    attr_accessor :name, :children, :votes
  
    def initialize(name)
      @name = name
      @children = {}
      @votes = 1
    end

    def add(name)
      add_helper(name, 7)
    end


    def search(name, max_distance, results)
      distance = levenshtein_distance(@name, name)
  
      if distance <= max_distance
        results << @name
      end
  
      (@children.keys.select { |d| (d - distance).abs <= max_distance }).each do |d|
        @children[d].search(name, max_distance, results)
      end
    end

    private

    def add_helper(name, min_distance)
      distance = levenshtein_distance(@name, name)
      if distance == 0
        @votes+=1
      else
        if distance <= 6 and @children[distance].nil?
          @children[distance] = BKNode.new(name)
        else
          @children.each{
            |dist,val|
                    
        }
        end
      end
    end

  end
end

bk_tree = BKTree.new

begin_time = Time.now

File.foreach("data/log1.txt"){
  |line|
  
  name = line[line.index('>')+2...line.length-2]
  
  bk_tree.add(name)
}

puts 0