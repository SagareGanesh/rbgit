
module Rbgit
  class Tree
    attr_reader :name, :hash
    def initialize(key)
      @name = key
      @hash = {}
      make_dir("#{@@objects}/#{yaml_dir(key)}") unless is_directory?("#{@@objects}/#{yaml_dir(key)}")
      File.new("#{@@objects}/#{yaml_file(key)}","w")
    end

    def add_to_hash(key,name)
      @hash[key] = name
    end

    def remove_from_hash(name)
      @hash.delete_if{ |_, v| v == name }
    end

  end
end
