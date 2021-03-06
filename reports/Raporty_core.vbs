'url do API 
Environment("TestDataAPIurl") = "http://88.220.130.130:8081/plk-test-data-manager/get-test-data-json?data_type="
'key do szyfrowania
Environment("SecretKey") = "92654827"

'@Global variables
fp = Environment("TestDir") & "\execution.txt"
Environment("ExecutionUid") = readUID(fp)
Environment("v_DataStartu") = AktualnaData
Environment("v_DataKonca") = null
Environment("thisResultPath") = Environment("TestDir") & "\Test Results\" & Environment("ExecutionUid") & "\Report\" & Environment("ExecutionUid") &"_report.csv"
Environment("thisLogPath") = Environment("TestDir") & "\Test Results\" & Environment("ExecutionUid") & "\Report\" & Environment("ExecutionUid") &"_log.csv"
Environment("thisOutputPath") = Environment("TestDir") & "\Test Results\" & Environment("ExecutionUid") & "\Report\" & Environment("ExecutionUid") &"_output.csv"


'@Description Pobierz TestUID z runa TestFactory
'@Author TMajk
Public Function readUID(byVal filePath)
	Set MyFSO = CreateObject("Scripting.FileSystemObject")
    If (MyFSO.FileExists(filePath)) Then
        set ReadStuff = MyFSO.OpenTextFile(filePath , 1, True)
        executionUid = ReadStuff.ReadAll
        ReadStuff.Close
    Else
        executionUid = "0000"
    End If
    readUID = Replace(executionUid, " ", "") ' <- strip spaces if any
End Function


'@Description utowrzenie plikow CSV dla platformy
'@Author TMajk
Public Function SetUpCSVFiles
	filesPath = Environment("TestDir") & "\Test Results\" & Environment("ExecutionUid") & "\Report" 
	Call CreateTestReportFolder(filesPath)
	Call CreateFile(Environment("thisResultPath"))
    Print "Tworze plik raportu => " & Environment("thisResultPath")
	Call CreateFile(Environment("thisLogPath"))
    Print "Tworze plik loga => " & Environment("thisLogPath")
	Call CreateFile(Environment("thisOutputPath"))
    Print "Tworze plik parametrow wyjsciowych => " & Environment("thisOutputPath")
    'jesli jest w folderze CSV z TF to nadpisz Data Table
    csvPath = Environment("TestDir") & "\" & Environment("ExecutionUid") & ".csv"
    'MsgBox csvPath
    Call OverrideDataTableFromCsv(csvPath)
End Function


'@Description UtwĂłrz strukturÄ™ folderĂłw dla raportow TF
'@Author TMajk
Public Function CreateTestReportFolder(path)
	fullPath = path
	rootPath = Environment("TestDir")
	result = Environment("TestDir") & "\Test Results"
	execID = result & "\" & Environment("ExecutionUid") 
	Set fso = CreateObject("Scripting.FileSystemObject")
	If Not fso.FolderExists(result) Then
	    fso.CreateFolder result
	End If
	If Not fso.FolderExists(execID) Then
		fso.CreateFolder execID
	End if
	If Not fso.FolderExists(fullPath) Then
		fso.CreateFolder fullPath
	End if
End Function

'@Desription Tworzy plik - fileName - pelna sciezka z nazwa pliku
'@Author TMajk
Public Function CreateFile(ByVal fileName)
	DeleteFile(fileName)
	Set obj = Createobject("Scripting.FileSystemObject")
	If obj.FileExists(fileName)  = false Then
 		obj.CreateTextFile fileName,true
	End If
	Set obj = nothing
End Function


'@Description Dodanie parametru wyjsciowego wraz z wartoscia do pliku CSV na potrzeby platformy
'@Author TMajk
Public Function AddToOutputParameters(ByVal NazwaParametru, ByVal WartoscParametru)
    Dim Stuff, MyFSO
    Set MyFSO = CreateObject("Scripting.FileSystemObject")
	Set WriteStuff = MyFSO.OpenTextFile(Environment("thisOutputPath") , 8, True)
	WriteStuff.WriteLine NazwaParametru & "|" & WartoscParametru
    WriteStuff.Close
    Set WriteStuff = Nothing
    Set MyFSO = Nothing
