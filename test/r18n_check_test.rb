require 'rubygems'
require 'bundler/setup'
require 'test/unit'
require 'r18n-core'

require '../lib/r18n/check'

class R18nCheckTest < Test::Unit::TestCase
  def test_it_signals_missing_stuff
    italian=translations_for('it-it')
    spanish=translations_for('es-es')
    french=translations_for('fr-fr')

    translations = italian

    [spanish, french].each do |translation|
      R18n::Check.new.check(translations.t, translation.t)
    end
  end

  def test_simple_key_not_contains_bad_word
    assert_no_problem_for(translations_for('simplekey_ok'))
  end

  def test_simple_key_contains_bad_word
    trans=translations_for('simplekey_ko')
    assert_raise_problem_for(trans, 'simplekey_ko', 'key')
  end

  def test_subkey_not_contains_bad_word
    assert_no_problem_for(translations_for('subkey_ok'))
  end

  def test_subkey_contains_bad_word
    trans=translations_for('subkey_ko')
    assert_raise_problem_for(trans, 'subkey_ko', 'subkey')
  end

  def test_specialkey_not_contains_bad_word
    assert_no_problem_for(translations_for('specialkey_ok'))
  end

  def test_specialkey_contains_bad_word
    trans=translations_for('specialkey_ko')
    assert_raise_problem_for(trans, 'specialkey_ko', 'key')
  end

  def translations_for(filename)
    R18n::I18n.new(filename, File.join(File.dirname(__FILE__), '..', 'i18n'))
  end

  def assert_no_problem_for(trans)
    assert_nothing_raised { R18n::Check.new.check_bad_word(trans.t, 'bad') }
  end

  def assert_raise_problem_for(trans, filename, key)
    assert_raise_message("problems on translation <<#{key}>> of <<#{filename}>>") {
      R18n::Check.new.check_bad_word(trans.t, 'bad')
    }
  end
end