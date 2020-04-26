# Testing Code Symtax Highlighting {.title}

## Bash

~~~ bash
#!/bin/bash

###### CONFIG
ACCEPTED_HOSTS="/root/.hag_accepted.conf"
BE_VERBOSE=false

if [ "$UID" -ne 0 ]
then
 echo "Superuser rights required"
 exit 2
fi

genApacheConf(){
 echo -e "# Host ${HOME_DIR}$1/$2 :"
}

echo '"quoted"' | tr -d \" > text.txt
~~~

## C#

~~~ C#
using System.IO.Compression;

#pragma warning disable 414, 3021

namespace MyApplication
{
    [Obsolete("...")]
    class Program : IInterface
    {
        public static List<int> JustDoIt(int count)
        {
            Console.WriteLine($"Hello {Name}!");
            return new List<int>(new int[] { 1, 2, 3 })
        }
    }
}
~~~

## C++

~~~ C++
#include <iostream>

int main(int argc, char *argv[]) {

  /* An annoying "Hello World" example */
  for (auto i = 0; i < 0xFFFF; i++)
    cout << "Hello, World!" << endl;

  char c = '\n';
  unordered_map <string, vector<string> > m;
  m["key"] = "\\\\"; // this is an error

  return -2e3 + 12l;
}
~~~

## Clojure

~~~ clojure
(def ^:dynamic chunk-size 17)

(defn next-chunk [rdr]
  (let [buf (char-array chunk-size)
        s (.read rdr buf)]
  (when (pos? s)
    (java.nio.CharBuffer/wrap buf 0 s))))

(defn chunk-seq [rdr]
  (when-let [chunk (next-chunk rdr)]
    (cons chunk (lazy-seq (chunk-seq rdr)))))
~~~

## CMake

~~~ cmake
cmake_minimum_required(VERSION 2.8.8)
project(cmake_example)

# Show message on Linux platform
if (${CMAKE_SYSTEM_NAME} MATCHES Linux)
    message("Good choice, bro!")
endif()

# Tell CMake to run moc when necessary:
set(CMAKE_AUTOMOC ON)
# As moc files are generated in the binary dir,
# tell CMake to always look for includes there:
set(CMAKE_INCLUDE_CURRENT_DIR ON)

# Widgets finds its own dependencies.
find_package(Qt5Widgets REQUIRED)

add_executable(myproject main.cpp mainwindow.cpp)
qt5_use_modules(myproject Widgets)
~~~

## CSS

~~~ css
@font-face {
  font-family: Chunkfive; src: url('Chunkfive.otf');
}

body, .usertext {
  color: #F0F0F0; background: #600;
  font-family: Chunkfive, sans;
  --heading-1: 30px/32px Helvetica, sans-serif;
}

@import url(print.css);
@media print {
  a[href^=http]::after {
    content: attr(href)
  }
}
~~~

## Diff

