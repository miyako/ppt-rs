# ppt-rs

**aknowledgements**: [`yingkitw/ppt-rs`](https://github.com/yingkitw/ppt-rs)

#### Abstract

[`yingkitw/ppt-rs`](https://github.com/yingkitw/ppt-rs) is a Rust CLI for generating PowerPoint presentations. This component provides a wrapper class for calling it via SystemWorker. 

#### Usage

Create a project method for callback (this is optional)

```4d
// OnData
#DECLARE($worker : 4D.SystemWorker; $params : Object)

var $text : Text
$text:=$worker.response
$file:=$params.context

OPEN URL($file.platformPath)
```

Instantiate `cs.ppt_rs.pptcli` and pass one or more task objects:

```4d
#DECLARE($params : Object)

If ($params=Null)
    
    CALL WORKER(1; Current method name; {})
    
Else 
    
    var $pptcli : cs.ppt_rs.pptcli
    $pptcli:=cs.ppt_rs.pptcli.new(cs.ppt_rs._pptcli_Controller)
    
    $events:={}
    $events.onResponse:=Formula(onData)
    $events.onError:=Formula(ALERT("error!"))
    
    $folder:=Folder(Temporary folder; fk platform path).folder(Generate UUID)
    $folder.create()
    $tasks:=[]
    
    /*
        markdown to pptx
    */
    
    $md:="# Introduction\n- Welcome to the presentation\n- Today's agenda\n\n# Key Points\n- First important point\n- Second important point\n- Third important point\n\n# Conclusion\n- Summary of takeaways\n- Next steps"
    $in:=$folder.file("slides.md")
    $in.setText($md)
    $out:=Folder(fk desktop folder).file("slides1.pptx")
    $tasks.push(["md2ppt"; $in; $out; {data: $out; file: $md}])
    
    /*
        html to pptx
    */
    
    $html:="\n    <h1>Introduction</h1>\n    <p>Welcome to the presentation</p>\n    <ul>\n        <li>Point one</li>\n        <li>Point two</li>\n    </ul>\n    <h1>Data</h1>\n    <table>\n        <tr><th>Item</th><th>Value</th></tr>\n        <tr><td>A</td><td>100</td></t"+"r>\n    </table>"
    $in:=$folder.file("slides.md")
    $in.setText($md)
    $out:=Folder(fk desktop folder).file("slides2.pptx")
    $tasks.push(["html2ppt"; $in; $out; {data: $out; file: $html}])
    
    $results:=$pptcli.execute($tasks; $events)
    
End if 
```
