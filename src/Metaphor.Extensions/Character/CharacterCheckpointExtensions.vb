Imports System.Runtime.CompilerServices
Imports Metaphor.Persistence

Public Module CharacterCheckpointExtensions
#Region "Checkpoint"
    <Extension>
    Public Sub SetCheckpoint(character As ICharacter, checkpoint As IFeature)
        character.SetYoke(Yokes.CHECKPOINT, checkpoint.EntityId)
    End Sub
    <Extension>
    Public Function GetCheckpoint(character As ICharacter) As IFeature
        Return character.World.GetFeature(character.GetYoke(Yokes.CHECKPOINT))
    End Function
    <Extension>
    Public Function IsCurrentCheckpoint(character As ICharacter, checkpoint As IFeature) As Boolean
        Return character.GetCheckpoint().EntityId = checkpoint.EntityId
    End Function
#End Region

End Module
