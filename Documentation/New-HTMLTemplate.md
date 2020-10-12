# New-HTMLTemplate

Create a customizable template directory for Markdown to HTML conversion.

# Syntax
```PowerShell
 New-HTMLTemplate [-Destination] <String>  [<CommonParameters>] 
```


# Description


The factory-default conversion template is copied to the destination directory
to seed the customization process.

See [`about_MarkdownToHTML`](about_MarkdownToHTML.md) section TEMPLATE CUSTOMIZATION for details about the
customization options.

The HTML template file returned by this function (`md-template.html`) has a
simple structure containing two content placeholders:

`{{title}}`
:   Placeholder for a page title generated from the Markdown content or filename.

`{{content}}`
:   Placeholder for the HTML content fragment generated from Markdown content.

If a more sophisticated HTML template is needed which can also contain custom
placeholders, check out [`New-StaticHTMLSiteProject`](New-StaticHTMLSiteProject.md).





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
This function does not read from the pipe


# Outputs
The new conversion template directory `[System.IO.DirectoryInfo]`

# Examples

<blockquote>


## EXAMPLE 1

```PowerShell
New-HTMLTemplate -Destination 'E:\MyTemplate'
```


Create a copy of the default template in `E:\MyTemplate` for customization.













</blockquote>

# Related Links

* [https://github.com/WetHat/MarkdownToHtml/blob/master/Documentation/New-HTMLTemplate.md](https://github.com/WetHat/MarkdownToHtml/blob/master/Documentation/New-HTMLTemplate.md) 
* [`New-StaticHTMLSiteProject`](New-StaticHTMLSiteProject.md)

---

<cite>Module: MarkdownToHtml; Version: 2.2.2; (c) 2018-2020 WetHat Lab. All rights reserved.</cite>
