Imports Metaphor.Persistence

Friend Module FeatureInitializationExtensions
#Region "Stained Mattress"
    Friend Sub InitializeStainedMattress(feature As IFeature)
        feature.SetCounter(Counters.FILTH, 5)
        feature.CreateVerb(VerbSubtypes.SLEEP, "Sleep")
    End Sub

    Friend Sub InitializeSink(feature As IFeature)
        feature.SetCounter(Counters.FILTH, 10)
        feature.SetCounter(Counters.STAMINA, 1)
        feature.CreateVerb(VerbSubtypes.WASH_UP, "Wash Up")
    End Sub
#End Region
End Module
