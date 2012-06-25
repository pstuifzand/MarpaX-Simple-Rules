use Test::More;
use MarpaX::Simple::Rules 'parse_rules';

my $rules = parse_rules(<<"RULES");
expr0 ::=                       => return_0
expr1 ::=              
expr2 ::= test
expr3 ::=                       => return_0
RULES

is_deeply($rules, [
    { lhs => 'expr0', rhs => [], action => 'return_0' },
    { lhs => 'expr1', rhs => [] },
    { lhs => 'expr2', rhs => [qw/test/] },
    { lhs => 'expr3', rhs => [], action => 'return_0' },
]);

done_testing();

