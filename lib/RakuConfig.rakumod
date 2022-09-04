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

#| :path is an existing file, or a current directory,
#| if a directory, it should contain .raku files
#| :required are the keys needed in a config after all .raku files are evaluated
#| If :required is not given, or empty, no keys will be tested for existence
#| With no parameters, the file 'config.raku' in the current directory is assumed
multi sub get-config(:$path = 'config.raku', :@required) is export {
    my %config;
    my Bool $test-keys = ?(+@required);
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
                        BadConfig.new(:path($path.subst(/ ^ "$*CWD" '/' /, '')), :response(.gist))
                            .throw
                    }
                }
                my @overlap = (%config.keys (&) %partial.keys).keys;
                OverwriteKey
                    .new(:path($path.subst(/ ^ "$*CWD" '/' /, '')), :@overlap)
                    .throw
                if +@overlap;
                %config ,= %partial
                # merge partial into config
            }
        }
        default {
            NoFiles.new(:$path, :comment('is not a file or a directory')).throw;
        }
    }
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
                @r-lines.append: "\t" x $level ~ ":{ $key }{ $val ?? '<' ~ $val ~ '>' !! '()' },"
            }
            when Num {
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
                    ~ "\t" x ($level+1) ~ $val.raku
                    ~ "\n" ~ "\t" x $level ~ '),'
            }
        }
    }
    return @r-lines if $level > 1;
    "%\(\n" ~ @r-lines.join("\n") ~ "\n)"
}
multi sub format-config(@a, :$level --> Str) is export {
    @a.map({ "\n" ~ "\t" x $level ~ "\"$_\"," }).join
}
