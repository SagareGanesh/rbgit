
module Rbgit
  class CLI::Commit

    def initialize(message)
      @name = message
      @commit_key = generate_key(Time.new.asctime)
      get_rbgit_path
    end

    def run
      create_commit
      update_log_file
      update_tree_list_file
    end

    def create_commit
      tree_list_hash = load_tree_list_hash
      tree_key = tree_list_hash.to_a.last[0]
      obj = Rbgit::Commit.new(@name, @commit_key, tree_key)
      file = open_commit_file(@commit_key)
      file.puts dump_yaml(obj)
      file.close
      puts " Commit Successfull ".red
    end

    def update_tree_list_file
      tree_list_hash = load_tree_list_hash
      tree_list_hash[tree_list_hash.to_a.last[0]] = 1
      file = open_tree_list_file
      file.puts dump_yaml(tree_list_hash)
      file.close
    end

    def update_log_file
        log_array = load_log_file_array
        log_array.push(@commit_key)
        file = open_log_file
        file.puts dump_yaml(log_array)
        file.close
    end

  end
end
