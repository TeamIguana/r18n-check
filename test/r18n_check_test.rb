require 'rubygems'
require 'bundler/setup'
require 'test/unit'
require 'r18n-core'

require '../lib/r18n/check'

class R18nCheckTest < Test::Unit::TestCase
  def test_it_signals_missing_stuff

    italian=R18n::I18n.new('it-it', File.join(File.dirname(__FILE__),'..','i18n'))
    spanish=R18n::I18n.new('es-es', File.join(File.dirname(__FILE__),'..','i18n'))
    french=R18n::I18n.new('fr-fr', File.join(File.dirname(__FILE__),'..','i18n'))

    translations = italian

    [spanish, french].each do |translation|
      R18n::Check.new.check(translations.t, translation.t)
    end
  end
end