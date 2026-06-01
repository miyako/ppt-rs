//%attributes = {}
#DECLARE($params : Object)

If ($params=Null:C1517)
	
	CALL WORKER:C1389(1; Current method name:C684; {})
	
Else 
	
	var $pptcli : cs:C1710.pptcli
	$pptcli:=cs:C1710.pptcli.new(cs:C1710._pptcli_Controller)
	
	$events:={}
	$events.onResponse:=Formula:C1597(onData)
	$events.onError:=Formula:C1597(ALERT:C41("error!"))
	
	$folder:=Folder:C1567(Temporary folder:C486; fk platform path:K87:2).folder(Generate UUID:C1066)
	$folder.create()
	$tasks:=[]
	
/*
markdown to pptx
*/
	
	$md:="# Introduction\n- Welcome to the presentation\n- Today's agenda\n\n# Key Points\n- First important point\n- Second important point\n- Third important point\n\n# Conclusion\n- Summary of takeaways\n- Next steps"
	$in:=$folder.file("slides.md")
	$in.setText($md)
	$out:=Folder:C1567(fk desktop folder:K87:19).file("slides1.pptx")
	$tasks.push(["md2ppt"; $in; $out; {data: $out; file: $md}])
	
/*
html to pptx
*/
	
	$html:="\n    <h1>Introduction</h1>\n    <p>Welcome to the presentation</p>\n    <ul>\n        <li>Point one</li>\n        <li>Point two</li>\n    </ul>\n    <h1>Data</h1>\n    <table>\n        <tr><th>Item</th><th>Value</th></tr>\n        <tr><td>A</td><td>100</td></t"+"r>\n    </table>"
	$in:=$folder.file("slides.md")
	$in.setText($md)
	$out:=Folder:C1567(fk desktop folder:K87:19).file("slides2.pptx")
	$tasks.push(["html2ppt"; $in; $out; {data: $out; file: $html}])
	
	$results:=$pptcli.execute($tasks; $events)
	
End if 