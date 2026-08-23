Imports Metaphor.Persistence

Friend Module FeatureInitializationExtensions
#Region "Stained Mattress"
    Friend Sub InitializeStainedMattress(feature As IFeature)
        feature.CreateVerb(VerbSubtypes.SLEEP, "Sleep")
    End Sub
#End Region
End Module