End Function


'@Description usuwanie pliku - w parametrze file path do pliku
'@Author TMajk - B2BNet
Public Function DeleteFile(ByVal filePathName)
	Set filesys = CreateObject("Scripting.FileSystemObject")
	If filesys.FileExists(filePathName) Then 
	filesys.DeleteFile filePathName
	End if
End Function


'@Description Dodanie screenshota desktopu 
' w parametrze sciezka do pliku ze screenem
' jesli istnieje to nadpisuje
'@Author TMajk
Public Function TakeDesktopScreenShot(ByVal filePath)
	Call DeleteFile(filePath)
	Desktop.CaptureBitmap filePath
End Function

'@Description Funkcja raportujĂ„â€¦ca do pliku _report.csv
'reportStatus - przyjmuje za parametr wartoÄąâ€şci : "PASS", "FAIL", "WARNING"
'@Author MMincberg - B2BNet
Public Function TestReport(ByVal reportStatus)
    Dim Stuff, MyFSO, dateStamp
    Data = Date & " " & Time
    Set MyFSO = CreateObject("Scripting.FileSystemObject")
	Set WriteStuff = MyFSO.OpenTextFile(Environment("thisResultPath") , 8, True)
    reportStatus = UCase(reportStatus)
	Select Case reportStatus
		Case "PASS"
		    WriteStuff.WriteLine DataTable.Value("TestUID","Run") & "|" & DataTable.Value("Akcja","Run")  & "|" & Environment("v_DataStartu")& "|" & AktualnaData& "|" & "PASS"	
		Case "FAIL"
		    WriteStuff.WriteLine DataTable.Value("TestUID","Run") & "|" & DataTable.Value("Akcja","Run")  & "|" & Environment("v_DataStartu")& "|" & AktualnaData& "|" & "FAIL"
			screenShotPath = Environment("TestDir") & "\Test Results\" & Environment("ExecutionUid") & "\Report\" & DataTable.Value("TestUID", "Run") & ".png"
			Call TakeDesktopScreenShot(screenShotPath)
		Case "WARNING"
		   WriteStuff.WriteLine DataTable.Value("TestUID","Run") & "|" & DataTable.Value("Akcja","Run")  & "|" & Environment("v_DataStartu")& "|" & AktualnaData& "|" & "WARNING"		
	End Select
    WriteStuff.Close
    Set WriteStuff = Nothing
    Set MyFSO = Nothing
End Function


'@Description Funkcja logujĂ„â€¦ca do pliku _log.csv
'logStatus - przyjmuje za parametr wartoÄąâ€şci : "PASS", "FAIL", "DONE"
'logMessage - string z msg przekazanym do loga
'@Author MMincberg - B2BNet
Public Function Log_Result(ByVal logStatus, ByVal logMessage)
    Dim Stuff, MyFSO, dateStamp
    Data = Date & " " & Time
    Set MyFSO = CreateObject("Scripting.FileSystemObject")
	Set WriteStuff = MyFSO.OpenTextFile(Environment("thisLogPath") , 8, True)
    logStatus = UCase(logStatus)
	Select Case logStatus
		Case "DONE"
		   WriteStuff.WriteLine DataTable.Value("TestUID","Run") & "|" & DataTable.Value("Akcja","Run")  & "|" &  "DONE" &"|"& Environment("v_DataStartu")& "|" & AktualnaData & "|" & logMessage
		Case "PASS"
		    WriteStuff.WriteLine DataTable.Value("TestUID","Run") & "|" & DataTable.Value("Akcja","Run")  & "|" &  "PASS" &"|"& Environment("v_DataStartu")& "|" & AktualnaData & "|" & logMessage
		Case "FAIL"
		    WriteStuff.WriteLine DataTable.Value("TestUID","Run") & "|" & DataTable.Value("Akcja","Run")  & "|" &  "FAIL" &"|"& Environment("v_DataStartu")& "|" & AktualnaData & "|" & logMessage
		Case "WARNING"
		   WriteStuff.WriteLine DataTable.Value("TestUID","Run") & "|" & DataTable.Value("Akcja","Run")  & "|" &  "WARNING" &"|"& Environment("v_DataStartu")& "|" & AktualnaData & "|" & logMessage		
	End Select
    WriteStuff.Close
    Set WriteStuff = Nothing
    Set MyFSO = Nothing
