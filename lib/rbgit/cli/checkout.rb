
module Rbgit
  class CLI::Checkout
    def initialize(arr)
      @arr = arr
      @working_path = get_rbgit_path
    end

    def run
      @arr.each do |path|
        if is_path_file?(path)
          @path = @working_path + path
          process_path
        else
          puts "#{path} does not exist".red
          exit 1
        end
      end
      #print_status
    end

    def process_path
      if is_file_staged?
        checkout_file
      elsif is_file_commited?
        checkout_file
      end
    end

    def is_file_staged?
      tree_list_hash = load_tree_list_hash
      unless tree_list_hash.empty?
        last_tree_entry = tree_list_hash.to_a.last
        if last_tree_entry[1] == 0
          last_tree = load_tree(last_tree_entry[0])
          if last_tree.hash.has_value?(@path)
            @blob_key = last_tree.hash.key(@path)
            return true
          end
          return false
        end
        return false
      end
      return false
    end

    def is_file_commited?
      log_file_array = load_log_file_array
      unless log_file_array.empty?
        log_file_array.reverse.each do |commit_key|
          commit = load_commit(commit_key)
          tree = load_tree(commit.tree_key)
          if tree.hash.has_value?(@path)
            @blob_key = tree.hash.key(@path)
            return true
          end
        end
        return false
      end
      return false
    end

    def checkout_file
      file = open_file(@path,"w")
      blob_obj = load_blob(@blob_key)
      blob_obj.data.each{ |line| file.puts line }
      file.close
    end

    def print_status
      require 'rbgit/cli/status'
      Rbgit::CLI::Status.new.run
    end

  end
end
