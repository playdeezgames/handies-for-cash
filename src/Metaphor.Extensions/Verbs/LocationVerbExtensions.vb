Imports System.Runtime.CompilerServices
Imports Metaphor.Persistence

Public Module LocationVerbExtensions
    Private Delegate Function CanPerformHandler(verb As IVerb, location As ILocation, actor As ICharacter) As Boolean
    Private Delegate Sub PerformHandler(verb As IVerb, location As ILocation, actor As ICharacter)

    Private ReadOnly canPerformTable As New Dictionary(Of String, CanPerformHandler) From
        {
            {VerbSubtypes.SOLICIT, AddressOf CanSolicit}
        }

    Private Function CanSolicit(verb As IVerb, location As ILocation, actor As ICharacter) As Boolean
        Return Not location.Characters.Any(Function(x) x.EntitySubtype = CharacterSubtypes.JOHN)
    End Function

    <Extension>
    Public Function CanPerform(verb As IVerb, location As ILocation, actor As ICharacter) As Boolean
        Dim handler As CanPerformHandler = Nothing
        If canPerformTable.TryGetValue(verb.EntitySubtype, handler) Then
            Return handler.Invoke(verb, location, actor)
        End If
        Return True
    End Function

    Private ReadOnly performTable As New Dictionary(Of String, PerformHandler) From
        {
            {VerbSubtypes.SOLICIT, AddressOf HandleSolicit}
        }

    Private Sub HandleSolicit(verb As IVerb, location As ILocation, actor As ICharacter)
        Dim john = location.CreateJohn()
        actor.AddMessage($"{actor.Name} manages to solicit {john.Name}.")
        actor.Look()
    End Sub

    <Extension>
    Sub Perform(verb As IVerb, location As ILocation, actor As ICharacter)
        Dim handler As PerformHandler = Nothing
        If performTable.TryGetValue(verb.EntitySubtype, handler) Then
            handler.Invoke(verb, location, actor)
            Return
        End If
    End Sub

End Module
