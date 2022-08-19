# Changlog
>For RakuConfig


## Table of Contents
[2021-01-24](#2021-01-24)  
[2021-01-27](#2021-01-27)  
[2021-02-08](#2021-02-08)  
[v0.3.1 2022-07-08](#v031-2022-07-08)  
[v0.4.0 2022-07-08](#v040-2022-07-08)  
[Head](#head)  

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

# v0.3.1 2022-07-08
*  bump version

*  change auth to zef, prepare for fez

*  change to githhub actions

# v0.4.0 2022-07-08
*  change version to 3 part, bump

# head

v0.5.0 2022-08-19



*  removed all mention of :no-cache. It is an unnecessary optimisation. Config files are not large.

*  comment out proto for write-config. This removes all reference to write-config.

*  rename xt/01

*  rewrote test files & README to eliminated :no-cache

*  renamed all files to raku* extensions





----
Rendered from CHANGELOG at 2022-08-19T21:27:51Z