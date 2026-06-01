//%attributes = {}
#DECLARE($params : Object)

If ($params=Null:C1517)
	
	CALL WORKER:C1389(1; Current method name:C684; {})
	
Else 
	
	var $pptcli : cs:C1710.pptcli
	$pptcli:=cs:C1710.pptcli.new(cs:C1710._pptcli_Controller)
	
	$events:={}
	$events.onResponse:=Formula:C1597(ALERT:C41([$2.context.fullName; "downloaded!"].join(" ")))
	$events.onData:=Formula:C1597(MESSAGE:C88([$2.context.fullName; $2.percentage; "%"].join(" ")))
	$events.onTerminate:=Formula:C1597(ALERT:C41("terminated!"))
	$events.onError:=Formula:C1597(ALERT:C41("error!"))
	
	$md:="# Introduction\n- Welcome to the presentation\n- Today's agenda\n\n# Key Points\n- First important point\n- Second important point\n- Third important point\n\n# Conclusion\n- Summary of takeaways\n- Next steps"
	$folder:=Folder:C1567(Temporary folder:C486; fk platform path:K87:2).folder(Generate UUID:C1066)
	$folder.create()
	$in:=$folder.file("slides.md")
	$in.setText($md)
	
	$out:=Folder:C1567(fk desktop folder:K87:19).file("slides.pptx")
	
	$tasks:=[]
/*
any element that is an object not a file or folder is considered a context object
context object can have 2 properties: .data, .file
.data is a variant that is passed to the callback 
.file is used as the stdin (assuming you pass @ - or -)
it can be 4D.File, 4D.Blob, Blob, or Text
*/
	$tasks.push(["md2ppt"; $in; $out; {data: $out; file: $md}])
	$results:=$pptcli.execute($tasks; $events)
	
End if 