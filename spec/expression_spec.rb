require './lib/transaction_ql/expressions'
require './lib/transaction_ql/filter'

include TransactionQL

RSpec.describe Match, '#matches?' do
  before { @expression = Match.new 'a', /Hello\ RSpec$/i}
  it 'matches when the regex matches' do
    result = @expression.matches?('a' => 'Oh, hello rspec')
    expect(result).to be true
  end
  it 'does not match when the regex does not match' do
    result = @expression.matches?('a' => 'Hello rspec!')
    expect(result).to be false
  end
  it 'throws KeyError if column does not exist' do
    expression = Match.new('x', /Hello\ RSpec/)
    expect {
      expression.matches?('a' => 'Hello RSpec')
    }.to raise_error(KeyError)
  end
end

RSpec.describe NumericExpression, '#matches?' do
  it 'compares to numeric values' do
    expression = NumericExpression.new('a', 10, :>)
    result = expression.matches?('a' => 11)
    expect(result).to be true

    result = expression.matches?('a' => 10)
    expect(result).to be false
  end

  it 'compares to columns' do
    expression = NumericExpression.new('a', 'b', :<)
    result = expression.matches?('a' => 11, 'b' => 12)
    expect(result).to be true

    result = expression.matches?('a' => 11, 'b' => 10)
    expect(result).to be false
  end

  it 'raises KeyError if the column does not exist' do
    expression = NumericExpression.new('x', 10, :>)
    expect { expression.matches?('a' => 11) }.to raise_error(KeyError)
  end
end

RSpec.describe Any, '#matches?' do
  it 'returns true when any of its children matches' do
    expression = Any.new [
      Match.new('a', /Hello\ RSpec$/i),
      NumericExpression.new('b', 'c', :<),
      NumericExpression.new('b', 10, :>)
    ]
    result = expression.matches?(
      'a' => 'Hello RSpec!',
      'b' => 9,
      'c' => 10
    )
    expect(result).to be true

    result = expression.matches?(
      'a' => 'Hello RSpec!',
      'b' => 9,
      'c' => 9
    )
    expect(result).to be false
  end
end

RSpec.describe All, '#matches?' do
  it 'returns true only when all of its children matches' do
    expression = All.new [
      Match.new('a', /Hello\ RSpec$/i),
      NumericExpression.new('b', 'c', :<),
      NumericExpression.new('b', 10, :>)
    ]
    result = expression.matches?(
      'a' => 'Hello RSpec',
      'b' => 11,
      'c' => 12
    )
    expect(result).to be true

    result = expression.matches?(
      'a' => 'Hello RSpec!',
      'b' => 11,
      'c' => 12
    )
    expect(result).to be false
  end
end

RSpec.describe Not, '#matches?' do
  it 'returns true when all of its subexpressions does not match' do
    expression = Not.new [
      NumericExpression.new('x', 10, :>),
      NumericExpression.new('y', 10, :>)
    ]
    result = expression.matches?('x' => 10, 'y' => 10)
    expect(result).to be true

    result = expression.matches?('x' => 11, 'y' => 10)
    expect(result).to be false
  end
end

RSpec.describe Filter, '#matches?' do
  it 'returns true when everything in the filter matches' do
    filter = Filter.new 'rspec-test' do
      match 'sender', /INGB/i
      invert { match 'description', /donation/i }
      any {
        greater 'amount', 50
        smaller 'amount', 0
      }
    end

    data = {
      'sender' => 'NL31 INGB 1234 5678 90',
      'amount' => 51,
      'description' => 'rspec test description'
    }
    expect(filter.matches?(data)).to be true

    data['description'] = 'donation to RSpec'
    expect(filter.matches?(data)).to be false

    data['description'] = 'rspec test description'
    data['amount'] = -1
    expect(filter.matches?(data)).to be true

    data['amount'] = 50
    expect(filter.matches?(data)).to be false

    data['amount'] = 0
    expect(filter.matches?(data)).to be false

    data['amount'] = 51
    data['sender'] = 'someone else'
    expect(filter.matches?(data)).to be false
  end
end