Imports System.Runtime.CompilerServices
Imports Metaphor.Extensions
Imports Metaphor.Persistence

Friend Module InitializationContextExtensions
    <Extension>
    Friend Function InitializeAbandonedHouse(context As IInitializationContext) As Persistence.LocationInitializer
        Return Sub(room)
                   room.CreateCharacter(CharacterSubtypes.N00B, context.ChosenName, context.InitializeN00b())
               End Sub
    End Function

    <Extension>
    Private Function InitializeN00b(context As IInitializationContext) As CharacterInitializer
        Return Sub(character)
                   character.World.Avatar = character
               End Sub
    End Function
End Module
