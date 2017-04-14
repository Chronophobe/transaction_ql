# TransactionQL
A Ruby gem aimed at filtering bank transactions

This project is both a way to extend my knowledge of Ruby and Ruby gems and as a small helper to actually make readable, textual filters for bank transactions (to aid a personal project).

## Example
The expressions used by the filter can currently only be written in CNF.


Available expressions:
```Ruby
# Match a column to a (ruby) regex
match      'column', /regex/

# Compare a column to a number
# or the contents of another column
equal      'column', <number>
greater    'column', <number>
greater_eq 'column', <number>
smaller    'column', <number>
smaller_eq 'column', <number>

# Match if any of the expressions match
any {
    <expression>
    <expression>
    ...
}

# Match if all of the expression don't match
invert {
    <expression>
    <expression>
    ...
}
```

Example:
```Ruby
require 'transaction_ql'
include TransactionQL

Filter.new 'test filter' do
  match 'sender', /INGB/i                     # 1
  invert { match 'description', /donation/i } # 2
  any {                                       # 3
    greater 'amount', 50
    smaller 'amount', 0
  }
end
```

This example matches when:
1. `'sender'` matches the regexp `/INGB/i`
2. `'description'` does **not*
* match the regexp `/donation/i`
3. `'amount'` is either greater than `50` **or** smaller than `0`
