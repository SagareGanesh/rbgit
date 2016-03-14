
module Rbgit
  class Blob
    attr_reader :size, :name, :data
    def initialize(name, blob_key)
      @name = name
      @size = File.size(name)
      arr = []
      IO.foreach(@name){|line| arr << line }
      @data = arr
      make_dir("#{@@objects}/#{yaml_dir(blob_key)}") unless is_directory?("#{@@objects}/#{yaml_dir(blob_key)}")
      File.new("#{@@objects}/#{yaml_file(blob_key)}","w")
    end
  end
end
