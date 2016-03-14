
module Rbgit
  class CLI::Reset
    def initialize(arr, hard_option, soft_option)
      @arr = arr
      @hard_reset = hard_option
      @soft_reset = soft_option
      @working_path = get_rbgit_path
    end

    def run
      if @arr.length == 1 && @arr[0].length == 40 && is_key_file?(@arr[0])
        if is_commit_obj?(@arr[0])
           if is_some_files_staged?
             remove_currently_staged_files
           end
           if @soft_reset
              key = change_reset_key(@arr[0])
              delete_ahead_commits(key) unless key.nil?
              delete_last_commit unless key == @arr[0]
           else
              delete_ahead_commits(@arr[0])
           end
           checkout_all_tracked_files if @hard_reset
        end
      else
        @arr.each do |path|
          if is_path_file?(path)
            @path = @working_path + path
            process_path
          else
            puts "#{path} does not exist".red
            exit 1
          end
        end
        print_status
      end
    end

    #--------------- reset commit -----------------#

    def is_some_files_staged?
      @tree_list_hash = load_tree_list_hash
      if @tree_list_hash.to_a.last[1] == 0
        return true
      end
      return false
    end

    def remove_currently_staged_files
      tree_key = @tree_list_hash.to_a.last[0]
      tree_obj = load_tree(tree_key)
      tree_obj.hash.to_a.each do |arr|
        delete_blob(arr[0])
        update_tracked_list_file(arr[1])
      end
      delete_tree(tree_obj.name)
      update_tree_list_hash(tree_obj.name)
    end

    #-----------------------------------------------#

    def is_commit_obj?(key)
      commit = load_commit(key)
      return true if commit.class == Rbgit::Commit
      return false
    end

    def delete_ahead_commits(key)
      @tree_list_hash = load_tree_list_hash
      @log_file_array = load_log_file_array
      @tracked_list_hash = load_tracked_list_hash
      @log_file_array.reverse.each do |commit_key|
        unless commit_key == key
          commit_obj = load_commit(commit_key)
          remove_commit_dependencies(commit_obj)
          delete_commit(commit_key)
          change_log_file_array(commit_key)
        end
      end
      update_sys_files
    end

    def remove_commit_dependencies(commit_obj)
      tree_obj = load_tree(commit_obj.tree_key)
      tree_obj.hash.to_a.each do |arr|
        delete_blob(arr[0])
        change_tracked_list_hash(arr[1])
      end
      delete_tree(commit_obj.tree_key)
      change_tree_list_hash(commit_obj.tree_key)
    end

    def change_tree_list_hash(tree_key)
      @tree_list_hash.delete_if{ |k, _| k == tree_key }
    end

    def change_tracked_list_hash(file_name)
      if @tracked_list_hash[file_name] > 1
         @tracked_list_hash[file_name] = @tracked_list_hash[file_name] - 1
      else
         @tracked_list_hash.delete_if{ |k, _| k == file_name }
      end
    end

    def change_log_file_array(commit_key)
      @log_file_array.delete(commit_key)
    end

    def update_sys_files
      file = open_tree_list_file
      file.puts dump_yaml(@tree_list_hash)
      file.close

      file = open_tracked_list_file
      file.puts dump_yaml(@tracked_list_hash)
      file.close

      file = open_log_file
      file.puts dump_yaml(@log_file_array)
      file.close
    end

    #--------------- reset file --------------------#

    def process_path
      tree_list_hash = load_tree_list_hash
      last_tree_entry = tree_list_hash.to_a.last
      if last_tree_entry[1] == 0
        last_tree = load_tree(last_tree_entry[0])
        if last_tree.hash.has_value?(@path)
          delete_blob(last_tree.hash.key(@path))
          update_tracked_list_file(@path)
          update_last_tree(last_tree)
        else
          puts "cant reset this file ".red
        end
      else
        puts "Unable to reset".red
        exit 1
      end
    end

    def update_last_tree(last_tree)
      last_tree.remove_from_hash(@path)
      unless last_tree.hash.empty?
        file = open_tree_file(last_tree.name)
        file.puts dump_yaml(last_tree)
        file.close
      else
        update_tree_list_hash(last_tree.name)
        delete_tree(last_tree.name)
      end
    end

    #---------------------- hard reset ---------------------------#

     def checkout_all_tracked_files
       require 'rbgit/cli/checkout'
       tracked_file_hash = load_tracked_list_hash
       tracked_file_hash.each_key do |file|
         Rbgit::CLI::Checkout.new([file]).run
       end
       remove_untracked_files(tracked_file_hash)
     end

     def remove_untracked_files(tracked_file_hash)
       Dir.glob("**/*") do |file|
         unless is_directory?(file)
           delete_file(file) unless tracked_file_hash[file]
         end
       end
     end


    #--------------------- soft reset ----------------------------#

    def change_reset_key(key)
      log_file_array = load_log_file_array
      unless log_file_array.last == key
        current_index = log_file_array.find_index(key)
        return log_file_array[current_index + 2]
      end
      return key
    end

    def delete_last_commit
      log_file_array = load_log_file_array
      # update_log_file
      unless log_file_array.empty?
        delete_commit(log_file_array.last)
        log_file_array.pop
        file = open_log_file
        file.puts dump_yaml(log_file_array)
        file.close
      end
      # update_tree_list_file
      tree_list_hash = load_tree_list_hash
      tree_list_hash[tree_list_hash.to_a.last[0]] = 0
      file = open_tree_list_file
      file.puts dump_yaml(tree_list_hash)
      file.close
    end

    #---------------------- common --------------------------------#

    def update_tree_list_hash(tree_key)
      tree_list_hash = load_tree_list_hash
      tree_list_hash.delete_if{ |k, _| k == tree_key }
      file = open_tree_list_file
      file.puts dump_yaml(tree_list_hash)
      file.close
    end

    def update_tracked_list_file(path)
      tracked_list_hash = load_tracked_list_hash
      if tracked_list_hash[path] > 1
        tracked_list_hash[path] = tracked_list_hash[path] - 1
      else
         tracked_list_hash.delete_if{ |k, _| k == path }
      end
      tracked_list_file = open_tracked_list_file
      tracked_list_file.puts dump_yaml(tracked_list_hash)
      tracked_list_file.close
    end


    def print_status
      require 'rbgit/cli/status'
      Rbgit::CLI::Status.new.run
    end

  end
end
