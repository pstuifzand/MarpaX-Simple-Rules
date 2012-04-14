## NAME

MarpaX::Simple::Rules - Simplest way to create Marpa::XS rules.

## SYNOPSYS

    use Marpa::XS;
    use MarpaX::Simple::Rules 'parse_rules';
    
    my $rules = parse_rules(<<"RULES");
    Expression  ::= Term                => Return_0
    Term        ::= Factor              => Return_0
    Term        ::= Term Plus Term      => Plus
    Factor      ::= Number              => Return_0
    Factor      ::= Factor Mul Factor   => Mul
    RULES
    
    my $grammar = Marpa::XS::Grammar->new({
        start => 'Expression',
        rules => $rules,
        ...
    });


## FUNCTIONS

### `$rules = parse_rules(STRING)`

Parses a string containing a grammar description. Returns the rules in the form
that Marpa::XS::Grammar uses.


## SEE ALSO

[Marpa::XS](http://metacpan.org/release/Marpa-XS)


## AUTHOR

Peter Stuifzand

## LICENSE

Same as Perl5.

## COPYRIGHT

Peter Stuifzand 2012

