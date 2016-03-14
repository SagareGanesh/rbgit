module Rbgit
  class CLI < Thor

    desc "init", "this will initialize"
    def init
      require 'rbgit/cli/init'
      Init.new.run
    end

    desc "status", "this will display current status"
    def status
      require 'rbgit/cli/status'
      Status.new.run
    end

    desc "add PATHS","this will add files in index"
    def add(*paths)
      require 'rbgit/cli/add'
      Add.new(paths).run
    end

    desc "commit","this will commit your current version"
    option :m, :required => true, :type => :string
    def commit
      require 'rbgit/cli/commit'
      Commit.new(options[:m]).run
    end

    desc "log", "this will describe commit history"
    def log
      require 'rbgit/cli/log'
      Log.new.run
    end

    desc "reset PATHS", "this will reset files from index"
    option :soft, :type => :boolean
    option :hard, :type => :boolean
    def reset(*paths)
      require 'rbgit/cli/reset'
      Reset.new(paths, options[:hard], options[:soft]).run
    end

    desc "checkout PATHS", "this will undo file changes"
    def checkout(*paths)
      require 'rbgit/cli/checkout'
      Checkout.new(paths).run
    end

  end
end
