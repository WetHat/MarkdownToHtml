# Add-ContentSubstitutionMap

Add a mapping table to each input object to specify the placeholder substitution in the HTML template.

# Syntax
```PowerShell
 Add-ContentSubstitutionMap [-InputObject] <Hashtable> [-ContentMap] <Hashtable>  [<CommonParameters>] 
```


# Description


The mapping table as added as property `ContentMap` and is processed by
[[`Publish-StaticHTMLSite`](Publish-StaticHTMLSite.md)](Publish-StaticHTMLSite.md) to substitute the placeholders in the
HTML-template file (`md-template.html`) with HTML fragments.

The keys of the mapping table are the verbatim, case sensitive placeholders as they appear in the
HTML template. Each instance of a key found in `md-template.html` is substituted by the HTML fragment
associated with that key.

Following default substitution mappings are added by default:

| Key | Description                            | Origin                      |
|:------------- | :--------------------------- | :-------------------------- |
| `{{title}}`   | Auto generated page title    | `$inputObject.Title`        |
| `[title]`     | For backwards compatibility. | `$inputObject.Title`        |
| `{{content}}` | HTML content                 | `$inputObject.HtmlFragment` |
| `[content]`   | For backwards compatibility. | `$inputObject.HtmlFragment` |

Additional mappings are added from the content map passed into this function.





# Parameters

<blockquote>



## -InputObject \<Hashtable\>

<blockquote>

A HTML fragment typically produced by [`Convert-MarkdownToHTMLFragment`](Convert-MarkdownToHTMLFragment.md).
Custom hashtables are supported as well as long as they define at least the keys
`HTMLFragment` and `Title`.

A property named `ContentMap` will be added to the `InputObject` to define the
substitution rules before it is passed through to the output pipe.

Parameter Property         | Value
--------------------------:|:----------
Required?                  | true
Position?                  | 1
Default value              | ``
Accept pipeline input?     | true (ByValue)
Accept wildcard characters?| false

</blockquote>
 

## -ContentMap \<Hashtable\>

<blockquote>

Additional placeholder substitution mappings. This map should contain an entry
for each custom placeholder in the HTML-template (`md-template.html`). The keys
of this map should represent the place holders verbatim including the
delimiters. E.g [`{{my-placeholder}}`]({{my-placeholder}}.md). The values in this map can be
* a string one or more strings
* a script block which takes **one** parameter to which the InputObject is bound.
  The script block should return one or more strings which define the
  substitution value.

  Example:

  ~~~ PowerShell
  {
      param($Input)
      "Source = $($Input.RelativePath)"
  }
  ~~~

Parameter Property         | Value
--------------------------:|:----------
Required?                  | false
Position?                  | 2
Default value              | `@{}`
Accept pipeline input?     | false
Accept wildcard characters?| false

</blockquote>


</blockquote>


# Inputs
A HTML fragment object typically produced by `Convert-MarkdownToHTMLFragment`
or a hashtable having at least the keys `HTMLFragment` and `Title`


# Outputs
The input objects with an additional key `ContentMap` which contains a mapping table defining the
rules for substitution of placeholders by HTM fragments.

# Related Links

* [https://github.com/WetHat/MarkdownToHtml/blob/master/Documentation/Add-ContentSubstitutionMap.md](https://github.com/WetHat/MarkdownToHtml/blob/master/Documentation/Add-ContentSubstitutionMap.md) 
* [`Convert-MarkdownToHtmlFragment`](Convert-MarkdownToHtmlFragment.md) 
* [`Publish-StaticHtmlSite`](Publish-StaticHtmlSite.md)

---

<cite>Module: MarkdownToHtml; Version: 2.1.0; (c) 2018-2020 WetHat Lab. All rights reserved.</cite>
