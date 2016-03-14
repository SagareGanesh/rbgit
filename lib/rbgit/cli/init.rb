
module Rbgit
  class CLI::Init

    def run
      generate_file_structure
    end

    def generate_file_structure
      %w[objects sys].each{ |name|  make_dir("#{@@rbgit}/#{name}") }
      create_and_init_file("tree",{})
      create_and_init_file("trackfile", Hash.new(0))
      create_and_init_file("logfile", [])
      puts "Initialized empty rbgit repository .rbgit/"
    end

    def create_and_init_file(name,initial_value)
      key = generate_key(name)
      make_dir("#{@@sys}/#{yaml_dir(key)}")
      file = open_file("#{@@sys}/#{yaml_file(key)}","w")
      file.puts dump_yaml(initial_value)
      file.close
    end

  end
end

