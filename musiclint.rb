require 'bigdecimal'
require 'nokogiri'
require 'pp'

require 'musiclint/score'
require 'musiclint/rules/no-consecutive-perfect-intervals'

module MusicLint
  class App
    def initialize
      doc = Nokogiri::XML(
        IO.read(ARGV[0])
      )
      @score = Score.new(xml_doc: doc)
    end

    def run
      problems = []
      rules = [
        Rules::NoConsecutivePerfectIntervals,
      ]

      rules.each do |rule|
        problems += rule.check(@score)
      end

      problems.each do |problem|
        puts problem
      end

      error_count = problems.find_all(&:error?).count
      warning_count = problems.find_all(&:warning?).count
      problem_plural_morpheme = problems.count == 1 ? '' : 's'
      error_plural_morpheme = error_count == 1 ? '' : 's'
      warning_plural_morpheme = warning_count == 1 ? '' : 's'

      problem_str = "#{problems.count} problem#{problem_plural_morpheme}"
      error_str = "#{error_count} error#{error_plural_morpheme}"
      warning_str = "#{warning_count} warning#{warning_plural_morpheme}"

      puts
      puts "   #{problem_str} (#{error_str}, #{warning_str})"
    end
  end
end

MusicLint::App.new.run
