
module Rbgit
  class Commit
    attr_reader :name, :tree_key, :commit_key
    def initialize(name,commit_key,tree_key)
      @name = name
      @author = "GaneshSagare <ganesh@joshsoftware.com>"
      @time = Time.new.asctime
      @tree_key = tree_key
      @commit_key = commit_key
      make_dir("#{@@objects}/#{yaml_dir(commit_key)}") unless is_directory?("#{@@objects}/#{yaml_dir(commit_key)}")
      File.new("#{@@objects}/#{yaml_file(commit_key)}","w")
    end

    def display_commit
      puts "commit:  #{@commit_key}".cyan
      puts "Author:  #{@author}".green
      puts "Date  :  #{@time}".green
      puts ""
      puts "     #{@name}".green
      puts ""
    end
  end
end
