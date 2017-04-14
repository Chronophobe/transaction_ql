require 'transaction_ql/expressions'

module TransactionQL
  class Filter
    attr_reader :name, :query

    def initialize(name, &block)
      @name = name
      @query = All.new []

      @block_depth = 0
      @last_blocks = []
      @timeframe = []

      instance_eval(&block)
    end

    def matches?(hash)
      @query.matches? hash
    end

    def match(column, regex)
      add_expression Match.new(column, regex)
    end

    def greater(column, other)
      add_expression Greater.new(column, other)
    end

    def smaller(column, other)
      add_expression Smaller.new(column, other)
    end

    def equal(column, other)
      add_expression Equal.new(column, other)
    end

    def greater_eq(column, other)
      add_expression Any.new [
        Greater.new(column, other),
        Equal.new(column, other)
      ]
    end

    def smaller_eq(column, other)
      add_expression Any.new [
        Smaller.new(column, other),
        Equal.new(column, other)
      ]
    end

    def any(&block)
      last_block = process_inner(&block)
      add_expression Any.new(last_block)
    end

    def invert(&block)
      last_block = process_inner(&block)
      add_expression Not.new(last_block)
    end

    private

    def process_inner(&block)
      @last_blocks.push []
      @block_depth += 1
      instance_eval(&block)
      @block_depth -= 1
      @last_blocks.pop
    end

    def add_expression(expression)
      if @block_depth > 0
        @last_blocks[-1] << expression
      else
        @query.expressions << expression
      end
    end
  end
end
