use v6;
unit class Crust::App::File;
use Crust::MIME;

has $.root;
has $.file;
has $.content-type;
has $.encoding;

method !should-handle($file) {
    $file.IO.f;
}

method to-app() {
    sub ($env) { self.call($env) };
}

method call($env) {
    my ($file, $path-info, @error-res) = $!file || self!locate-file($env);
    return |@error-res if @error-res;

    return self!serve-path($env, $file);
}

method !locate-file($env) {
    my $path = $env<PATH_INFO> || '';
    if $path ~~ /\0/ {
        return Nil, Nil, self!return_400;
    }

    my $docroot = $!root || ".";
    my @path = $path.split(/<[\\/]>/);

    if @path {
        @path.shift if $path[0] eq '';
    } else {
        @path = ".";
    }

    note $docroot.perl;
    note @path.perl;

    if grep /^ \. ** 2 /, @path {
        return Nil, Nil, self!return_403;
    }

    my ($file, @path-info);
    while @path {
        my $try = IO::Spec::Unix.catfile($docroot, |@path);
        note $try.perl;
        if self!should-handle($try) {
            $file = $try;
            last;
        } elsif !self.allow-path-info {
            last;
        }
        @path-info.unshift( @path.pop );
    }
    unless $file {
        return Nil, Nil, self!return_404;
    }
    unless $file.IO.r {
        return Nil, Nil, self!return_403;
    }

    return $file, join("/", "", |@path-info);
}

method allow-path-info { False }

method !serve-path($env, $file) {
    my $content-type = $!content-type || Crust::MIME.mime-type($file) || 'text/plain';
    if $content-type ~~ Callable {
        $content-type = $content-type($file);
    }

    if $content-type ~~ /^ text '/' / {
        $content-type ~= "; charset=" ~ ( $!encoding || "utf-8" );
    }

    my $fh = try open $file, :bin;
    return self!return_403 unless $fh;

    return
        200,
        [
            'Content-Type' => $content-type,
            'Content-Length' => $file.IO.s,
            'Last-Modified' => $file.IO.modified,
        ],
        $fh,
    ;
}

method !return_403() {
    return 403, ['Content-Type' => 'text/plain', 'Content-Length' => 9], ['forbidden'.encode('ascii')];
}
method !return_400() {
    return 400, ['Content-Type' => 'text/plain', 'Content-Length' => 11], ['Bad Request'.encode('ascii')];
}
method !return_404() {
    return 404, ['Content-Type' => 'text/plain', 'Content-Length' => 9], ['not found'.encode('ascii')];
}

=begin pod

=head1 NAME

Crust::App::File - like Plack::App::File

=head1 SYNOPSIS

  > cat app.psgi6
  use Crust::App::File;
  Crust::App::File.new.to-app;

  > crustup app.psgi6

=head1 DESCRIPTION

Crust::App::File is 

=head1 COPYRIGHT AND LICENSE

Copyright 2015 Shoichi Kaji <skaji@cpan.org>

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

=end pod
