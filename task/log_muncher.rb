require "rubygems/text"
include Gem::Text 
# levenshtein_distance('asd', 'sdf') # => 2

h = {}

begin_time = Time.now
n = 0
File.foreach("data/log.txt"){
  |line|
  if n == 1000
    break
  end
  n+=1
  name = line[line.index('>')+1...line.length-1]
  flag = false
  h.each{
    |key,value|
    if levenshtein_distance(key, name) <= 6
            h[key]+=1
            # if flag
            #   print("duplicate #{key}  - #{name} \n")
            # end
            flag = true
            break
    end
  }
  if !flag
        h[name] = 1
  end
  
}

puts "Time: ", Time.now - begin_time
# sum = 0
h.each{
  |key, val|
  # sum+=val
  print (key + ' ' + val.to_s + "\n")
}

# puts sum