End Function


'@Description Zwraca aktualna date
'@Author MMincberg - B2BNet
Public Function AktualnaData()
	AktualnaData = Date & " " & Time
End Function


'@Description Start loga
'@Author MMinberg - B2BNet
Public Function StartLog()
    Dim Stuff, MyFSO, dateStamp
	Stuff = vbcrlf & "------------- URUCHOMIENIE TESTU | >>>> " & Environment("TestName") 
    Set MyFSO = CreateObject("Scripting.FileSystemObject")
    Set WriteStuff = MyFSO.OpenTextFile(Environment("thisLogPath") , 8, True)
	WriteStuff.WriteLine (Stuff)
    WriteStuff.Close
    Set WriteStuff = Nothing
    Set MyFSO = Nothing
End Function


'@Description Koniec loga
'@Author MMincberg - B2BNet
Public Function EndLog()
	akcja  =  DataTable.Value("Akcja", "Run")
    Dim Stuff, MyFSO, dateStamp
		Stuff = vbcrlf & "-------------- ZAKONCZENIE TESTU | >>>> " & Environment("TestName") 
    Set MyFSO = CreateObject("Scripting.FileSystemObject")
    Set WriteStuff = MyFSO.OpenTextFile(Environment("thisLogPath"), 8, True)
	WriteStuff.WriteLine (Stuff)
    WriteStuff.Close
    Set WriteStuff = Nothing
    Set MyFSO = Nothing
End Function


'@Desription Tworzy plik - fileName - pelna sciezka z nazwa pliku
'Tworzy plik wraz z zawartoscia.
'Author Sebastian Hoppa - B2BNet
Public Function CreateFileWithText(ByVal filePathName, ByVal fileText)
	DeleteFile(filePathName)
	Set obj = Createobject("Scripting.FileSystemObject")
	If obj.FileExists(filePathName)  = false Then
 		obj.CreateTextFile filePathName, true
		Dim Stuff, MyFSO
		Set WriteStuff = obj.OpenTextFile(filePathName , 8, True)
		WriteStuff.WriteLine fileText
		WriteStuff.Close
		Set WriteStuff = Nothing
		Set MyFSO = Nothing
	End If
	Set obj = nothing
End Function


'@Description Zwraca aktualna date w postaci YYYY/MM/DD
'W przypadku miesiecy i dni <10 dodaje 0 przed liczba (np. 01, 06)
'@Author S.Hoppa
Public Function GetCurrentDateInYYYYMMDD()
	currentDate = now
	If Len(day(currentDate)) = 1 Then
		dzien = 0 & day(currentDate)
	else
		dzien = day(currentDate)
	End If

	If Len(month(currentDate)) = 1 Then
		miesiac = 0 & month(currentDate)
	else
		miesiac = month(currentDate)
	End If

	rok = year(currentDate)
	GetCurrentDateInYYYYMMDD = rok & "/" & miesiac & "/" & dzien
end Function

'@Description zaszyfruj input string
'@Author TMajk - B2BNet 
Public Function EncryptStr(str)
' AddToOutputParameters(NazwaParametru, WartoscParametru)
'AddToOutputParameters
	keyMod = Len(Environment("SecretKey")) Mod 3 + 1
	encStr = StrReverse(str)
	newStr = ""
	For i = 1 to Len(encStr)
		newStr = newStr & asc(Mid(encStr,i,1)) + keyMod & "@"
	Next
	EncryptStr = newStr
