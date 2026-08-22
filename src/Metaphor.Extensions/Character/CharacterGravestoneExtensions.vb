Imports System.Runtime.CompilerServices
Imports Metaphor.Persistence

Friend Module CharacterGravestoneExtensions
    <Extension>
    Friend Function GetGravestone(character As ICharacter) As IFeature
        Return character.World.GetFeature(character.GetYoke(Yokes.GRAVESTONE))
    End Function
    <Extension>
    Private Sub SetGravestone(character As ICharacter, gravestone As IFeature)
        character.SetYoke(Yokes.GRAVESTONE, gravestone.EntityId)
    End Sub
    <Extension>
    Friend Sub ClearGravestone(character As ICharacter)
        character.ClearYoke(Yokes.GRAVESTONE)
    End Sub
    <Extension>
    Friend Function CreateGravestone(character As ICharacter) As IFeature
        Return character.Location.CreateFeature(FeatureSubtypes.GRAVESTONE, $"{character.Name}'s Gravestone", InitializeGravestone(character))
    End Function

    Private Function InitializeGravestone(character As ICharacter) As FeatureInitializer
        Return Sub(feature)
                   character.SetGravestone(feature)
                   feature.SetCruor(character.GetCruor())
                   character.SetCruor(0)
                   feature.CreateVerb(VerbSubtypes.RESTORE_CRUOR, "Restore Cruor")
               End Sub
    End Function
End Module
