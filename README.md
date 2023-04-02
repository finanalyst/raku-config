# Raku Config files
>Introducing RakuON (Raku Object Notation) to write configuration files.


> **Author** Richard Hainsworth, aka finanalyst


----
## Table of Contents
[License](#license)  
[Purpose](#purpose)  
[Installation and use](#installation-and-use)  
[Subs Three subs are exported](#subs-three-subs-are-exported)  
[get-config](#get-config)  
[write-config](#write-config)  
[format-config](#format-config)  
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
# Subs Three subs are exported
## get-config
Has several variants

```
get-config
```
Will look in the current working directory for `config.raku` and / or `configs/` subdirectory.

If both found, the keys will be merged, but repeated keys (eg. in two or more of the files in the `configs/` subdirectory) will raise an exception

```
get-config(:@required)
```
Will look for the keys listed in @required in the defaults, as above.

If the @required keys are not found, a MissingKeys exception will be thrown.

```
get-config(Str:D $mode)
```
Will look for both `config.raku` and files under `configs/` in the $mode directory. Throws a _NotValidDirectory_ exception if $mode is not a directory.

```
#| :path is an existing file, or a directory,
#| if a directory, it should contain .raku files
#| :required are the keys needed in a config after all .raku files are evaluated
#| If :required is not given, or empty, no keys will be tested for existence
multi sub get-config(:$path, :@required )
```
This allows for non-default filenames or directories to be searched as if `config.raku` or `configs/`

## write-config
```
multi sub write-config(%ds, :$path, :$fn, :@save )
```
`write-config` attempts to write a readable config file.

%ds is the config file to be written as Raku hash.

$path is a string that must be a valid path, or the Current working directory

$fn is the file name where the hash is to be stored, defaults to 'config.raku'

@save, see format-config

## format-config
```
multi sub format-config(%ds, @save)
```
Formats %ds for writing. If a key points to a type that is not known to the formatter, it will revert to the `.raku` version.

@save is a list of keys to be written, defaults to Empty, in which case all keys are written.

# Testing
To reduce testing and installation hassle, the following have been removed from Test-depends: 'Test::META', 'Test::Deeply::Relaxed', 'File::Directory::Tree'". They will need to be installed to prove the xt/ tests.







----
Rendered from README at 2023-04-02T17:59:46Z