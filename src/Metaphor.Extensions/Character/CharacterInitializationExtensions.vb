Imports System.Runtime.CompilerServices
Imports Metaphor.Persistence

Friend Module CharacterInitializationExtensions
#Region "N00b"
    <Extension>
    Friend Sub InitializeN00b(character As ICharacter)
        character.InitializeCounter(Counters.HANDY_COUNT, 0, 0, Integer.MaxValue)
        character.InitializeCounter(Counters.CASH, 0, 0, Integer.MaxValue)
        character.InitializeCounter(Counters.CASH_PER_HANDY, 5, 5, Integer.MaxValue)
        character.InitializeCounter(Counters.STAMINA, 10, 0, 10)
        character.InitializeCounter(Counters.FILTH, 0, 0, Integer.MaxValue)
        character.World.Avatar = character
    End Sub
#End Region
#Region "John"
    Friend Sub InitializeJohn(character As ICharacter)
        character.CreateVerb(VerbSubtypes.GIVE_HANDY, "Give Handy")
    End Sub
#End Region
End Module