~~~ diff
Index: languages/ini.js
===================================================================
--- languages/ini.js    (revision 199)
+++ languages/ini.js    (revision 200)
@@ -1,8 +1,7 @@
 hljs.LANGUAGES.ini =
 {
   case_insensitive: true,
-  defaultMode:
-  {
+  defaultMode: {
     contains: ['comment', 'title', 'setting'],
     illegal: '[^\\s]'
   },

*** /path/to/original timestamp
--- /path/to/new      timestamp
***************
*** 1,3 ****
--- 1,9 ----
+ This is an important
+ notice! It should
+ therefore be located at
+ the beginning of this
+ document!

! compress the size of the
! changes.

  It is important to spell
~~~

## DOS .bat

~~~ dos
cd \
copy a b
ping 192.168.0.1
@rem ping 192.168.0.1
net stop sharedaccess
del %tmp% /f /s /q
del %temp% /f /s /q
ipconfig /flushdns
taskkill /F /IM JAVA.EXE /T

cd Photoshop/Adobe Photoshop CS3/AMT/
if exist application.sif (
    ren application.sif _application.sif
) else (
    ren _application.sif application.sif
)

taskkill /F /IM proquota.exe /T

sfc /SCANNOW

set path = test

xcopy %1\*.* %2
~~~

## F#

~~~ fsharp
open System

// Single line comment...
(*
  This is a
  multiline comment.
*)
let checkList alist =
    match alist with
    | [] -> 0
    | [a] -> 1
    | [a; b] -> 2
    | [a; b; c] -> 3
    | _ -> failwith "List is too big!"


let text = "Some text..."
let text2 = @"A ""verbatim"" string..."
let catalog = """
Some "long" string...
"""

let rec fib x = if x <= 2 then 1 else fib(x-1) + fib(x-2)

let fibs =
    Async.Parallel [ for i in 0..40 -> async { return fib(i) } ]
    |> Async.RunSynchronously

type Sprocket(gears) =
  member this.Gears : int = gears

[<AbstractClass>]
type Animal =
  abstract Speak : unit -> unit

type Widget =
  | RedWidget
  | GreenWidget

type Point = {X: float; Y: float;}

[<Measure>]
type s
let minutte = 60<s>

type DefaultMailbox<'a>() =
    let mutable inbox = ConcurrentQueue<'a>()
    let awaitMsg = new AutoResetEvent(false)
~~~

## Groovy

~~~ groovy
#!/usr/bin/env groovy
package model

import groovy.transform.CompileStatic
import java.util.List as MyList

trait Distributable {
    void distribute(String version) {}
}

@CompileStatic
class Distribution implements Distributable {
    double number = 1234.234 / 567
    def otherNumber = 3 / 4
    boolean archivable = condition ?: true
    def ternary = a ? b : c
    String name = "Guillaume"
    Closure description = null
    List<DownloadPackage> packages = []
    String regex = ~/.*foo.*/
    String multi = '''
        multi line string
    ''' + """
        now with double quotes and ${gstring}
    """ + $/
        even with dollar slashy strings
    /$

    /**
     * description method
     * @param cl the closure
     */
    void description(Closure cl) { this.description = cl }

    void version(String name, Closure versionSpec) {
        def closure = { println "hi" } as Runnable

        MyList ml = [1, 2, [a: 1, b:2,c :3]]
        for (ch in "name") {}

        // single line comment
        DownloadPackage pkg = new DownloadPackage(version: name)

        check that: true

        label:
        def clone = versionSpec.rehydrate(pkg, pkg, pkg)
        /*
            now clone() in a multiline comment
        */
        clone()
        packages.add(pkg)

        assert 4 / 2 == 2
    }
}
~~~

## HTML/XML

~~~ HTML
<!DOCTYPE html>
<title>Title</title>

<style>body {width: 500px;}</style>

<script type="application/javascript">
  function $init() {return true;}
</script>

<body>
  <p checked class="title" id='title'>Title</p>
  <!-- here goes the rest of the page -->
</body>
~~~

## HTTP

~~~ http
POST /task?id=1 HTTP/1.1
Host: example.org
Content-Type: application/json; charset=utf-8
Content-Length: 137

{
  "status": "ok",
  "extended": true,
  "results": [
    {"value": 0, "type": "int64"},
    {"value": 1.0e+3, "type": "decimal"}
  ]
}
~~~

## Java

~~~ java
/**
 * @author John Smith <john.smith@example.com>
*/
package l2f.gameserver.model;

public abstract class L2Char extends L2Object {
  public static final Short ERROR = 0x0001;

  public void moveTo(int x, int y, int z) {
    _ai = null;
    log("Should not be called");
    if (1 > 5) { // wtf!?
      return;
    }
  }
}
~~~

## JavaScript

~~~ javascript
function $initHighlight(block, cls) {
  try {
    if (cls.search(/\bno\-highlight\b/) != -1)
      return process(block, true, 0x0F) +
             ` class="${cls}"`;
  } catch (e) {
    /* handle exception */
  }
  for (var i = 0 / 2; i < classes.length; i++) {
    if (checkCondition(classes[i]) === undefined)
      console.log('undefined');
  }

  return (
    <div>
      <web-component>{block}</web-component>
    </div>
  )
}

export  $initHighlight;
~~~

## JSON

~~~ json
[
  {
    "title": "apples",
    "count": [12000, 20000],
    "description": {"text": "...", "sensitive": false}
  },
  {
    "title": "oranges",
    "count": [17500, null],
    "description": {"text": "...", "sensitive": false}
  }
]
~~~

## Lisp

~~~ lisp
#!/usr/bin/env csi

(defun prompt-for-cd ()
   "Prompts
    for CD"
   (prompt-read "Title" 1.53 1 2/4 1.7 1.7e0 2.9E-4 +42 -7 #b001 #b001/100 #o777 #O777 #xabc55 #c(0 -5.6))
   (prompt-read "Artist" &rest)
   (or (parse-integer (prompt-read "Rating") :junk-allowed t) 0)
  (if x (format t "yes") (format t "no" nil) ;and here comment
  )
  ;; second line comment
  '(+ 1 2)
  (defvar *lines*)                ; list of all lines
  (position-if-not #'sys::whitespacep line :start beg))
  (quote (privet 1 2 3))
  '(hello world)
  (* 5 7)
  (1 2 34 5)
  (:use "aaaa")
  (let ((x 10) (y 20))
    (print (+ x y))
  )
~~~

## Makefile

~~~ makefile
# Makefile

BUILDDIR      = _build
EXTRAS       ?= $(BUILDDIR)/extras

.PHONY: main clean

main:
	@echo "Building main facility..."
	build_main $(BUILDDIR)

clean:
	rm -rf $(BUILDDIR)/*
~~~

## Markdown

~~~ markdown
# hello world

you can write text [with links](http://example.com) inline or [link references][1].

* one _thing_ has *em*phasis
* two __things__ are **bold**

[1]: http://example.com

---

hello world
===========

<this_is inline="xml"></this_is>

> markdown is so cool

    so are code segments

1. one thing (yeah!)
2. two thing `i can write code`, and `more` wipee!
~~~

## Maxima

~~~ maxima
/* Maxima computer algebra system */

/* symbolic constants */

[true, false, unknown, inf, minf, ind,
 und, %e, %i, %pi, %phi, %gamma];

/* programming keywords */

if a then b elseif c then d else f;
for x:1 thru 10 step 2 do print(x);
for z:-2 while z < 0 do print(z);
for m:0 unless m > 10 do print(m);
for x in [1, 2, 3] do print(x);
foo and bar or not baz;

/* built-in variables */

[_, __, %, %%, linel, simp, dispflag,
 stringdisp, lispdisp, %edispflag];

/* built-in functions */

[sin, cosh, exp, atan2, sqrt, log, struve_h,
 sublist_indices, read_array];

/* user-defined symbols */

[foo, ?bar, baz%, quux_mumble_blurf];

/* symbols using Unicode characters */

[?, ?, ?, ?, ???, ?????];

/* numbers */

ibase : 18 $
[0, 1234, 1234., 0abcdefgh];
reset (ibase) $
[.54321, 3.21e+0, 12.34B56];

/* strings */

s1 : "\"now\" is";
s2 : "the 'time' for all good men";
print (s1, s2, "to come to the aid",
  "of their country");

/* expressions */

foo (x, y, z) :=
  if x > 1 + y
    then z - x*y
  elseif y <= 100!
    then x/(y + z)^2
  else z - y . x . y;

~~~

## Perl

~~~ Perl
# loads object
sub load
{
  my $flds = $c->db_load($id,@_) || do {
    Carp::carp "Can`t load (class: $c, id: $id): '$!'"; return undef
  };
  my $o = $c->_perl_new();
  $id12 = $id / 24 / 3600;
  $o->{'ID'} = $id12 + 123;
  #$o->{'SHCUT'} = $flds->{'SHCUT'};
  my $p = $o->props;
  my $vt;
  $string =~ m/^sought_text$/;
  $items = split //, 'abc';
  $string //= "bar";
  for my $key (keys %$p)
  {
    if(${$vt.'::property'}) {
      $o->{$key . '_real'} = $flds->{$key};
      tie $o->{$key}, 'CMSBuilder::Property', $o, $key;
    }
  }
  $o->save if delete $o->{'_save_after_load'};

  # GH-117
  my $g = glob("/usr/bin/*");

  return $o;
}

__DATA__
@@ layouts/default.html.ep
<!DOCTYPE html>
<html>
  <head><title><%= title %></title></head>
  <body><%= content %></body>
</html>
__END__

=head1 NAME
POD till the end of file
~~~

## Python

~~~ Python
@requires_authorization
def somefunc(param1='', param2=0):
    r'''A docstring'''
    if param1 > param2: # interesting
        print 'Gre\'ater'
    return (param2 - param1 + 1 + 0b10l) or None

class SomeClass:
    pass

>>> message = '''interpreter
... prompt'''
~~~

## PowerShell

~~~ Powershell
$initialDate = [datetime]'2013/1/8'

$rollingDate = $initialDate

do {
    $client = New-Object System.Net.WebClient
    $results = $client.DownloadString("http://not.a.real.url")
    Write-Host "$rollingDate.ToShortDateString() - $results"
    $rollingDate = $rollingDate.AddDays(21)
    $username = [System.Environment]::UserName
} until ($rollingDate -ge [datetime]'2013/12/31')
~~~

## SQL

~~~ SQL
CREATE TABLE "topic" (
    "id" serial NOT NULL PRIMARY KEY,
    "forum_id" integer NOT NULL,
    "subject" varchar(255) NOT NULL
);
ALTER TABLE "topic"
ADD CONSTRAINT forum_id FOREIGN KEY ("forum_id")
REFERENCES "forum" ("id");

-- Initials
insert into "topic" ("forum_id", "subject")
values (2, 'D''artagnian');
~~~
## YAML

~~~ yaml
---
# comment
string_1: "Bar"
string_2: 'bar'
string_3: bar
inline_keys_ignored: sompath/name/file.jpg
keywords_in_yaml:
  - true
  - false
  - TRUE
  - FALSE
  - 21
  - 21.0
  - !!str 123
"quoted_key": &foobar
  bar: foo
  foo:
  "foo": bar

reference: *foobar

multiline_1: |
  Multiline
  String
multiline_2: >
  Multiline
  String
multiline_3: "
  Multiline string
  "

ansible_variables: "foo {{variable}}"

array_nested:
- a
- b: 1
  c: 2
- b
- comment
~~~



