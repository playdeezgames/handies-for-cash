Imports System.Runtime.CompilerServices
Imports Metaphor.Persistence

Public Module LocationExtensions
#Region "N00b"
    <Extension>
    Friend Function CreateN00b(location As ILocation, name As String) As ICharacter
        Return location.CreateCharacter(CharacterSubtypes.N00B, name, AddressOf InitializeN00b)
    End Function
    Private Sub InitializeN00b(character As ICharacter)
        character.World.Avatar = character
    End Sub
#End Region
#Region "John"
    <Extension>
    Friend Function CreateJohn(location As ILocation) As ICharacter
        Return location.CreateCharacter(CharacterSubtypes.JOHN, "John", AddressOf InitializeJohn)
    End Function

    Private Sub InitializeJohn(character As ICharacter)
        character.CreateVerb(VerbSubtypes.GIVE_HANDY, "Give Handy")
    End Sub
#End Region
#Region "Door"
    <Extension>
    Friend Function CreateDoor(location As ILocation, name As String, destination As ILocation) As IFeature
        Return location.CreateFeature(
            FeatureSubtypes.DOOR,
            name,
            Sub(feature)
                feature.SetDestination(destination)
                feature.CreateVerb(VerbSubtypes.ENTER, "Enter")
            End Sub)
    End Function
    <Extension>
    Friend Sub CreateDoors(fromLocation As ILocation, toLocation As ILocation)
        fromLocation.CreateDoor($"Door to {toLocation.Name}", toLocation)
        toLocation.CreateDoor($"Door to {fromLocation.Name}", fromLocation)
    End Sub
#End Region

End Module
