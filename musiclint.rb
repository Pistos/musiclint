require 'bigdecimal'
require 'nokogiri'
require 'pp'

require 'musiclint/score'
require 'musiclint/rules/no-consecutive-perfect-intervals'

module MusicLint
  class App
    private def count_str(countable:, countable_type:)
      plural_morpheme = countable.count == 1 ? '' : 's'
      "#{countable.count} #{countable_type}#{plural_morpheme}"
    end

    private def errors
      @_errors ||= problems.find_all(&:error?)
    end

    def initialize
      doc = Nokogiri::XML(
        IO.read(ARGV[0])
      )
      @score = Score.new(xml_doc: doc)
    end

    RULES = [
      Rules::NoConsecutivePerfectIntervals,
    ]

    private def problems
      @_problems ||= RULES.reduce([]) { |problems, rule|
        problems + rule.new(@score).check
      }
    end

    def run
      problems.each do |problem|
        puts problem
      end

      problem_str = count_str(countable: problems, countable_type: 'problem')
      error_str = count_str(countable: errors, countable_type: 'error')
      warning_str = count_str(countable: warnings, countable_type: 'warning')

      puts
      puts "   #{problem_str} (#{error_str}, #{warning_str})"
    end

    private def warnings
      @_warnings ||= problems.find_all(&:warning?)
    end
  end
end

MusicLint::App.new.run
