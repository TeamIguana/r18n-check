require 'rubygems'
require 'bundler/setup'
require 'test/unit'
require 'r18n-core'

class R18nCheckTest < Test::Unit::TestCase
  def test_it_signals_missing_stuff

    italian=R18n::I18n.new('it-it', File.join(File.dirname(__FILE__),'..','i18n'))
    spanish=R18n::I18n.new('es-es', File.join(File.dirname(__FILE__),'..','i18n'))
    french=R18n::I18n.new('fr-fr', File.join(File.dirname(__FILE__),'..','i18n'))

    translations = italian

    [spanish, french].each do |t|
      @current_trans = t
      check(translations.t, @current_trans.t)
    end
  end

  def check(translations, other)
    p translations
    data= translations.instance_eval { @data }
    if data.nil?
      return ''
    end
    data.each do |key, val|
      if val.class.eql? R18n::Translation
        check(translations.send(key), other.send(key))
        assert_exist_key(other, key)
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
        assert_equal(data[key].value.keys, evaluated[k].value.keys, error_message(data[key].path))
      end
    end
  end

  def assert_exist_key(other, key)
    evaluated = other.instance_eval { @data }
    assert_true(evaluated.key?(key), error_message(key)) unless  evaluated.nil?
  end

  def error_message(key)
    "problems on translation <<#{key}>> of <<#{@current_trans.locale.code}>>"
  end
end