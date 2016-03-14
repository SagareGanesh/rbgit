
module Helper

    @@rbgit   = "./.rbgit"
    @@sys     = "./.rbgit/sys"
    @@objects = "./.rbgit/objects"

    #-------------------- get_rbgit_path -------------------------------------------#

    def get_rbgit_path
      str = ""
      until is_directory?('./.rbgit')
        unless File.basename(Dir.getwd) == 'home'
          str = File.basename(Dir.getwd) + "/" + str
          Dir.chdir('../.')
        else
          puts " You not initialized rbgit".red
          exit 1
        end
      end
      str
    end

    #------------------ yaml file and dir path -------------------------------------#

    def yaml_file(key)
      "#{key[0..1]}/#{key[2..39]}.yaml"
    end

    def yaml_dir(key)
      "#{key[0..1]}"
    end

    #------------------  Hash key related functions -------------------------------#

    def generate_key(str)
      Digest::RMD160.hexdigest(str)
    end

    #---------------- file and direcotory releated funtions -------------------------#

    def make_dir(path)
      FileUtils.mkdir_p(path)
    end

    def read_file(path)
      File.read(path)
    end

    def open_file(path, w)
      File.open(path, w)
    end

    def delete_file(path)
      File.delete(path)
    end

    def is_key_file?(key)
      File.file?("#{@@objects}/#{yaml_file(key)}")
    end

    def is_path_file?(path)
      File.file?(path)
    end

    def is_directory?(path)
      File.directory?(path)
    end

    #---------------------- yaml releated functions --------------------------------#

    def load_yaml(path)
      YAML::load_file(path)
    end

    def dump_yaml(value)
      YAML::dump(value)
    end

    #---------------------- open file in sys directory ----------------------------------#

    def open_sys_file(name)
      key = generate_key(name)
      open_file("#{@@sys}/#{yaml_file(key)}", "w")
    end

    def open_tree_list_file
      open_sys_file("tree")
    end

    def open_tracked_list_file
      open_sys_file("trackfile")
    end

    def open_log_file
      open_sys_file("logfile")
    end

    #------------------- open file in objects directory -------------------------------#

    def open_obj_file(key)
      open_file("#{@@objects}/#{yaml_file(key)}", "w")
    end

    def open_tree_file(tree_key)
      open_obj_file(tree_key)
    end

    def open_blob_file(blob_key)
      open_obj_file(blob_key)
    end

    def open_commit_file(commit_key)
      open_obj_file(commit_key)
    end


    #----------------------- loading sys/ object ---------------------------------#

    def load_sys_obj(name)
      key = generate_key(name)
      load_yaml("#{@@sys}/#{yaml_file(key)}")
    end

    def load_tree_list_hash
      load_sys_obj("tree")
    end

    def load_tracked_list_hash
      load_sys_obj("trackfile")
    end

    def load_log_file_array
      load_sys_obj("logfile")
    end

    #------------------------- loading objects/ object -------------------------------#

    def load_objects_obj(key)
      load_yaml("#{@@objects}/#{yaml_file(key)}")
    end

    def load_tree(tree_key)
      load_objects_obj(tree_key)
    end

    def load_commit(commit_key)
      load_objects_obj(commit_key)
    end

    def load_blob(blob_key)
      load_objects_obj(blob_key)
    end

    #---------------------------- Delete file in objects/ directory--------------------#

    def delete_obj_file(key)
      delete_file("#{@@objects}/#{yaml_file(key)}")
    end

    def delete_blob(key)
      delete_obj_file(key)
    end

    def delete_tree(key)
      delete_obj_file(key)
    end

    def delete_commit(key)
      delete_obj_file(key)
    end

    #----------------------------------------------------------------------------------#


end
