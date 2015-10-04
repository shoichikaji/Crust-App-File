[![Build Status](https://travis-ci.org/shoichikaji/Crust-App-File.svg?branch=master)](https://travis-ci.org/shoichikaji/Crust-App-File)

NAME
====

Crust::App::File - like Plack::App::File

SYNOPSIS
========

    > cat app.psgi6
    use Crust::App::File;
    Crust::App::File.new.to-app;

    > crustup app.psgi6

DESCRIPTION
===========

Crust::App::File is 

COPYRIGHT AND LICENSE
=====================

Copyright 2015 Shoichi Kaji <skaji@cpan.org>

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.
