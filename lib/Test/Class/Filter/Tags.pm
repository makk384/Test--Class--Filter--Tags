package Test::Class::Filter::Tags;

use Test::Class;
use Attribute::Method::Tags;

our $VERSION = '0.10';

my $filter = sub {
    my ( $test_class, $test_method ) = @_;

    # as test_class permits changing of the TEST_METHOD definitions,
    # support doing similar for TEST_TAGS, so need to check it here, rather
    # than once outside of the filter.

    # don't filter if TEST_TAGS env var not set`
    return if not defined $ENV{ TEST_TAGS };

    my $test_tags = $ENV{ TEST_TAGS };
    $test_tags =~ s/^\s+//;
    $test_tags =~ s/\s+$//;

    my @tags = split /[\s,]+/, $test_tags;

    my $matched = grep { 
        Attribute::Method::Tags::Registry->method_has_tag(
            $test_class,
            $test_method,
            $_
        );
    } @tags;

    return 1 if not $matched;
};

Test::Class->add_filter( $filter );

1;

__END__

=head1 NAME

Test::Class::Filter::Tags - Selectively run only a subset of Test::Class tests
that have the specified method tag.

=head1 SYNOPSIS

 package MyTests::Wibble;

 # use Attribute::Method::Tags to get Tags definition
 use Attribute::Method::Tags;

 use Base qw( Test::Class );

 # can specify both Test and Tags attributes on test methods
 sub t_foo : Test( 1 ) Tags( quick fast ) {
 }

 sub t_bar : Test( 1 ) Tags( loose ) {
 }

 sub t_baz : Test( 1 ) Tags( fast ) {
 }

 1;


 #
 # in Test::Class driver script, or your Test::Class baseclass
 #
 use Test::Class;
 use Test::Class::Filter::Tags;

 # load the test classes, in whatever manner you normally use
 # ...

 $ENV{ TEST_TAGS } = 'quick,loose';

 Test::Class->runtests;

 # from the test above, only t_foo and t_bar methods would be run, the
 # first because it has the 'quick' tag, and the second becuase it has
 # 'loose' tag.  t_baz doesn't have either tag, so it's not run.

=head1 DESCRIPTION

When used in conjunction with L<Test::Class> tests, that also define
L<Attribute::Method::Tags> tags, this class allows filtering of the
tests that will be run.  If $ENV{ TEST_TAGS } is set, it will be
treated as a list of tags, seperated by any combination of whitespace or
commas.  The tests that will be run will only be the subset of tests
that have at least of these tags specified.

Note that, as per normal Test::Class behaviour, only normal tests will
be filtered.  Any fixture tests (startup, shutdown, setup and teardown)
will still be run, where appropriate, whether they have the given
attributes or not.

=head1 TAGS ADDITIVE OVER INHERITANCE

When inheriting from test classes, the subclasses will adopt any tags
that the superclass methods have, in addition to any that they specify.
(ie, tags are addative, when subclass and superclass have the same method
with different tags, the tags for the subclass method will be those from
both).

=head1 SEE ALSO

=over 4

=item Test::Class

This class acts as a normal Test::Class filter.

=item Attribute::Method::Tags

Attribute-based tag definitions.  This class assumes that you'll be
implementing tags via this mechanism.

=back

=head1 AUTHOR

Mark Morgan <makk384@gmail.com>

=head1 BUGS

Please send bugs or feature requests through to
bugs-Test-Class-Filter-Tags@rt.rt.cpan.org or through web interface
L<http://rt.cpan.org> .

=head1 COPYRIGHT AND LICENSE

Copyright 2010 Mark Morgan, All Rights Reserved.

This program is free software; you can redistribute it and/or modify it under
the same terms as Perl itself.