End Function


'@Description Odszyfruj input string
'@Author TMajk - B2BNet
Public Function DecryptStr(str)
	Dim newStr, char
	keyMod = Len(Environment("SecretKey")) Mod 3 + 1
	newStr = ""
	encStr = Split(str, "@")
	for each char in encStr
		if char <> "" then
		newStr = newStr & Chr(char- keyMod) 
		end if
	Next
	DecryptStr = StrReverse(newStr)
End Function

'Na potrzeby zgodnoĹ›ci z poprzednia wersja dokumentu
Public Function DecriptPassword(str)
   DecriptPassword = DecryptStr(str)
End Function


'@Description Parser JSON <- source online
Class VbsJson
        Private Whitespace, NumberRegex, StringChunk
        Private b, f, r, n, t

        Private Sub Class_Initialize
            Whitespace = " " & vbTab & vbCr & vbLf
            b = ChrW(8)
            f = vbFormFeed
            r = vbCr
            n = vbLf
            t = vbTab

            Set NumberRegex = New RegExp
            NumberRegex.Pattern = "(-?(?:0|[1-9]\d*))(\.\d+)?([eE][-+]?\d+)?"
            NumberRegex.Global = False
            NumberRegex.MultiLine = True
            NumberRegex.IgnoreCase = True

            Set StringChunk = New RegExp
            StringChunk.Pattern = "([\s\S]*?)([""\\\x00-\x1f])"
            StringChunk.Global = False
            StringChunk.MultiLine = True
            StringChunk.IgnoreCase = True
        End Sub
        
        'Return a JSON string representation of a VBScript data structure
        'Supports the following objects and types
        '+-------------------+---------------+
        '| VBScript          | JSON          |
        '+===================+===============+
        '| Dictionary        | object        |
        '+-------------------+---------------+
        '| Array             | array         |
        '+-------------------+---------------+
        '| String            | string        |
        '+-------------------+---------------+
        '| Number            | number        |
        '+-------------------+---------------+
        '| True              | true          |
        '+-------------------+---------------+
        '| False             | false         |
        '+-------------------+---------------+
        '| Null              | null          |
        '+-------------------+---------------+
        Public Function Encode(ByRef obj)
            Dim buf, i, c, g
            Set buf = CreateObject("Scripting.Dictionary")
            Select Case VarType(obj)
                Case vbNull
                    buf.Add buf.Count, "null"
                Case vbBoolean
                    If obj Then
                        buf.Add buf.Count, "true"
                    Else
                        buf.Add buf.Count, "false"
                    End If
                Case vbInteger, vbLong, vbSingle, vbDouble
                    buf.Add buf.Count, obj
                Case vbString
                    buf.Add buf.Count, """"
                    For i = 1 To Len(obj)
                        c = Mid(obj, i, 1)
                        Select Case c
                            Case """" buf.Add buf.Count, "\"""
                            Case "\"  buf.Add buf.Count, "\\"
                            Case "/"  buf.Add buf.Count, "/"
                            Case b    buf.Add buf.Count, "\b"
                            Case f    buf.Add buf.Count, "\f"
                            Case r    buf.Add buf.Count, "\r"
                            Case n    buf.Add buf.Count, "\n"
                            Case t    buf.Add buf.Count, "\t"
                            Case Else
                                If AscW(c) >= 0 And AscW(c) <= 31 Then
                                    c = Right("0" & Hex(AscW(c)), 2)
                                    buf.Add buf.Count, "\u00" & c
                                Else
                                    buf.Add buf.Count, c
                                End If
                        End Select
                    Next
                    buf.Add buf.Count, """"
                Case vbArray + vbVariant
                    g = True
                    buf.Add buf.Count, "["
                    For Each i In obj
                        If g Then g = False Else buf.Add buf.Count, ","
                        buf.Add buf.Count, Encode(i)
                    Next
                    buf.Add buf.Count, "]"
                Case vbObject
                    If TypeName(obj) = "Dictionary" Then
                        g = True
                        buf.Add buf.Count, "{"
                        For Each i In obj
                            If g Then g = False Else buf.Add buf.Count, ","
                            buf.Add buf.Count, """" & i & """" & ":" & Encode(obj(i))
                        Next
                        buf.Add buf.Count, "}"
                    Else
                        Err.Raise 8732,,"None dictionary object"
                    End If
                Case Else
                    buf.Add buf.Count, """" & CStr(obj) & """"
            End Select
            Encode = Join(buf.Items, "")
        End Function

        'Return the VBScript representation of ``str(``
        'Performs the following translations in decoding
        '+---------------+-------------------+
        '| JSON          | VBScript          |
        '+===============+===================+
        '| object        | Dictionary        |
        '+---------------+-------------------+
        '| array         | Array             |
        '+---------------+-------------------+
        '| string        | String            |
        '+---------------+-------------------+
        '| number        | Double            |
        '+---------------+-------------------+
        '| true          | True              |
        '+---------------+-------------------+
        '| false         | False             |
        '+---------------+-------------------+
        '| null          | Null              |
        '+---------------+-------------------+
        Public Function Decode(ByRef str)
            Dim idx
            idx = SkipWhitespace(str, 1)

            If Mid(str, idx, 1) = "{" Then
                Set Decode = ScanOnce(str, 1)
            Else
                Decode = ScanOnce(str, 1)
            End If
        End Function
        
        Private Function ScanOnce(ByRef str, ByRef idx)
            Dim c, ms

            idx = SkipWhitespace(str, idx)
            c = Mid(str, idx, 1)

            If c = "{" Then
                idx = idx + 1
                Set ScanOnce = ParseObject(str, idx)
                Exit Function
            ElseIf c = "[" Then
                idx = idx + 1
                ScanOnce = ParseArray(str, idx)
                Exit Function
            ElseIf c = """" Then
                idx = idx + 1
                ScanOnce = ParseString(str, idx)
                Exit Function
            ElseIf c = "n" And StrComp("null", Mid(str, idx, 4)) = 0 Then
                idx = idx + 4
                ScanOnce = Null
                Exit Function
            ElseIf c = "t" And StrComp("true", Mid(str, idx, 4)) = 0 Then
                idx = idx + 4
                ScanOnce = True
                Exit Function
            ElseIf c = "f" And StrComp("false", Mid(str, idx, 5)) = 0 Then
                idx = idx + 5
                ScanOnce = False
                Exit Function
            End If
            
            Set ms = NumberRegex.Execute(Mid(str, idx))
            If ms.Count = 1 Then
                idx = idx + ms(0).Length
                ScanOnce = CDbl(ms(0))
                Exit Function
            End If
            
            Err.Raise 8732,,"No JSON object could be ScanOnced"
        End Function

        Private Function ParseObject(ByRef str, ByRef idx)
            Dim c, key, value
            Set ParseObject = CreateObject("Scripting.Dictionary")
            idx = SkipWhitespace(str, idx)
            c = Mid(str, idx, 1)
            
            If c = "}" Then
                Exit Function
            ElseIf c <> """" Then
                Err.Raise 8732,,"Expecting property name"
            End If

            idx = idx + 1
            
            Do
                key = ParseString(str, idx)

                idx = SkipWhitespace(str, idx)
                If Mid(str, idx, 1) <> ":" Then
                    Err.Raise 8732,,"Expecting : delimiter"
                End If

                idx = SkipWhitespace(str, idx + 1)
                If Mid(str, idx, 1) = "{" Then
                    Set value = ScanOnce(str, idx)
                Else
                    value = ScanOnce(str, idx)
                End If
                ParseObject.Add key, value

                idx = SkipWhitespace(str, idx)
                c = Mid(str, idx, 1)
                If c = "}" Then
                    Exit Do
                ElseIf c <> "," Then
                    Err.Raise 8732,,"Expecting , delimiter"
                End If

                idx = SkipWhitespace(str, idx + 1)
                c = Mid(str, idx, 1)
                If c <> """" Then
                    Err.Raise 8732,,"Expecting property name"
                End If

                idx = idx + 1
            Loop

            idx = idx + 1
        End Function
        
        Private Function ParseArray(ByRef str, ByRef idx)
            Dim c, values, value
            Set values = CreateObject("Scripting.Dictionary")
            idx = SkipWhitespace(str, idx)
            c = Mid(str, idx, 1)

            If c = "]" Then
                ParseArray = values.Items
                Exit Function
            End If

            Do
                idx = SkipWhitespace(str, idx)
                If Mid(str, idx, 1) = "{" Then
                    Set value = ScanOnce(str, idx)
                Else
                    value = ScanOnce(str, idx)
                End If
                values.Add values.Count, value

                idx = SkipWhitespace(str, idx)
                c = Mid(str, idx, 1)
                If c = "]" Then
                    Exit Do
                ElseIf c <> "," Then
                    Err.Raise 8732,,"Expecting , delimiter"
                End If

                idx = idx + 1
            Loop

            idx = idx + 1
            ParseArray = values.Items
        End Function
        
        Private Function ParseString(ByRef str, ByRef idx)
            Dim chunks, content, terminator, ms, esc, char
            Set chunks = CreateObject("Scripting.Dictionary")

            Do
                Set ms = StringChunk.Execute(Mid(str, idx))
                If ms.Count = 0 Then
                    Err.Raise 8732,,"Unterminated string starting"
                End If
                
                content = ms(0).Submatches(0)
                terminator = ms(0).Submatches(1)
                If Len(content) > 0 Then
                    chunks.Add chunks.Count, content
                End If
                
                idx = idx + ms(0).Length
                
                If terminator = """" Then
                    Exit Do
                ElseIf terminator <> "\" Then
                    Err.Raise 8732,,"Invalid control character"
                End If
                
                esc = Mid(str, idx, 1)

                If esc <> "u" Then
                    Select Case esc
                        Case """" char = """"
                        Case "\"  char = "\"
                        Case "/"  char = "/"
                        Case "b"  char = b
                        Case "f"  char = f
                        Case "n"  char = n
                        Case "r"  char = r
                        Case "t"  char = t
                        Case Else Err.Raise 8732,,"Invalid escape"
                    End Select
                    idx = idx + 1
                Else
                    char = ChrW("&H" & Mid(str, idx + 1, 4))
                    idx = idx + 5
                End If

                chunks.Add chunks.Count, char
            Loop

            ParseString = Join(chunks.Items, "")
        End Function

        Private Function SkipWhitespace(ByRef str, ByVal idx)
            Do While idx <= Len(str) And _
                InStr(Whitespace, Mid(str, idx, 1)) > 0
                idx = idx + 1
            Loop
            SkipWhitespace = idx
        End Function

