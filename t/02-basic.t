use Test;
use RakuConfig;
use Test::Deeply::Relaxed;
use File::Directory::Tree;

plan 9;

my $tmp = 'tmp';
my $cwd = $*CWD;
rmtree $tmp if $tmp.IO.e;
mktree $tmp;
chdir $tmp;

my $path = 'config.raku';

my %config = <one two three > Z=> 1 ..*;
$path.IO.spurt: %config.raku;

is-deeply-relaxed get-config, %config, 'simple get works';
$path.IO.unlink;

write-config(%config);
my $rv = $path.IO.slurp;
like $rv, /
['one => 1' \,? .+?
| 'two => 2' \,? .+?
| 'three => 3' \,? .+?
] ** 3
/, 'written human readable';

is-deeply-relaxed get-config, %config, 'round about correct';

$path.IO.unlink;
$path = 'configs';
mktree $path;

write-config(%config, :$path);
is-deeply-relaxed get-config(:path("$path/config.raku")), %config, 'different filename round about correct';

empty-directory $path;
my %big-conf;
for <xfig yfig zfig> {
    my %config = (<a b c>  X~ $_) Z=> 1 ..*;
    write-config(%config, :$path, :fn($_ ~ '.raku'));
    %big-conf,=%config;
}

is-deeply-relaxed get-config(:$path), %big-conf, "config from multiple files";

throws-like { get-config(:$path, :required<mode supply>) },
        X::RakuConfig::MissingKeys,
        message => / 'The following keys were expected' /,
        'died without required keys', ;
# with automagical caching
lives-ok { get-config(:$path, :required<axfig byfig czfig azfig>) }, 'happy with keys';
# prevent caching by changing path
rmtree $path;
$path = 'plugs';
mktree $path;
%big-conf = Empty;
for <xfig yfig zfig> {
    my %config = (<a b c>  X~ $_) Z=> 1 ..*;
    write-config(%config, :$path, :fn($_ ~ '.raku'));
    %big-conf,= %config;
}
is-deeply-relaxed get-config(:$path, :required<axfig byfig czfig azfig>),
        %big-conf, "config from multiple files with required keys";

rmtree $path;
throws-like { $rv = write-config(%config, :$path, :fn<xxx.raku>) },
    X::RakuConfig::BadDirectory,
    'captures non-existent directory',
    message => / 'Cannot write' .+ 'to' /;

#restore
chdir $cwd;
rmtree $tmp;

done-testing;
