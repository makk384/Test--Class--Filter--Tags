package Base;

use strict;
use warnings;

use Attribute::Method::Tags;
use Test::More;

use base qw( Test::Class );

our @run;

sub startup : Test( startup ) {
    push @run, 'startup';
}

sub setup : Test( setup ) {
    push @run, 'setup';
}

sub shutdown : Test( shutdown ) {
    push @run, 'shutdown';
}

sub teardown : Test( teardown ) {
    push @run, 'teardown';
}

sub foo : Tests Tags( foo ) {
    pass( "foo ran" );
    push @run, "foo";
}

sub bar : Tests Tags( bar ) {
    pass( "bar ran" );
    push @run, "bar";
}

sub foo_bar : Tests Tags( foo bar ) {
    pass( "foo_bar run" );
    push @run, "foo_bar";
}

sub baz : Tests {
    pass( "baz run" );
    push @run, "baz";
}
    
package main;

use Test::Class::Filter::Tags;
use Test::More tests => 13;

# no filter
{
    @Base::run = ();
    Base->runtests;

    is_deeply(
        \@Base::run,
        [ qw( startup setup bar teardown setup baz teardown setup foo teardown setup foo_bar teardown shutdown ) ],
        "expected run, when no filters specified",
    );
}

# filter matching only one method
{
    $ENV{ TEST_TAGS } = 'foo';

    @Base::run = ();
    Base->runtests;

    is_deeply(
        \@Base::run,
        [ qw( startup setup foo teardown setup foo_bar teardown shutdown ) ],
        "expected run, when filter specified that matches single tag"
    );
}

# filter matching multiple method
{
    $ENV{ TEST_TAGS } = 'foo,bar';

    @Base::run = ();
    Base->runtests;

    is_deeply(
        \@Base::run,
        [ qw( startup setup bar teardown setup foo teardown setup foo_bar teardown shutdown ) ],
        "expected run, when filter matches multiple tags"
    );
}

# filter matching no tags, startup, shutdown still run
{
    $ENV{ TEST_TAGS } = 'wibble';

    @Base::run = ();
    Base->runtests;

    is_deeply(
        \@Base::run,
        [ qw( startup shutdown ) ],
        "when specifying tags that match no methods, startup and shutdown still run"
    );
}
