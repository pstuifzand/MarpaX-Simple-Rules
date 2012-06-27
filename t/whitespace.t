
use Test::More;

use Data::Dumper;
use MarpaX::Simple::Rules 'parse_rules';

{
    my $rules = parse_rules("");
    is_deeply($rules, []);
}

{
    my $rules = parse_rules(" ");
    is_deeply($rules, []);
}

{
    my $rules = parse_rules(" \t ");
    is_deeply($rules, []);
}

{
    my $rules = parse_rules(<<"RULES");
    \t

RULES
    is_deeply($rules, []);
}

{
    eval {
        my $rules = parse_rules(<<"RULES");
abc
RULES
        print Dumper($rules);
    };
    unlike($@, qr/Can't use an undefined value as a SCALAR reference/);
    #like($@, qr/Missing "::=" operator/);
    #like($@, qr/Error: Parse exhausted, DeclareOp expected at line 1/);
    like($@, qr/Input incomplete DeclareOp expected at line 1/);
}

{
    eval {
        parse_rules(<<"RULES");
::= 
RULES
    };
    unlike($@, qr/Can't use an undefined value as a SCALAR reference/);
    #like($@, qr/Missing name left of "::=" operator/);
    like($@, qr/Error: Parse exhausted, Name expected before '::=' at line 1/);
}

{
    eval {
        parse_rules(<<"RULES");
::= hello world
RULES
    };
    unlike($@, qr/Can't use an undefined value as a SCALAR reference/);
    #like($@, qr/Missing name left of "::=" operator/);
    like($@, qr/Error: Parse exhausted, Name expected before '::=' at line 1/);
}

# No whitespace around operator
{
    my $rules = parse_rules(<<"RULES");
a::=b 
RULES
    is_deeply($rules, [ { lhs => 'a', rhs => [qw/b/] } ]);
}

done_testing();

