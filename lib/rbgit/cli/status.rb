
module Rbgit
  class CLI::Status

    def initialize
      @untracked_array = []
      @modified_array  = []
      @deleted_array   = []
      @staged_array    = []
      get_rbgit_path
    end

    def run
      tracked_file_hash = load_tracked_list_hash
      find_untracked_files(tracked_file_hash)
      find_modified_files
      find_deleted_files(tracked_file_hash)
      find_staged_files
      print_status
    end

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

    def find_deleted_files(tracked_file_hash)
      tracked_file_hash.each do |key, value|
        @deleted_array << key unless is_path_file?(key)
      end
    end

    def find_staged_files
      tree_list_hash = load_tree_list_hash
      unless tree_list_hash.empty?
        if tree_list_hash.to_a.last[1] == 0
          tree_key = tree_list_hash.to_a.last[0]
          tree_obj = load_tree(tree_key)
          tree_obj.hash.each do |k, v|
            @staged_array << v
          end
        end
      end
    end

    def print_status
      messages = ["Modified Files:", "Deleted Files:", "Staged Files:", "Untracked Files:"]
      arrays = [@modified_array, @deleted_array, @staged_array, @untracked_array]
      arrays.each_with_index do |arr, index|
        unless arr.empty?
          puts messages[index].cyan
          arr.each do |file|
            puts "      #{file}".red
          end
        end
      end
    end

  end
end
