Public Sub CreateNewFilesOnLoad()
    Dim folderPath As String
    Dim folderName As String

    folderPath = "C:\Your\Desired\Path" ' Change this to your desired path
    fileName = "NewFile.txt" 'Change this to your desired file name

    CreateNewFolder(folderPath)
    CreateNewFile(folderPath, fileName)

    MsgBox "New folder and file created successfully!"
End Sub

Public Sub CreateNewFolder(folderPath As String)
    Dim fso As Object ' or Dim fso As FileSystemObject - requires adding a reference
    Set fso = CreateObject("Scripting.FileSystemObject") ' or New FileSystemObject
    
    ' Check if the folder already exists
    If Not fso.FolderExists(folderPath) Then
        Call fso.CreateFolder(folderPath)
    Else
        MsgBox "Folder already exists."
    End If
End Sub

Public Sub CreateNewFile(folderPath As String, fileName As String)
    Dim fso As Object ' or Dim fso As FileSystemObject - requires adding a reference
    Set fso = CreateObject("Scripting.FileSystemObject") ' or New FileSystemObject

    filePath = folderPath & "\" & fileName
    
    ' Create a new text file
    Dim fileStream As Object
    Set fileStream = fso.CreateTextFile(filePath, True) ' True to overwrite if exists
    
    ' Write some content to the file
    fileStream.WriteLine "This is a new file created."
    
    ' Close the file stream
    fileStream.Close
    
    MsgBox "New file created successfully!"
End Sub