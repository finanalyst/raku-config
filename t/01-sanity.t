use Test;

plan 2;
use-ok 'RakuConfig', 'compiles and loads';
if %*ENV<AUTHOR_TESTING> {
    require Test::META <&meta-ok>;
    meta-ok;
}
else {
    skip 'Set AUTHOR_TESTING to test meta file';
}
done-testing;
