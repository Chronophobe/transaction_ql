require 'transaction_ql/expressions'

module TransactionQL
  class Filter
    attr_reader :name, :query

    def initialize(name, &block)
      @name = name
      @query = All.new []

      @in_any_block = false
      @any_expressions = []

      instance_eval(&block)
    end

    def match(column, regex)
      expression = Match.new(column, regex)
      if @in_any_block
        @any_expressions << expression
      else
        @query.expressions << expression
      end
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
      raise 'Nested any blocks are not supported.' if @in_any_block
      @in_any_block = true
      instance_eval(&block)
      @in_any_block = false
      expression = Any.new @any_expressions
      add_expression(expression)
      @any_expressions = []
    end

    private

    def add_expression(expression)
      if @in_any_block
        @any_expressions << expression
      else
        @query.expressions << expression
      end
    end
  end
end
