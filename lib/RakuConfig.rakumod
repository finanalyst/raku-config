use v6.d;
unit module RakuConfig;

class NoFiles is Exception {
    has $.path;
    has $.comment;
    method message {
        "｢$!path｣ $!comment"
    }
}
class MissingKeys is Exception {
    has @.missing;
    method message {
        "The following keys were expected, but not found:"
            ~ @!missing.gist
    }
}
class BadConfig is Exception {
    has $.path;
    has $.response;
    method message {
        "｢$!path｣ did not evaluate correctly with ｢$!response｣"
    }
}
class OverwriteKey is Exception {
    has $.path;
    has @.overlap;
    method message {
        "｢$!path｣ has keys which over-write the existing: " ~ @!overlap.gist
    }
}
class BadDirectory is Exception {
    has $.path;
    has $.fn;
    method message {
        "Cannot write ｢$!fn｣ to ｢$!path｣."
    }
}
class NotValidDirectory is Exception {
    has $.mode;
    method message {
        "Expecting ｢$!mode｣ to be a directory"
    }
}

multi sub get-config() {
    get-config($*CWD.Str)
}
multi sub get-config(:@required!) {
    get-config($*CWD.Str, :@required)
}
multi sub get-config(Str:D $mode, :@required --> Associative) is export {
    NotValidDirectory.new(:$mode).throw
        unless $mode.IO ~~ :e & :d;
    my Bool $no-config-file = False;
    my %config;
    try {
        %config = get-config(:path("$mode/config.raku"), :@required);
        CATCH {
            when RakuConfig::BadConfig {
                .rethrow
            }
            when RakuConfig::MissingKeys {
                # will retest after tried default directory
                .resume
            }
            when RakuConfig::NoFiles {
                %config = Empty;
                $no-config-file = True;
                .resume
            }
            default { .rethrow }
        }
    }
    try {
        %config ,= get-config(:path("$mode/configs"), :@required);
        CATCH {
            when RakuConfig::BadConfig {
                .rethrow
            }
            when RakuConfig::MissingKeys {
                # will retest
                .resume
            }
            when RakuConfig::NoFiles {
                .resume unless $no-config-file;
                RakuConfig::NoFiles.new(:path($mode),
                    :comment('contains neither ｢config.raku｣ nor ｢configs/｣ with valid config files')
                    ).throw
            }
            default { .rethrow }
        }
    }
    test-missing-keys(%config, @required)
}
#| :path is an existing file, or a current directory,
#| if a directory, it should contain .raku files
#| :required are the keys needed in a config after all .raku files are evaluated
#| If :required is not given, or empty, no keys will be tested for existence
multi sub get-config(:$path!, :@required --> Associative) is export {
    my %config;
    given $path.IO {
        when :e and :f {
            %config = EVALFILE $path;
            CATCH {
                default {
                    BadConfig.new(:$path, :response(.gist)).throw
                }
            }
        }
        when :d {
            my @files = $path.IO.dir(test => / '.raku' /).sort>>.Str;
            NoFiles.new(:$path, :comment('is a directory without .raku files')).throw
            unless +@files;
            for @files -> $file {
                my %partial = EVALFILE "$file";
                CATCH {
                    default {
                        BadConfig.new(:path($path.IO.basename), :response(.gist))
                            .throw
                    }
                }
                my @overlap = (%config.keys (&) %partial.keys).keys;
                OverwriteKey
                    .new(:path($path.IO.basename), :@overlap)
                    .throw
                if +@overlap;
                %config ,= %partial
                # merge partial into config
            }
        }
        default {
            NoFiles.new(:path($path.IO.basename), :comment('is not a file or a directory')).throw;
        }
    }
    test-missing-keys(%config, @required)
}
sub test-missing-keys(%config, @required --> Associative) {
    my Bool $test-keys = ?(+@required);
    MissingKeys.new(:missing((@required (-) %config.keys).keys.flat)).throw
    unless !$test-keys or %config.keys (>=) @required;
    # the keys on the RHS above are required in %config. To throw here, the templates supplied are not
    # a superset of the required keys.
    %config
}
multi sub write-config(%ds) is export {
    write-config(%ds, :path(~$*CWD), :fn<config.raku>)
}
multi sub write-config(%ds, Str:D :$path where *.IO.d, Str :$fn = 'config.raku', :@save) is export {
    "$path/$fn".IO.spurt: format-config(%ds, :@save)
}
multi sub write-config(%ds, Str:D :$path where !*.IO.d, :$fn) is export {
    BadDirectory.new(:$path, :$fn).throw;
}

#| format a config file for writing.
multi sub format-config(%d, :$level = 1, :@save = () --> Str) is export {
    my @r-lines;
    for %d.sort.map(|*.kv) -> $key, $val {
        next if (@save and $key !~~ any(@save));
        given $val {
            when Bool {
                @r-lines.append: "\t" x $level ~ "{ $val ?? ':' !! ':!' }$key,"
            }
            when Associative {
                @r-lines.append: "\t" x $level ~ ":$key\( \%(\n" ~ format-config($val, :level($level + 1))
                    ~ "\n" ~ "\t" x $level ~ ")),";
            }
            when Str:D {
                my @lines = $val.lines;
                if @lines.elems <= 1 {
                    @r-lines.append: "\t" x $level ~ ":{ $key }{ $val ?? '<' ~ $val ~ '>' !! '()' },"
                }
                else {
                    @r-lines.append: "\t" x $level ~ ":{ $key }( q:to/DATA/ ),";
                    @r-lines.append: "\t" x ($level+1) ~ @lines.join( "\n" ~ "\t" x ($level+1) );
                    @r-lines.append: "\t" x ($level+1) ~ 'DATA'
                }
            }
            when Numeric {
                @r-lines.append: "\t" x $level ~ ":$key\($val),"
            }
            when Positional {
                if .elems {
                    @r-lines.append:
                        "\t" x $level
                            ~ ":$key\("
                            ~ format-config($val, :level($level + 1))
                            ~ "\n" ~ "\t" x $level ~ "),"
                }
                else {
                    @r-lines.append: "\t" x $level ~ ":$key\(),"
                }
            }
            default {
                @r-lines.append: "\t" x $level ~ ":$key\(\n"
                    ~ "\t" x ($level + 1) ~ $val.raku
                    ~ "\n" ~ "\t" x $level ~ '),'
            }
        }
    }
    if $level > 1 { @r-lines.join("\n") }
    else { "%\(\n" ~ @r-lines.join("\n") ~ "\n)" }
}
multi sub format-config(@a, :$level --> Str) is export {
    @a.map({ "\n" ~ "\t" x $level ~ "\"$_\"," }).join
}
