# require 'transaction_ql/expressions'

module TransactionQL
  class Filter
    attr_reader :name, :query

    def initialize(name, &block)
      @name = name
      @query = All.new []

      @in_block = false
      @last_block = []

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
      raise 'Nested blocks are not supported.' if @in_block
      @in_block = true
      instance_eval(&block)
      @in_block = false

      expression = Any.new @last_block
      add_expression(expression)

      @any_expressions = []
    end

    def invert(&block)
      raise 'Nested blocks are not supported.' if @in_block
      @in_block = true
      instance_eval(&block)
      @in_block = false
      expression = Not.new @last_block
      add_expression(expression)

      @last_block = []
    end

    private

    def add_expression(expression)
      if @in_block
        @last_block << expression
      else
        @query.expressions << expression
      end
    end
  end
end
