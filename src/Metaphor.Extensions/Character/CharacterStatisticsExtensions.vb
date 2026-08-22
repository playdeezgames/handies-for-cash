Imports System.Runtime.CompilerServices
Imports Metaphor.Persistence

Public Module CharacterStatisticsExtensions
    <Extension>
    Public Function GetHealthImprovementCost(entity As IMetaphorEntity) As Integer
        Return entity.GetCounterMaximum(Counters.HEALTH) \ Grimoire.HEALTH_MULTIPLIER
    End Function
    <Extension>
    Public Function GetStaminaImprovementCost(entity As IMetaphorEntity) As Integer
        Return entity.GetCounterMaximum(Counters.STAMINA)
    End Function
    <Extension>
    Public Function GetAttackImprovementCost(entity As IMetaphorEntity) As Integer
        Return entity.GetCounter(Counters.ATTACK)
    End Function
    <Extension>
    Public Function GetDefendImprovementCost(entity As IMetaphorEntity) As Integer
        Return entity.GetCounter(Counters.DEFEND)
    End Function
    <Extension>
    Public Function GetClumsinessImprovementCost(entity As IMetaphorEntity) As Integer
        Return entity.GetCounterCapacity(Counters.CLUMSINESS)
    End Function
    <Extension>
    Public Function GetCruor(entity As IMetaphorEntity) As Integer
        Return entity.GetCounter(Counters.CRUOR)
    End Function
    <Extension>
    Public Sub SetCruor(entity As IMetaphorEntity, cruor As Integer)
        entity.SetCounter(Counters.CRUOR, cruor)
    End Sub
    <Extension>
    Public Function IsAvatar(character As ICharacter) As Boolean
        Return character.World.Avatar.EntityId = character.EntityId
    End Function
    <Extension>
    Public Function IsEnemy(character As ICharacter) As Boolean
        Return character.HasTag(Tags.ENEMY)
    End Function
#Region "Counters"
    <Extension>
    Friend Sub SpendStamina(character As ICharacter, stamina As Integer)
        If Not character.IsAvatar Then
            Return
        End If
        character.AddMessage($"{character.Name} loses {stamina} stamina.")
        character.ChangeCounter(Counters.STAMINA, -stamina)
        character.AddMessage($"{character.Name} now has {character.GetCounterStatistic(Counters.STAMINA)} stamina.")
    End Sub
    <Extension>
    Friend Sub RecoverStamina(character As ICharacter, stamina As Integer)
        If Not character.IsAvatar Then
            Return
        End If
        character.AddMessage($"{character.Name} gains {stamina} stamina.")
        character.ChangeCounter(Counters.STAMINA, stamina)
        character.AddMessage($"{character.Name} now has {character.GetCounterStatistic(Counters.STAMINA)} stamina.")
    End Sub
    <Extension>
    Friend Function GetHealth(character As ICharacter) As Integer
        Return character.GetCounter(Counters.HEALTH)
    End Function
    <Extension>
    Friend Function GetStamina(character As ICharacter) As Integer
        Return character.GetCounter(Counters.STAMINA)
    End Function
    <Extension>
    Friend Function GetAttack(character As ICharacter, Optional effectiveness As Double = 1.0) As Integer
        Return CInt(character.GetCounter(Counters.ATTACK) * effectiveness)
    End Function
    <Extension>
    Friend Function GetDefend(character As ICharacter) As Integer
        Return character.GetCounter(Counters.DEFEND)
    End Function
    <Extension>
    Friend Function GetPosture(character As ICharacter) As String
        Return character.GetMetadata(Metadatas.POSTURE)
    End Function
    <Extension>
    Friend Sub SetPosture(character As ICharacter, posture As String)
        character.SetMetadata(Metadatas.POSTURE, posture)
    End Sub
    <Extension>
    Friend Function GetDodgeCost(character As ICharacter) As Integer
        If Not character.IsAvatar Then Return 0
        Return Math.Max(1, character.GetCounterMaximum(Counters.STAMINA) \ 10)
    End Function
    <Extension>
    Friend Function GetRestRecovery(character As ICharacter) As Integer
        If Not character.IsAvatar Then Return 0
        Return Math.Max(1, character.GetCounterMaximum(Counters.STAMINA) \ 2)
    End Function
    <Extension>
    Friend Function GetParryCost(character As ICharacter) As Integer
        If Not character.IsAvatar Then Return 0
        Return Math.Max(1, character.GetCounterMaximum(Counters.STAMINA) \ 5)
    End Function
    <Extension>
    Friend Function GetFastAttackCost(character As ICharacter) As Integer
        If Not character.IsAvatar Then Return 0
        Return Math.Max(1, character.GetCounterMaximum(Counters.STAMINA) \ 3)
    End Function
    <Extension>
    Friend Function GetStrongAttackCost(character As ICharacter) As Integer
        If Not character.IsAvatar Then Return 0
        Return Math.Max(1, character.GetCounterMaximum(Counters.STAMINA) * 2 \ 3)
    End Function
#End Region
End Module
