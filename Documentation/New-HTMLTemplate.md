# New-HTMLTemplate

Create a new customizable template directory for Markdown to HTML conversion.

# Syntax

<blockquote>

```PowerShell
 New-HTMLTemplate [-Destination] <String>  [<CommonParameters>] 
```


</blockquote>

# Description

<blockquote>

The default conversion template is copied to the destination directory to
seed the creation of a custom template.

Typically following files are customized:

* `styles\md-styles.css`: html styling
* `md-template.html`: Html template file. Used for creating standalone HTML files
  from HTML fragments. A html template typically has a structure like shown in the example below.
  There are two placeholders which get replaced by help content:
  * [title] - Page title generated from the markdown filename.
  * [content] - Help content. **Note**: This placeholder must be the only text on the line.

<blockquote>

```html
<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8" />
    <title>[title]</title>
    <link rel="stylesheet" type="text/css" href="styles/md-styles.css" />
    <link rel="stylesheet" type="text/css" href="styles/vs.css" />
    <script src="js/highlight.pack.js"></script>
    <script>
        hljs.configure({ languages: [] });
        hljs.initHighlightingOnLoad();
    </script>
</head>
<body>
    [content]
</body>
</html>
```
</blockquote>

</blockquote>

# Parameters

<blockquote>



## -Destination \<String\>

<blockquote>

Location of the new conversion template directory. The template directory
should be empty or non-existent.

Parameter Property         | Value
--------------------------:|:----------
Required?                  | true
Position?                  | 1
Default value              | ``
Accept pipeline input?     | false
Accept wildcard characters?| false

</blockquote>


</blockquote>


# Inputs

<blockquote>

This function does not read from the pipe

</blockquote>

# Outputs

<blockquote>

The new conversion template directory `[System.IO.DirectoryInfo]`

</blockquote>

# Examples

<blockquote>


## EXAMPLE 1

```PowerShell
New-HTMLTemplate -Destination 'E:\MyTemplate'
```

Create a copy of the default template in `E:\MyTemplate` for customization.

</blockquote>

# Related Links

<blockquote>


* [Convert-MarkdownToHTML](Convert-MarkdownToHTML.md)

</blockquote>

---

<cite>Module: MarkdownToHTML; Version: 1.2.6; (c) 2018 WeHat Lab. All rights reserved.</cite>
