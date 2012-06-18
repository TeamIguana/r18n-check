module R18n
  class Check
    def check(translations, other)
      data= translations.instance_eval { @data }
      if data.nil?
        return ''
      end
      data.each do |key, val|
        if val.class.eql? R18n::Translation
          assert_exist_key(other, key)
          check(translations.send(key), other.send(key))
        else
          if val.class.eql? R18n::Typed
            assert_typed_pl_keys(data, key, other)
          else
            assert_exist_key(other, key)
          end
        end
      end
    end

    def check_bad_word(translation, bad_word)
      data = translation.instance_eval { @data }
      if data.nil?
        return ''
      end
      data.each do |key, val|
        if val.class == R18n::TranslatedString
          assert_is_key_correct(translation, key, val, bad_word)
        elsif val.class == R18n::Typed
          val.value.each{|key,value| assert_is_key_correct(translation, data.first[0], value, bad_word)}
        else
          check_bad_word(translation.send(key), bad_word)
        end
      end
    end

    def assert_is_key_correct(translation, key, value, bad_word)
      if value.to_s.match(/#{bad_word}/i)
        raise "problems on translation <<#{key}>> of <<#{translation.instance_eval { @locale }.code}>>"
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

    def error_message(key, other)
      "problems on translation <<#{key}>> of <<#{other.instance_eval { @locale }.code}>>"
    end
  end
end