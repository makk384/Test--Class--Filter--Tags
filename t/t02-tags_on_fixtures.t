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

package main;

use Test::Class::Filter::Tags;
use Test::More tests => 5;

# no filter
{
    @Base::run = ();
    Base->runtests;

    is_deeply(
        \@Base::run,
        [ qw( startup setup foo teardown shutdown ) ],
        "expected run, when no filters specified",
    );
}

# tags ignored on fixture methods
{
    $ENV{ TEST_TAGS } = 'foo';

    @Base::run = ();
    Base->runtests;

    is_deeply(
        \@Base::run,
        [ qw( startup setup foo teardown shutdown ) ],
        "tags are ignored on fixture methods"
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
        "startup/shutdown still run, when nothing matches fixture, even if they have tags that don't match run"
    );
}
