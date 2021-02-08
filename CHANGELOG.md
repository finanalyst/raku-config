# Changlog

----
----
## Table of Contents
[2021-01-24](#2021-01-24)  
[2021-01-27](#2021-01-27)  
[2021-02-08](#2021-02-08)  

----
# 2021-01-24
*  Add Changelog

*  Add test for no config.raku file

*  re-order tests, put author and extensive tests in xt/

*  add :cache = True option, so that if :!cache, then the previous value of config is not used

# 2021-01-27
*  added test for empty strings in config files, no need to change code

*  removed :cache and replaced with :no-cache which is False by default

# 2021-02-08


*  removed write-config, so as to reduce dependency on PrettyDump.

*  remove 'Test::META', 'Test::Deeply::Relaxed', 'File::Directory::Tree' from Test depends.





----
Rendered from CHANGELOG at 2021-02-08T12:35:37Z