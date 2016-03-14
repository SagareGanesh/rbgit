
module Rbgit
  class CLI::Add

    def initialize(arr)
      @arr = arr
      @working_path = get_rbgit_path
    end

    def run
      if @arr.length == 1 && @arr[0] == "."
        @untracked_array = []
        @modified_array = []
        tracked_file_hash = load_tracked_list_hash
        find_untracked_files(tracked_file_hash)
        find_modified_files
        @arr = @untracked_array + @modified_array
      end

      @arr.each do |path|
        if is_path_file?(path)
          @path = @working_path + path
          @tree_present = false
          @blob_present = false
          process_path
        else
          puts "#{path} does not exist".red
          exit 1
        end
      end
      print_status
    end

    def process_path
      @tree = initialize_tree
      check_is_file_already_staged? if @tree_present
      blob_key = generate_key(read_file(@path))
      create_blob(blob_key)
      update_tree(blob_key, @tree.name)
      update_tracked_list_file unless @blob_present
    end

    def check_is_file_already_staged?
      if is_file_staged?
        @blob_preset = true
        delete_blob(@tree.hash.key(@path))
        @tree.remove_from_hash(@path)
      end
    end

    def is_file_staged?
      if @tree.hash.has_value?(@path)
        return true
      end
      return false
    end

    def initialize_tree
      tree_list_hash = load_tree_list_hash
      if tree_list_hash.empty? || tree_list_hash.to_a.last[1] == 1
        tree = create_tree
      else
        tree_key = tree_list_hash.to_a.last[0]
        @tree_present = true
        tree = load_tree(tree_key)
      end
    end

    def create_tree
      tree_key = generate_key(Time.new.asctime)
      tree = Rbgit::Tree.new(tree_key)
      tree_file = open_tree_file(tree_key)
      tree_file.puts dump_yaml(tree)
      tree_file.close
      update_tree_list_file(tree_key)
      tree
    end


    def update_tree_list_file(tree_key)
      tree_list_hash = load_tree_list_hash
      file = open_tree_list_file
      tree_list_hash[tree_key] = 0
      file.puts dump_yaml(tree_list_hash)
      file.close
    end

    def create_blob(blob_key)
      blob = Rbgit::Blob.new(@path, blob_key)
      file = open_blob_file(blob_key)
      file.puts dump_yaml(blob)
      file.close
    end

    def update_tree(blob_key, tree_key)
      @tree.add_to_hash(blob_key, @path)
      tree_file = open_tree_file(tree_key)
      tree_file.puts dump_yaml(@tree)
      tree_file.close
    end

    def update_tracked_list_file
      tracked_list_hash = load_tracked_list_hash
      unless tracked_list_hash[@path].nil?
        tracked_list_hash[@path] = tracked_list_hash[@path] + 1
      else
        tracked_list_hash[@path] = 1
      end
      tracked_list_file = open_tracked_list_file
      tracked_list_file.puts dump_yaml(tracked_list_hash)
      tracked_list_file.close
    end

    def print_status
      require 'rbgit/cli/status'
      Rbgit::CLI::Status.new.run
    end

    #--------------------- rbgit add . ----------------------------------#

    def find_untracked_files(tracked_file_hash)
      Dir.glob("**/*") do |file|
        unless is_directory?(file)
          @untracked_array << file unless tracked_file_hash[file]
        end
      end
    end

    def find_modified_files
      Dir.glob("**/*") do |file|
        unless @untracked_array.include?(file) || is_directory?(file)
          key = generate_key(read_file(file))
          unless is_key_file?(key)
            @modified_array << file 
          end
        end
      end
    end

    #-------------------------------------------------------------------#

  end
end
