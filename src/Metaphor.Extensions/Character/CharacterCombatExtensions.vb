Imports System.Runtime.CompilerServices
Imports Metaphor.Persistence
Imports TGGD.Extensions

Public Module CharacterCombatExtensions
#Region "Combat"
    <Extension>
    Public Function InCombat(character As ICharacter) As Boolean
        Return character.IsAvatar AndAlso character.Location.Characters.Any(Function(x) x.HasTag(Tags.ENEMY) And Not x.IsDead)
    End Function
    <Extension>
    Public Function CanDodge(character As ICharacter) As Boolean
        Return character.IsAvatar AndAlso character.GetStamina() > character.GetDodgeCost()
    End Function
    <Extension>
    Public Function CanParry(character As ICharacter) As Boolean
        Return character.IsAvatar AndAlso character.GetStamina() > character.GetParryCost()
    End Function
    <Extension>
    Public Function CanFastAttack(character As ICharacter) As Boolean
        Return character.IsAvatar AndAlso character.GetStamina() > character.GetFastAttackCost()
    End Function
    <Extension>
    Public Function CanStrongAttack(character As ICharacter) As Boolean
        Return character.IsAvatar AndAlso character.GetStamina() > character.GetStrongAttackCost()
    End Function
    <Extension>
    Public Sub DoRest(character As ICharacter)
        character.SetPosture(Postures.REST)
        character.RecoverStamina(character.GetRestRecovery())
        character.AddMessage($"{character.Name} rests.")
        character.EndCombatTurn()
    End Sub
    <Extension>
    Public Sub DoDodge(character As ICharacter)
        character.SetPosture(Postures.DODGE)
        character.SpendStamina(character.GetDodgeCost())
        character.AddMessage($"{character.Name} dodges.")
        character.EndCombatTurn()
    End Sub
    <Extension>
    Public Sub DoParry(character As ICharacter)
        character.SetPosture(Postures.PARRY)
        character.SpendStamina(character.GetParryCost())
        character.AddMessage($"{character.Name} parries.")
        character.EndCombatTurn()
    End Sub
    <Extension>
    Public Sub DoFastAttack(attacker As ICharacter)
        attacker.SetPosture(Postures.FAST_ATTACK)
        attacker.SpendStamina(attacker.GetFastAttackCost())
        attacker.AddMessage($"{attacker.Name} does fast attack.")
        attacker.ResolveAttack()
        attacker.EndCombatTurn()
    End Sub
    Private ReadOnly attackEffectiveness As New Dictionary(Of String, Dictionary(Of String, Double)) From
        {
            {
                Postures.FAST_ATTACK,
                New Dictionary(Of String, Double) From
                {
                    {Postures.PARRY, 0.5},
                    {Postures.DODGE, 0.0},
                    {Postures.REST, 1.5}
                }
            },
            {
                Postures.STRONG_ATTACK,
                New Dictionary(Of String, Double) From
                {
                    {Postures.PARRY, 0.0},
                    {Postures.DODGE, 0.5},
                    {Postures.REST, 1.5}
                }
            }
        }
    Private Function GetAttackEffectiveness(attackPosture As String, defendPosture As String) As Double
        Dim table As Dictionary(Of String, Double) = Nothing
        If attackEffectiveness.TryGetValue(attackPosture, table) Then
            Dim effectiveness As Double = 0.0
            If table.TryGetValue(defendPosture, effectiveness) Then
                Return effectiveness
            End If
        End If
        Return 1.0
    End Function
    <Extension>
    Private Sub ResolveAttack(attacker As ICharacter)
        Dim defender = If(attacker.IsAvatar, attacker.Location.GetEnemies().First, attacker.World.Avatar)
        Dim attack = attacker.GetAttack(GetAttackEffectiveness(attacker.GetPosture(), defender.GetPosture()))
        Dim defend = defender.GetDefend()
        Dim damage = Math.Max(attack - defend, 0)
        If attacker.HasCounter(Counters.CLUMSINESS) Then
            damage = damage * attacker.GetCounterCapacity(Counters.CLUMSINESS) \ attacker.GetCounterMaximum(Counters.CLUMSINESS)
        End If
        attacker.AddMessage($"{attacker.Name} does {damage} damage to {defender.Name}.")
        If damage > 0 Then
            defender.DoDamage(damage)
            If defender.IsDead Then
                attacker.AddMessage($"{attacker.Name} kills {defender.Name}.")
                defender.HandleDeath()
            Else
                attacker.AddMessage($"{defender.Name} has {defender.GetCounterStatistic(Counters.HEALTH)} health.")
            End If
        End If
    End Sub

    <Extension>
    Public Sub DoStrongAttack(character As ICharacter)
        character.SetPosture(Postures.STRONG_ATTACK)
        character.SpendStamina(character.GetStrongAttackCost())
        character.AddMessage($"{character.Name} does strong attack.")
        character.ResolveAttack()
        character.EndCombatTurn()
    End Sub
    Private postureGenerator As New Dictionary(Of String, Integer) From
        {
            {Postures.DODGE, 1},
            {Postures.FAST_ATTACK, 1},
            {Postures.PARRY, 1},
            {Postures.REST, 1},
            {Postures.STRONG_ATTACK, 1}
        }
    <Extension>
    Friend Sub GeneratePosture(character As ICharacter)
        character.SetPosture(RNG.FromGenerator(postureGenerator))
    End Sub
    <Extension>
    Private Sub EndCombatTurn(attacker As ICharacter)
        If attacker.IsAvatar Then
            attacker.DoCounterAttacks()
            If Not attacker.IsDead Then
                attacker.Look()
            End If
        Else
            attacker.GeneratePosture()
        End If
    End Sub
#Region "Counter Attacks"
    Private Delegate Sub CounterAttackDelegate(character As ICharacter)
    Private ReadOnly counterAttacks As New Dictionary(Of String, CounterAttackDelegate) From
        {
            {Postures.DODGE, AddressOf DoDodge},
            {Postures.FAST_ATTACK, AddressOf DoFastAttack},
            {Postures.PARRY, AddressOf DoParry},
            {Postures.REST, AddressOf DoRest},
            {Postures.STRONG_ATTACK, AddressOf DoStrongAttack}
        }
    <Extension>
    Private Sub DoCounterAttacks(defender As ICharacter)
        Dim attackers = defender.Location.GetEnemies()
        For Each attacker In attackers
            counterAttacks(attacker.GetPosture()).Invoke(attacker)
        Next
    End Sub
#End Region
#End Region
#Region "Damage"
    <Extension>
    Friend Sub DoDamage(character As ICharacter, damage As Integer)
        character.ChangeCounter(Counters.HEALTH, -damage)
    End Sub
#End Region
End Module
