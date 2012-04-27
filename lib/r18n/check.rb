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