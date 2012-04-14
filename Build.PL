use Module::Build;

my $build = Module::Build->new
(
    module_name => 'MarpaX::Simple::Rules',
    license  => 'perl',
    requires => {
        'Marpa::XS' => '1.0',
    },
);
$build->create_build_script;
