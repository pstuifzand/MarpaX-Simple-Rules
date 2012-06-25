use Test::More;
use MarpaX::Simple::Rules 'parse_rules';

my $rules = parse_rules(<<"RULES");
expression ::=                       => return_0
RULES

is_deeply($rules, [
    { lhs => 'expression', rhs => [], action => 'return_0' },
]);

done_testing();

