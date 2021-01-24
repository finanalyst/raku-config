use PrettyDump;

class X::RakuConfig::NoFiles is Exception {
    has $.path;
    has $.comment;
    method message {
        "｢$!path｣ $!comment"
    }
}
class X::RakuConfig::MissingKeys is Exception {
    has @.missing;
    method message {
        "The following keys were expected, but not found:"
                ~ @!missing.gist
    }
}
class X::RakuConfig::BadConfig is Exception {
    has $.path;
    has $.response;
    method message {
        "｢$!path｣ did not evaluate correctly with ｢$!response｣"
    }
}
class X::RakuConfig::OverwriteKey is Exception {
    has $.path;
    has @.overlap;
    method message {
        "｢$!path｣ has keys which over-write the existing: " ~ @!overlap.gist
    }
}
class X::RakuConfig::BadDirectory is Exception {
    has $.path;
    has $.fn;
    method message {
        "Cannot write ｢$!fn｣ to ｢$!path｣."
    }
}

module RakuConfig {
    #| :path is an existing file, or a current directory,
    #| if a directory, it should contain .raku files
    #| :required are the keys needed in a config after all .raku files are evaluated
    #| If :required is not given, or empty, no keys will be tested for existence
    #| With no parameters, the file 'config.raku' in the current directory is assumed
    #| Previous value of config is not used when :cache(False)
    proto sub get-config(| --> Hash) is export {*};

    #| writes $s to config.raku by default,
    #| will also write tp :path / :fn, if path exists
    proto sub write-config(|) is export {*};

    multi sub get-config(:$path = 'config.raku', :@required, Bool :$cache = True) {
        state %config;
        state $prev-path;
        my Bool $test-keys = ?( +@required );
        return %config if $cache and $prev-path and $path eq $prev-path
                and (!$test-keys or %config.keys (>=) @required);
        $prev-path = $path;
        %config = Empty;
        given $path.IO {
            when :f {
                %config = EVALFILE $path;
                CATCH {
                    default {
                        X::RakuConfig::BadConfig.new(:$path, :response(.gist)).throw
                    }
                }
            }
            when :d {
                my @files = $path.IO.dir(test => / '.raku' /).sort>>.Str;
                X::RakuConfig::NoFiles.new(:$path, :comment('is a directory without .raku files')).throw
                unless +@files;
                for @files -> $file {
                    my %partial = EVALFILE "$file";
                    CATCH {
                        default {
                            X::RakuConfig::BadConfig.new(:path($path.subst(/ ^ "$*CWD" '/' /, '')), :response(.gist))
                            .throw
                        }
                    }
                    my @overlap = (%config.keys (&) %partial.keys).keys;
                    X::RakuConfig::OverwriteKey
                            .new(:path($path.subst(/ ^ "$*CWD" '/' /, '')), :@overlap)
                            .throw
                    if +@overlap;
                    %config ,= %partial
                    # merge partial into config
                }
            }
            default {
                X::RakuConfig::NoFiles.new(:$path, :comment('is not a file or a directory')).throw;
            }
        }
        X::RakuConfig::MissingKeys.new(:missing((@required (-) %config.keys).keys.flat)).throw
            unless ! $test-keys or %config.keys (>=) @required;
        # the keys on the RHS above are required in %config. To throw here, the templates supplied are not
        # a superset of the required keys.
        %config
    }
    multi sub write-config($ds) {
        write-config($ds, :path<.>, :fn<config.raku>)
    }
    multi sub write-config($ds, Str:D :$path where *.IO.d, Str :$fn = 'config.raku') {
        "$path/$fn".IO.spurt: compile-dump($ds)
    }
    multi sub write-config($ds, Str:D :$path where ! *.IO.d, :$fn ) {
        X::RakuConfig::BadDirectory.new(:$path,:$fn).throw;
    }

    sub compile-dump($ds --> Str) {
        my $pretty = PrettyDump.new;
        my $pair-code = -> PrettyDump $pretty, $ds, Int:D :$depth = 0 --> Str {
            [~]
            $ds.key,
            ' => ',
            $pretty.dump: $ds.value, :depth(0)

        };
        my $hash-code = -> PrettyDump $pretty, $ds, Int:D :$depth = 0 --> Str {
            my $longest-key = $ds.keys.max: *.chars;
            my $template = "%-{ 2 + $depth + 1 + $longest-key.chars }s => %s";

            my $str = do {
                if @($ds).keys {
                    my $separator = [~] $pretty.pre-separator-spacing, ',', $pretty.post-separator-spacing;
                    [~]
                    $pretty.pre-item-spacing,
                    join($separator,
                            grep { $_ ~~ Str:D },
                                    map {
                                        /^ \t* '｢' .*? '｣' \h+ '=>' \h+/
                                                ??
                                                sprintf($template, .split: / \h+ '=>' \h+  /, 2)
                                                !!
                                                $_
                                    },
                                            map { $pretty.dump: $_, :depth($depth + 1) }, $ds.pairs
                    ),
                    $pretty.post-item-spacing;
                }
                else {
                    $pretty.intra-group-spacing;
                }
            }

            "\%($str)"
        }
        my $match-code = -> PrettyDump $pretty, $ds, Int:D :$depth = 0 --> Str {
            $pretty.Match($ds, :start</>, :end</>)
        };
        my $array-code = -> PrettyDump $pretty, $ds, Int:D :$depth = 0 --> Str {
            $pretty.Array($ds, :start<[>)
        };
        my $list-code = -> PrettyDump $pretty, $ds, Int:D :$depth = 0 --> Str {
            $pretty.List($ds, :start<(>)
        };

        $pretty.add-handler: 'Pair', $pair-code;
        $pretty.add-handler: 'Hash', $hash-code;
        $pretty.add-handler: 'Array', $array-code;
        $pretty.add-handler: 'Match', $match-code;
        $pretty.add-handler: 'List', $list-code;
        $pretty.dump: $ds
    }
}