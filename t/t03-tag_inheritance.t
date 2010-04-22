package Base;

use strict;
use warnings;

use Attribute::Method::Tags;
use Test::More;

use base qw( Test::Class );

our @run;

sub startup : Test( startup ) Tags( bar ) {
    push @run, 'startup';
}

sub setup : Test( setup ) Tags( bar ) {
    push @run, 'setup';
}

sub shutdown : Test( shutdown ) Tags( bar ) {
    push @run, 'shutdown';
}

sub teardown : Test( teardown ) Tags( bar ) {
    push @run, 'teardown';
}

sub foo : Tests Tags( foo ) {
    pass( "foo ran" );
    push @run, "foo";
}

package Subclass;

use Test::More;

use base qw( Base );

sub bar : Tests Tags( bar ) {
    pass( "Subclass::bar ran" );
    push @Base::run, "Subclass::bar";
}

package main;

use Test::Class::Filter::Tags;
use Test::More;

# no filter
{
    @Base::run = ();
    Subclass->runtests;

    is_deeply(
        \@Base::run,
        [ qw( startup setup Subclass::bar teardown setup foo teardown shutdown ) ],
        "expected run, when no filters specified, runs superclass methods",
    );
}

# tags honour subclassing
{
    $ENV{ TEST_TAGS } = 'foo';

    @Base::run = ();
    Subclass->runtests;

    is_deeply(
        \@Base::run,
        [ qw( startup setup foo teardown shutdown ) ],
        "tags honour subclassing, parent class ones run"
    );
}

# subclass tags run
{
    $ENV{ TEST_TAGS } = 'bar';

    @Base::run = ();
    Subclass->runtests;

    is_deeply(
        \@Base::run,
        [ qw( startup setup Subclass::bar teardown shutdown ) ],
        "tags defined in subclass are honoured"
    );
}
