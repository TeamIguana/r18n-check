require "yaml"

module R18n
  class R18nCheck
    def check(file_name, block)
      file="#{file_name}.yml"
      root = YAML::load(IO.read("#{file}"))
      root.each { |key, value| traverse({key => value}, file, [], block) }
    end

    def traverse(node, file, path, block)
      path = path.dup << node.keys.first
      value = node.values.first
      if !value.is_a?(Hash)
        block.call(value, file, path)
      else
        node.values.first.each { |k, v| traverse({k => v}, file, path, block) }
      end
    end

    def check_presence(main_t, to_check_t)
      to_check_file_name="#{to_check_t}.yml"
      other_t = YAML::load(IO.read("#{to_check_file_name}"))
      block = lambda { |value, file, path|
        assert_presence(path, other_t, to_check_file_name)
      }
      check(main_t, block)
    end

    def assert_presence(path, to_check_t, to_check_file_name)
      current_path = to_check_t
      path.each do |xx|
        current_path = current_path[xx]
      end
      raise_with_message(to_check_file_name, path) if current_path.nil?
    end

    def check_bad_word(file_name, bad_word)
      block = lambda { |value, file, path|
        assert_is_key_correct(value, file, bad_word, path)
      }
      check(file_name, block)
    end

    def assert_is_key_correct(value, file, bad_word, path)
      if value.to_s.match(/#{bad_word}/i)
        raise_with_message(file, path)
      end
    end

    def raise_with_message(file, path)
      raise "problems on translation [#{path.join(' -> ')}] of <<#{file}>>"
    end
  end
end