End Class


'@Description Pobierz zuzywalne dane testowe
'variableName - typ danych do pobrania
'disable - czy zuzyc dana testowa True/False
'@Author TMajk B2bNet
Public Function GetTestData(byval variableName, byval disable)
	Dim o
	If disable = True Then
    	disable = "True"
	Else
    	disable = "False"
	End If
	newQueryString = Environment("TestDataAPIurl")&variableName&"&disable="&disable&""
	myText = queryTestDataApi(newQueryString)
    Set json = New VbsJson
    Set j = json.Decode(myText)
	If j("stored_data") = "ERROR" Then
    	Log_Result "FAIL" , "Nie udalo sie pobrac danej testowej: "&variableName&" zla nazwa typu danych lub brak wolnych danych"
    	Reporter.ReportEvent micFail, "Pobieranie danej testowej z API", "Nie udalo sie pobrac danej testowej: "&variableName&" zla nazwa typu danych lub brak wolnych danych"
    	Call ExitTest
	Else
    	GetTestData = j("stored_data")
    	Log_Result "PASS" , "Pobrano dana testowa: "&variableName 
    	Reporter.ReportEvent micPass, "Pobieranie danej testowej z API", "Pobrano dana testowa: "&variableName 
	End If
End Function


'@Description zapytaj API o dane
'@Author TMajk
Private Function QueryTestDataApi(ByVal queryStringData)
	Dim o
	Set o = CreateObject("MSXML2.XMLHTTP")
	Randomize
	o.open "GET", queryStringData&"&"&Cstr(Rnd) , False
	o.setRequestHeader "Content-Type", "application/json"
	o.send
	If o.status <> 200 Then
    	Log_Result "FAIL" , "Nie udalo sie pobrac danej testowej: "&variableName&" blad polaczenia z API"
		Reporter.ReportEvent micFail, "Pobieranie danej testowej z API", "Nie udalo sie pobrac danej testowej: "&variableName&" blad polaczenia z API"
		Set o = Nothing
		Call ExitTest
	Else
		query_result = o.responseText
		QueryTestDataApi = query_result
		Set o = Nothing
	End If
