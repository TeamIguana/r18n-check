require 'rubygems'
require 'bundler/setup'
require 'test/unit'
require 'r18n-core'

require '../lib/r18n/r18n_check'

class R18nCheckTest < Test::Unit::TestCase
  def test_it_signals_nothing_because_correct
    italian=file_full_path('it-it')
    french=file_full_path('fr-fr')

    R18n::Check.new.check_presence(italian, french)
  end

  def test_it_signals_missing_stuff
    italian=file_full_path('it-it')
    spain=file_full_path('es-es')

    assert_raise_message("es-es: missing [b -> leaf2]") {
      R18n::Check.new.check_presence(italian, spain)
    }
  end

  def test_it_signals_missing_full_section
    italian=file_full_path('it-it')
    german=file_full_path('de-de')

    assert_raise_message("de-de: missing [d -> section -> leaf]") {
      R18n::Check.new.check_presence(italian, german)
    }
  end

  def test_it_signals_missing_pl_subsection
    italian=file_full_path('it-it')
    polish=file_full_path('pl-pl')

    assert_raise_message("pl-pl: missing [c -> 1]") {
      R18n::Check.new.check_presence(italian, polish)
    }
  end

  def test_simple_key_not_contains_bad_word
    assert_no_problem_for(file_full_path('simplekey_ok'))
  end

  def test_simple_key_contains_bad_word
    assert_raise_problem_for(file_full_path('simplekey_ko'), 'key')
  end

  def test_subkey_not_contains_bad_word
    assert_no_problem_for(file_full_path('subkey_ok'))
  end

  def test_subkey_contains_bad_word
    assert_raise_problem_for(file_full_path('subkey_ko'), 'key -> subkey2 -> subkey3')
  end

  def test_specialkey_not_contains_bad_word
    assert_no_problem_for(file_full_path('specialkey_ok'))
  end

  def test_more_key_contains_bad_word
    assert_raise_problem_for(file_full_path('more_key_ko'), 'b -> leaf2')
  end

  def test_specialkey_contains_bad_word
    assert_raise_problem_for(file_full_path('specialkey_ko'), 'key -> n')
  end

  def file_full_path(filename)
    File.join(File.dirname(__FILE__), '..', 'i18n', filename)
  end

  def assert_no_problem_for(file_name)
    assert_nothing_raised { R18n::Check.new.check_bad_word(file_name, 'bad') }
  end

  def assert_raise_problem_for(filename, key)
    assert_raise_message("#{File.basename(filename)}: missing [#{key}]") {
      R18n::Check.new.check_bad_word(filename, 'bad')
    }
  end
end