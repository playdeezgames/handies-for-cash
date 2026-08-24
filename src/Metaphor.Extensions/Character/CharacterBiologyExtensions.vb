Imports System.Runtime.CompilerServices
Imports Metaphor.Persistence

Friend Module CharacterBiologyExtensions
    <Extension>
    Friend Sub DoBiology(character As ICharacter, amount As Integer)
        If Not character.IsDead() Then
            Dim stomach = Math.Min(amount, character.GetCounter(Counters.STOMACH))
            character.ChangeStomach(-stomach)
            amount -= stomach
            Dim satiety = Math.Min(amount, character.GetCounter(Counters.SATIETY))
            character.ChangeSatiety(-satiety)
            amount -= satiety
            Dim health = Math.Min(amount, character.GetCounter(Counters.HEALTH))
            character.ChangeHealth(-health)
            If character.IsDead Then
                character.AddMessage($"{character.Name} dies.")
            End If
        End If
    End Sub
End Module
