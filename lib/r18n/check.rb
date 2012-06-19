module R18n
  class Check
    def check(translations, other)
      visit(translations, other) do |other, key|
        assert_exist_key(other, key)
      end
    end

    def check_bad_word(translation, bad_word)
      visit(translation, translation) do |other, key|
        assert_is_key_correct(other, key, bad_word)
      end
    end

    def visit(translations, other, &block)
      data= translations.instance_eval { @data }
      if data.nil?
        return ''
      end
      data.each do |key, val|
        if val.class.eql? R18n::Translation
          block.call(other, key)
          visit(translations.send(key), other.send(key), &block)
        else
          if val.class.eql? R18n::Typed
            assert_typed_pl_keys(data, key, other)
          else
            block.call(other, key)
          end
        end
      end
    end

    def assert_typed_pl_keys(data, key, other)
      evaluated = other.instance_eval { @data }
      evaluated.each do |k, v|
        if v.class.eql? R18n::Typed
          unless data[key].value.keys == evaluated[k].value.keys
            raise error_message(data[key].path, other)
          end
        end
      end
    end

    def assert_exist_key(other, key)
      evaluated = other.instance_eval { @data }
      unless evaluated.nil?
        raise error_message(key, other) unless evaluated.key?(key)
      end
    end

    def assert_is_key_correct(other, key, bad_word)
      value = other.instance_eval { @data }
      if value.to_s.match(/#{bad_word}/i)
        raise error_message(key, other)
      end
    end

    def error_message(key, other)
      "problems on translation <<#{key}>> of <<#{other.instance_eval { @locale }.code}>>"
    end
  end
end