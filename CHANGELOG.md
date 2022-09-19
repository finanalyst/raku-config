# Changlog
>For RakuConfig


## Table of Contents
[2021-01-24](#2021-01-24)  
[2021-01-27](#2021-01-27)  
[2021-02-08](#2021-02-08)  
[v0.3.1 2022-07-08](#v031-2022-07-08)  
[v0.4.0 2022-07-08](#v040-2022-07-08)  
[v0.5.0 2022-08-19](#v050-2022-08-19)  
[v0.6.0 2022-09-02](#v060-2022-09-02)  
[v0.6.1 2022-09-03](#v061-2022-09-03)  
[v0.7.0 2022-09-11](#v070-2022-09-11)  
[v0.7.1 2022-09-13](#v071-2022-09-13)  
[v0.7.2 2022-09-16](#v072-2022-09-16)  
[v0.7.3 2022-09-19](#v073-2022-09-19)  

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

# v0.5.0 2022-08-19
*  removed all mention of :no-cache. It is an unnecessary optimisation. Config files are not large.

*  comment out proto for write-config. This removes all reference to write-config.

*  rename xt/01

*  rewrote test files & README to eliminated :no-cache

*  renamed all files to raku* extensions

# v0.6.0 2022-09-02
*  added write-config & format-config with minimal pretty formatting.

# v0.6.1 2022-09-03
*  remove redundant no-precompilation

# v0.7.0 2022-09-11
*  increased default behaviour so that one of or both of following are tried

	*  config.raku in CWD

	*  configs/ directory

	*  if both, then the keys are merged and tested against @required

*  added get-config( Str )

	*  where the Str is a directory

*  if not given CWD is default.

*  rewrite README

*  fix CHANGELOG

*  fix tests with cleanup

# v0.7.1 2022-09-13
*  fix bad return type with embedded Hash

# v0.7.2 2022-09-16
*  change formatting of multiline Str.

*  make Num into Numeric to capture more generic numbers

# v0.7.3 2022-09-19


*  add tests for mode form of RakuConfig

*  improve Exception message for non-directory mode

*  fix error in mode





----
Rendered from CHANGELOG at 2022-09-19T17:54:05Z