End Function


'@desc: stripuje " na poczatku i koncu stringa, zwraca string bez "
'@Author TMajk 
Private Function StripWrapperCommas(ByVal stringForStrip)
    StripWrapperCommas = stringForStrip
    dim firstAnsiCode, lastAnsiCode
 	if len(StripWrapperCommas)>1 Then
 		firstAnsiCode = Asc(Left(StripWrapperCommas, 1))
 		lastAnsiCode = Asc(Right(StripWrapperCommas, 1))
 		if firstAnsiCode = 34 then
 			StripWrapperCommas = Mid(StripWrapperCommas, 2, Len(StripWrapperCommas))
            print "after first strip: " & StripWrapperCommas
        end if
        if lastAnsiCode = 34 then
            StripWrapperCommas = Mid(StripWrapperCommas, 1, Len(StripWrapperCommas)-1)
        end if
	end if
End Function



'@desc - nadpisanie danych w datatable z csv "wyplutego" z TF
'@Author TMajk 
Sub OverrideDataTableFromCsv(ByVal csvPath)
	Set inCsvSys = CreateObject("Scripting.FileSystemObject") 
	If (inCsvSys.FileExists(csvPath)) Then
		Set inCsv = inCsvSys.OpenTextFile(csvPath,"1",True)
	Else
		Exit Sub
	End if
	colCount = -1
    firsLine = inCsv.ReadLine
    tstDelimiter = ","
    prdDelimiter = Chr(34) & "," & Chr(34)
    if InStr(firsLine, prdDelimiter) > 0 then
        csvDelimiter = prdDelimiter
    else
        csvDelimiter = tstDelimiter
    end if

	csvLineList = Split(firsLine, csvDelimiter)
	Set firstRowDict = CreateObject("Scripting.Dictionary")
	For each item in csvLineList
    	colCount = colCount + 1	
		firstRowDict.Add colCount, StripWrapperCommas(item)
	Next
	rowCount = -1
	Set rowsDict = CreateObject("Scripting.Dictionary")
	Do While Not inCsv.AtEndOfStream
		rowCount = rowCount + 1
		rowsDict.Add rowCount,Split(inCsv.ReadLine, csvDelimiter)
	Loop
	inCsv.Close
	
	'przetworzeenie kolumn
	For i = 0 To rowCount Step 1
		DataTable.SetCurrentRow(i + 1)
            n = 0
            For each item in rowsDict(i)
        		DataTable(firstRowDict(n), "Run") = StripWrapperCommas(item)
                n = n + 1
	        Next
	Next
End Sub
