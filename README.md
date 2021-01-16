# Raku Config files
>Using Raku code to write configuration files.


----
## Table of Contents
[License](#license)  
[Head](#head)  
[Head](#head)  
[Head](#head)  
[get-config](#get-config)  
[write-config](#write-config)  

----
# LICENSE

Artist 2

# head

Purpose

Lots of modules need configuration files. Many Raku modules use JSON, or YAML. But neither YAML nor JSON is not Raku, and a configuration file has to be brought in and assigned to a data structure, typically a HASH.

But writing JSON or YAML means memorising the syntax of that language, then mapping it to Raku.

So, why not simply write the file in Raku and use EVALFILE to assign it to a Hash?

This module uses that idea, but allows for the configuration module to be anywhere.

When reading in a configuration file, any Raku code is possible, so configuration files can look at Environment variables, or slurp in local files.

When writing a configuration file, there are many caveats relating to what can be serialised, but for static data, not closures, writing a config file is easy.

# head

Installation and use

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
# head

Subs Only two subs are exported

## get-config
```
#| :path is an existing file, or a current directory,
#| if a directory, it should contain .raku files
#| :required are the keys needed in a config after all .raku files are evaluated
#| If :required is not given, or empty, no keys will be tested for existence
#| With no parameters, the file 'config.raku' in the current directory is assumed
multi sub get-config(:$path = 'config.raku', :@required)
```
## write-config
```
#| writes $s to config.raku by default, but will take any path fn, so long as path exists
multi sub write-config($ds)
multi sub write-config($ds, Str:D :$path where *.IO.d, Str :$fn = 'config.raku')
multi sub write-config($ds, Str:D :$path where ! *.IO.d, :$fn )
```







----
Rendered from README at 2021-01-16T11:31:24Z