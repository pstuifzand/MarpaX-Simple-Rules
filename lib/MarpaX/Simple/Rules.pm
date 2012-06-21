package MarpaX::Simple::Rules;
use strict;

our $VERSION='0.2.4';

use Marpa::XS;
use base 'Exporter';

our @EXPORT_OK = qw/parse_rules/;

sub Rules { shift; return \@_; } 
sub Rule { shift; return { @{$_[0]}, @{$_[2]} }; }
sub RuleWithAction { shift; return { @{$_[0]}, @{$_[2]}, action => $_[4] }; }
sub Lhs { shift; return [lhs => $_[0]];}
sub Rhs { shift; return [rhs => $_[0]];}
sub Star { shift; return [rhs => [ $_[0] ], min => 0]; }
sub Plus { shift; return [rhs => [ $_[0] ], min => 1]; }
sub Names { shift; return [@_];}
sub Null { shift; return [rhs => []]; }

sub parse_rules {
    my ($string) = @_;

    my $grammar = Marpa::XS::Grammar->new({
        start   => 'Rules',
        actions => __PACKAGE__,
        
        rules => [
            { lhs => 'Rules',     rhs => [qw/Rule/],                min => 1 },
            { lhs => 'Rule',      rhs => [qw/Lhs ::= Rhs/],         action => 'Rule' },
            { lhs => 'Rule',      rhs => [qw/Lhs ::= Rhs => Name/], action => 'RuleWithAction' },
            { lhs => 'Lhs',       rhs => [qw/Name/] },
            { lhs => 'Rhs',       rhs => [qw/Names/] },
            { lhs => 'Rhs',       rhs => [qw/Name +/],              action => 'Plus' },
            { lhs => 'Rhs',       rhs => [qw/Name */],              action => 'Star' },
            { lhs => 'Rhs',       rhs => [qw/Null/],                action => 'Null' },
            { lhs => 'Names',     rhs => [qw/Name/],                min => 1 },
        ],

        lhs_terminals => 0,
    });
    $grammar->precompute;

    my $rec = Marpa::XS::Recognizer->new({grammar => $grammar});

    my @tokens = split /\s+/, $string;
    for (@tokens) {
        next if m/^\s*$/;

        if (m/^::=$/) {
            $rec->read('::=');
        }
        elsif (m/^Null$/) {
            $rec->read('Null');
        }
        elsif (m/^=>$/) {
            $rec->read('=>');
        }
        elsif (m/^[+]$/) {
            $rec->read('+');
        }
        elsif (m/^[*]$/) {
            $rec->read('*');
        }
        elsif (m/^(\w+)$/) {
            $rec->read('Name', $1);
        }
        elsif (m/^(::\w+)$/) {
            $rec->read('Name', $1);
        }
        elsif (m/^(\w+)([+*]?)$/) {
            $rec->read('Name', $1);
            $rec->read($2, $2);
        }
    }

    $rec->end_input;
    my $rules = ${$rec->value};

    return $rules;
}

1;

__END__

=head1 NAME

MarpaX::Simple::Rules - Simple definition language for rules

=head1 SYNOPSYS

    use Marpa::XS;
    use MarpaX::Simple::Rules 'parse_rules';

    sub numbers {
        my (undef, @numbers) = @_;
        return \@numbers;
    }

    my $rules = parse_rules(<<"RULES");
    parser   ::= number+  => numbers
    RULES

    my $grammar = Marpa::XS::Grammar->new({
        start   => 'parser',
        rules   => $rules,
        actions => __PACKAGE__,
    });
    $grammar->precompute();

    # Read tokens
    my $rec = Marpa::XS::Recognizer->new({grammar => $grammar });
    $rec->read('number', 1);
    $rec->read('number', 2);

    # Get the return value
    my $val = ${$rec->value()};
    print @{$val} . "\n";

=head1 DESCRIPTION

MarpaX::Simple::Rules is a specification language that allows us to write the
parameter for the rules argument of Marpa::XS grammar as a string.

=head1 FUNCTION

=head2 parse_rules(GRAMMAR-STRING)

Parses the argument and returns a values that can be used as the C<rules> argument in
Marpa::XS::Grammar constructor.

=head1 SYNTAX

A rule is a line that consists of two or three parts. These parts are called
the left-hand side (LHS), the right-hand side (RHS) and the action. Every rule
should contain a LHS and RHS. The action is optional.

The LHS and RHS are separated by the declare operator C<::=>. A LHS begins with
a Name. A name is anything that matches the following regex: C<\w+>.

The RHS can be specified in four ways: multiple names, a name with a plus C<+>, a name
with a star C<*>, or C<Null>.

=head1 TRANSFORMATION

This is a list of the patterns that can be specified. On the left of C<becomes>
we see the rule as used in the grammar string and on the right we see perl data
structure that it becomes.

    A ::= B                   becomes      { lhs => 'A', rhs => [ qw/B/ ] }
    A ::= B C                 becomes      { lhs => 'A', rhs => [ qw/B C/ ] }
    A ::= B+                  becomes      { lhs => 'A', rhs => [ qw/B/ ], min => 1 }
    A ::= B*                  becomes      { lhs => 'A', rhs => [ qw/B/ ], min => 0 }
    A ::= B* => return_all    becomes      { 
                                              lhs => 'A',  
                                              rhs => [ qw/B/ ],
                                              min => 0,
                                              action => 'return_all',
                                           }

=head1 TOKENS

MarpaX::Simple::Rules doesn't help you getting from a stream to tokens. See
L<MarpaX::Simple::Lexer> for that or L<MarpaX::Simple::Rules>, which contains a
very simple lexer.

=head1 SEE ALSO

L<Marpa::XS>, L<MarpaX::Simple::Lexer>

=head1 HOMEPAGE

L<http://github.com/pstuifzand/MarpaX-Simple-Rules>

=head1 LICENSE 

This library is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

=head1 AUTHOR

Peter Stuifzand E<lt>peter@stuifzand.euE<gt>

=head1 COPYRIGHT

Copyright (c) 2012 Peter Stuifzand.  All rights reserved.

=cut

