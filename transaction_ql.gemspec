Gem::Specification.new do |gem|
    gem.name        = 'transaction_ql'
    gem.version     = '1.2.0'
    gem.date        = '2017-04-08'
    gem.summary     = 'Embedded DSL to filter bank transactions.'
    gem.description = 'Embedded DSL created to filter/categorise bank transactions.'
    gem.authors     = ['Stan Janssen']
    gem.email       = 'stan@janssen.io'
    gem.files       = [
        'lib/transaction_ql.rb',
        'lib/transaction_ql/filter.rb',
        'lib/transaction_ql/expressions.rb'
    ]
    gem.homepage    = 'https://github.com/chronophobe/transaction_ql'
    gem.license     = 'MIT'
end
