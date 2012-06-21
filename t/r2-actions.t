use Test::More;
use MarpaX::Simple::Rules 'parse_rules';

my $rules = parse_rules(<<"RULES");
expression ::= term  => ::whatever
expression ::= term  => ::undef
RULES

is_deeply($rules, [
    { lhs => 'expression', rhs => [ qw/term/ ], action => '::whatever' },
    { lhs => 'expression', rhs => [ qw/term/ ], action => '::undef' },
]);

done_testing();

