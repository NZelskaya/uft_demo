
Public Function CreateNewDict()

	Dim newParametersDict

	Set newParametersDict = CreateObject("Scripting.Dictionary")

	Set CreateNewDict = newParametersDict

End Function


Public Function GetTestParameterValue(ByVal parameterName)

	GetTestParameterValue = DataTable.GetSheet("Run").GetParameter(parameterName).Value

End Function

Public Function GetTestParameterRawValue(ByVal parameterName)

	GetTestParameterValue = DataTable.GetSheet("Run").GetParameter(parameterName).RawValue

End Function

Public Sub PassDataToNextAction(columnName,value)

 	 DataTable.SetCurrentRow(DataTable.GetSheet("Run").GetCurrentRow+1)

	 DataTable.Value(columnName,"Run") = value

	 DataTable.SetCurrentRow(DataTable.GetSheet("Run").GetCurrentRow-1) 

End sub
