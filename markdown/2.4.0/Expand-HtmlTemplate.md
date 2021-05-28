# Expand-HtmlTemplate

Simple template expansion based on a content substitution dictionary.

# Syntax
```PowerShell
 Expand-HtmlTemplate [-InputObject] <String> [-ContentMap] <Hashtable>  [<CommonParameters>] 
```


# Description


Locates placeholders in the input string abd replaced them
with values found for the placeholders in the given dictionary. The placeholder
expansion is non-recursive.





# Parameters

<blockquote>



## -InputObject \<String\>

<blockquote>

An string representing an Html fragment.

---

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

A dictionary whose keys define placeholders and whose values define the
replacements.

---

Parameter Property         | Value
--------------------------:|:----------
Required?                  | true
Position?                  | 2
Default value              | ``
Accept pipeline input?     | false
Accept wildcard characters?| false

</blockquote>


</blockquote>


# Inputs
HTML template with placeholders.


# Outputs
HTML fragment with all paceholders replaced by the content specified
by the `ContentMap`.

# Examples


## EXAMPLE 1

> ~~~ PowerShell
> Expand-HtmlTemplate -InputObject $template -ContentMap $map
> ~~~
>
> 
> Expand the HTML template `$template` mappings provided with `$map`.
> 
> With:
> 
> ~~~ PowerShell
> $template = '<span class="navitem{{level}}">{{navtext}}</span>'
> $map = @{
>     '{{level}}'   = 1
>     '{{navtext}}' = 'foo'
> }
> ~~~
> 
> this HTML fragment is generated:
> 
> ~~~ html
> <span class="navitem1">foo</span>
> ~~~
> 
> 
> 
> 
> 
> 
> 
> 
> 
> 
> 
> 


# Related Links

* [https://wethat.github.io/MarkdownToHtml/2.4.0/Expand-HtmlTemplate.html](https://wethat.github.io/MarkdownToHtml/2.4.0/Expand-HtmlTemplate.html)

---

<cite>Module: MarkDownToHTML; Version: 2.4.0; (c) 2018-2021 WetHat Lab. All rights reserved.</cite>
