Imports System.Runtime.CompilerServices
Imports Metaphor.Persistence

Public Module CharacterDeathExtensions
#Region "Death/Respawn"
    <Extension>
    Public Function IsDead(character As ICharacter) As Boolean
        Return character.IsCounterMinimum(Counters.HEALTH)
    End Function
    <Extension>
    Friend Sub Die(character As ICharacter)
        character.AddMessage($"{character.Name} dies.")
        character.MinimizeCounter(Counters.HEALTH)
    End Sub
    <Extension>
    Public Sub Respawn(character As ICharacter)
        If Not character.IsAvatar Then
            Return
        End If
        'TODO: drop yer stuff in a gravestone?
        character.Location = character.GetCheckpoint().Location
        character.AddMessage($"{character.Name} respawns in {character.Location.Name}.")
        character.MaximizeCounter(Counters.HEALTH)
        character.MaximizeCounter(Counters.STAMINA)
    End Sub
#Region "Death Handling"
    Private Delegate Sub DeathHandler(character As ICharacter)
    Private deathHandlers As New Dictionary(Of String, DeathHandler) From
        {
            {CharacterSubtypes.N00B, AddressOf HandleN00bDeath}
        }

    Private Sub HandleN00bDeath(character As ICharacter)
        Dim gravestone = character.GetGravestone()
        If gravestone IsNot Nothing Then
            character.ClearGravestone()
            gravestone.Remove()
        End If
        character.CreateGravestone()
    End Sub

    Private Sub HandleStandardDeath(character As ICharacter)
        If character.IsEnemy() Then
            Dim avatar = character.World.Avatar
            Dim cruor = character.GetCruor()
            avatar.ChangeCounter(Counters.CRUOR, cruor)
            avatar.AddMessage($"{avatar.Name} receives {cruor} cruor.")
            avatar.AddMessage($"{avatar.Name} now has {avatar.GetCruor()} cruor.")
        End If
        If Not character.IsAvatar Then
            character.Remove()
        End If
    End Sub
    <Extension>
    Friend Sub HandleDeath(character As ICharacter)
        Dim deathHandler As DeathHandler = Nothing
        If deathHandlers.TryGetValue(character.EntitySubtype, deathHandler) Then
            deathHandler.Invoke(character)
        Else
            HandleStandardDeath(character)
        End If
    End Sub
#End Region
#End Region
End Module
