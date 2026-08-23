Imports System.Runtime.CompilerServices
Imports Metaphor.Persistence

Friend Module CharacterStatisticExtensions
#Region "Cash"
    <Extension>
    Friend Function GetCash(character As ICharacter) As Integer
        Return character.GetCounter(Counters.CASH)
    End Function
    <Extension>
    Friend Function ChangeCash(character As ICharacter, cash As Integer, Optional silent As Boolean = False) As Integer
        Return character.ChangeStatistic(Counters.CASH, cash, silent)
    End Function
#End Region
#Region "Cash Per Handy"
    <Extension>
    Friend Function GetCashPerHandy(character As ICharacter) As Integer
        Return character.GetCounter(Counters.CASH_PER_HANDY)
    End Function
#End Region
#Region "Handy Count"
    <Extension>
    Friend Sub IncrementHandyCount(character As ICharacter, Optional silent As Boolean = False)
        If Not silent Then character.AddMessage($"{character.Name} gives {character.Name} a handy.")
        character.ChangeCounter(Counters.HANDY_COUNT, 1)
        If Not silent Then character.AddMessage($"{character.Name} has given {character.GetHandyCount()} handies.")
    End Sub
    <Extension>
    Friend Function GetHandyCount(character As ICharacter) As Integer
        Return character.GetCounter(Counters.HANDY_COUNT)
    End Function
#End Region
#Region "Stamina"
    <Extension>
    Friend Function ChangeStamina(character As ICharacter, stamina As Integer, Optional silent As Boolean = False) As Integer
        Return character.ChangeStatistic(Counters.STAMINA, stamina, silent)
    End Function
#End Region
#Region "Utility"
    Private ReadOnly counterNames As New Dictionary(Of String, String) From
        {
            {Counters.CASH, "cash"},
            {Counters.STAMINA, "stamina"},
            {Counters.HANDY_COUNT, "handies"}
        }
    <Extension>
    Private Function ChangeStatistic(character As ICharacter, counterId As String, delta As Integer, Optional silent As Boolean = False) As Integer
        If delta <> 0 Then
            Dim counterName = counterNames(counterId)
            If Not silent Then character.AddMessage($"{character.Name} {If(delta > 0, "gains", "loses")} {Math.Abs(delta)} {counterName}.")
            character.ChangeCounter(counterId, delta)
            If Not silent Then
                If character.GetCounterMaximum(counterId) = Integer.MaxValue Then
                    character.AddMessage($"{character.Name} now has {character.GetCounter(counterId)} {counterName}.")
                Else
                    character.AddMessage($"{character.Name} now has {character.GetCounterStatistic(counterId)} {counterName}.")
                End If
            End If
        End If
        Return character.GetCounter(counterId)
    End Function
#End Region
End Module
