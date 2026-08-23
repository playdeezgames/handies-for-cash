Imports System.Runtime.CompilerServices
Imports Metaphor.Persistence

Friend Module CharacterStatisticExtensions
#Region "Cash"
    <Extension>
    Friend Function GetCash(character As ICharacter) As Integer
        Return character.GetCounter(Counters.CASH)
    End Function
    <Extension>
    Friend Function ChangeCash(character As ICharacter, cash As Integer) As Integer
        Return character.ChangeCounter(Counters.CASH, cash)
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
    Friend Sub IncrementHandyCount(character As ICharacter)
        character.ChangeCounter(Counters.HANDY_COUNT, 1)
    End Sub
    <Extension>
    Friend Function GetHandyCount(character As ICharacter) As Integer
        Return character.GetCounter(Counters.HANDY_COUNT)
    End Function
#End Region
End Module
