Imports System.Runtime.CompilerServices
Imports Metaphor.Persistence

Public Module CharacterExtensions
#Region "Show Status"
    <Extension>
    Public Sub ShowStatus(character As ICharacter)
        character.AddMessage($"Status:")
        character.AddMessage($"Health: {character.GetCounterStatistic(Counters.HEALTH)}")
        character.AddMessage($"Stamina: {character.GetCounterStatistic(Counters.STAMINA)}")
        character.AddMessage($"Clumsiness: {character.GetCounterPercentage(Counters.CLUMSINESS)}")
        character.AddMessage($"Cruor: {character.GetCruor()}")
        character.AddMessage($"Attack: {character.GetAttack()}")
        character.AddMessage($"Defend: {character.GetDefend()}")
    End Sub
#End Region
#Region "Look"
    <Extension>
    Public Sub Look(character As ICharacter)
        Dim location = character.Location
        If character.InCombat Then
            DescribeCombat(character)
        Else
            character.AddMessage($"{character.Name} is in {location.Name}.")
            DescribeFeatures(location)
        End If
    End Sub

    Private Sub DescribeCombat(character As ICharacter)
        character.AddMessage($"Health: {character.GetCounterStatistic(Counters.HEALTH)}")
        character.AddMessage($"Stamina: {character.GetCounterStatistic(Counters.STAMINA)}")
        Dim enemies = character.Location.GetEnemies()
        character.AddMessage($"{character.Name} is in combat with:")
        For Each enemy In enemies
            character.AddMessage($"- {enemy.Name}(Health: {enemy.GetCounterStatistic(Counters.HEALTH)}, Posture: {enemy.GetMetadata(Metadatas.POSTURE)})")
        Next
    End Sub

    Private Sub DescribeFeatures(location As ILocation)
        If Not location.Features.Any(Function(x) Not x.IsHidden) Then
            Return
        End If
        location.AddMessage($"Features:")
        For Each feature In location.Features.Where(Function(x) Not x.IsHidden)
            location.AddMessage($"- {feature.Name}")
        Next
    End Sub
#End Region
End Module
