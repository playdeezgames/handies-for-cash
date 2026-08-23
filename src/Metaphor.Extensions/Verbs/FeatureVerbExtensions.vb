Imports System.Runtime.CompilerServices
Imports Metaphor.Persistence

Public Module FeatureVerbExtensions
    Private Delegate Function CanPerformHandler(verb As IVerb, feature As IFeature, actor As ICharacter) As Boolean
    Private Delegate Sub PerformHandler(verb As IVerb, feature As IFeature, actor As ICharacter)
#Region "Can Perform"
    Private ReadOnly canPerformTable As New Dictionary(Of String, CanPerformHandler) From
        {
            {VerbSubtypes.ENTER, AddressOf CanEnter}
        }

    Private Function CanEnter(verb As IVerb, feature As IFeature, actor As ICharacter) As Boolean
        Return If(feature.TryGetCounter(Counters.CASH), 0) <= actor.GetCash()
    End Function

    <Extension>
    Public Function CanPerform(verb As IVerb, feature As IFeature, actor As ICharacter) As Boolean
        Dim handler As CanPerformHandler = Nothing
        If canPerformTable.TryGetValue(verb.EntitySubtype, handler) Then
            Return handler.Invoke(verb, feature, actor)
        End If
        Return True
    End Function
#End Region
#Region "Perform"
    Private ReadOnly performTable As New Dictionary(Of String, PerformHandler) From
        {
            {VerbSubtypes.ENTER, AddressOf HandleEnter},
            {VerbSubtypes.SLEEP, AddressOf HandleSleep}
        }

    Private Sub HandleSleep(verb As IVerb, feature As IFeature, actor As ICharacter)
        actor.AddMessage($"{actor.Name} sleeps on {feature.Name}.")
        actor.ChangeStamina(actor.GetCounterCapacity(Counters.STAMINA))
        actor.ChangeFilth(feature.GetCounter(Counters.FILTH))
    End Sub

    Private Sub HandleEnter(verb As IVerb, feature As IFeature, actor As ICharacter)
        Dim destination = feature.GetDestination()
        actor.ChangeCash(-If(feature.TryGetCounter(Counters.CASH), 0))
        actor.AddMessage($"{actor.Name} enters {destination.Name} through {feature.Name}.")
        actor.Location = destination
        actor.Look()
    End Sub

    <Extension>
    Sub Perform(verb As IVerb, feature As IFeature, actor As ICharacter)
        Dim handler As PerformHandler = Nothing
        If performTable.TryGetValue(verb.EntitySubtype, handler) Then
            handler.Invoke(verb, feature, actor)
            Return
        End If
    End Sub
#End Region
End Module
