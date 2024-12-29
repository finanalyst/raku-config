
# Raku Config files

	Introducing RakuON (Raku Object Notation) to write configuration files.

----

## Table of Contents

<a href="#LICENSE">LICENSE</a>   
<a href="#AUTHOR">AUTHOR</a>   
<a href="#Purpose">Purpose</a>   
<a href="#Installation_and_use">Installation and use</a>   
<a href="#Subs_Three_subs_are_exported">Subs Three subs are exported</a>   
&nbsp;&nbsp;- <a href="#get-config">get-config</a>   
&nbsp;&nbsp;- <a href="#write-config">write-config</a>   
&nbsp;&nbsp;- <a href="#format-config">format-config</a>   
<a href="#Testing">Testing</a>   


<div id="LICENSE"></div>

## LICENSE
Artist 2

<div id="AUTHOR"></div>

## AUTHOR
Richard Hainsworth, aka finanalyst

<div id="Purpose"></div>

## Purpose
<span class="para" id="bb1df9a"></span>Lots of modules need configuration files. Many Raku modules use JSON, or YAML. But neither YAML nor JSON is not Raku, and a configuration file has to be brought in and assigned to a data structure, typically a HASH. 

<span class="para" id="6ef7304"></span>But writing JSON or YAML means memorising the syntax of that language, then mapping it to Raku. 

<span class="para" id="8a448c4"></span>So, why not simply write the file in Raku and use EVALFILE to assign it to a Hash? 

<span class="para" id="74f1e64"></span>There is an objection that Raku code is being injected into a program. But the same is true for any module. Configuration is only taken from a file in the control of the developer. Configuration is not a change of state from outside the control of the developer. It is EVALFILE, not EVAL. 

<span class="para" id="a343b3a"></span>This module uses that idea, but allows for the configuration file(s) to be anywhere accessible by the program. 

<span class="para" id="bf944b9"></span>When reading in a configuration file, any Raku code is possible, so configuration files can look at Environment variables, or slurp in local files. 


<div id="Installation and use"></div><div id="Installation_and_use"></div>

## Installation and use
<span class="para" id="743dbe8"></span>Simply 


```
zef install RakuConfig
```
<span class="para" id="d0a9af9"></span>then 


```
use RakuConfig;
my %config = get-config;
# assumes that 'config.raku' exists in the current directory.
my %big-config = get-config( 'config-files' );
# assumes multiple files of the form config-files/*.raku
# files are evaluated in lexical order
# detects whether keys in one file overwrite a previously set key
# throws an Exception if an overwrite is attempted.
```

<div id="Subs Three subs are exported"></div><div id="Subs_Three_subs_are_exported"></div>

## Subs Three subs are exported
<div id="get-config"></div>

### get-config
<span class="para" id="57dafba"></span>Has several variants 


```
get-config
```
<span class="para" id="4b6b615"></span>Will look in the current working directory for `config.raku` and / or `configs/` subdirectory. 

<span class="para" id="e7ada83"></span>If both found, the keys will be merged, but repeated keys (eg. in two or more of the files in the `configs/` subdirectory) will raise an exception 


```
get-config(:@required)
```
<span class="para" id="12e88ee"></span>Will look for the keys listed in @required in the defaults, as above. 

<span class="para" id="ff4f6fa"></span>If the @required keys are not found, a MissingKeys exception will be thrown. 


```
get-config(Str:D $mode)
```
<span class="para" id="a0c0a6e"></span>Will look for both `config.raku` and files under `configs/` in the $mode directory. Throws a *NotValidDirectory* exception if $mode is not a directory. 


```
#| :path is an existing file, or a directory,
#| if a directory, it should contain .raku files
#| :required are the keys needed in a config after all .raku files are evaluated
#| If :required is not given, or empty, no keys will be tested for existence
multi sub get-config(:$path, :@required )
```
<span class="para" id="2f91930"></span>This allows for non-default filenames or directories to be searched as if `config.raku` or `configs/` 

<div id="write-config"></div>

### write-config

```
multi sub write-config(%ds, :$path, :$fn, :@save )
```
<span class="para" id="6755690"></span>`write-config` attempts to write a readable config file. 

<span class="para" id="f77dea0"></span>%ds is the config file to be written as Raku hash. 

<span class="para" id="51ea4f0"></span>$path is a string that must be a valid path, or the Current working directory 

<span class="para" id="2a2be56"></span>$fn is the file name where the hash is to be stored, defaults to 'config.raku' 

<span class="para" id="8d22d10"></span>@save, see format-config 

<div id="format-config"></div>

### format-config

```
multi sub format-config(%ds, @save)
```
<span class="para" id="ee93c49"></span>Formats %ds for writing. If a key points to a type that is not known to the formatter, it will revert to the `.raku` version. 

<span class="para" id="ffdbcbc"></span>@save is a list of keys to be written, defaults to Empty, in which case all keys are written. 

<div id="Testing"></div>

## Testing
<span class="para" id="2d08281"></span>To reduce testing and installation hassle, the following have been removed from Test-depends: 'Test::META', 'Test::Deeply::Relaxed', 'File::Directory::Tree'". They will need to be installed to prove the xt/ tests.



----

----

Rendered from ./README.rakudoc/README at 19:02 UTC on 2024-12-29

Source last modified at 19:01 UTC on 2024-12-29

