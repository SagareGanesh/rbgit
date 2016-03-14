
module Rbgit
  class CLI::Log

    def initialize
      get_rbgit_path
    end

    def run
      commit_array = load_log_file_array
      unless commit_array.empty?
        commit_array.reverse.each do |commit_key|
          commit_obj = load_commit(commit_key)
          commit_obj.display_commit
        end
      else
        puts "There is no any commit".red
      end
    end

  end
end
