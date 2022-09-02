![github-tests-passing-badge](https://github.com/finanalyst/raku-config/actions/workflows/test.yaml/badge.svg)
# Raku Config files
>Introducing RakuON (Raku Object Notation) to write configuration files.


> **Author** Richard Hainsworth, aka finanalyst


----
## Table of Contents
[License](#license)  
[Purpose](#purpose)  
[Installation and use](#installation-and-use)  
[Subs Two subs are exported](#subs-two-subs-are-exported)  
[get-config](#get-config)  
[write-config](#write-config)  
[Testing](#testing)  

----
# LICENSE

Artist 2

# Purpose
Lots of modules need configuration files. Many Raku modules use JSON, or YAML. But neither YAML nor JSON is not Raku, and a configuration file has to be brought in and assigned to a data structure, typically a HASH.

But writing JSON or YAML means memorising the syntax of that language, then mapping it to Raku.

So, why not simply write the file in Raku and use EVALFILE to assign it to a Hash?

There is an objection that Raku code is being injected into a program. But the same is true for any module. Configuration is only taken from a file in the control of the developer. Configuration is not a change of state from outside the control of the developer. It is EVALFILE, not EVAL.

This module uses that idea, but allows for the configuration file(s) to be anywhere accessible by the program.

When reading in a configuration file, any Raku code is possible, so configuration files can look at Environment variables, or slurp in local files.

# Installation and use
Simply

```
zef install RakuConfig
```
then

```
use RakuConfig;
my %config = get-config;
# assumes that 'config.raku' exists in the current directory.
my %big-config = get-config( 'config-files' );
# assumes multiple files of the for config-files/*.raku
# files are evaluated in lexical order
# detects whether keys in one file overwrite a previously set key
# throws an Exception if an overwrite is attempted.
```
# Subs Two subs are exported
## get-config
```
#| :path is an existing file, or a current directory,
#| if a directory, it should contain .raku files
#| :required are the keys needed in a config after all .raku files are evaluated
#| If :required is not given, or empty, no keys will be tested for existence
#| With no parameters, the file 'config.raku' in the current directory is assumed
multi sub get-config(:$path = 'config.raku', :@required )
```
## write-config
```
#| :path is an existing file, or a current directory,
#| if a directory, it should contain .raku files
#| :save are the keys to be stored in the config file
#| If :save is not given, or empty, ALL the keys will be saved
#| With no parameters, the file 'config.raku' in the current directory is assumed
multi sub write-config(:$path = 'config.raku', :@required )
```
`write-config` attempts to write a readable config file. But if a type is not known, it will revert to the `.raku` version.

# Testing
To reduce testing and installation hassle, the following have been removed from Test-depends: 'Test::META', 'Test::Deeply::Relaxed', 'File::Directory::Tree'". They will need to be installed to prove the xt/ tests.







----
Rendered from README at 2022-09-02T20:52:10Z