module TransactionQL
  class Expression
    def matches?(hash)
      false
    end
  end

  class NumericExpression < Expression
    def initialize(column, other, operator)
      @column = column
      @other = other
      @operator = operator
    end

    def matches?(hash)
      case @other
      when Numeric
        hash.fetch(@column).send @operator, @other
      when String
        if !hash[@other].is_a? Numeric
          raise "Column `#{@other}` is not numeric!"
        end
        hash.fetch(@column).send @operator, hash.fetch(@other)
      else
        raise 'Unsupported right hand type.'
      end
    end
  end

  class All < Expression
    attr_reader :expressions
    def initialize(expressions)
      @expressions = expressions
    end

    def matches?(hash)
      @expressions.map { |exp| exp.matches? hash }.all?
    end
  end

  class Any < Expression
    attr_reader :expressions
    def initialize(expressions)
      @expressions = expressions
    end

    def matches?(hash)
      @expressions.map { |exp| exp.matches? hash }.any?
    end
  end

  class Not < Expression
    attr_reader :expressions
    def initialize(expressions)
      @expressions = expressions
    end

    def matches?(hash)
      result = @expressions.map { |exp| exp.matches? hash }.any?
      return !(result)
    end
  end

  class Match < Expression
    def initialize(column, regexp)
      @column = column
      @regexp = regexp
    end

    def matches?(hash)
      match = @regexp.match hash.fetch(@column)
      return !match.nil?
    end
  end

  class Greater < NumericExpression
    def initialize(column, other)
      super column, other, :>
    end
  end

  class Smaller < NumericExpression
    def initialize(column, other)
      super column, other, :<
    end
  end

  class Equal < NumericExpression
    def initialize(column, other)
      super column, other, :==
    end
  end
end